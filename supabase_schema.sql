-- =============================================
-- FINTRACK - Schema Supabase
-- Execute este SQL no Supabase SQL Editor
-- =============================================

-- CATEGORIAS
CREATE TABLE categorias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL,
  icone TEXT NOT NULL DEFAULT '💳',
  cor TEXT NOT NULL DEFAULT '#007AFF',
  tipo TEXT NOT NULL CHECK (tipo IN ('fixo', 'variavel')),
  orcamento_mensal DECIMAL(12,2) DEFAULT 0,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- IMPORTAÇÕES
CREATE TABLE importacoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome_arquivo TEXT NOT NULL,
  tipo_arquivo TEXT NOT NULL CHECK (tipo_arquivo IN ('ofx', 'pdf', 'excel', 'csv')),
  total_transacoes INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'revisando', 'concluido', 'erro')),
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TRANSAÇÕES
CREATE TABLE transacoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  importacao_id UUID REFERENCES importacoes(id) ON DELETE SET NULL,
  categoria_id UUID REFERENCES categorias(id) ON DELETE SET NULL,
  data_transacao DATE NOT NULL,
  data_pagamento DATE,
  descricao TEXT NOT NULL,
  valor DECIMAL(12,2) NOT NULL,
  tipo TEXT NOT NULL DEFAULT 'debito' CHECK (tipo IN ('debito', 'credito')),
  comentario TEXT,
  categorizado_por_ia BOOLEAN DEFAULT false,
  confirmado BOOLEAN DEFAULT false,
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PADRÕES DE CATEGORIZAÇÃO (aprendizado da IA)
CREATE TABLE padroes_categorizacao (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  texto_padrao TEXT NOT NULL,
  categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE,
  ocorrencias INTEGER DEFAULT 1,
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(texto_padrao, categoria_id)
);

-- OBJETIVOS
CREATE TABLE objetivos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  categoria_id UUID REFERENCES categorias(id) ON DELETE CASCADE,
  mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
  ano INTEGER NOT NULL,
  valor_objetivo DECIMAL(12,2) NOT NULL,
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(categoria_id, mes, ano)
);

-- CONFIGURAÇÕES DO SISTEMA
CREATE TABLE configuracoes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chave TEXT UNIQUE NOT NULL,
  valor TEXT,
  atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- DADOS INICIAIS
-- =============================================

INSERT INTO categorias (nome, icone, cor, tipo, orcamento_mensal) VALUES
  ('Viagem',             '✈️',  '#007AFF', 'variavel', 3000.00),
  ('Restaurante',        '🍽️', '#FF9500', 'variavel', 1200.00),
  ('Mercado',            '🛒',  '#34C759', 'fixo',     2000.00),
  ('Roupas e Acessórios','👗',  '#AF52DE', 'variavel',  800.00),
  ('Médicos',            '🏥',  '#5AC8FA', 'fixo',      600.00);

INSERT INTO configuracoes (chave, valor) VALUES
  ('whatsapp_numero', ''),
  ('whatsapp_ativo', 'false'),
  ('ia_autocategorizacao', 'true'),
  ('moeda', 'BRL');

-- =============================================
-- FUNÇÃO: atualizar timestamp
-- =============================================
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_transacoes_updated
  BEFORE UPDATE ON transacoes
  FOR EACH ROW EXECUTE FUNCTION atualizar_timestamp();

-- =============================================
-- VIEWS ÚTEIS
-- =============================================

-- Resumo por categoria no mês atual
CREATE VIEW resumo_categorias_mes AS
SELECT
  c.id,
  c.nome,
  c.icone,
  c.cor,
  c.tipo,
  c.orcamento_mensal,
  COALESCE(SUM(CASE WHEN t.tipo = 'debito' THEN ABS(t.valor) ELSE 0 END), 0) AS total_gasto,
  COUNT(t.id) AS total_transacoes
FROM categorias c
LEFT JOIN transacoes t ON t.categoria_id = c.id
  AND EXTRACT(MONTH FROM t.data_transacao) = EXTRACT(MONTH FROM NOW())
  AND EXTRACT(YEAR FROM t.data_transacao) = EXTRACT(YEAR FROM NOW())
  AND t.confirmado = true
WHERE c.ativo = true
GROUP BY c.id, c.nome, c.icone, c.cor, c.tipo, c.orcamento_mensal;

-- Evolução mensal (últimos 6 meses)
CREATE VIEW evolucao_mensal AS
SELECT
  EXTRACT(YEAR FROM data_transacao) AS ano,
  EXTRACT(MONTH FROM data_transacao) AS mes,
  SUM(CASE WHEN tipo = 'credito' THEN valor ELSE 0 END) AS total_receitas,
  SUM(CASE WHEN tipo = 'debito' THEN ABS(valor) ELSE 0 END) AS total_despesas
FROM transacoes
WHERE confirmado = true
  AND data_transacao >= NOW() - INTERVAL '6 months'
GROUP BY ano, mes
ORDER BY ano, mes;

-- =============================================
-- ROW LEVEL SECURITY (básico - single user)
-- =============================================
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE transacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE importacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE padroes_categorizacao ENABLE ROW LEVEL SECURITY;
ALTER TABLE objetivos ENABLE ROW LEVEL SECURITY;
ALTER TABLE configuracoes ENABLE ROW LEVEL SECURITY;

-- Políticas permissivas (ajuste para multi-usuário se necessário)
CREATE POLICY "acesso_total" ON categorias FOR ALL USING (true);
CREATE POLICY "acesso_total" ON transacoes FOR ALL USING (true);
CREATE POLICY "acesso_total" ON importacoes FOR ALL USING (true);
CREATE POLICY "acesso_total" ON padroes_categorizacao FOR ALL USING (true);
CREATE POLICY "acesso_total" ON objetivos FOR ALL USING (true);
CREATE POLICY "acesso_total" ON configuracoes FOR ALL USING (true);
