-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.
--
-- SOURCE OF TRUTH: keep this file in sync with the live database. Any schema
-- change must (1) update the relevant table/index here and (2) ship a numbered
-- migration in this folder (see 000-README.md).

CREATE TABLE public.edit_history (
  synonyms ARRAY,
  examples ARRAY,
  mnemonics ARRAY,
  email text NOT NULL,
  word_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  word text DEFAULT ''::text,
  meaning text DEFAULT ''::text,
  state text NOT NULL DEFAULT 'pending'::text,
  edit_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  edit_type text NOT NULL DEFAULT 'edit'::text,
  comments text NOT NULL DEFAULT ''::text,
  CONSTRAINT edit_history_pkey PRIMARY KEY (edit_id),
  CONSTRAINT edit_history_email_fkey FOREIGN KEY (email) REFERENCES public.users_mobile(email)
);
CREATE TABLE public.feedback (
  name text,
  email text,
  feedback text,
  created_at timestamp with time zone DEFAULT now(),
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  CONSTRAINT feedback_pkey PRIMARY KEY (id)
);
CREATE TABLE public.users_mobile (
  name text NOT NULL,
  accessToken text,
  avatarUrl text,
  idToken text,
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  isLoggedIn boolean DEFAULT false,
  isAdmin boolean NOT NULL DEFAULT false,
  username text NOT NULL DEFAULT ''::text,
  token text DEFAULT ''::text,
  deleted boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  uid text,
  phone text,
  email text UNIQUE,
  CONSTRAINT users_mobile_pkey PRIMARY KEY (id)
);
-- Identity keys added for Firebase auth (Google + phone). uid is the canonical
-- lookup key and MUST be a full unique index (used as an ON CONFLICT upsert
-- target); both allow multiple NULLs for rows not yet linked.
CREATE UNIQUE INDEX users_mobile_uid_key ON public.users_mobile (uid);
CREATE UNIQUE INDEX users_mobile_phone_key ON public.users_mobile (phone) WHERE phone IS NOT NULL;
CREATE TABLE public.vocabsheet_mobile (
  word text,
  meaning text,
  synonyms ARRAY,
  examples ARRAY,
  mnemonics ARRAY,
  editedAt timestamp with time zone,
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT vocabsheet_mobile_pkey PRIMARY KEY (id)
);
CREATE TABLE public.word_of_the_day (
  word text,
  id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  wod_id uuid NOT NULL DEFAULT uuid_generate_v4(),
  CONSTRAINT word_of_the_day_pkey PRIMARY KEY (wod_id),
  CONSTRAINT word_of_the_day_id_fkey FOREIGN KEY (id) REFERENCES public.vocabsheet_mobile(id)
);
CREATE TABLE public.word_state (
  email text NOT NULL,
  state text NOT NULL,
  word_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  CONSTRAINT word_state_pkey PRIMARY KEY (id),
  CONSTRAINT word_state_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocabsheet_mobile(id)
);