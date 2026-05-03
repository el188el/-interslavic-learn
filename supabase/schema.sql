-- Interslavic Learn — Supabase schema (PostgreSQL 15+)
-- Выполните в SQL Editor нового проекта. Удалите старые версии таблиц при конфликте имён.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========= Profiles (1:1 с auth.users) =========
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT 'Ученик',
  avatar_url TEXT,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  locale TEXT NOT NULL DEFAULT 'ru',
  use_cyrillic BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_progress (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  total_xp INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  best_streak INTEGER NOT NULL DEFAULT 0,
  last_active_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.lesson_completions (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  lesson_id TEXT NOT NULL,
  score_xp INTEGER NOT NULL DEFAULT 0,
  accuracy REAL,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, lesson_id)
);

-- ========= Курсы (контент из админки / импорта JSON) =========
CREATE TABLE IF NOT EXISTS public.course_categories (
  id TEXT PRIMARY KEY,
  sort_order INTEGER NOT NULL DEFAULT 0,
  title_ru TEXT NOT NULL,
  title_en TEXT NOT NULL,
  title_isv_lat TEXT DEFAULT '',
  title_isv_cyr TEXT DEFAULT '',
  icon TEXT DEFAULT 'school'
);

CREATE TABLE IF NOT EXISTS public.course_lessons (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES public.course_categories(id) ON DELETE CASCADE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  payload JSONB NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_course_lessons_cat ON public.course_lessons(category_id);

-- ========= Рейтинг (SECURITY DEFINER — обход RLS для чтения топа) =========
CREATE OR REPLACE FUNCTION public.leaderboard_top(row_limit integer DEFAULT 100)
RETURNS TABLE (
  user_id uuid,
  display_name text,
  total_xp integer,
  current_streak integer
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT p.id, p.display_name, up.total_xp, up.current_streak
  FROM public.profiles p
  INNER JOIN public.user_progress up ON up.user_id = p.id
  ORDER BY up.total_xp DESC, p.display_name ASC
  LIMIT row_limit;
$$;

GRANT EXECUTE ON FUNCTION public.leaderboard_top(integer) TO anon, authenticated;

-- ========= Триггер: профиль + прогресс при регистрации =========
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', 'Ученик')
  );
  INSERT INTO public.user_progress (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ========= RLS =========
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_public" ON public.profiles;
CREATE POLICY "profiles_select_public"
  ON public.profiles FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "progress_own" ON public.user_progress;
CREATE POLICY "progress_own"
  ON public.user_progress FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "completions_own" ON public.lesson_completions;
CREATE POLICY "completions_own"
  ON public.lesson_completions FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "course_cat_read" ON public.course_categories;
CREATE POLICY "course_cat_read"
  ON public.course_categories FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "course_less_read" ON public.course_lessons;
CREATE POLICY "course_less_read"
  ON public.course_lessons FOR SELECT TO anon, authenticated USING (true);

-- Служебное обновление updated_at
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profiles_touch ON public.profiles;
CREATE TRIGGER trg_profiles_touch
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_progress_touch ON public.user_progress;
CREATE TRIGGER trg_progress_touch
  BEFORE UPDATE ON public.user_progress
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Дополнительно для админ-панели курсов: migrations/002_admin_courses.sql (is_admin, RLS на запись course_*, RPC admin_list_users).
