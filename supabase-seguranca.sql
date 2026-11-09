-- Meu App Estudos: proteção da tabela de dados pessoais
-- Execute este arquivo no Supabase > SQL Editor > New query.
-- A tabela guarda um único documento JSON por usuário autenticado.

create table if not exists public.estudos (
  id uuid primary key references auth.users(id) on delete cascade,
  dados jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

alter table public.estudos
  add column if not exists dados jsonb not null default '{}'::jsonb;

alter table public.estudos
  add column if not exists atualizado_em timestamptz not null default now();

alter table public.estudos enable row level security;

-- Remove políticas antigas desta tabela para impedir que uma regra permissiva
-- antiga continue liberando leitura ou escrita entre usuários.
do $$
declare
  p record;
begin
  for p in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'estudos'
  loop
    execute format('drop policy if exists %I on public.estudos', p.policyname);
  end loop;
end
$$;

revoke all on table public.estudos from anon;
revoke all on table public.estudos from public;
grant select, insert, update on table public.estudos to authenticated;

create policy estudos_select_own
  on public.estudos for select
  to authenticated
  using (id::text = auth.uid()::text);

create policy estudos_insert_own
  on public.estudos for insert
  to authenticated
  with check (id::text = auth.uid()::text);

create policy estudos_update_own
  on public.estudos for update
  to authenticated
  using (id::text = auth.uid()::text)
  with check (id::text = auth.uid()::text);

-- Não é concedido DELETE ao navegador. A chave service_role nunca deve ser
-- colocada no HTML ou compartilhada publicamente.
