import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TADDY_ENDPOINT = "https://api.taddy.org";

function log(
  level: "info" | "warn" | "error",
  msg: string,
  extra: Record<string, unknown> = {},
) {
  console.log(
    JSON.stringify({
      ts: new Date().toISOString(),
      fn: "seed-episodes",
      level,
      msg,
      ...extra,
    }),
  );
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function taddyQuery(query: string, userId: string, apiKey: string) {
  const res = await fetch(TADDY_ENDPOINT, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-USER-ID": userId,
      "X-API-KEY": apiKey,
    },
    body: JSON.stringify({ query }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Taddy API error ${res.status}: ${text}`);
  }
  return res.json();
}

Deno.serve(async (req) => {
  const requestId = crypto.randomUUID();
  log("info", "request_received", { requestId });

  try {
    const taddyUserId = Deno.env.get("TADDY_USER_ID");
    const taddyApiKey = Deno.env.get("TADDY_API_KEY");
    if (!taddyUserId || !taddyApiKey) {
      return new Response(
        JSON.stringify({ error: "Missing Taddy credentials" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Accept offset + limit via query params (default: offset=0, limit=50)
    const url = new URL(req.url);
    const offset = parseInt(url.searchParams.get("offset") || "0", 10);
    const limit = parseInt(url.searchParams.get("limit") || "50", 10);
    const delayMs = parseInt(url.searchParams.get("delay") || "1500", 10);

    // Fetch a batch of podcasts that need episodes
    const { data: podcasts, error: fetchErr } = await supabase
      .from("podcasts")
      .select("id, external_id")
      .order("created_at", { ascending: true })
      .range(offset, offset + limit - 1);

    if (fetchErr) {
      return new Response(
        JSON.stringify({ error: fetchErr.message }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    if (!podcasts || podcasts.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: "No more podcasts to process", offset, episodes_seeded: 0 }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    // Build external_id -> internal id map
    const idMap = new Map<string, string>();
    for (const p of podcasts) {
      idMap.set(p.external_id, p.id);
    }

    const uuids = podcasts.map((p) => p.external_id);
    let episodeCount = 0;
    let apiCalls = 0;
    const errors: string[] = [];

    // Fetch episodes in batches of 5 UUIDs, with delay between calls
    for (let i = 0; i < uuids.length; i += 5) {
      const batchUuids = uuids.slice(i, i + 5);
      const uuidsStr = batchUuids.map((u) => `"${u}"`).join(",");

      try {
        const data = await taddyQuery(
          `{
            getLatestEpisodesFromMultiplePodcasts(uuids: [${uuidsStr}]) {
              uuid name description audioUrl duration datePublished episodeNumber seasonNumber
              podcastSeries { uuid }
            }
          }`,
          taddyUserId,
          taddyApiKey,
        );
        apiCalls++;

        const episodes =
          data?.data?.getLatestEpisodesFromMultiplePodcasts || [];
        const episodeRows = episodes
          .filter(
            (ep: any) =>
              ep?.uuid && ep?.audioUrl && ep?.podcastSeries?.uuid,
          )
          .map((ep: any) => ({
            external_id: ep.uuid,
            podcast_id: idMap.get(ep.podcastSeries.uuid),
            title: ep.name || "Untitled Episode",
            description: ep.description || null,
            audio_url: ep.audioUrl,
            duration_seconds: ep.duration || null,
            published_at: ep.datePublished
              ? new Date(ep.datePublished * 1000).toISOString()
              : null,
          }))
          .filter((r: any) => r.podcast_id);

        if (episodeRows.length > 0) {
          const { error } = await supabase
            .from("episodes")
            .upsert(episodeRows, {
              onConflict: "external_id",
              ignoreDuplicates: false,
            });
          if (error) {
            errors.push(`upsert_batch_${i}: ${error.message}`);
          }
          episodeCount += episodeRows.length;
        }

        log("info", "batch_done", {
          requestId,
          batch: i,
          episodes: episodeRows.length,
          apiCalls,
        });
      } catch (e) {
        const errMsg = String(e);
        errors.push(`fetch_batch_${i}: ${errMsg}`);
        log("error", "batch_failed", { requestId, batch: i, error: errMsg });

        // If rate limited, wait longer
        if (errMsg.includes("RATE_LIMIT")) {
          log("warn", "rate_limited_backing_off", { requestId, batch: i });
          await sleep(5000);
        }
      }

      // Delay between Taddy calls to avoid rate limiting
      if (i + 5 < uuids.length) {
        await sleep(delayMs);
      }
    }

    const payload = {
      success: true,
      request_id: requestId,
      offset,
      limit,
      podcasts_processed: podcasts.length,
      episodes_seeded: episodeCount,
      api_calls: apiCalls,
      next_offset: offset + podcasts.length,
      errors: errors.slice(0, 10),
    };
    log("info", "request_complete", payload);

    return new Response(JSON.stringify(payload), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    log("error", "unhandled_error", {
      requestId,
      error: (error as Error).message,
    });
    return new Response(
      JSON.stringify({
        error: (error as Error).message,
        request_id: requestId,
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
