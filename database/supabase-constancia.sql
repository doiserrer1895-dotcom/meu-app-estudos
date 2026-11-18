-- Meu App Estudos — sincronização da área Constância por conta.
-- Execute no Supabase > SQL Editor. Este bloco cria somente a tabela nova
-- e suas permissões; não apaga nem altera os dados das tabelas existentes.

create table if not exists public.constancia_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.constancia_data enable row level security;

drop policy if exists constancia_data_read_own on public.constancia_data;
create policy constancia_data_read_own
  on public.constancia_data for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists constancia_data_insert_own on public.constancia_data;
create policy constancia_data_insert_own
  on public.constancia_data for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists constancia_data_update_own on public.constancia_data;
create policy constancia_data_update_own
  on public.constancia_data for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.constancia_data from anon, public, authenticated;
grant select, insert, update on public.constancia_data to authenticated;

-- Não há política de DELETE: a aplicação não pode apagar a cópia da conta.
