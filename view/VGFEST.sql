/*==============================================================================
  Nome do Script : VGFEST
  Tipo           : VIEW
  Descrição      : Consolida o estoque disponível por SKU (CODPROD) para todos
                   os produtos ativos que tiveram movimentação comercial nos
                   últimos 300 dias.

                   O resultado é composto por duas partes unidas via UNION ALL:
                   1) Estoque direto do produto (TGFEST) — soma por produto,
                      empresa e local filtrados.
                   2) Estoque indireto via composição (TGFICP) — calcula o
                      estoque disponível de produto acabado com base no estoque
                      das matérias-primas que o compõem. Estoques negativos de
                      MP são tratados como zero, pois limitam a produção.

  Tabelas fonte  : TGFPRO  — cadastro de produtos
                   TGFEST  — posição de estoque por produto/empresa/local
                   TGFCAB  — cabeçalho de notas (filtro de movimento recente)
                   TGFITE  — itens de nota (filtro de movimento recente)
                   TGFICP  — composição de produto (PA → MP)

  Colunas        : SKU   — código do produto (CODPROD)
                   ESTO  — estoque disponível consolidado (mínimo 0)

  Filtros ativos : Empresa    : 1
                   Local      : 109
                   Ativo      : PRO.ATIVO = 'S'
                   Uso        : USOPROD IN ('R', 'V')
                   Movimento  : últimos 300 dias (DTNEG > SYSDATE - 300)

  Uso            : Componentes BI de estimativa de estoque, painel de produção
                   e planejamento de compras.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2021
  Última Revisão : Abril/2026 — Padronização de cabeçalho, comentários e indentação

  Observações    : - CODEMP e CODLOCAL estão fixos (1 e 109). Ajustar conforme
                     ambiente se necessário.
                   - Produtos sem nenhum registro em TGFEST retornam ESTO = 0
                     via NVL na parte 1 e via UNION ALL com valor 0 na parte 2.
                   - Na parte 2 (composição), o MIN() sobre as MPs garante que
                     o estoque do PA reflita a MP mais restritiva (gargalo).
==============================================================================*/

CREATE OR REPLACE VIEW VGFEST (SKU, ESTO) AS

-- =============================================================================
-- PARTE 1: Estoque direto do produto (TGFEST)
-- Soma o estoque físico por produto nas combinações de empresa e local
-- definidas. Inclui apenas produtos ativos com uso 'R' (Revenda) ou 'V' (Venda)
-- que tiveram alguma negociação nos últimos 300 dias.
-- =============================================================================
SELECT
    PRO.CODPROD   AS SKU,
    NVL(ESTOQUE, 0) AS ESTO
FROM TGFPRO PRO
LEFT OUTER JOIN (
    -- Agrega estoque bruto por produto nas empresas e locais filtrados
    SELECT
        CODPROD,
        SUM(ESTOQUE) AS ESTOQUE
    FROM TGFEST
    WHERE CODEMP   IN (1)       -- Empresa Spark Eletrônica
      AND CODLOCAL IN (109)     -- Local de estoque principal
    GROUP BY CODPROD
) EST ON EST.CODPROD = PRO.CODPROD
WHERE PRO.ATIVO = 'S'
  -- Restringe a produtos que tiveram movimentação nos últimos 300 dias
  AND PRO.CODPROD IN (
      SELECT DISTINCT ITE.CODPROD
      FROM TGFCAB CAB
      JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
      WHERE DTNEG > SYSDATE - 300
  )
  -- Apenas produtos de venda (Revenda ou Venda direta)
  AND PRO.USOPROD IN ('R', 'V')
GROUP BY
    PRO.CODPROD,
    NVL(ESTOQUE, 0)

UNION ALL

-- =============================================================================
-- PARTE 2: Estoque indireto via composição de produto (TGFICP)
-- Calcula o estoque disponível de produtos acabados (PA) com base no estoque
-- das matérias-primas (MP) que os compõem.
--
-- Para cada PA, considera a MP com menor estoque disponível (MIN), pois ela
-- é o fator limitante de produção. Estoques negativos de MP são zerados para
-- não distorcer a análise.
--
-- Produtos cujas MPs não têm nenhum registro em TGFEST são incluídos com
-- ESTO = 0 (via sub-UNION ALL interno), evitando que o PA desapareça da view.
-- =============================================================================
SELECT
    A.CODPROD  AS SKU,
    NVL(MIN(VALOR), 0) AS ESTO
FROM (
    -- Estoque disponível de cada MP que compõe o PA
    -- Estoque negativo é tratado como zero (MP indisponível, não negativa)
    SELECT
        ICP.CODPROD,
        CASE
            WHEN SUM(ESTOQUE) < 0 THEN 0
            ELSE SUM(ESTOQUE)
        END AS VALOR,
        ICP.CODMATPRIMA
    FROM TGFICP ICP
    INNER JOIN TGFEST EST ON EST.CODPROD = ICP.CODMATPRIMA
    WHERE EST.CODEMP   IN (1)
      AND EST.CODLOCAL IN (109)
    GROUP BY
        ICP.CODPROD,
        ICP.CODMATPRIMA

    UNION ALL

    -- MPs que existem na composição mas não têm registro em TGFEST
    -- (sem estoque cadastrado = estoque zero para efeitos de cálculo)
    SELECT
        CODPROD,
        0 AS VALOR,
        CODMATPRIMA
    FROM TGFICP
    WHERE CODMATPRIMA NOT IN (
        SELECT ICP.CODMATPRIMA
        FROM TGFICP ICP
        JOIN TGFEST EST ON EST.CODPROD = ICP.CODMATPRIMA
        WHERE EST.CODEMP   IN (1)
          AND EST.CODLOCAL IN (109)
    )
) A
GROUP BY A.CODPROD;
