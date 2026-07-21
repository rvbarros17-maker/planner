-- ============================================================
-- MIGRAÇÃO: Protocolo Capilar v2 (AAG + Oleosidade + Microagulhamento)
-- Rode isso no SQL Editor do Supabase (projeto já existente)
-- ============================================================

-- 1. Nova tabela: rotina semanal de shampoos
create table if not exists shampoo_config (
  user_id uuid primary key references auth.users(id) on delete cascade,
  schedule jsonb default '{"0":"Vichy Dercos Energizante","1":"Vichy Dercos Energizante","2":"Alpecin C1","3":"Cetoconazol 2%","4":"Vichy Dercos Energizante","5":"Alpecin C1","6":"Cetoconazol 2%"}'
  -- chave = dia da semana (0=domingo ... 6=sábado), valor = nome do shampoo (vazio "" = sem lavagem)
);
alter table shampoo_config enable row level security;
create policy "select_own_shampoo_config" on shampoo_config for select using (auth.uid() = user_id);
create policy "insert_own_shampoo_config" on shampoo_config for insert with check (auth.uid() = user_id);
create policy "update_own_shampoo_config" on shampoo_config for update using (auth.uid() = user_id);
create policy "delete_own_shampoo_config" on shampoo_config for delete using (auth.uid() = user_id);

-- 2. daily_log ganha registro de shampoo do dia
alter table daily_log add column if not exists shampoo_taken boolean default false;

-- 3. formula_config: sai o modelo de "ciclo pós-procedimento fixo",
--    entra frequência semanal livre + pausa em horas ao redor do microagulhamento
alter table formula_config add column if not exists freq_min int default 2;
alter table formula_config add column if not exists freq_max int default 3;
-- start_hours já existe e passa a significar "horas de pausa após o microagulhamento"
-- duration_days não é mais usado (pode ficar na tabela sem problema, ou remover com o comando abaixo)
alter table formula_config drop column if exists duration_days;

-- 4. formula_activations não é mais necessária (a pausa agora é calculada
--    automaticamente a partir das sessões de microagulhamento). Pode remover:
drop table if exists formula_activations;

-- ============================================================
-- Pronto! Depois de rodar isso, atualize o index.html com a nova versão.
-- ============================================================
