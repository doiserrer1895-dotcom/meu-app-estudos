-- Correção pontual para quem já executou supabase-comunidade.sql antes desta atualização.
-- Execute este bloco no Supabase > SQL Editor.
-- Cada usuário poderá sincronizar e ler somente os próprios totais diários.

drop policy if exists community_daily_totals_read_own on public.community_daily_totals;
create policy community_daily_totals_read_own on public.community_daily_totals
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists community_daily_totals_insert_own on public.community_daily_totals;
create policy community_daily_totals_insert_own on public.community_daily_totals
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists community_daily_totals_update_own on public.community_daily_totals;
create policy community_daily_totals_update_own on public.community_daily_totals
  for update to authenticated using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
