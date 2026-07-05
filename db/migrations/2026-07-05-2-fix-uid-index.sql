-- FIX for 2026-07-05-1-add-uid-phone-auth.sql
-- The original uid index was partial (WHERE uid IS NOT NULL), which Postgres
-- cannot use as an ON CONFLICT (uid) target. Replace it with a full unique
-- index (still allows multiple NULLs for legacy rows).
--
-- Run this once in the Supabase SQL editor if you applied the original migration.

begin;

drop index if exists public.users_mobile_uid_key;

create unique index users_mobile_uid_key
  on public.users_mobile (uid);

commit;
