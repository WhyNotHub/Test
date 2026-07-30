-- Bamboo -- Supabase schema
--
-- Run this once in your Supabase project's SQL Editor (Dashboard ->
-- SQL Editor -> New query -> paste this whole file -> Run) after creating
-- the project and before building the app. Safe to re-run: every statement
-- is idempotent (create-if-not-exists / create-or-replace).

-- One row per signed-in user, holding exactly what AvatarStore.swift syncs:
-- their display name and their avatar, as the same JSON shape Codable
-- already produces on the client. `id` is the same UUID Supabase Auth
-- assigns the user, and `on delete cascade` means deleting the auth user
-- (see delete_user() below) automatically removes their profile row too.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  user_name text not null default 'You',
  avatar jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Row Level Security is what makes it safe to ship the anon/publishable
-- key inside the app: without these policies, "authenticated" would mean
-- "can read and write every row," not just their own.
drop policy if exists "Users can view their own profile" on public.profiles;
create policy "Users can view their own profile"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

drop policy if exists "Users can delete their own profile" on public.profiles;
create policy "Users can delete their own profile"
  on public.profiles for delete
  using (auth.uid() = id);

-- Keeps updated_at honest on every change -- `default now()` on the column
-- only fires on insert, not on subsequent updates.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();

-- Lets a signed-in user delete their own account (AuthService.deleteAccount
-- in the app calls this via supabase.rpc("delete_user")). Deleting from
-- auth.users requires elevated privileges a normal client never has, so
-- this runs as `security definer` -- but it only ever touches auth.uid(),
-- the caller's own id straight from their JWT, never a client-supplied
-- parameter. That's what makes it safe to expose: there is no argument a
-- malicious or buggy client could pass to delete *someone else's* account.
create or replace function public.delete_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

grant execute on function public.delete_user() to authenticated;
