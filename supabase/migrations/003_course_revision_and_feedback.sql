-- Версия каталога курсов (триггеры при правках в админке) + обращения пользователей.
-- Применить после 002_admin_courses.sql.

-- ---------- Мета: монотонный revision, читают все клиенты ----------
CREATE TABLE IF NOT EXISTS public.course_catalog_meta (
  id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  revision BIGINT NOT NULL DEFAULT 1,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.course_catalog_meta (id, revision)
VALUES (1, 1)
ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION public.bump_course_catalog_revision()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.course_catalog_meta
  SET revision = revision + 1, updated_at = now()
  WHERE id = 1;
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_course_categories_bump ON public.course_categories;
CREATE TRIGGER trg_course_categories_bump
  AFTER INSERT OR UPDATE OR DELETE ON public.course_categories
  FOR EACH ROW EXECUTE FUNCTION public.bump_course_catalog_revision();

DROP TRIGGER IF EXISTS trg_course_lessons_bump ON public.course_lessons;
CREATE TRIGGER trg_course_lessons_bump
  AFTER INSERT OR UPDATE OR DELETE ON public.course_lessons
  FOR EACH ROW EXECUTE FUNCTION public.bump_course_catalog_revision();

ALTER TABLE public.course_catalog_meta ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "course_catalog_meta_read" ON public.course_catalog_meta;
CREATE POLICY "course_catalog_meta_read"
  ON public.course_catalog_meta FOR SELECT TO anon, authenticated
  USING (true);

-- ---------- Обратная связь ----------
CREATE TABLE IF NOT EXISTS public.app_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  guest_email TEXT,
  display_name TEXT NOT NULL DEFAULT '',
  message TEXT NOT NULL,
  screen TEXT NOT NULL,
  lesson_id TEXT,
  category_id TEXT,
  app_version TEXT
);

CREATE INDEX IF NOT EXISTS idx_app_feedback_created ON public.app_feedback (created_at DESC);

ALTER TABLE public.app_feedback ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "app_feedback_insert_anon" ON public.app_feedback;
CREATE POLICY "app_feedback_insert_anon"
  ON public.app_feedback FOR INSERT TO anon
  WITH CHECK (
    user_id IS NULL
    AND guest_email IS NOT NULL
    AND length(trim(guest_email)) >= 5
    AND position('@' IN trim(guest_email)) > 1
    AND length(trim(message)) >= 8
  );

DROP POLICY IF EXISTS "app_feedback_insert_auth" ON public.app_feedback;
CREATE POLICY "app_feedback_insert_auth"
  ON public.app_feedback FOR INSERT TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND guest_email IS NULL
    AND length(trim(message)) >= 8
  );

DROP POLICY IF EXISTS "app_feedback_select_admin" ON public.app_feedback;
CREATE POLICY "app_feedback_select_admin"
  ON public.app_feedback FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

GRANT SELECT ON public.course_catalog_meta TO anon, authenticated;
GRANT INSERT ON public.app_feedback TO anon, authenticated;
GRANT SELECT ON public.app_feedback TO authenticated;
