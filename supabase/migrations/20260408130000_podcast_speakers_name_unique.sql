-- Enables upsert onConflict: "name" from seed-onboarding-data Edge Function
CREATE UNIQUE INDEX IF NOT EXISTS podcast_speakers_name_unique
  ON public.podcast_speakers (name);
