-- FRANTSAY 2.0 — Supabase
-- Relation stricte : 1 e-mail = 1 pseudo = 1 UUID.
-- La vérification de possession de la boîte e-mail n'est volontairement
-- pas faite par OTP dans cette version.

create extension if not exists pgcrypto;

create table if not exists public.users (
    id uuid primary key default gen_random_uuid(),
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

-- Nettoyage de l'ancien mécanisme OTP s'il avait été installé.
drop table if exists public.pending_otps;

alter table public.users enable row level security;
revoke all on table public.users from anon, authenticated;
grant all on table public.users to service_role;

-- À vérifier si ton projet n'expose pas automatiquement la table :
-- Dashboard Supabase > Settings > API > Data API > Exposed schemas/tables.
