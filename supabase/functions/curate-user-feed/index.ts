import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FN = "curate-user-feed";

function log(
  level: "info" | "warn" | "error",
  msg: string,
  extra: Record<string, unknown> = {},
) {
  console.log(
    JSON.stringify({
      ts: new Date().toISOString(),
      fn: FN,
      level,
      msg,
      ...extra,
    }),
  );
}

// -- Types -------------------------------------------------------
interface CatalogPodcast {
  id: string;
  title: string;
  categories: string[] | null;
}

interface AiPicks {
  s: number[];  // to_get_started indices
  r: number[];  // recommended indices
  q: string;    // reasoning
}

// -- System prompt (static - cached across warm invocations) -----
const SYSTEM_PROMPT = `You are ClipCast's podcast recommendation engine.
Return catalog INDEX NUMBERS only (not IDs or titles).

RULES:
1. Return ONLY valid index numbers from the CATALOG array.
2. "s" (start) = accessible, popular, easy entry points.
3. "r" (recommended) = deeper / surprising picks.
4. Maximise diversity across categories.
5. No duplicates between or within lists.
6. 15 items per list (or fewer if catalog is small).
7. "q" = reasoning, 1 sentence max.

RESPOND with strict JSON using SHORT keys:
{"s":[0,3,7,...],"r":[1,4,9,...],"q":"..."}`;

// -- Helpers -----------------------------------------------------
function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function sanitizeIds(input: unknown): string[] {
  if (!Array.isArray(input)) return [];
  return input.filter((v) => typeof v === "string" && UUID_RE.test(v));
}

// -- Handler -----------------------------------------------------
serve(async (req) => {
  const requestId = crypto.randomUUID();
  const t0 = Date.now();

  try {
    if (req.method !== "POST") {
      return jsonResponse({ error: "Method not allowed" }, 405);
    }

    const body = await req.json();
    const { user_id, category_ids, speaker_ids, podcast_ids } = body;

    if (!user_id || typeof user_id !== "string") {
      return jsonResponse({ error: "user_id required" }, 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const openaiKey = Deno.env.get("OPENAI_API_KEY") ?? "";

    log("info", "request_received", {
      requestId,
      user_id,
      supabaseUrl,
      hasOpenAiKey: !!openaiKey,
    });

    // -- Auth ----------------------------------------------------
    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      log("warn", "auth_no_header", {
        requestId,
        hint: "No Authorization header present — client may not be sending the session token",
      });
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    if (!authHeader.startsWith("Bearer ")) {
      log("warn", "auth_malformed_header", {
        requestId,
        headerPrefix: authHeader.slice(0, 20),
        hint: "Authorization header must start with 'Bearer '",
      });
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    // Log token prefix only (never the full token)
    const tokenPreview = authHeader.slice(7, 27) + "...";
    log("info", "auth_token_received", { requestId, tokenPreview });

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: authErr } = await userClient.auth.getUser();

    if (authErr) {
      log("warn", "auth_get_user_failed", {
        requestId,
        errorCode: authErr.code ?? "unknown",
        errorMessage: authErr.message,
        errorStatus: authErr.status ?? "unknown",
        hint: authErr.status === 401
          ? "Token is expired or invalid — client must refresh the session before calling"
          : "Supabase rejected the token",
      });
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    if (!userData.user) {
      log("warn", "auth_no_user", {
        requestId,
        hint: "getUser() succeeded but returned no user — this should not happen",
      });
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    if (userData.user.id !== user_id) {
      log("warn", "auth_user_id_mismatch", {
        requestId,
        jwtUserId: userData.user.id,
        bodyUserId: user_id,
        hint: "user_id in request body does not match the authenticated user",
      });
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    log("info", "auth_ok", {
      requestId,
      userId: user_id,
      ms: Date.now() - t0,
    });

    const supabase = createClient(supabaseUrl, serviceKey);
    const safeCategoryIds: string[] = sanitizeIds(category_ids);
    const safeSpeakerIds: string[] = sanitizeIds(speaker_ids);
    const safePodcastIds: string[] = sanitizeIds(podcast_ids);

    // -- Phase 1: Parallel reads + writes ------------------------
    const [
      ,
      ,
      catalogResult,
      categoryNamesResult,
      speakerNamesResult,
      trendingResult,
    ] = await Promise.all([
      // 1a. Save onboarding choices
      supabase.from("user_onboarding_choices").upsert({
        user_id,
        category_ids: safeCategoryIds,
        speaker_ids: safeSpeakerIds,
        podcast_ids: safePodcastIds,
        completed_at: new Date().toISOString(),
      }),
      // 1b. Upsert podcast favourites
      safePodcastIds.length
        ? supabase
            .from("podcast_favourites")
            .upsert(
              safePodcastIds.map((pid) => ({ user_id, podcast_id: pid })),
              { onConflict: "user_id,podcast_id" },
            )
        : Promise.resolve({ error: null }),
      // 1c. Fetch compact catalog (top 50 by episode count — keeps prompt small)
      supabase
        .from("podcasts")
        .select("id, title, categories")
        .order("total_episodes", { ascending: false })
        .limit(50),
      // 1d. Resolve selected category names
      safeCategoryIds.length
        ? supabase
            .from("podcast_categories")
            .select("name")
            .in("id", safeCategoryIds)
        : Promise.resolve({ data: [] }),
      // 1e. Resolve selected speaker names
      safeSpeakerIds.length
        ? supabase
            .from("podcast_speakers")
            .select("name")
            .in("id", safeSpeakerIds)
        : Promise.resolve({ data: [] }),
      // 1f. Fetch trending (safety net fallback)
      supabase
        .from("trending_podcasts")
        .select("podcast_id")
        .order("score", { ascending: false })
        .limit(30),
    ]);

    const catalog: CatalogPodcast[] =
      (catalogResult.data as CatalogPodcast[]) ?? [];
    const categoryNames = (
      (categoryNamesResult.data as { name: string }[]) ?? []
    ).map((c) => c.name);
    const speakerNames = (
      (speakerNamesResult.data as { name: string }[]) ?? []
    ).map((s) => s.name);
    const trendingIds = (
      (trendingResult.data as { podcast_id: string }[]) ?? []
    )
      .map((t) => t.podcast_id)
      .filter((v, i, a) => a.indexOf(v) === i);

    const selectedTitles = catalog
      .filter((p) => safePodcastIds.includes(p.id))
      .map((p) => p.title);

    const skippedAll =
      !categoryNames.length &&
      !speakerNames.length &&
      !selectedTitles.length;

    log("info", "phase1_done", {
      requestId,
      ms: Date.now() - t0,
      catalogSize: catalog.length,
      skippedAll,
    });

    // -- Phase 2: AI-powered selection from real catalog ---------
    let toGetStartedIds: string[] = [];
    let recommendedIds: string[] = [];
    let reasoning = "";

    if (openaiKey && catalog.length) {
      // Compact catalog: index + title + categories (no UUIDs sent to AI)
      const compactCatalog = catalog.map((p, idx) =>
        `${idx}:${p.title.slice(0, 40)}[${(p.categories ?? []).join(",")}]`
      ).join("\n");

      const userPrompt = skippedAll
        ? `User skipped preferences.

CATALOG (index:title[categories]):
${compactCatalog}

Return 15 diverse indices for "s" and 15 different for "r".`
        : `User likes: ${[...categoryNames, ...speakerNames, ...selectedTitles].filter(Boolean).join(", ") || "nothing specific"}

CATALOG (index:title[categories]):
${compactCatalog}

Return 15 matching indices for "s" and 15 complementary for "r".`;

      try {
        const aiT0 = Date.now();
        const aiRes = await fetch(
          "https://api.openai.com/v1/chat/completions",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${openaiKey}`,
            },
            body: JSON.stringify({
              model: "gpt-4o-mini",
              messages: [
                { role: "system", content: SYSTEM_PROMPT },
                { role: "user", content: userPrompt },
              ],
              temperature: 0.6,
              max_tokens: 300,
              response_format: { type: "json_object" },
            }),
          },
        );

        if (aiRes.ok) {
          const aiJson = await aiRes.json();
          const content =
            aiJson.choices?.[0]?.message?.content ?? "{}";
          const parsed: AiPicks = JSON.parse(content);

          // Map indices back to catalog UUIDs, skip out-of-range
          const maxIdx = catalog.length - 1;
          const toIdx = (parsed.s ?? []).filter(
            (n) => typeof n === "number" && n >= 0 && n <= maxIdx,
          );
          const recIdx = (parsed.r ?? []).filter(
            (n) => typeof n === "number" && n >= 0 && n <= maxIdx,
          );

          const startSet = new Set(toIdx);
          toGetStartedIds = toIdx.map((i) => catalog[i].id);
          recommendedIds = recIdx
            .filter((i) => !startSet.has(i))
            .map((i) => catalog[i].id);
          reasoning =
            typeof parsed.q === "string"
              ? parsed.q
              : "";

          log("info", "ai_ok", {
            requestId,
            ms: Date.now() - aiT0,
            validStart: toGetStartedIds.length,
            validRec: recommendedIds.length,
          });
        } else {
          log("warn", "ai_http_error", {
            requestId,
            status: aiRes.status,
          });
        }
      } catch (err) {
        log("error", "ai_failed", {
          requestId,
          error: err instanceof Error ? err.message : String(err),
        });
      }
    }

    // -- Fallback: fill from trending / catalog if AI short ------
    const MIN_RESULTS = 5;

    if (toGetStartedIds.length < MIN_RESULTS) {
      log("info", "fallback_trending", {
        requestId,
        aiCount: toGetStartedIds.length,
      });
      const usedIds = new Set([
        ...toGetStartedIds,
        ...recommendedIds,
      ]);
      for (const tid of trendingIds) {
        if (toGetStartedIds.length >= 15) break;
        if (!usedIds.has(tid)) {
          toGetStartedIds.push(tid);
          usedIds.add(tid);
        }
      }
    }

    if (recommendedIds.length < MIN_RESULTS) {
      const usedIds = new Set([
        ...toGetStartedIds,
        ...recommendedIds,
      ]);
      for (const p of catalog) {
        if (recommendedIds.length >= 15) break;
        if (!usedIds.has(p.id)) {
          recommendedIds.push(p.id);
          usedIds.add(p.id);
        }
      }
    }

    if (!reasoning) {
      reasoning = skippedAll
        ? "Popular podcasts across trending topics to get you started."
        : "Based on your selected preferences.";
    }

    log("info", "phase2_done", {
      requestId,
      ms: Date.now() - t0,
      toGetStarted: toGetStartedIds.length,
      recommended: recommendedIds.length,
    });

    // -- Phase 3: Parallel writes --------------------------------
    const expiresAt = new Date(
      Date.now() + 7 * 24 * 60 * 60 * 1000,
    ).toISOString();

    const sections = [
      {
        user_id,
        section_type: "to_get_started",
        podcast_ids: toGetStartedIds,
        metadata: { reasoning },
        expires_at: expiresAt,
      },
      {
        user_id,
        section_type: "recommended_podcasts",
        podcast_ids: recommendedIds,
        metadata: { reasoning },
        expires_at: expiresAt,
      },
      {
        user_id,
        section_type: "curated_collections",
        collection_ids: [],
        metadata: { reasoning },
        expires_at: expiresAt,
      },
    ];

    const writeResults = await Promise.all([
      ...sections.map((s) =>
        supabase
          .from("user_recommendations")
          .upsert(s, { onConflict: "user_id,section_type" }),
      ),
      supabase
        .from("profiles")
        .update({ onboarding_completed: true })
        .eq("id", user_id),
    ]);

    for (const wr of writeResults) {
      if (wr.error) {
        log("error", "write_failed", {
          requestId,
          error: wr.error.message,
        });
        throw wr.error;
      }
    }

    // -- Phase 4: Fetch 5 preview artworks for the great-picks screen ----
    // Index 0 = top priority (center card), 1-4 = random from the rest.
    let previewArtworks: string[] = [];
    if (toGetStartedIds.length > 0) {
      const [topId, ...rest] = toGetStartedIds;
      // Fisher-Yates shuffle on the rest, then take 4
      for (let i = rest.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [rest[i], rest[j]] = [rest[j], rest[i]];
      }
      const sampleIds = [topId, ...rest.slice(0, 4)];

      const { data: artworkRows } = await supabase
        .from("podcasts")
        .select("id, artwork_url")
        .in("id", sampleIds);

      const urlMap: Record<string, string> = {};
      for (const row of (artworkRows ?? []) as { id: string; artwork_url: string | null }[]) {
        if (row.artwork_url) urlMap[row.id] = row.artwork_url;
      }
      previewArtworks = sampleIds
        .map((id) => urlMap[id])
        .filter((url): url is string => !!url);
    }

    const totalMs = Date.now() - t0;
    log("info", "done", {
      requestId,
      ms: totalMs,
      toGetStarted: toGetStartedIds.length,
      recommended: recommendedIds.length,
      previewArtworks: previewArtworks.length,
    });

    return jsonResponse({
      success: true,
      request_id: requestId,
      sections: sections.length,
      preview_artworks: previewArtworks,
      ms: totalMs,
    });
  } catch (err) {
    log("error", "unhandled", {
      requestId,
      error: err instanceof Error ? err.message : String(err),
    });
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});
