-- Correção pontual da média da plataforma: exclui o usuário autenticado.
-- Execute este arquivo uma vez no Supabase > SQL Editor.
-- Não altera dados existentes nem mexe nas métricas pessoais.
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
      and t.user_id <> (select auth.uid())
    group by 1,2
  ),
  other_users as (
    select count(*)::integer as total
    from public.community_profiles
    where user_id <> (select auth.uid())
  ),
  daily_avg as (
    select d.day,
           case when (select total from other_users) = 0 then 0
                else round(coalesce(sum(t.minutes),0)::numeric /
                     (select total from other_users))::integer end as minutes
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
      and s.user_id <> (select auth.uid())
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

revoke all on function public.community_platform_stats() from public, anon;
grant execute on function public.community_platform_stats() to authenticated;
