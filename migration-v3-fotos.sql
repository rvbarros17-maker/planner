-- ============================================================
-- MIGRAÇÃO v3: Fotos de evolução (upload + comparativo)
-- Rode isso no SQL Editor do Supabase
-- ============================================================

-- 1. Bucket privado de armazenamento das fotos
insert into storage.buckets (id, name, public)
values ('evolucao-fotos', 'evolucao-fotos', false)
on conflict (id) do nothing;

-- 2. Políticas do bucket — cada usuário só acessa a própria pasta
--    (as fotos são salvas em caminhos "uid/nome-do-arquivo.jpg")
create policy "select_own_fotos_storage" on storage.objects
  for select using (bucket_id = 'evolucao-fotos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "insert_own_fotos_storage" on storage.objects
  for insert with check (bucket_id = 'evolucao-fotos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "delete_own_fotos_storage" on storage.objects
  for delete using (bucket_id = 'evolucao-fotos' and (storage.foldername(name))[1] = auth.uid()::text);

-- 3. Tabela de metadados (data, ângulo, caminho do arquivo)
create table if not exists fotos_evolucao (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  data date not null,
  angulo text not null,
  storage_path text not null,
  created_at timestamptz default now()
);
alter table fotos_evolucao enable row level security;

create policy "select_own_fotos_evolucao" on fotos_evolucao for select using (auth.uid() = user_id);
create policy "insert_own_fotos_evolucao" on fotos_evolucao for insert with check (auth.uid() = user_id);
create policy "update_own_fotos_evolucao" on fotos_evolucao for update using (auth.uid() = user_id);
create policy "delete_own_fotos_evolucao" on fotos_evolucao for delete using (auth.uid() = user_id);

-- ============================================================
-- Pronto! As fotos ficam em bucket privado, só o dono acessa
-- (mesmo o link direto do arquivo não funciona sem estar logado).
-- ============================================================
