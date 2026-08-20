-- FRANTSAY — schéma Supabase
-- Exécuter ce script dans Supabase > SQL Editor.
-- Le service_role_key est utilisé uniquement côté serveur Streamlit.

create extension if not exists pgcrypto;

create table if not exists public.users (
    id uuid primary key,
    email text not null,
    pseudo text not null,
    level text not null default 'Lycée',
    score integer not null default 0,
    questions_done integer not null default 0,
    progress jsonb not null default jsonb_build_object(
        'score', 0,
        'questions_done', 0,
        'level', 'Lycée'
    ),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint users_email_unique unique (email),
    constraint users_pseudo_unique unique (pseudo),
    constraint users_score_nonnegative check (score >= 0),
    constraint users_questions_nonnegative check (questions_done >= 0)
);

create table if not exists public.pending_otps (
    email text primary key,
    pseudo text not null,
    otp_hash text not null,
    expires_at timestamptz not null,
    attempts integer not null default 0,
    sent_at timestamptz not null default now(),
    constraint pending_otps_attempts_nonnegative check (attempts >= 0)
);

-- Durcissement : RLS activé et aucune permission publique nécessaire.
-- Le service_role utilisé par Streamlit contourne RLS côté serveur.
alter table public.users enable row level security;
alter table public.pending_otps enable row level security;

revoke all on table public.users from anon, authenticated;
revoke all on table public.pending_otps from anon, authenticated;
grant all on table public.users to service_role;
grant all on table public.pending_otps to service_role;

-- Expose les tables à la Data API Supabase.
-- Dans Dashboard > Settings > API > Data API, ajouter/exposer public.users
-- et public.pending_otps si ton projet n'expose pas automatiquement les tables.

-- Vérifications utiles après exécution :
-- select column_name, data_type from information_schema.columns
-- where table_schema = 'public' and table_name in ('users','pending_otps')
-- order by table_name, ordinal_position;
