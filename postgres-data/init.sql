CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Este script apaga a tabela de vendas existente e a recria com dados históricos.
-- Ele é ideal para popular o banco de dados para desenvolvimento e teste de dashboards.

-- Apaga a tabela se ela já existir para garantir um ambiente limpo.
DROP TABLE IF EXISTS vendas;

-- Recria a tabela de vendas com a coluna de preço como INTEGER para armazenar centavos.
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco_unitario INTEGER NOT NULL, -- Armazenará o valor em centavos
    quantidade INTEGER NOT NULL,
    data_venda TIMESTAMP NOT NULL
);

-- Inserção de dados históricos de vendas com maior volume e variância.
INSERT INTO vendas (produto, categoria, preco_unitario, quantidade, data_venda)
WITH
  -- 1. Define os produtos e suas respectivas categorias.
  produtos_categorias AS (
    SELECT
      p.produto,
      c.categoria
    FROM (
      VALUES
        ('Eletrônicos', ARRAY['Laptop X1', 'Smartphone Z', 'Fone TWS', 'Smartwatch V5']),
        ('Livros', ARRAY['A Arte da Guerra', 'Guia do Mochileiro', 'Sapiens', 'Duna']),
        ('Casa', ARRAY['Lâmpada Smart', 'Cadeira Gamer', 'Mesa Digitalizadora', 'Cafeteira'])
    ) AS c (categoria, produtos)
    CROSS JOIN unnest(c.produtos) AS p (produto)
  ),
  -- 2. Gera uma série de timestamps base a cada 30 minutos para o último ano.
  tempo_series AS (
    SELECT
      generate_series(
        NOW() - INTERVAL '365 days',
        NOW(),
        INTERVAL '30 minutes'
      ) AS base_time
  )
-- 3. Combina os dados gerados para criar as linhas de venda.
SELECT
  p.produto,
  p.categoria,
  -- Gera um preço unitário aleatório em centavos (entre 5000 e 250000).
  (floor(random() * (250000 - 5000) + 5000)) :: INTEGER AS preco_unitario,
  -- Gera uma quantidade aleatória entre 1 e 5.
  (floor(random() * 5) + 1) :: INTEGER AS quantidade,
  -- Adiciona uma variação aleatória de até 30 minutos no timestamp para mais realismo.
  t.base_time + (random() * INTERVAL '30 minutes') AS data_venda
FROM tempo_series AS t
-- Para cada timestamp base, gera um número aleatório de vendas (de 1 a 3).
CROSS JOIN LATERAL (
    SELECT generate_series(1, (floor(random() * 3) + 1)::int)
) AS s(i)
-- Para cada uma dessas vendas, escolhe um produto aleatório da nossa lista.
CROSS JOIN LATERAL (
  SELECT
    produto,
    categoria
  FROM produtos_categorias
  ORDER BY
    random()
  LIMIT 1
) AS p;