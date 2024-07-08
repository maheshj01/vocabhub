Vocabhub uses Supabase and Firebase for backend services. The project is built using Flutter and Dart.
So you will need to have Flutter installed on your machine to run the project locally. You also need to setup Firebase project and Supabase project with a database to run the project locally.

Below are the steps to setup the project locally:

#### Setting up Firebase

You can skip step 1-3 if you have firebase_cli already installed and activated on your machine.

1. Install firebase tools and activate firebase_cli locally by following instructions here https://firebase.google.com/docs/cli#mac-linux-standalone-binary ()
2. login to firebase `firebase login`
3. activate flutterfire_cli by running `dart pub global activate flutterfire_cli`

4. Create a new firebase project by visiting https://console.firebase.google.com/
5. Run `firebase projects:list` to get the list of projects in your account.
6. Run `firebase use <project_id>` to use the project you created in step 4.
7. Run `flutterfire configure` to configure the flutter project with the firebase project.
   > Note: If flutterfire is not found you need to add the flutterfire_cli to your system path. see [Instructons here](https://stackoverflow.com/a/70325312)
8. Do not use existing firebae.json by answering 'n`,This step will configure your firebase project for selected platforms(android, ios, web etc).
9. Now you should have firebase_options.dart file in your libr folder, move the file to `lib/utils` folder.
10. Go to firebase console -> Run -> RemoteConfig and add the following keys

- `buildNumber`: <from pubspec.yaml>
- `version`: <from pubspec.yaml>

e.g if pubspec has 0.7.9+31 - `buildNumber`: 31 - `version`: 0.7.9
and click Publish Changes

#### Setting up Supabase Project

1. Create a Supabase project and go to SQL editor and run the following SQL commands to create the tables required for the project.

```sql
-- Ensure the UUID extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the public schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS public;

-- Table: users_mobile (create this table first since other tables depend on it)
CREATE TABLE public.users_mobile (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    accessToken text DEFAULT NULL,
    avatarUrl text DEFAULT NULL,
    idToken text DEFAULT NULL,
    isLoggedIn boolean DEFAULT false,
    isAdmin boolean NOT NULL DEFAULT false,
    username text NOT NULL DEFAULT ''::text,
    token text DEFAULT ''::text,
    deleted boolean NOT NULL DEFAULT false,
    updated_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
    PRIMARY KEY (id),
    UNIQUE (email)
);

-- Table: vocabsheet_mobile (create this table before referencing it)
CREATE TABLE public.vocabsheet_mobile (
    word text DEFAULT NULL,
    meaning text DEFAULT NULL,
    synonyms text[] DEFAULT NULL,
    examples text[] DEFAULT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    mnemonics text[] DEFAULT NULL,
    editedAt timestamp with time zone DEFAULT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- Table: edit_history
CREATE TABLE public.edit_history (
    created_at timestamp with time zone DEFAULT now(),
    word text DEFAULT ''::text,
    meaning text DEFAULT ''::text,
    synonyms text[] DEFAULT NULL,
    state text NOT NULL DEFAULT 'pending'::text,
    examples text[] DEFAULT NULL,
    mnemonics text[] DEFAULT NULL,
    email text NOT NULL,
    word_id uuid NOT NULL,
    edit_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    edit_type text NOT NULL DEFAULT 'edit'::text,
    comments text NOT NULL DEFAULT ''::text,
    PRIMARY KEY (edit_id),
    CONSTRAINT edit_history_email_fkey FOREIGN KEY (email) REFERENCES public.users_mobile (email)
);

-- Table: feedback
CREATE TABLE public.feedback (
    created_at timestamp with time zone DEFAULT now(),
    name text DEFAULT NULL,
    email text DEFAULT NULL,
    feedback text DEFAULT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    PRIMARY KEY (id)
);

-- Table: login
CREATE TABLE public.login (
    id uuid NOT NULL,
    last_updated_at timestamp with time zone DEFAULT now(),
    PRIMARY KEY (id)
);

-- Table: word_of_the_day
CREATE TABLE public.word_of_the_day (
    created_at timestamp with time zone DEFAULT now(),
    word text DEFAULT NULL,
    id uuid NOT NULL,
    wod_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    PRIMARY KEY (id),
    CONSTRAINT word_of_the_day_id_fkey FOREIGN KEY (id) REFERENCES public.vocabsheet_mobile (id)
);

-- Table: word_state
CREATE TABLE public.word_state (
    created_at timestamp with time zone DEFAULT now(),
    email text NOT NULL,
    state text NOT NULL,
    word_id uuid DEFAULT NULL,
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    PRIMARY KEY (id),
    CONSTRAINT word_state_word_id_fkey FOREIGN KEY (word_id) REFERENCES public.vocabsheet_mobile (id)
);
```

To delete the entire Schema Run

```sql
-- Drop foreign key constraints in public schema
ALTER TABLE public.edit_history DROP CONSTRAINT IF EXISTS edit_history_email_fkey;
ALTER TABLE public.word_of_the_day DROP CONSTRAINT IF EXISTS word_of_the_day_id_fkey;
ALTER TABLE public.word_state DROP CONSTRAINT IF EXISTS word_state_word_id_fkey;

-- Drop tables in public schema
DROP TABLE IF EXISTS public.edit_history CASCADE;
DROP TABLE IF EXISTS public.feedback CASCADE;
DROP TABLE IF EXISTS public.login CASCADE;
DROP TABLE IF EXISTS public.users_mobile CASCADE;
DROP TABLE IF EXISTS public.vocabsheet_mobile CASCADE;
DROP TABLE IF EXISTS public.word_of_the_day CASCADE;
DROP TABLE IF EXISTS public.word_state CASCADE;

-- Drop schema public
DROP SCHEMA IF EXISTS public CASCADE;
```

> Note: Rename the column `editedat` to `editedAt` probably a bug in supabase. 2. Click on `vocabsheet_mobile` table and import the data from this csv [vocabhub_50_rows.csv](https://github.com/user-attachments/files/16122035/supabase_bisasplfdnyiiggonpcx_Update.null.column.csv)

5. Running the app see [Running the app guide on wiki](https://github.com/maheshmnj/vocabhub/wiki/Project-Specifications-and-Knowledge-base#running-the-app)
