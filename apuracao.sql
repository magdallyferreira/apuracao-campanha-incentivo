-- Apuração da campanha "Giro Certo" (Out/2026)
-- Regras: período 01/10/2026 a 31/10/2026 | categoria "bebida" | NF aprovada e não duplicada
--         | participante ativo | loja elegível: gatilho >= 80% da meta
--         | faixas: 80-99,99%=1,0x | 100-119,99%=1,2x | >=120%=1,5x
--         | prêmio = 2% do valor vendido válido x multiplicador | teto R$5.000

-- 0) normaliza o código da loja (resolve grafias como "001" ou " l001" em vez de "L001")
--    e marca ocorrência de NF (para pegar duplicidade)
DROP VIEW IF EXISTS vendas_norm;
CREATE VIEW vendas_norm AS
SELECT
  id_venda, id_participante,
  CASE
    WHEN upper(trim(id_loja)) GLOB 'L[0-9][0-9][0-9]' THEN upper(trim(id_loja))
    WHEN trim(id_loja) GLOB '[0-9]*' THEN 'L' || substr('000' || trim(id_loja), -3)
    ELSE upper(trim(id_loja))
  END AS id_loja,
  data_venda, categoria_produto, valor, nota_fiscal, status_nf,
  date(substr(data_venda,7,4) || '-' || substr(data_venda,4,2) || '-' || substr(data_venda,1,2)) AS data_iso,
  COUNT(*) OVER (PARTITION BY nota_fiscal) AS ocorrencias_nf
FROM vendas;

-- 1) vendas válidas: aplica as 6 regras de exclusão
DROP VIEW IF EXISTS vendas_validas;
CREATE VIEW vendas_validas AS
SELECT v.*
FROM vendas_norm v
JOIN participantes p ON p.id_participante = v.id_participante
JOIN lojas l ON l.id_loja = v.id_loja
WHERE
  v.data_iso BETWEEN '2026-10-01' AND '2026-10-31'   -- período
  AND v.categoria_produto = 'bebida'                   -- categoria elegível
  AND v.status_nf = 'aprovada'                         -- NF aprovada
  AND v.ocorrencias_nf = 1                             -- NF não duplicada (exclui AMBAS ocorrências)
  AND p.status = 'ativo';                              -- participante ativo

-- 2) atingimento de meta por loja (só com base nas vendas válidas)
DROP VIEW IF EXISTS atingimento_loja;
CREATE VIEW atingimento_loja AS
SELECT
  l.id_loja,
  l.meta_valor,
  COALESCE(SUM(v.valor), 0) AS total_valido,
  ROUND(COALESCE(SUM(v.valor), 0) * 100.0 / l.meta_valor, 2) AS pct_atingimento
FROM lojas l
LEFT JOIN vendas_validas v ON v.id_loja = l.id_loja
GROUP BY l.id_loja, l.meta_valor;

-- 3) faixa/multiplicador e elegibilidade (gatilho) de cada loja
DROP VIEW IF EXISTS faixa_loja;
CREATE VIEW faixa_loja AS
SELECT
  id_loja, meta_valor, total_valido, pct_atingimento,
  CASE
    WHEN pct_atingimento >= 120 THEN 1.5
    WHEN pct_atingimento >= 100 THEN 1.2
    WHEN pct_atingimento >= 80  THEN 1.0
    ELSE 0.0
  END AS multiplicador,
  CASE WHEN pct_atingimento >= 80 THEN 'ELEGIVEL' ELSE 'NAO ELEGIVEL' END AS status_gatilho
FROM atingimento_loja;

-- 4) prêmio por participante, com teto aplicado
DROP VIEW IF EXISTS premio_participante;
CREATE VIEW premio_participante AS
SELECT
  p.id_participante,
  p.nome,
  p.id_loja,
  f.status_gatilho,
  f.pct_atingimento,
  f.multiplicador,
  ROUND(COALESCE(SUM(v.valor), 0), 2) AS valor_vendido_valido,
  ROUND(MIN(COALESCE(SUM(v.valor), 0) * 0.02 * f.multiplicador, 5000), 2) AS premio_final
FROM participantes p
JOIN faixa_loja f ON f.id_loja = p.id_loja
LEFT JOIN vendas_validas v ON v.id_participante = p.id_participante
WHERE p.status = 'ativo'
GROUP BY p.id_participante, p.nome, p.id_loja, f.status_gatilho, f.pct_atingimento, f.multiplicador;

-- consultas finais
SELECT '--- ATINGIMENTO POR LOJA ---' AS corte;
SELECT * FROM faixa_loja ORDER BY id_loja;

SELECT '--- PREMIO POR PARTICIPANTE ---' AS corte;
SELECT * FROM premio_participante ORDER BY premio_final DESC;

SELECT '--- TOTAL PAGO ---' AS corte;
SELECT ROUND(SUM(premio_final),2) AS total_pago FROM premio_participante;

SELECT '--- CONTAGEM DE VENDAS (bruto x validas) ---' AS corte;
SELECT (SELECT COUNT(*) FROM vendas) AS vendas_brutas, (SELECT COUNT(*) FROM vendas_validas) AS vendas_validas;
