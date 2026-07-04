-- ============================================================
-- SCHEMA: Plano Mestre de Recuperação Capilar
-- Rode isso no SQL Editor do seu projeto Supabase
-- ============================================================

-- Extensão para gerar UUIDs (geralmente já vem habilitada no Supabase)
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 1. Configuração geral do usuário (capa do planner)
-- ------------------------------------------------------------
create table if not exists user_config (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nome text default 'Rafael',
  data_inicio date default current_date,
  meta text default '',
  updated_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 2. Medicamentos configurados (nome, dose, horário)
-- ------------------------------------------------------------
create table if not exists meds (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  nome text not null,
  dose text default '',
  horario text default '08:00',
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 3. Configuração do microagulhamento
-- ------------------------------------------------------------
create table if not exists micro_config (
  user_id uuid primary key references auth.users(id) on delete cascade,
  intervalo_dias int default 15,
  last_date date
);

-- ------------------------------------------------------------
-- 4. Sessões de microagulhamento (histórico)
-- ------------------------------------------------------------
create table if not exists micro_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  date date not null,
  checklist_antes jsonb default '[]',
  checklist_depois jsonb default '[]',
  notes text default '',
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 5. Configuração da fórmula manipulada
-- ------------------------------------------------------------
create table if not exists formula_config (
  user_id uuid primary key references auth.users(id) on delete cascade,
  composicao text default '',
  start_hours int default 24,
  duration_days int default 4
);

-- ------------------------------------------------------------
-- 6. Ciclos de ativação da fórmula
-- ------------------------------------------------------------
create table if not exists formula_activations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  ref_date date not null,
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 7. Log diário (checklist de comprimidos/fórmula por dia)
-- ------------------------------------------------------------
create table if not exists daily_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  date date not null,
  meds_status jsonb default '{}',   -- {"<med_id>": true/false}
  formula_taken boolean default false,
  nota text default '',
  unique (user_id, date)
);

-- ------------------------------------------------------------
-- 8. Evolução mensal
-- ------------------------------------------------------------
create table if not exists evolucao (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  mes text not null,
  queda int,
  espessura int,
  obs text default '',
  created_at timestamptz default now()
);

-- ------------------------------------------------------------
-- 9. Controle financeiro
-- ------------------------------------------------------------
create table if not exists financeiro (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  data date not null,
  categoria text default 'Outro',
  descricao text default '',
  valor numeric(10,2) default 0,
  created_at timestamptz default now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- Cada usuário só enxerga e mexe nos próprios dados
-- ============================================================
alter table user_config enable row level security;
alter table meds enable row level security;
alter table micro_config enable row level security;
alter table micro_sessions enable row level security;
alter table formula_config enable row level security;
alter table formula_activations enable row level security;
alter table daily_log enable row level security;
alter table evolucao enable row level security;
alter table financeiro enable row level security;

-- Policy genérica reaproveitada para cada tabela (select/insert/update/delete)
do $$
declare
  t text;
begin
  foreach t in array array['user_config','meds','micro_config','micro_sessions','formula_config','formula_activations','daily_log','evolucao','financeiro']
  loop
    execute format('
      create policy "select_own_%1$s" on %1$s
        for select using (auth.uid() = user_id);
      create policy "insert_own_%1$s" on %1$s
        for insert with check (auth.uid() = user_id);
      create policy "update_own_%1$s" on %1$s
        for update using (auth.uid() = user_id);
      create policy "delete_own_%1$s" on %1$s
        for delete using (auth.uid() = user_id);
    ', t);
  end loop;
end $$;

-- ============================================================
-- Pronto! Depois de rodar isso:
-- 1. Vá em Authentication > Providers e habilite "Email"
-- 2. (Opcional) Desabilite "Confirm email" em Authentication > Settings
--    para não precisar clicar em link de confirmação toda vez
-- 3. Pegue sua URL e anon key em Project Settings > API
-- ============================================================
