-- Migration: onboarding tables for account setup + recommendation flow
-- Tables: podcast_categories, podcast_speakers, user_onboarding_choices, user_recommendations
-- Column addition: profiles.onboarding_completed

-- ─── podcast_categories ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.podcast_categories (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  taddy_genre   TEXT NOT NULL UNIQUE,
  parent_id     UUID REFERENCES public.podcast_categories(id) ON DELETE SET NULL,
  icon_name     TEXT,
  display_order INT NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_podcast_categories_parent ON public.podcast_categories(parent_id);
CREATE INDEX idx_podcast_categories_order  ON public.podcast_categories(display_order);

ALTER TABLE public.podcast_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "podcast_categories_select_all"
  ON public.podcast_categories FOR SELECT
  USING (true);

-- ─── podcast_speakers ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.podcast_speakers (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 TEXT NOT NULL,
  photo_url            TEXT,
  external_podcast_ids TEXT[] NOT NULL DEFAULT '{}',
  display_order        INT NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_podcast_speakers_order ON public.podcast_speakers(display_order);

ALTER TABLE public.podcast_speakers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "podcast_speakers_select_all"
  ON public.podcast_speakers FOR SELECT
  USING (true);

-- ─── user_onboarding_choices ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_onboarding_choices (
  user_id      UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_ids UUID[] NOT NULL DEFAULT '{}',
  speaker_ids  UUID[] NOT NULL DEFAULT '{}',
  podcast_ids  UUID[] NOT NULL DEFAULT '{}',
  completed_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.user_onboarding_choices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_onboarding_choices_select_own"
  ON public.user_onboarding_choices FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "user_onboarding_choices_insert_own"
  ON public.user_onboarding_choices FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_onboarding_choices_update_own"
  ON public.user_onboarding_choices FOR UPDATE
  USING (auth.uid() = user_id);

-- ─── user_recommendations ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_recommendations (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  section_type   TEXT NOT NULL,
  podcast_ids    UUID[] NOT NULL DEFAULT '{}',
  episode_ids    UUID[] NOT NULL DEFAULT '{}',
  collection_ids UUID[] NOT NULL DEFAULT '{}',
  clip_ids       UUID[] NOT NULL DEFAULT '{}',
  metadata       JSONB NOT NULL DEFAULT '{}',
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, section_type)
);

CREATE INDEX idx_user_recommendations_user ON public.user_recommendations(user_id);

ALTER TABLE public.user_recommendations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_recommendations_select_own"
  ON public.user_recommendations FOR SELECT
  USING (auth.uid() = user_id);

-- ─── profiles.onboarding_completed ──────────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE;
