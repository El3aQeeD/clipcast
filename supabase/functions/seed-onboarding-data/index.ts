import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GENRE_MAP } from "./genres.ts";

const FN = "seed-onboarding-data";

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

const TADDY_ENDPOINT = "https://api.taddy.org";

async function fetchTaddySpeakers(taddyUserId: string, taddyApiKey: string): Promise<Array<{ name: string; photoUrl: string; externalPodcastIds: string[] }>> {
  const query = `{
    getPopularContent(filterByLanguage: ENGLISH, page: 1, limitPerPage: 25) {
      popularityRankId
      podcastSeries {
        uuid
        name
        authorName
        imageUrl
        itunesInfo { uuid baseArtworkUrlOf(size: 640) }
      }
    }
  }`;

  const speakers = new Map<string, { name: string; photoUrl: string; externalPodcastIds: string[] }>();

  for (let page = 1; page <= 8; page++) {
    const pageQuery = query.replace("page: 1", `page: ${page}`);
    try {
      const res = await fetch(TADDY_ENDPOINT, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-USER-ID": taddyUserId,
          "X-API-KEY": taddyApiKey,
        },
        body: JSON.stringify({ query: pageQuery }),
      });

      const json = await res.json();

      if (json.errors) {
        log("error", "taddy_graphql_error", {
          page,
          errors: json.errors,
        });
        continue;
      }

      if (!res.ok) {
        log("error", "taddy_http_error", {
          page,
          status: res.status,
          body: JSON.stringify(json).slice(0, 500),
        });
        continue;
      }

      const series = json?.data?.getPopularContent?.podcastSeries ?? [];
      log("info", "taddy_page_fetched", { page, seriesCount: series.length });

      for (const podcast of series) {
        const authorName = podcast.authorName?.trim();
        if (!authorName) continue;

        const existing = speakers.get(authorName);
        const photoUrl = podcast.itunesInfo?.baseArtworkUrlOf ?? podcast.imageUrl ?? "";

        if (existing) {
          existing.externalPodcastIds.push(podcast.uuid);
        } else {
          speakers.set(authorName, {
            name: authorName,
            photoUrl,
            externalPodcastIds: [podcast.uuid],
          });
        }
      }
    } catch (err) {
      log("error", "taddy_page_fetch_failed", {
        page,
        error: err instanceof Error ? err.message : String(err),
      });
    }
  }

  return Array.from(speakers.values());
}

serve(async (req) => {
  const requestId = crypto.randomUUID();
  log("info", "request_received", { requestId, method: req.method });

  try {
    const seedSecret = Deno.env.get("SEED_FUNCTION_SECRET") ?? "";
    if (seedSecret) {
      const header = req.headers.get("x-clipcast-seed");
      if (header !== seedSecret) {
        log("warn", "forbidden_bad_seed_secret", { requestId });
        return new Response(JSON.stringify({ error: "Forbidden" }), {
          status: 403,
          headers: { "Content-Type": "application/json" },
        });
      }
    } else {
      log("warn", "seed_secret_not_set_invocation_unauthenticated", {
        requestId,
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const taddyUserId = Deno.env.get("TADDY_USER_ID") ?? "";
    const taddyApiKey = Deno.env.get("TADDY_API_KEY") ?? "";

    log("info", "env_loaded", {
      requestId,
      hasTaddyUser: Boolean(taddyUserId),
      hasTaddyKey: Boolean(taddyApiKey),
    });

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // ── Seed categories ─────────────────────────────────────────
    const topLevelGenres = Object.entries(GENRE_MAP).filter(([_, v]) => !v.parent);
    const subGenres = Object.entries(GENRE_MAP).filter(([_, v]) => !!v.parent);

    // Insert top-level first
    const topLevelRows = topLevelGenres.map(([genre, info], i) => ({
      name: info.name,
      taddy_genre: genre,
      parent_id: null,
      display_order: i,
    }));

    const { error: topErr } = await supabase
      .from("podcast_categories")
      .upsert(topLevelRows, { onConflict: "taddy_genre" });

    if (topErr) {
      log("error", "top_level_categories_upsert_failed", {
        requestId,
        error: topErr.message,
      });
    } else {
      log("info", "top_level_categories_upsert_ok", {
        requestId,
        count: topLevelRows.length,
      });
    }

    // Fetch top-level IDs for parent references
    const { data: topLevelData } = await supabase
      .from("podcast_categories")
      .select("id, taddy_genre")
      .is("parent_id", null);

    const parentMap = new Map<string, string>();
    for (const row of topLevelData ?? []) {
      parentMap.set(row.taddy_genre, row.id);
    }

    // Insert sub-genres with parent references
    const subRows = subGenres.map(([genre, info], i) => ({
      name: info.name,
      taddy_genre: genre,
      parent_id: parentMap.get(info.parent!) ?? null,
      display_order: topLevelGenres.length + i,
    }));

    if (subRows.length > 0) {
      const { error: subErr } = await supabase
        .from("podcast_categories")
        .upsert(subRows, { onConflict: "taddy_genre" });

      if (subErr) {
        log("error", "subgenre_categories_upsert_failed", {
          requestId,
          error: subErr.message,
        });
      } else {
        log("info", "subgenre_categories_upsert_ok", {
          requestId,
          count: subRows.length,
        });
      }
    }

    // ── Seed speakers ───────────────────────────────────────────
    let speakerCount = 0;
    if (taddyUserId && taddyApiKey) {
      const speakers = await fetchTaddySpeakers(taddyUserId, taddyApiKey);
      const speakerRows = speakers.map((s, i) => ({
        name: s.name,
        photo_url: s.photoUrl,
        external_podcast_ids: s.externalPodcastIds,
        display_order: i,
      }));

      if (speakerRows.length > 0) {
        const { error: spkErr } = await supabase
          .from("podcast_speakers")
          .upsert(speakerRows, { onConflict: "name" });

        if (spkErr) {
          log("error", "speakers_upsert_failed", {
            requestId,
            error: spkErr.message,
          });
        } else {
          log("info", "speakers_upsert_ok", {
            requestId,
            count: speakerRows.length,
          });
        }
        speakerCount = speakerRows.length;
      }
    } else {
      log("warn", "taddy_credentials_missing_skip_speakers", { requestId });
    }

    const payload = {
      success: true,
      request_id: requestId,
      categories_count: topLevelRows.length + subRows.length,
      speakers_count: speakerCount,
    };
    log("info", "request_complete", payload);

    return new Response(
      JSON.stringify(payload),
      { headers: { "Content-Type": "application/json" }, status: 200 },
    );
  } catch (err) {
    log("error", "unhandled_error", {
      requestId,
      error: err instanceof Error ? err.message : String(err),
      stack: err instanceof Error ? err.stack : undefined,
    });
    return new Response(
      JSON.stringify({ error: String(err), request_id: requestId }),
      { headers: { "Content-Type": "application/json" }, status: 500 },
    );
  }
});
