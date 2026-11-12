-- Comunidade do Meu App Estudos
-- Execute este arquivo uma única vez no Supabase > SQL Editor.
-- Não concede acesso público/anônimo nem expõe o conteúdo privado da tabela estudos.

create table if not exists public.community_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (length(trim(display_name)) between 2 and 60),
  exam_name text not null default '',
  patent text not null default 'Recruta',
  patent_level integer not null default 1 check (patent_level >= 1),
  evolution_score numeric not null default 10 check (evolution_score between 0 and 100),
  streak_days integer not null default 0 check (streak_days >= 0),
  average_daily_minutes integer not null default 0 check (average_daily_minutes between 0 and 1440),
  invite_code text not null unique,
  updated_at timestamptz not null default now()
);

-- Cria perfil comunitário para contas já existentes e para novos cadastros.
insert into public.community_profiles(user_id,display_name,invite_code)
select u.id,
       coalesce(nullif(trim(u.raw_user_meta_data->>'name'),''), nullif(split_part(u.email,'@',1),''), 'Estudante'),
       'EST-' || upper(substr(replace(u.id::text,'-',''),1,8))
from auth.users u
on conflict (user_id) do nothing;

create or replace function public.community_create_profile_on_signup()
returns trigger
language plpgsql
security definer
set search_path = ''
as $
begin
  insert into public.community_profiles(user_id,display_name,invite_code)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data->>'name'),''), nullif(split_part(new.email,'@',1),''), 'Estudante'),
    'EST-' || upper(substr(replace(new.id::text,'-',''),1,8))
  )
  on conflict (user_id) do nothing;
  return new;
end;
$;
revoke all on function public.community_create_profile_on_signup() from public, anon, authenticated;
drop trigger if exists community_profile_after_signup on auth.users;
create trigger community_profile_after_signup
  after insert on auth.users
  for each row execute function public.community_create_profile_on_signup();

alter table public.community_profiles add column if not exists evolution_score numeric not null default 10 check (evolution_score between 0 and 100);

create table if not exists public.community_daily_totals (
  user_id uuid not null references auth.users(id) on delete cascade,
  study_date date not null,
  minutes integer not null check (minutes between 0 and 1440),
  updated_at timestamptz not null default now(),
  primary key (user_id, study_date)
);
create index if not exists community_daily_totals_date_idx
  on public.community_daily_totals (study_date);

create table if not exists public.community_sessions (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  source_id text not null,
  started_at timestamptz not null,
  minutes integer not null check (minutes between 1 and 1440),
  created_at timestamptz not null default now(),
  unique (user_id, source_id)
);
create index if not exists community_sessions_started_at_idx
  on public.community_sessions (started_at);
create index if not exists community_sessions_user_started_idx
  on public.community_sessions (user_id, started_at desc);

create table if not exists public.community_friend_requests (
  id bigint generated always as identity primary key,
  sender_id uuid not null references auth.users(id) on delete cascade,
  receiver_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint community_friend_requests_not_self check (sender_id <> receiver_id)
);
create unique index if not exists community_friend_requests_pending_pair
  on public.community_friend_requests (sender_id, receiver_id);

create table if not exists public.community_friendships (
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_a, user_b),
  constraint community_friendships_ordered check (user_a < user_b)
);

create table if not exists public.community_notifications (
  id bigint generated always as identity primary key,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('cheer','friend_accepted')),
  created_at timestamptz not null default now(),
  read_at timestamptz,
  constraint community_notifications_not_self check (sender_id <> recipient_id)
);
create index if not exists community_notifications_recipient_idx
  on public.community_notifications (recipient_id, created_at desc);

alter table public.community_profiles enable row level security;
alter table public.community_sessions enable row level security;
alter table public.community_daily_totals enable row level security;
alter table public.community_friend_requests enable row level security;
alter table public.community_friendships enable row level security;
alter table public.community_notifications enable row level security;

drop policy if exists community_profiles_read on public.community_profiles;
create policy community_profiles_read on public.community_profiles
  for select to authenticated using (true);
drop policy if exists community_profiles_insert_own on public.community_profiles;
create policy community_profiles_insert_own on public.community_profiles
  for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists community_profiles_update_own on public.community_profiles;
create policy community_profiles_update_own on public.community_profiles
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists community_sessions_read_own on public.community_sessions;
create policy community_sessions_read_own on public.community_sessions
  for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists community_sessions_insert_own on public.community_sessions;
create policy community_sessions_insert_own on public.community_sessions
  for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists community_sessions_update_own on public.community_sessions;
create policy community_sessions_update_own on public.community_sessions
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists community_requests_read_related on public.community_friend_requests;
create policy community_requests_read_related on public.community_friend_requests
  for select to authenticated using ((select auth.uid()) in (sender_id, receiver_id));
drop policy if exists community_requests_insert_sender on public.community_friend_requests;
create policy community_requests_insert_sender on public.community_friend_requests
  for insert to authenticated with check ((select auth.uid()) = sender_id);
drop policy if exists community_requests_delete_related on public.community_friend_requests;
create policy community_requests_delete_related on public.community_friend_requests
  for delete to authenticated using ((select auth.uid()) in (sender_id, receiver_id));

drop policy if exists community_friendships_read_member on public.community_friendships;
create policy community_friendships_read_member on public.community_friendships
  for select to authenticated using ((select auth.uid()) in (user_a, user_b));

drop policy if exists community_notifications_read_recipient on public.community_notifications;
create policy community_notifications_read_recipient on public.community_notifications
  for select to authenticated using ((select auth.uid()) = recipient_id);
drop policy if exists community_notifications_update_recipient on public.community_notifications;
create policy community_notifications_update_recipient on public.community_notifications
  for update to authenticated using ((select auth.uid()) = recipient_id)
  with check ((select auth.uid()) = recipient_id);

revoke all on public.community_profiles, public.community_sessions,
  public.community_friend_requests, public.community_friendships,
  public.community_notifications, public.community_daily_totals from anon, public, authenticated;
grant select, insert, update on public.community_profiles to authenticated;
grant select, insert, update on public.community_daily_totals to authenticated;
grant select, insert, update on public.community_sessions to authenticated;
grant select, insert, delete on public.community_friend_requests to authenticated;
grant select on public.community_friendships to authenticated;
grant select, update on public.community_notifications to authenticated;
grant usage, select on sequence public.community_sessions_id_seq to authenticated;
grant usage, select on sequence public.community_friend_requests_id_seq to authenticated;
grant usage, select on sequence public.community_notifications_id_seq to authenticated;

create or replace function public.community_platform_stats()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with today as (
    select (now() at time zone 'America/Sao_Paulo')::date as day
  ),
  days as (
    select (today.day - n)::date as day
    from today cross join generate_series(6, 0, -1) as n
  ),
  totals as (
    select t.study_date as day,
           t.user_id,
           sum(t.minutes)::integer as minutes
    from public.community_daily_totals t
    cross join today
    where t.study_date between today.day - 6 and today.day
    group by 1,2
  ),
  daily_avg as (
    select d.day,
           case when (select count(*) from public.community_profiles) = 0 then 0
                else round(coalesce(sum(t.minutes),0)::numeric /
                     (select count(*) from public.community_profiles))::integer end as minutes
    from days d left join totals t using(day)
    group by d.day
  ),
  periods as (
    select case
      when extract(hour from (s.started_at at time zone 'America/Sao_Paulo')) < 6 then 0
      when extract(hour from (s.started_at at time zone 'America/Sao_Paulo')) < 12 then 1
      when extract(hour from (s.started_at at time zone 'America/Sao_Paulo')) < 18 then 2
      else 3 end as period,
      sum(s.minutes)::numeric as minutes
    from public.community_sessions s
    cross join today
    where (s.started_at at time zone 'America/Sao_Paulo')::date between today.day - 6 and today.day
    group by 1
  ),
  period_sum as (select coalesce(sum(minutes), 0) as total from periods)
  select jsonb_build_object(
    'days', coalesce((select jsonb_agg(coalesce(t.minutes,0) order by d.day)
      from days d left join daily_avg t using(day)), '[]'::jsonb),
    'periods', coalesce((select jsonb_agg(
      case when ps.total = 0 then 0 else round(100 * coalesce(p.minutes,0) / ps.total)::integer end
      order by x.period)
      from (select generate_series(0,3) as period) x
      cross join period_sum ps left join periods p using(period)), '[0,0,0,0]'::jsonb)
  );
$$;

create or replace function public.community_respond_request(p_request_id bigint, p_accept boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  req public.community_friend_requests%rowtype;
  a uuid;
  b uuid;
begin
  select * into req
  from public.community_friend_requests
  where id = p_request_id and receiver_id = auth.uid()
  for update;
  if not found then raise exception 'Pedido não encontrado ou não pertence a esta conta.'; end if;

  if p_accept then
    a := least(req.sender_id, req.receiver_id);
    b := greatest(req.sender_id, req.receiver_id);
    insert into public.community_friendships(user_a,user_b)
    values(a,b) on conflict do nothing;
    insert into public.community_notifications(recipient_id,sender_id,kind)
    values(req.sender_id,req.receiver_id,'friend_accepted');
  end if;
  delete from public.community_friend_requests where id = req.id;
end;
$$;

create or replace function public.community_remove_friend(p_friend_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare a uuid; b uuid;
begin
  if p_friend_id = auth.uid() then raise exception 'Operação inválida.'; end if;
  a := least(auth.uid(), p_friend_id);
  b := greatest(auth.uid(), p_friend_id);
  delete from public.community_friendships where user_a=a and user_b=b;
end;
$$;

create or replace function public.community_send_cheer(p_friend_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare a uuid; b uuid;
begin
  if p_friend_id = auth.uid() then raise exception 'Operação inválida.'; end if;
  a := least(auth.uid(), p_friend_id);
  b := greatest(auth.uid(), p_friend_id);
  if not exists(select 1 from public.community_friendships where user_a=a and user_b=b) then
    raise exception 'Vocês não são amigos.';
  end if;
  insert into public.community_notifications(recipient_id,sender_id,kind)
  values(p_friend_id,auth.uid(),'cheer');
end;
$$;

revoke all on function public.community_platform_stats() from public, anon;
revoke all on function public.community_respond_request(bigint,boolean) from public, anon;
revoke all on function public.community_remove_friend(uuid) from public, anon;
revoke all on function public.community_send_cheer(uuid) from public, anon;
grant execute on function public.community_platform_stats() to authenticated;
grant execute on function public.community_respond_request(bigint,boolean) to authenticated;
grant execute on function public.community_remove_friend(uuid) to authenticated;
grant execute on function public.community_send_cheer(uuid) to authenticated;

-- A tabela estudos continua privada: a Comunidade só recebe métricas públicas resumidas.
