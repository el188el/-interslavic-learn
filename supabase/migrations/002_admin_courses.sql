-- Admin: флаг в профиле, запись курсов только для is_admin, список пользователей через RPC.
-- Применить после schema.sql (SQL Editor или supabase db push).

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.profiles.is_admin IS 'Доступ к админ-панели курсов и RPC admin_list_users; выставлять вручную в SQL.';

-- ---------- Запись в course_* только для администраторов ----------

DROP POLICY IF EXISTS "course_categories_admin_insert" ON public.course_categories;
CREATE POLICY "course_categories_admin_insert"
  ON public.course_categories FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

DROP POLICY IF EXISTS "course_categories_admin_update" ON public.course_categories;
CREATE POLICY "course_categories_admin_update"
  ON public.course_categories FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

DROP POLICY IF EXISTS "course_categories_admin_delete" ON public.course_categories;
CREATE POLICY "course_categories_admin_delete"
  ON public.course_categories FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

DROP POLICY IF EXISTS "course_lessons_admin_insert" ON public.course_lessons;
CREATE POLICY "course_lessons_admin_insert"
  ON public.course_lessons FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

DROP POLICY IF EXISTS "course_lessons_admin_update" ON public.course_lessons;
CREATE POLICY "course_lessons_admin_update"
  ON public.course_lessons FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

DROP POLICY IF EXISTS "course_lessons_admin_delete" ON public.course_lessons;
CREATE POLICY "course_lessons_admin_delete"
  ON public.course_lessons FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.is_admin = TRUE
    )
  );

-- ---------- Список пользователей (email из auth.users) только для админа ----------

CREATE OR REPLACE FUNCTION public.admin_list_users()
RETURNS TABLE (
  user_id uuid,
  email text,
  display_name text,
  total_xp integer,
  current_streak integer,
  is_admin boolean,
  created_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.is_admin = TRUE
  ) THEN
    RAISE EXCEPTION 'forbidden' USING ERRCODE = '42501';
  END IF;

  RETURN QUERY
  SELECT
    p.id,
    COALESCE(u.email::text, ''),
    p.display_name,
    COALESCE(up.total_xp, 0),
    COALESCE(up.current_streak, 0),
    p.is_admin,
    p.created_at
  FROM public.profiles p
  INNER JOIN auth.users u ON u.id = p.id
  LEFT JOIN public.user_progress up ON up.user_id = p.id
  ORDER BY p.created_at DESC;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_list_users() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_list_users() TO authenticated;
