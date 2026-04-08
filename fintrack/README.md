# FinTrack — Advisory Financeiro Pessoal
**Sistema completo de gestão financeira com IA, Supabase e WhatsApp**

---

## 🚀 Como colocar no ar (passo a passo)

### PASSO 1 — Crie sua conta Supabase (gratuito)

1. Acesse **https://supabase.com** e clique em "Start for free"
2. Faça login com GitHub ou e-mail
3. Clique em **"New Project"**
4. Escolha um nome (ex: `fintrack`) e uma senha forte
5. Selecione a região **South America (São Paulo)**
6. Aguarde 2 minutos o projeto subir

### PASSO 2 — Configure o banco de dados

1. No painel do Supabase, clique em **"SQL Editor"** no menu lateral
2. Clique em **"New query"**
3. Copie **todo o conteúdo** do arquivo `supabase_schema.sql`
4. Cole no editor e clique em **"Run"**
5. Você verá as tabelas criadas na seção **"Table Editor"**

### PASSO 3 — Pegue suas credenciais Supabase

1. Vá em **Settings → API**
2. Copie a **"Project URL"** (ex: `https://xxxxx.supabase.co`)
3. Copie a **"anon public"** key (começa com `eyJ...`)
4. Guarde esses dois valores — você vai precisar deles no app

### PASSO 4 — Obtenha a chave da API do Claude (IA)

1. Acesse **https://console.anthropic.com**
2. Crie uma conta (gratuito para testar)
3. Vá em **API Keys → Create Key**
4. Copie a chave (começa com `sk-ant-...`)

### PASSO 5 — Deploy no Vercel (gratuito)

**Opção A — Via upload direto (mais fácil):**
1. Acesse **https://vercel.com** e crie conta com GitHub
2. Clique em **"Add New → Project"**
3. Escolha **"Deploy from template"** → **"Other"**
4. Faça upload da pasta `fintrack` completa
5. Clique em **Deploy**
6. Em ~1 minuto, você terá sua URL! (ex: `fintrack-seu-nome.vercel.app`)

**Opção B — Via GitHub (recomendado para atualizações):**
1. Crie um repositório no GitHub e faça push desta pasta
2. No Vercel, importe o repositório
3. Deploy automático a cada atualização

### PASSO 6 — Acessar e configurar o app

1. Abra sua URL do Vercel
2. Na tela de setup, cole:
   - **Supabase URL**
   - **Supabase Anon Key**
   - **Anthropic API Key**
3. Clique em **"Entrar no FinTrack"**
4. Pronto! 🎉

---

## 📱 Integração WhatsApp (Twilio)

Para ativar o bot do WhatsApp:

1. Crie conta gratuita em **https://twilio.com**
2. Ative o **WhatsApp Sandbox**
3. Configure o Webhook para:  
   `https://seu-projeto.vercel.app/api/whatsapp`
4. Adicione as variáveis de ambiente no Vercel:
   - `TWILIO_ACCOUNT_SID`
   - `TWILIO_AUTH_TOKEN`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
   - `ANTHROPIC_API_KEY`

---

## 📂 Estrutura dos arquivos

```
fintrack/
├── public/
│   └── index.html          ← App completo (frontend)
├── supabase_schema.sql     ← Execute no Supabase SQL Editor
├── vercel.json             ← Configuração de deploy
└── README.md               ← Este guia
```

---

## 📊 Formatos de extrato suportados

| Formato | Como obter |
|---------|-----------|
| **OFX** | Maioria dos bancos oferece exportação OFX no internet banking |
| **Excel (.xlsx)** | Colunas: Data, Descrição, Valor |
| **CSV** | Separado por vírgula ou ponto-e-vírgula |
| **PDF** | Em breve (extração automática de texto) |

### Formato esperado para CSV/Excel:
```
Data,Descrição,Valor
01/04/2025,Restaurante Figueira,-320.00
02/04/2025,Carrefour,-189.50
03/04/2025,Salário,18400.00
```

---

## 🔮 Roadmap futuro

- [ ] Integração Open Finance (Belvo/Pluggy) para sync automático
- [ ] Extração automática de PDF bancário
- [ ] App mobile (PWA)
- [ ] Relatórios em PDF mensal
- [ ] Multi-usuário / família
- [ ] Previsão de gastos com IA

---

## 🛠️ Suporte

Em caso de dúvidas, consulte:
- Supabase Docs: https://supabase.com/docs
- Vercel Docs: https://vercel.com/docs
- Anthropic API: https://docs.anthropic.com
