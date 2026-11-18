-- Meu App Estudos — segurança e cópias de segurança por usuário.
-- Referência do esquema aplicado no Supabase MeuAppEstudos.
-- Nunca coloque sb_secret_ ou service_role no código do navegador.

create table if not exists public.estudos_backups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  backup_date date not null,
  backup_type text not null default 'daily',
  dados jsonb not null,
  atualizado_em timestamptz,
  created_at timestamptz not null default now()
);

alter table public.estudos_backups
  add column if not exists backup_type text not null default 'daily';

alter table public.estudos_backups
  drop constraint if exists estudos_backups_user_day_unique;
alter table public.estudos_backups
  drop constraint if exists estudos_backups_user_day_type_unique;
drop index if exists public.estudos_backups_user_day_type_unique;

alter table public.estudos_backups
  drop constraint if exists estudos_backups_backup_type_check;
alter table public.estudos_backups
  add constraint estudos_backups_backup_type_check
  check (backup_type in ('daily','manual'));

-- Apenas uma cópia automática diária por conta. Cópias manuais podem ser várias.
create unique index if not exists estudos_backups_one_daily_per_user_day
  on public.estudos_backups (user_id, backup_date)
  where backup_type = 'daily';

alter table public.estudos enable row level security;
alter table public.estudos_backups enable row level security;

-- Cada usuário só enxerga/altera sua própria linha de estudos.
alter policy "Acesso aos próprios estudos"
  on public.estudos
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

revoke all on table public.estudos from anon, public, authenticated;
grant select, insert, update on table public.estudos to authenticated;

-- Backups são privados, só podem ser lidos/criados pelo próprio usuário.
revoke all on table public.estudos_backups from anon, public, authenticated;
grant select, insert on table public.estudos_backups to authenticated;

drop policy if exists estudos_backups_select_own on public.estudos_backups;
create policy estudos_backups_select_own
  on public.estudos_backups for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists estudos_backups_insert_own on public.estudos_backups;
create policy estudos_backups_insert_own
  on public.estudos_backups for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

-- Preserva uma cópia inicial dos dados existentes.
insert into public.estudos_backups (user_id, backup_date, backup_type, dados, atualizado_em)
select id, (now() at time zone 'UTC')::date, 'daily', dados, atualizado_em
from public.estudos
on conflict (user_id, backup_date) where backup_type = 'daily' do nothing;

-- Antes da primeira alteração do dia, guarda o estado anterior.
create or replace function public.capture_estudos_daily_backup()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  insert into public.estudos_backups (user_id, backup_date, backup_type, dados, atualizado_em)
  values (old.id, (now() at time zone 'UTC')::date, 'daily', old.dados, old.atualizado_em)
  on conflict (user_id, backup_date) where backup_type = 'daily' do nothing;
  return new;
end;
$$;

revoke all on function public.capture_estudos_daily_backup() from public, anon, authenticated;
drop trigger if exists estudos_daily_backup_before_update on public.estudos;
create trigger estudos_daily_backup_before_update
  before update on public.estudos
  for each row
  execute function public.capture_estudos_daily_backup();

-- As cópias dentro do Supabase não substituem cópias externas.
-- Use "Cópia nuvem" para baixar uma cópia JSON fora do projeto.
