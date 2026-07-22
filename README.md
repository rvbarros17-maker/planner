# Plano Mestre de Recuperação Capilar — App

App pessoal (PWA) para acompanhar o tratamento capilar: medicamentos, microagulhamento,
fórmula manipulada, calendário, evolução mensal e financeiro. Dados sincronizados via Supabase,
protegidos por login, instalável no celular como app.

## Estrutura

```
planner-app/
├── index.html          → app inteiro (HTML + CSS + JS, sem build step)
├── manifest.json        → configuração do PWA
├── sw.js                 → service worker (cache offline básico)
└── icons/
    ├── icon-192.png
    ├── icon-512.png
    └── apple-touch-icon.png
```

## Passo 1 — Criar o projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) → New Project.
2. Depois de criado, vá em **SQL Editor** e rode o conteúdo do arquivo `supabase-schema.sql`
   (está na pasta ao lado desse README). Isso cria todas as tabelas com
   RLS (cada usuário só vê os próprios dados).
3. Rode também `migration-v2.sql` (protocolo com shampoo + fórmula em frequência livre)
   e `migration-v3-fotos.sql` (upload de fotos de evolução + comparativo), nessa ordem.
4. Vá em **Authentication → Providers** e confirme que "Email" está habilitado.
5. (Recomendado, já que é uso pessoal) Em **Authentication → Settings**, desabilite
   *"Confirm email"* para não precisar clicar em link de confirmação toda vez que criar a conta.
6. Vá em **Project Settings → API** e copie:
   - `Project URL`
   - `anon public key` (ou, no novo formato, a `publishable key`)

## Passo 2 — Conectar o app ao Supabase

Abra `index.html`, procure este trecho (perto do topo do `<script type="module">`):

```js
const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
const SUPABASE_ANON_KEY = 'SUA-ANON-KEY-AQUI';
```

Substitua pelos valores que você copiou no passo anterior. A `anon key` é segura para
ficar exposta no client — é assim que o Supabase funciona por padrão (a segurança real
está nas policies de RLS que já estão no schema).

## Passo 3 — Testar localmente (opcional)

Qualquer servidor estático funciona, por exemplo:

```bash
npx serve planner-app
```

## Passo 4 — Deploy no Vercel

Igual você já faz com Totaliz/SigmaPEP:

```bash
cd planner-app
vercel --prod
```

Ou, se preferir, conecte a pasta a um repositório Git e importe no painel da Vercel.
Como é só HTML/CSS/JS estático, não precisa configurar build command nem output directory.

## Passo 5 — Instalar no celular

Depois do deploy, abra o link no navegador do celular:

- **Android (Chrome):** toque no menu (⋮) → "Adicionar à tela inicial" / "Instalar app".
- **iPhone (Safari):** toque em Compartilhar → "Adicionar à Tela de Início".

O app abre em tela cheia, com ícone próprio, como se fosse nativo.

## Criando sua conta

Na primeira vez que abrir o app, use a tela de login para **criar conta** (e-mail + senha).
Esse é o único usuário — as tabelas já são protegidas por RLS para que só você acesse
seus próprios dados, mesmo que o link seja aberto por outra pessoa sem sua senha.

## Próximos passos possíveis

- Trocar `duration_days`/`start_hours` por notificações push reais (exigiria um pouco mais
  de infraestrutura — Supabase Edge Functions + Web Push).
- Adicionar upload de fotos de evolução usando o Supabase Storage (hoje o app guarda só o
  texto das observações, as fotos ficam no seu dispositivo).
