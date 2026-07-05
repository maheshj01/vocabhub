-- Migration: unify identity on Firebase Auth uid; support phone auth.
-- Table: users_mobile
--
-- Rationale
--   Previously the app keyed users on `email`. Phone-auth users have no email,
--   so the canonical identity key becomes the Firebase Auth `uid` (stable across
--   both Google and phone providers). `email` becomes nullable; `phone` is added.
--
-- Run this in the Supabase SQL editor. Safe to run once.

begin;

-- 1. Firebase uid — canonical identity key.
alter table public.users_mobile
  add column if not exists uid text;

-- 2. E.164 phone number for phone-auth users.
alter table public.users_mobile
  add column if not exists phone text;

-- 3. Email is no longer mandatory (phone-only users have none).
alter table public.users_mobile
  alter column email drop not null;

-- 4. Enforce uniqueness on uid. This MUST be a full (non-partial) unique index:
--    the app upserts profiles with ON CONFLICT (uid), and Postgres cannot infer
--    a partial index as a conflict target. A standard unique index still allows
--    multiple NULLs, so legacy rows (uid IS NULL until first login) don't clash.
create unique index if not exists users_mobile_uid_key
  on public.users_mobile (uid);

-- Phone uniqueness can stay partial (it's never an ON CONFLICT target).
create unique index if not exists users_mobile_phone_key
  on public.users_mobile (phone) where phone is not null;

commit;

-- Backfill note
--   Existing Google users have an `email` but no `uid` (there was no Firebase
--   Auth before). The app links them automatically: on the next Google sign-in
--   it matches the legacy row by email and writes the Firebase `uid` into it.
--   No manual backfill required.
