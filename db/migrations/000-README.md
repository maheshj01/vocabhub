# Database migrations

`schema.sql` is the **source of truth** for the Supabase schema. Every schema
change must do **both** of the following, in the same PR:

1. **Update `schema.sql`** to reflect the new desired state (tables, columns,
   constraints, indexes).
2. **Add a numbered migration file** in this folder with the incremental SQL to
   apply the change to an existing database.

## Migration file naming

```
YYYY-MM-DD-N-short-description.sql
```

- `YYYY-MM-DD` — the date the migration is authored.
- `N` — a 1-based counter for that day (`-1`, `-2`, `-3`, …), so multiple
  migrations on the same day stay ordered.
- `short-description` — kebab-case summary of the change.

Examples:

```
2026-07-05-1-add-uid-phone-auth.sql
2026-07-05-2-fix-uid-index.sql
2026-07-06-1-add-word-difficulty-column.sql
```

Files sort chronologically and are applied in filename order. Once a migration
has been applied to a shared/production database, treat it as **immutable** —
ship a new numbered migration to correct it rather than editing the old one.

## Applying

Migrations are run manually in the Supabase SQL editor (paste and execute).
They are wrapped in `begin;`/`commit;` and written to be idempotent where
practical (`if not exists`, `drop ... if exists`).
