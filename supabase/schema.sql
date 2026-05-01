-- ============================================================
-- Interslavic Learn — Supabase Database Schema
-- ============================================================
-- This schema supports: user profiles, lesson progress tracking,
-- XP/streaks gamification, global leaderboard, and sync queue
-- for offline-first architecture.
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. Users / Profiles
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id       UUID UNIQUE,                          -- links to Supabase Auth
  display_name  TEXT NOT NULL DEFAULT 'Ученик',
  avatar_url    TEXT,
  is_premium    BOOLEAN NOT NULL DEFAULT FALSE,
  locale        TEXT NOT NULL DEFAULT 'ru',            -- 'ru' | 'en'
  use_cyrillic  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. User Progress
-- ============================================================
CREATE TABLE IF NOT EXISTS user_progress (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  total_xp        INTEGER NOT NULL DEFAULT 0,
  current_streak  INTEGER NOT NULL DEFAULT 0,
  best_streak     INTEGER NOT NULL DEFAULT 0,
  last_active_date DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

-- ============================================================
-- 3. Lesson Completion Records
-- ============================================================
CREATE TABLE IF NOT EXISTS lesson_completions (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id   TEXT NOT NULL,
  score_xp    INTEGER NOT NULL DEFAULT 0,
  accuracy    REAL,                                     -- 0.0 to 1.0
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, lesson_id)
);

-- ============================================================
-- 4. Global Leaderboard (materialized view / table)
-- ============================================================
CREATE TABLE IF NOT EXISTS leaderboard (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  display_name  TEXT NOT NULL,
  total_xp      INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  rank          INTEGER,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

-- Index for fast ranking queries
CREATE INDEX IF NOT EXISTS idx_leaderboard_xp
  ON leaderboard (total_xp DESC);

-- ============================================================
-- 5. Sync Queue (offline-first conflict resolution)
-- ============================================================
CREATE TABLE IF NOT EXISTS sync_queue (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  action_type   TEXT NOT NULL,          -- 'lesson_complete' | 'xp_update' | 'streak_update'
  payload       JSONB NOT NULL,         -- flexible payload for the action
  client_timestamp TIMESTAMPTZ NOT NULL, -- when the action was performed on client
  synced        BOOLEAN NOT NULL DEFAULT FALSE,
  synced_at     TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sync_queue_user_unsynced
  ON sync_queue (user_id, synced)
  WHERE synced = FALSE;

-- ============================================================
-- 6. Achievements (gamification extension)
-- ============================================================
CREATE TABLE IF NOT EXISTS achievements (
  id          TEXT PRIMARY KEY,
  title_ru    TEXT NOT NULL,
  title_en    TEXT NOT NULL,
  description_ru TEXT,
  description_en TEXT,
  icon        TEXT,
  xp_reward   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_achievements (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  TEXT NOT NULL REFERENCES achievements(id),
  earned_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, achievement_id)
);

-- ============================================================
-- 7. Row-Level Security Policies
-- ============================================================

-- Profiles: users can only read/update their own profile
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select ON profiles
  FOR SELECT USING (auth_id = auth.uid());

CREATE POLICY profiles_update ON profiles
  FOR UPDATE USING (auth_id = auth.uid());

-- Progress: users can only access their own progress
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY progress_select ON user_progress
  FOR SELECT USING (user_id IN (SELECT id FROM profiles WHERE auth_id = auth.uid()));

CREATE POLICY progress_upsert ON user_progress
  FOR ALL USING (user_id IN (SELECT id FROM profiles WHERE auth_id = auth.uid()));

-- Lesson completions: users can only access their own
ALTER TABLE lesson_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY completions_all ON lesson_completions
  FOR ALL USING (user_id IN (SELECT id FROM profiles WHERE auth_id = auth.uid()));

-- Leaderboard: everyone can read, only system can write
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

CREATE POLICY leaderboard_select ON leaderboard
  FOR SELECT USING (TRUE);

-- Sync queue: users can only access their own
ALTER TABLE sync_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY sync_queue_all ON sync_queue
  FOR ALL USING (user_id IN (SELECT id FROM profiles WHERE auth_id = auth.uid()));

-- ============================================================
-- 8. Functions
-- ============================================================

-- Function to update leaderboard when progress changes
CREATE OR REPLACE FUNCTION update_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO leaderboard (user_id, display_name, total_xp, current_streak, updated_at)
  SELECT
    NEW.user_id,
    p.display_name,
    NEW.total_xp,
    NEW.current_streak,
    now()
  FROM profiles p
  WHERE p.id = NEW.user_id
  ON CONFLICT (user_id) DO UPDATE SET
    total_xp = EXCLUDED.total_xp,
    current_streak = EXCLUDED.current_streak,
    display_name = EXCLUDED.display_name,
    updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_leaderboard
  AFTER INSERT OR UPDATE ON user_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_leaderboard();

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_progress_updated_at
  BEFORE UPDATE ON user_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 9. Seed Achievements
-- ============================================================
INSERT INTO achievements (id, title_ru, title_en, description_ru, description_en, icon, xp_reward) VALUES
  ('first_lesson', 'Первый урок', 'First Lesson', 'Завершите свой первый урок', 'Complete your first lesson', 'school', 50),
  ('streak_3', 'Серия 3 дня', '3-Day Streak', 'Занимайтесь 3 дня подряд', 'Study for 3 days in a row', 'local_fire_department', 100),
  ('streak_7', 'Серия 7 дней', '7-Day Streak', 'Занимайтесь 7 дней подряд', 'Study for 7 days in a row', 'local_fire_department', 250),
  ('streak_30', 'Серия 30 дней', '30-Day Streak', 'Занимайтесь 30 дней подряд', 'Study for 30 days in a row', 'local_fire_department', 1000),
  ('xp_100', '100 XP', '100 XP', 'Наберите 100 очков опыта', 'Earn 100 experience points', 'star', 50),
  ('xp_500', '500 XP', '500 XP', 'Наберите 500 очков опыта', 'Earn 500 experience points', 'star', 100),
  ('xp_1000', '1000 XP', '1000 XP', 'Наберите 1000 очков опыта', 'Earn 1000 experience points', 'star', 200),
  ('all_basics', 'Основы пройдены', 'Basics Complete', 'Завершите все уроки из раздела Основы', 'Complete all lessons in Basics', 'check_circle', 150)
ON CONFLICT (id) DO NOTHING;
