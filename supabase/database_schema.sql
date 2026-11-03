-- Habuu: esquema de base de datos
-- Ejecutar en: Supabase -> SQL Editor -> New query -> Run

begin;

-- 1. ENUMS

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

-- user_id null = categoria predeterminada visible para todos
create table if not exists public.categories (
  category_id   uuid not null default gen_random_uuid(),
  category_name text not null,
  user_id       uuid null,
  constraint categories_pkey primary key (category_id),
  constraint categories_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade
);

create table if not exists public.habits (
  habit_id      uuid    not null default gen_random_uuid(),
  user_id       uuid    not null default auth.uid(),
  category_id   uuid    not null,
  icon_key      text    not null,
  habit_name    text    not null,
  color         text    null,
  type          public.habit_type not null,
  frequency     public.habit_frequency null,
  days_of_week  smallint[] null,
  day_of_month  smallint null,
  goal          text    null,
  goal_per_day  smallint not null default 1,
  allow_skip    boolean  not null default false,
  created_date  date     not null,
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

-- un recordatorio por habito
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

-- catalogo de trofeos, igual para todos los usuarios
create table if not exists public.trophies (
  trophy_id   text not null,
  trophy_name text not null,
  trophy_key  text null,
  constraint trophies_pkey primary key (trophy_id)
);

create table if not exists public.trophies_per_user (
  user_id   uuid not null default auth.uid(),
  trophy_id text not null,
  earned_at timestamptz not null default now(),
  constraint trophies_per_user_pkey primary key (user_id, trophy_id),
  constraint trophies_per_user_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade,
  constraint trophies_per_user_trophy_id_fkey
    foreign key (trophy_id) references public.trophies (trophy_id) on delete cascade
);

-- all_done = true cuando se completaron todos los habitos del dia
create table if not exists public.daily_summaries (
  user_id      uuid not null default auth.uid(),
  summary_date date not null,
  all_done     boolean not null default false,
  constraint daily_summaries_pkey primary key (user_id, summary_date),
  constraint daily_summaries_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade
);

-- cuantas verificaciones por foto hizo el usuario ese dia
create table if not exists public.verification_usage (
  user_id    uuid    not null default auth.uid(),
  usage_date date    not null default current_date,
  count      integer not null default 0,
  constraint verification_usage_pkey primary key (user_id, usage_date),
  constraint verification_usage_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade,
  constraint chk_count_positive check (count >= 0)
);

-- 3. INDICES

create index if not exists idx_habits_user_active
  on public.habits (user_id) where deleted_at is null;
create index if not exists idx_habits_category
  on public.habits (category_id);
create index if not exists idx_habit_logs_date
  on public.habit_logs (log_date);
create index if not exists idx_trophies_pu_user
  on public.trophies_per_user (user_id);

-- 4. VISTA Y FUNCION DE RACHA

create or replace view public.user_streak_days
with (security_invoker = true) as
select user_id, summary_date as log_date
from public.daily_summaries
where all_done;

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

-- 5. ROW LEVEL SECURITY

alter table public.categories         enable row level security;
alter table public.habits             enable row level security;
alter table public.habit_logs         enable row level security;
alter table public.reminders          enable row level security;
alter table public.trophies           enable row level security;
alter table public.trophies_per_user  enable row level security;
alter table public.daily_summaries    enable row level security;
alter table public.verification_usage enable row level security;

-- limpia politicas anteriores (nombres viejos y nuevos)

drop policy if exists "Delete categories"  on public.categories;
drop policy if exists "Insert categories"  on public.categories;
drop policy if exists "Update categories"  on public.categories;
drop policy if exists "View categories"    on public.categories;
drop policy if exists "categories_select"  on public.categories;
drop policy if exists "categories_insert"  on public.categories;
drop policy if exists "categories_update"  on public.categories;
drop policy if exists "categories_delete"  on public.categories;

drop policy if exists "habits_all_own"    on public.habits;
drop policy if exists "habits_owner_all"  on public.habits;

drop policy if exists "habit_logs_all_own"   on public.habit_logs;
drop policy if exists "habit_logs_owner_all" on public.habit_logs;

drop policy if exists "reminders_all_own"   on public.reminders;
drop policy if exists "reminders_owner_all" on public.reminders;

drop policy if exists "trophies_select" on public.trophies;

drop policy if exists "trophies_per_user_select_own" on public.trophies_per_user;
drop policy if exists "trophies_per_user_select"     on public.trophies_per_user;
drop policy if exists "trophies_per_user_insert"     on public.trophies_per_user;

drop policy if exists "daily_summaries: usuario solo actualiza los suyos" on public.daily_summaries;
drop policy if exists "daily_summaries: usuario solo escribe los suyos"   on public.daily_summaries;
drop policy if exists "daily_summaries: usuario solo ve los suyos"        on public.daily_summaries;
drop policy if exists "daily_summaries_owner_all"                         on public.daily_summaries;

drop policy if exists "verification_usage_owner_all" on public.verification_usage;

-- politicas definitivas

-- categorias predeterminadas (user_id null) las ven todos; las propias solo su dueno
create policy "categories_select" on public.categories
  for select to authenticated
  using (user_id is null or user_id = auth.uid());

create policy "categories_insert" on public.categories
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "categories_update" on public.categories
  for update to authenticated
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "categories_delete" on public.categories
  for delete to authenticated
  using (user_id = auth.uid());

create policy "habits_owner_all" on public.habits
  for all to authenticated
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

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

-- solo lectura para todos los autenticados
create policy "trophies_select" on public.trophies
  for select to authenticated
  using (true);

-- user_id no se envia en el insert; Supabase lo pone con DEFAULT auth.uid()
create policy "trophies_per_user_select" on public.trophies_per_user
  for select to authenticated
  using (user_id = auth.uid());

create policy "trophies_per_user_insert" on public.trophies_per_user
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "daily_summaries_owner_all" on public.daily_summaries
  for all to authenticated
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "verification_usage_owner_all" on public.verification_usage
  for all to authenticated
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

-- 6. DATOS INICIALES

insert into public.categories (category_name, user_id)
select v.name, null
from (values ('Hogar'), ('Salud'), ('Universidad'), ('Mascota')) as v(name)
where not exists (
  select 1 from public.categories c
  where c.user_id is null and c.category_name = v.name
);

insert into public.trophies (trophy_id, trophy_name, trophy_key) values
  ('day_completed', 'Dia completado',   'day_completed'),
  ('discipline',    'Disciplina',       'discipline'),
  ('new_habits',    'Habitos nuevos',   'new_habits'),
  ('one_month',     '1 mes con Habuu',  'one_month'),
  ('streak_14',     '14 dias de racha', 'streak_14'),
  ('streak_300',    '300 dias',         'streak_300'),
  ('streak_7',      '7 dias de racha',  'streak_7')
on conflict (trophy_id) do update
  set trophy_name = excluded.trophy_name,
      trophy_key  = excluded.trophy_key;

commit;
