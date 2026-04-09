import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TADDY_ENDPOINT = "https://api.taddy.org";

const GENRE_MAP: Record<string, string> = {
  PODCASTSERIES_BUSINESS: "Business",
  PODCASTSERIES_BUSINESS_CAREERS: "Business",
  PODCASTSERIES_BUSINESS_INVESTING: "Business",
  PODCASTSERIES_BUSINESS_MARKETING: "Business",
  PODCASTSERIES_BUSINESS_MANAGEMENT: "Business",
  PODCASTSERIES_BUSINESS_NON_PROFIT: "Business",
  PODCASTSERIES_BUSINESS_ENTREPRENEURSHIP: "Business",
  PODCASTSERIES_NEWS: "News",
  PODCASTSERIES_NEWS_BUSINESS: "News",
  PODCASTSERIES_NEWS_DAILY: "News",
  PODCASTSERIES_NEWS_DAILY_NEWS: "News",
  PODCASTSERIES_NEWS_POLITICS: "News",
  PODCASTSERIES_NEWS_TECH: "News",
  PODCASTSERIES_NEWS_SPORTS: "News",
  PODCASTSERIES_NEWS_COMMENTARY: "News",
  PODCASTSERIES_NEWS_ENTERTAINMENT: "News",
  PODCASTSERIES_TECHNOLOGY: "Technology",
  PODCASTSERIES_EDUCATION: "Education",
  PODCASTSERIES_EDUCATION_COURSES: "Education",
  PODCASTSERIES_EDUCATION_HOW_TO: "Education",
  PODCASTSERIES_EDUCATION_LANGUAGE_LEARNING: "Education",
  PODCASTSERIES_EDUCATION_SELF_IMPROVEMENT: "Education",
  PODCASTSERIES_HEALTH_AND_FITNESS: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_FITNESS: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_MEDICINE: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_MENTAL_HEALTH: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_NUTRITION: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_ALTERNATIVE_HEALTH: "Health & Fitness",
  PODCASTSERIES_HEALTH_AND_FITNESS_SEXUALITY: "Health & Fitness",
  PODCASTSERIES_SOCIETY_AND_CULTURE: "Society & Culture",
  PODCASTSERIES_SOCIETY_AND_CULTURE_DOCUMENTARY: "Society & Culture",
  PODCASTSERIES_SOCIETY_AND_CULTURE_PERSONAL_JOURNALS: "Society & Culture",
  PODCASTSERIES_SOCIETY_AND_CULTURE_PHILOSOPHY: "Society & Culture",
  PODCASTSERIES_SOCIETY_AND_CULTURE_PLACES_AND_TRAVEL: "Society & Culture",
  PODCASTSERIES_SOCIETY_AND_CULTURE_RELATIONSHIPS: "Society & Culture",
  PODCASTSERIES_COMEDY: "Comedy",
  PODCASTSERIES_COMEDY_IMPROV: "Comedy",
  PODCASTSERIES_COMEDY_INTERVIEWS: "Comedy",
  PODCASTSERIES_COMEDY_STANDUP: "Comedy",
  PODCASTSERIES_ARTS: "Arts",
  PODCASTSERIES_ARTS_BOOKS: "Arts",
  PODCASTSERIES_ARTS_DESIGN: "Arts",
  PODCASTSERIES_ARTS_FASHION_AND_BEAUTY: "Arts",
  PODCASTSERIES_ARTS_FOOD: "Arts",
  PODCASTSERIES_ARTS_PERFORMING_ARTS: "Arts",
  PODCASTSERIES_ARTS_VISUAL_ARTS: "Arts",
  PODCASTSERIES_FICTION: "Fiction",
  PODCASTSERIES_FICTION_COMEDY_FICTION: "Fiction",
  PODCASTSERIES_FICTION_DRAMA: "Fiction",
  PODCASTSERIES_FICTION_SCIENCE_FICTION: "Fiction",
  PODCASTSERIES_SPORTS: "Sports",
  PODCASTSERIES_SPORTS_BASEBALL: "Sports",
  PODCASTSERIES_SPORTS_BASKETBALL: "Sports",
  PODCASTSERIES_SPORTS_FOOTBALL: "Sports",
  PODCASTSERIES_SPORTS_SOCCER: "Sports",
  PODCASTSERIES_SPORTS_HOCKEY: "Sports",
  PODCASTSERIES_SPORTS_CRICKET: "Sports",
  PODCASTSERIES_SPORTS_RUGBY: "Sports",
  PODCASTSERIES_SPORTS_TENNIS: "Sports",
  PODCASTSERIES_SPORTS_GOLF: "Sports",
  PODCASTSERIES_SPORTS_RUNNING: "Sports",
  PODCASTSERIES_SPORTS_SWIMMING: "Sports",
  PODCASTSERIES_SPORTS_VOLLEYBALL: "Sports",
  PODCASTSERIES_SPORTS_WRESTLING: "Sports",
  PODCASTSERIES_SPORTS_WILDERNESS: "Sports",
  PODCASTSERIES_SPORTS_FANTASY_SPORTS: "Sports",
  PODCASTSERIES_SCIENCE: "Science",
  PODCASTSERIES_SCIENCE_ASTRONOMY: "Science",
  PODCASTSERIES_SCIENCE_CHEMISTRY: "Science",
  PODCASTSERIES_SCIENCE_EARTH_SCIENCES: "Science",
  PODCASTSERIES_SCIENCE_LIFE_SCIENCES: "Science",
  PODCASTSERIES_SCIENCE_MATHEMATICS: "Science",
  PODCASTSERIES_SCIENCE_NATURAL_SCIENCES: "Science",
  PODCASTSERIES_SCIENCE_NATURE: "Science",
  PODCASTSERIES_SCIENCE_PHYSICS: "Science",
  PODCASTSERIES_MUSIC: "Music",
  PODCASTSERIES_MUSIC_COMMENTARY: "Music",
  PODCASTSERIES_MUSIC_HISTORY: "Music",
  PODCASTSERIES_MUSIC_INTERVIEWS: "Music",
  PODCASTSERIES_TRUE_CRIME: "True Crime",
  PODCASTSERIES_HISTORY: "History",
  PODCASTSERIES_KIDS_AND_FAMILY: "Kids & Family",
  PODCASTSERIES_KIDS_AND_FAMILY_EDUCATION_FOR_KIDS: "Kids & Family",
  PODCASTSERIES_KIDS_AND_FAMILY_PARENTING: "Kids & Family",
  PODCASTSERIES_KIDS_AND_FAMILY_PETS_AND_ANIMALS: "Kids & Family",
  PODCASTSERIES_KIDS_AND_FAMILY_STORIES_FOR_KIDS: "Kids & Family",
  PODCASTSERIES_LEISURE: "Leisure",
  PODCASTSERIES_LEISURE_ANIMATION_AND_MANGA: "Leisure",
  PODCASTSERIES_LEISURE_AUTOMOTIVE: "Leisure",
  PODCASTSERIES_LEISURE_AVIATION: "Leisure",
  PODCASTSERIES_LEISURE_CRAFTS: "Leisure",
  PODCASTSERIES_LEISURE_GAMES: "Leisure",
  PODCASTSERIES_LEISURE_HOBBIES: "Leisure",
  PODCASTSERIES_LEISURE_HOME_AND_GARDEN: "Leisure",
  PODCASTSERIES_LEISURE_VIDEO_GAMES: "Leisure",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_BUDDHISM: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_CHRISTIANITY: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_HINDUISM: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_ISLAM: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_JUDAISM: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_RELIGION: "Religion & Spirituality",
  PODCASTSERIES_RELIGION_AND_SPIRITUALITY_SPIRITUALITY: "Religion & Spirituality",
  PODCASTSERIES_TV_AND_FILM: "TV & Film",
  PODCASTSERIES_TV_AND_FILM_AFTER_SHOWS: "TV & Film",
  PODCASTSERIES_TV_AND_FILM_FILM_HISTORY: "TV & Film",
  PODCASTSERIES_TV_AND_FILM_FILM_INTERVIEWS: "TV & Film",
  PODCASTSERIES_TV_AND_FILM_FILM_REVIEWS: "TV & Film",
  PODCASTSERIES_TV_AND_FILM_TV_REVIEWS: "TV & Film",
  PODCASTSERIES_GOVERNMENT: "Government",
};

function log(
  level: "info" | "warn" | "error",
  msg: string,
  extra: Record<string, unknown> = {},
) {
  console.log(
    JSON.stringify({
      ts: new Date().toISOString(),
      fn: "seed-initial",
      level,
      msg,
      ...extra,
    }),
  );
}

function mapGenres(taddyGenres: string[]): string[] {
  const mapped = new Set<string>();
  for (const g of taddyGenres) {
    const cat = GENRE_MAP[g];
    if (cat) mapped.add(cat);
  }
  if (mapped.size === 0 && taddyGenres.length > 0) mapped.add("Other");
  return Array.from(mapped);
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

interface TaddyPodcast {
  uuid: string;
  name: string;
  description?: string;
  imageUrl?: string;
  rssUrl?: string;
  authorName?: string;
  totalEpisodesCount?: number;
  genres?: string[];
  itunesInfo?: { baseArtworkUrlOf?: string; publisherName?: string };
}

function podcastToRow(p: TaddyPodcast) {
  return {
    external_id: p.uuid,
    title: p.name,
    author: p.authorName || p.itunesInfo?.publisherName || null,
    description: p.description ? p.description.substring(0, 2000) : null,
    artwork_url: p.itunesInfo?.baseArtworkUrlOf || p.imageUrl || null,
    rss_url: p.rssUrl || null,
    categories: mapGenres(p.genres || []),
    total_episodes: p.totalEpisodesCount || 0,
    source: "taddy",
  };
}

Deno.serve(async (_req) => {
  const requestId = crypto.randomUUID();
  log("info", "request_received", { requestId });

  try {
    const taddyUserId = Deno.env.get("TADDY_USER_ID");
    const taddyApiKey = Deno.env.get("TADDY_API_KEY");
    if (!taddyUserId || !taddyApiKey) {
      log("error", "missing_taddy_credentials", { requestId });
      return new Response(JSON.stringify({ error: "Missing Taddy credentials in secrets" }), {
        status: 500, headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const allPodcasts: TaddyPodcast[] = [];
    let apiCalls = 0;
    const errors: string[] = [];

    // 1. Fetch top 200 popular English podcasts
    for (let page = 1; page <= 8; page++) {
      try {
        const data = await taddyQuery(`{
          getPopularContent(filterByLanguage: ENGLISH, page: ${page}, limitPerPage: 25) {
            popularityRankId
            podcastSeries {
              uuid name description imageUrl rssUrl authorName totalEpisodesCount genres
              itunesInfo { uuid baseArtworkUrlOf(size: 640) publisherName }
            }
          }
        }`, taddyUserId, taddyApiKey);
        apiCalls++;
        const series = data?.data?.getPopularContent?.podcastSeries || [];
        log("info", "popular_page_fetched", { requestId, page, count: series.length });
        allPodcasts.push(...series);
        if (series.length < 25) break;
      } catch (err) {
        errors.push(`popular_page_${page}: ${String(err)}`);
        log("error", "popular_page_failed", { requestId, page, error: String(err) });
      }
    }

    // 2. Fetch top charts for US + EU markets
    const countries = [
      "UNITED_STATES_OF_AMERICA",
      "UNITED_KINGDOM",
      "GERMANY",
      "FRANCE",
      "IRELAND",
    ];
    const trendingByRegion: Record<string, TaddyPodcast[]> = {};

    for (const country of countries) {
      trendingByRegion[country] = [];
      for (let page = 1; page <= 4; page++) {
        try {
          const data = await taddyQuery(`{
            getTopChartsByCountry(taddyType: PODCASTSERIES, country: ${country}, page: ${page}, limitPerPage: 25) {
              topChartsId
              podcastSeries {
                uuid name description imageUrl rssUrl authorName totalEpisodesCount genres
                itunesInfo { uuid baseArtworkUrlOf(size: 640) publisherName }
              }
            }
          }`, taddyUserId, taddyApiKey);
          apiCalls++;
          const series = data?.data?.getTopChartsByCountry?.podcastSeries || [];
          log("info", "country_chart_fetched", { requestId, country, page, count: series.length });
          trendingByRegion[country].push(...series);
          allPodcasts.push(...series);
          if (series.length < 25) break;
        } catch (err) {
          errors.push(`country_${country}_page_${page}: ${String(err)}`);
          log("error", "country_chart_failed", { requestId, country, page, error: String(err) });
        }
      }
    }

    // 3. Fetch top charts per genre
    const genreGroups = [
      ["PODCASTSERIES_BUSINESS"],
      ["PODCASTSERIES_NEWS"],
      ["PODCASTSERIES_TECHNOLOGY"],
      ["PODCASTSERIES_EDUCATION"],
      ["PODCASTSERIES_HEALTH_AND_FITNESS"],
      ["PODCASTSERIES_SOCIETY_AND_CULTURE"],
      ["PODCASTSERIES_COMEDY"],
      ["PODCASTSERIES_TRUE_CRIME"],
      ["PODCASTSERIES_SPORTS"],
      ["PODCASTSERIES_SCIENCE"],
    ];
    for (const genres of genreGroups) {
      for (let page = 1; page <= 4; page++) {
        try {
          const data = await taddyQuery(`{
            getTopChartsByGenres(taddyType: PODCASTSERIES, genres: [${genres.join(",")}], page: ${page}, limitPerPage: 25) {
              topChartsId
              podcastSeries {
                uuid name description imageUrl rssUrl authorName totalEpisodesCount genres
                itunesInfo { uuid baseArtworkUrlOf(size: 640) publisherName }
              }
            }
          }`, taddyUserId, taddyApiKey);
          apiCalls++;
          const series = data?.data?.getTopChartsByGenres?.podcastSeries || [];
          log("info", "genre_chart_fetched", { requestId, genre: genres[0], page, count: series.length });
          allPodcasts.push(...series);
          if (series.length < 25) break;
        } catch (err) {
          errors.push(`genre_${genres[0]}_page_${page}: ${String(err)}`);
          log("error", "genre_chart_failed", { requestId, genre: genres[0], page, error: String(err) });
        }
      }
    }

    // Deduplicate
    const uniqueMap = new Map<string, TaddyPodcast>();
    for (const p of allPodcasts) {
      if (p?.uuid) uniqueMap.set(p.uuid, p);
    }
    const uniquePodcasts = Array.from(uniqueMap.values());
    log("info", "deduplication_complete", { requestId, total: allPodcasts.length, unique: uniquePodcasts.length });

    // 4. UPSERT podcasts
    const podcastRows = uniquePodcasts.map(podcastToRow);
    let upsertErrors = 0;
    for (let i = 0; i < podcastRows.length; i += 50) {
      const batch = podcastRows.slice(i, i + 50);
      const { error } = await supabase.from("podcasts").upsert(batch, {
        onConflict: "external_id",
        ignoreDuplicates: false,
      });
      if (error) {
        log("error", "podcast_upsert_batch_failed", { requestId, batchStart: i, error: error.message });
        upsertErrors++;
      }
    }
    log("info", "podcasts_upserted", { requestId, count: podcastRows.length, errors: upsertErrors });

    // 5. Build external_id -> internal id map
    const { data: existingPodcasts } = await supabase
      .from("podcasts")
      .select("id, external_id");
    const idMap = new Map<string, string>();
    for (const p of existingPodcasts || []) {
      idMap.set(p.external_id, p.id);
    }

    // 6. INSERT trending_podcasts per region
    for (const [region, pods] of Object.entries(trendingByRegion)) {
      await supabase.from("trending_podcasts").delete().eq("region", region);
      const trendingRows = pods
        .map((p, idx) => {
          const podcastId = idMap.get(p.uuid);
          if (!podcastId) return null;
          return { podcast_id: podcastId, rank: idx + 1, score: pods.length - idx, period: "daily", region };
        })
        .filter(Boolean);
      if (trendingRows.length > 0) {
        const { error } = await supabase.from("trending_podcasts").insert(trendingRows);
        if (error) log("error", "trending_insert_failed", { requestId, region, error: error.message });
        else log("info", "trending_inserted", { requestId, region, count: trendingRows.length });
      }
    }

    // 7. Fetch latest episodes per podcast (batches of 5 UUIDs)
    const uuids = Array.from(uniqueMap.keys());
    let episodeCount = 0;
    for (let i = 0; i < uuids.length; i += 5) {
      const batchUuids = uuids.slice(i, i + 5);
      const uuidsStr = batchUuids.map((u) => `"${u}"`).join(",");
      try {
        const data = await taddyQuery(`{
          getLatestEpisodesFromMultiplePodcasts(uuids: [${uuidsStr}]) {
            uuid name description audioUrl duration datePublished episodeNumber seasonNumber
            podcastSeries { uuid }
          }
        }`, taddyUserId, taddyApiKey);
        apiCalls++;
        const episodes = data?.data?.getLatestEpisodesFromMultiplePodcasts || [];
        const episodeRows = episodes
          .filter((ep: any) => ep?.uuid && ep?.audioUrl && ep?.podcastSeries?.uuid)
          .map((ep: any) => ({
            external_id: ep.uuid,
            podcast_id: idMap.get(ep.podcastSeries.uuid),
            title: ep.name || "Untitled Episode",
            description: ep.description || null,
            audio_url: ep.audioUrl,
            duration_seconds: ep.duration || null,
            published_at: ep.datePublished ? new Date(ep.datePublished * 1000).toISOString() : null,
          }))
          .filter((r: any) => r.podcast_id);

        if (episodeRows.length > 0) {
          const { error } = await supabase.from("episodes").upsert(episodeRows, {
            onConflict: "external_id",
            ignoreDuplicates: false,
          });
          if (error) log("error", "episode_upsert_failed", { requestId, batch: i, error: error.message });
          episodeCount += episodeRows.length;
        }
      } catch (e) {
        if (errors.length < 10) errors.push(`episode_batch_${i}: ${String(e)}`);
        log("error", "episode_fetch_failed", { requestId, batch: i, error: String(e) });
      }
    }

    const payload = {
      success: true,
      request_id: requestId,
      podcasts_seeded: uniquePodcasts.length,
      episodes_seeded: episodeCount,
      api_calls: apiCalls,
      regions: countries,
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
      stack: (error as Error).stack,
    });
    return new Response(
      JSON.stringify({ error: (error as Error).message, request_id: requestId }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
