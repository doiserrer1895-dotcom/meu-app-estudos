-- Meu App Estudos — segurança e cópias diárias por usuário
-- Estado aplicado ao projeto Supabase MeuAppEstudos em 09/11/2026.
-- Não inclui chaves secret/service_role.

create table if not exists public.estudos_backups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  backup_date date not null,
  backup_type text not null default 'daily' check (backup_type in ('daily','manual')),
  dados jsonb not null,
  atualizado_em timestamptz,
  created_at timestamptz not null default now(),
  constraint estudos_backups_user_day_type_unique unique (user_id, backup_date, backup_type)
);

alter table public.estudos enable row level security;
alter table public.estudos_backups enable row level security;

-- Política existente de estudos, otimizada para auth.uid().
alter policy "Acesso aos próprios estudos"
  on public.estudos
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- A tabela principal só permite ler/criar/atualizar a própria linha.
revoke all on table public.estudos from anon, public, authenticated;
grant select, insert, update on table public.estudos to authenticated;

-- Cópias: usuário só pode ler e inserir as próprias; não pode editar ou apagar.
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

-- Cópia inicial da linha existente, sem sobrescrever cópia já existente.
insert into public.estudos_backups (user_id, backup_date, dados, atualizado_em)
select id, (now() at time zone 'UTC')::date, dados, atualizado_em
from public.estudos
on conflict (user_id, backup_date, backup_type) do nothing;

-- Antes da primeira alteração do dia, guarda o estado anterior.
create or replace function public.capture_estudos_daily_backup()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  insert into public.estudos_backups (user_id, backup_date, dados, atualizado_em)
  values (old.id, (now() at time zone 'UTC')::date, old.dados, old.atualizado_em)
  on conflict (user_id, backup_date) do nothing;
  return new;
end;
$$;

revoke all on function public.capture_estudos_daily_backup() from public, anon, authenticated;
drop trigger if exists estudos_daily_backup_before_update on public.estudos;
create trigger estudos_daily_backup_before_update
  before update on public.estudos
  for each row
  execute function public.capture_estudos_daily_backup();

-- Importante: esta cópia está no mesmo projeto Supabase.
-- Baixe também cópias externas pelo botão "Cópia nuvem" no aplicativo.
