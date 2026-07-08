/*==============================================================================
  Nome do Script : VGFEST
  Tipo           : VIEW
  Descrição      : Consolida o estoque disponível por SKU (CODPROD) para todos
                   os produtos ativos de revenda/venda, com base no estoque
                   físico registrado em TGFEST para a empresa e local
                   filtrados.

  Tabelas fonte  : TGFPRO  — cadastro de produtos
                   TGFEST  — posição de estoque por produto/empresa/local

  Colunas        : SKU   — código do produto (CODPROD)
                   ESTO  — estoque disponível consolidado (mínimo 0)

  Filtros ativos : Empresa    : 1
                   Local      : 109
                   Ativo      : PRO.ATIVO = 'S'
                   Uso        : USOPROD IN ('R', 'V')

  Uso            : Componentes BI de estimativa de estoque, painel de produção
                   e planejamento de compras.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2021
  Última Revisão : Julho/2026 — Simplificação da view: removido filtro de
                   movimento recente (últimos 300 dias) e a parte de estoque
                   indireto via composição (TGFICP). Agora apenas soma o
                   estoque direto do produto.

  Observações    : - CODEMP e CODLOCAL estão fixos (1 e 109). Ajustar conforme
                     ambiente se necessário.
                   - Produtos sem nenhum registro em TGFEST retornam ESTO = 0
                     via NVL.
==============================================================================*/

CREATE OR REPLACE VIEW VGFEST (SKU, ESTO) AS

SELECT  PRO.CODPROD      AS SKU
       ,NVL(ESTOQUE, 0)  AS ESTO
FROM TGFPRO PRO
LEFT OUTER JOIN (
    -- Agrega estoque bruto por produto na empresa e local filtrados
    SELECT  CODPROD
           ,SUM(ESTOQUE) AS ESTOQUE
    FROM TGFEST
    WHERE CODEMP   IN (1)     -- Empresa Spark Eletrônica
      AND CODLOCAL IN (109)   -- Local de estoque principal
    GROUP BY CODPROD
) EST ON EST.CODPROD = PRO.CODPROD
WHERE PRO.ATIVO = 'S'
  -- Apenas produtos de venda (Revenda ou Venda direta)
  AND PRO.USOPROD IN ('R', 'V')
GROUP BY
    PRO.CODPROD,
    NVL(ESTOQUE, 0);
