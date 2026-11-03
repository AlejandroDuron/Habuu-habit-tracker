-- ============================================================================
-- Habuu: esquema de base de datos (Supabase / PostgreSQL)
-- Ejecutar completo en: Supabase, luego SQL Editor, luego New query y luego Run.
-- Contenido, en orden:
--   1. Tipos enum
--   2. Tablas
--   3. Índices
--   4. Vista y función de racha
--   5. RLS (Row Level Security)
--   6. Datos iniciales en categorías y trofeos son necesarios para que la app funcione
-- ============================================================================

begin;
-- ENUM

do $$ begin
  create type public.habit_type as enum ('one_time', 'recurring');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.habit_frequency as enum ('weekly', 'monthly');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.log_status as enum ('completed', 'skipped', 'missed');
exception when duplicate_object then null; end $$;

-- 2. TABLAS

-- Categorías. user_id null = categoría predeterminada (visible para todos).
create table if not exists public.categories (
  category_id   uuid not null default gen_random_uuid(),
  category_name text not null,
  user_id       uuid null,
  constraint categories_pkey primary key (category_id),
  constraint categories_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade
);

create table if not exists public.habits (
  habit_id      uuid not null default gen_random_uuid(),
  user_id       uuid not null,
  category_id   uuid not null,
  icon_key      text not null,
  habit_name    text not null,
  color         text null,
  type          public.habit_type not null,
  frequency     public.habit_frequency null,
  days_of_week  smallint[] null,
  day_of_month  smallint null,
  goal          text null,
  goal_per_day  smallint not null default 1,
  allow_skip    boolean not null default false,
  created_date  date not null,
  created_at    timestamptz not null default now(),
  deleted_at    timestamptz null,
  constraint habits_pkey primary key (habit_id),
  constraint habits_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade,
  constraint habits_category_id_fkey
    foreign key (category_id) references public.categories (category_id),
  constraint chk_goal_per_day check (goal_per_day between 1 and 99),
  constraint chk_day_of_month check (
    day_of_month is null or (day_of_month >= 1 and day_of_month <= 31)
  ),
  constraint chk_days_valid check (
    days_of_week is null
    or days_of_week <@ array[1,2,3,4,5,6,7]::smallint[]
  ),
  constraint chk_schedule check (
    (type = 'one_time'
      and frequency is null
      and days_of_week is null
      and day_of_month is null)
    or
    (type = 'recurring'
      and frequency = 'weekly'
      and coalesce(cardinality(days_of_week), 0) >= 1
      and day_of_month is null)
    or
    (type = 'recurring'
      and frequency = 'monthly'
      and day_of_month is not null
      and days_of_week is null)
  )
);

create table if not exists public.habit_logs (
  habit_log_id  uuid not null default gen_random_uuid(),
  habit_id      uuid not null,
  log_date      date not null,
  status        public.log_status not null,
  evidence_path text null,
  constraint habit_logs_pkey primary key (habit_log_id),
  constraint uq_habit_logs_habit_date unique (habit_id, log_date),
  constraint habit_logs_habit_id_fkey
    foreign key (habit_id) references public.habits (habit_id) on delete cascade
);

create table if not exists public.reminders (
  reminder_id       uuid not null default gen_random_uuid(),
  habit_id          uuid not null,
  reminder_time     time without time zone not null,
  activate_reminder boolean not null default true,
  constraint reminders_pkey primary key (reminder_id),
  constraint reminders_habit_id_key unique (habit_id),
  constraint reminders_habit_id_fkey
    foreign key (habit_id) references public.habits (habit_id) on delete cascade
);

-- Catálogo de trofeos (igual para todos los usuarios).
create table if not exists public.trophies (
  trophy_id   text not null,
  trophy_name text not null,
  trophy_key  text null,
  constraint trophies_pkey primary key (trophy_id)
);

-- Trofeos ganados por cada usuario.
create table if not exists public.trophies_per_user (
  user_id   uuid not null,
  trophy_id text not null,
  earned_at timestamptz not null default now(),
  constraint trophies_per_user_pkey primary key (user_id, trophy_id),
  constraint trophies_per_user_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade,
  constraint trophies_per_user_trophy_id_fkey
    foreign key (trophy_id) references public.trophies (trophy_id) on delete cascade
);

-- Resumen por día: all_done = true cuando se completó todo lo programado.
create table if not exists public.daily_summaries (
  user_id      uuid not null,
  summary_date date not null,
  all_done     boolean not null default false,
  constraint daily_summaries_pkey primary key (user_id, summary_date),
  constraint daily_summaries_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade
);

-- ----------------------------------------------------------------------------
-- 3. ÍNDICES
-- ----------------------------------------------------------------------------

create index if not exists idx_habits_user_active
  on public.habits (user_id) where deleted_at is null;
create index if not exists idx_habits_category
  on public.habits (category_id);
create index if not exists idx_habits_icon
  on public.habits (icon_key);
create index if not exists idx_habit_logs_date
  on public.habit_logs (log_date);
create index if not exists idx_trophies_pu_user
  on public.trophies_per_user (user_id);

-- VISTA Y FUNCIÓN DE RACHA
-- Un día cuenta para la racha cuando daily_summaries.all_done = true.

create or replace view public.user_streak_days
with (security_invoker = true) as
select user_id, summary_date as log_date
from public.daily_summaries
where all_done;

-- Racha actual
create or replace function public.current_streak(
  p_today date default current_date,
  p_user  uuid default auth.uid()
)
returns int
language sql stable
as $$
  with days as (
    select log_date as d from public.user_streak_days where user_id = p_user
  ),
  grp as (
    select d, d - (row_number() over (order by d))::int as g from days
  ),
  runs as (
    select count(*) as n, max(d) as last_d from grp group by g
  )
  select coalesce(
    (select n from runs where last_d >= p_today - 1 order by last_d desc limit 1),
    0
  )::int;
$$;

-- ROW LEVEL SECURITY

alter table public.categories        enable row level security;
alter table public.habits            enable row level security;
alter table public.habit_logs        enable row level security;
alter table public.reminders         enable row level security;
alter table public.trophies          enable row level security;
alter table public.trophies_per_user enable row level security;
alter table public.daily_summaries   enable row level security;

-- categories: las predeterminadas (user_id null) las ven todos y nadie las
-- modifica desde la app; las propias solo las ve y edita su dueño.
drop policy if exists "categories_select" on public.categories;
create policy "categories_select" on public.categories
  for select to authenticated
  using (user_id is null or user_id = auth.uid());

drop policy if exists "categories_insert" on public.categories;
create policy "categories_insert" on public.categories
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "categories_update" on public.categories;
create policy "categories_update" on public.categories
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "categories_delete" on public.categories;
create policy "categories_delete" on public.categories
  for delete to authenticated
  using (user_id = auth.uid());

-- habits: solo el dueño.
drop policy if exists "habits_owner_all" on public.habits;
create policy "habits_owner_all" on public.habits
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- habit_logs: solo si el hábito pertenece al usuario.
drop policy if exists "habit_logs_owner_all" on public.habit_logs;
create policy "habit_logs_owner_all" on public.habit_logs
  for all to authenticated
  using (exists (
    select 1 from public.habits h
    where h.habit_id = habit_logs.habit_id and h.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.habits h
    where h.habit_id = habit_logs.habit_id and h.user_id = auth.uid()
  ));

-- reminders: igual que habit_logs.
drop policy if exists "reminders_owner_all" on public.reminders;
create policy "reminders_owner_all" on public.reminders
  for all to authenticated
  using (exists (
    select 1 from public.habits h
    where h.habit_id = reminders.habit_id and h.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.habits h
    where h.habit_id = reminders.habit_id and h.user_id = auth.uid()
  ));

-- trophies: catálogo de solo lectura.
drop policy if exists "trophies_select" on public.trophies;
create policy "trophies_select" on public.trophies
  for select to authenticated
  using (true);

-- trophies_per_user: cada usuario ve y registra solo los suyos.
drop policy if exists "trophies_per_user_select" on public.trophies_per_user;
create policy "trophies_per_user_select" on public.trophies_per_user
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists "trophies_per_user_insert" on public.trophies_per_user;
create policy "trophies_per_user_insert" on public.trophies_per_user
  for insert to authenticated
  with check (user_id = auth.uid());

-- daily_summaries: solo el dueño.
drop policy if exists "daily_summaries_owner_all" on public.daily_summaries;
create policy "daily_summaries_owner_all" on public.daily_summaries
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- DATOS INICIALES
insert into public.categories (category_name, user_id)
select v.name, null
from (values ('Hogar'), ('Salud'), ('Universidad'), ('Mascota')) as v(name)
where not exists (
  select 1 from public.categories c
  where c.user_id is null and c.category_name = v.name
);

-- trofeos.
insert into public.trophies (trophy_id, trophy_name, trophy_key) values
  ('day_completed', 'Día completado',   'day_completed'),
  ('discipline',    'Disciplina',       'discipline'),
  ('new_habits',    'Hábitos nuevos',   'new_habits'),
  ('one_month',     '1+ mes con Habuu', 'one_month'),
  ('streak_14',     '14+ rachas',       'streak_14'),
  ('streak_300',    '300 rachas',       'streak_300'),
  ('streak_7',      '7 días de racha',  'streak_7')
on conflict (trophy_id) do update
  set trophy_name = excluded.trophy_name,
      trophy_key  = excluded.trophy_key;

commit;