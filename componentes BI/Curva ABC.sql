/*==============================================================================
  Nome do Script : Curva ABC
  Tipo           : Componente BI — Tabela
  Dashboard      : Análise ABC
  Descrição      : Análise de Curva ABC de produtos ou parceiros para
                   segmentação de clientes e estoque conforme valor/movimento.

  Parâmetros     : :@ANALISE — 'Produtos' ou outro para Parceiros
                   :DESC — 'S' para incluir descontos
                   :REP — 'S' para incluir reposição
                   :ST — 'S' para incluir substituição
                   :IPI — 'S' para incluir IPI
                   :STATUSNOTA — 'N' para incluir todas as notas
                   :GRUPO — Grupo de operação
                   :PERIODO — Data inicial e final
                   :CODEMP — Código da empresa
                   :CODPARC — Código do parceiro (ou NULL)
                   :CODVEND — Código do vendedor (ou NULL)
                   :PGRUPO — Grupo de produto (ou NULL)
                   :A — Percentual para classe A
                   :B — Percentual para classe B

  Tabelas        : TGFCAB, TGFPAR, TGFITE, TGFPRO, TGFGRU, TGFTOP, VGFCAB, TGFVEN

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

WITH BASE AS (
  SELECT CASE WHEN ':@ANALISE' = 'Produtos' THEN PRO.AD_AGRUPADOR ELSE PAR.CODPARC || '-' || PAR.NOMEPARC END AS CODIGO,
         SUM(((ITE.VLRTOT + NVL(ITE.AD_VLROUTROS,0))
              - CASE WHEN :DESC = 'S' THEN ITE.VLRDESC ELSE 0 END
              - CASE WHEN :REP  = 'S' THEN ITE.VLRREPRED ELSE 0 END
              + CASE WHEN :ST   = 'S' THEN ITE.VLRSUBST ELSE 0 END
              + CASE WHEN :IPI  = 'S' THEN ITE.VLRIPI  ELSE 0 END)
             * CASE WHEN CAB.TIPMOV = 'D' THEN -1 ELSE 1 END
             * VCAB.INDITENS) AS VALOR,
         SUM(ITE.QTDNEG) AS KG
  FROM TGFCAB CAB
  INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
  INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
  INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
  INNER JOIN TGFGRU GRU ON GRU.CODGRUPOPROD = PRO.CODGRUPOPROD
  INNER JOIN TGFTOP TPO ON TPO.CODTIPOPER = CAB.CODTIPOPER AND TPO.DHALTER = CAB.DHTIPOPER
  INNER JOIN VGFCAB VCAB ON VCAB.NUNOTA = CAB.NUNOTA
  INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
  WHERE (CAB.STATUSNOTA = 'L' OR :STATUSNOTA = 'N')
    AND ITE.USOPROD <> 'D'
    AND TPO.GOLSINAL = -1
    AND TPO.GRUPO IN :GRUPO
    AND CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN
    AND CAB.CODEMP IN :CODEMP
    AND ((CAB.CODPARC = :CODPARC) OR (:CODPARC IS NULL))
    AND ((CAB.CODVEND = :CODVEND) OR (:CODVEND IS NULL))
    AND ((GRU.CODGRUPOPROD = :PGRUPO) OR (:PGRUPO IS NULL))
  GROUP BY CASE WHEN ':@ANALISE' = 'Produtos' THEN PRO.AD_AGRUPADOR ELSE PAR.CODPARC || '-' || PAR.NOMEPARC END
),
FINAL AS (
  SELECT CODIGO,
         VALOR,
         SUM(VALOR) OVER (ORDER BY VALOR DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ACUMULADO,
         (SUM(VALOR) OVER ()) * 0.8 AS VALORTOT,
         (VALOR / NULLIF(SUM(VALOR) OVER (), 0)) * 100 AS PERC,
         (SUM(VALOR) OVER (ORDER BY VALOR DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / NULLIF(SUM(VALOR) OVER (), 0)) * 100 AS PERCACUM,
         KG,
         ROW_NUMBER() OVER (ORDER BY VALOR DESC) AS RANKING,
         CASE 
           WHEN ROW_NUMBER() OVER (ORDER BY VALOR DESC) <= ROUND(COUNT(*) OVER () * (:A/100)) THEN 'A'
           WHEN ROW_NUMBER() OVER (ORDER BY VALOR DESC) <= ROUND(COUNT(*) OVER () * (:A/100)) + ROUND(COUNT(*) OVER () * (:B/100)) THEN 'B'
           ELSE 'C'
         END AS CURVA,
         CASE 
           WHEN ROW_NUMBER() OVER (ORDER BY VALOR DESC) <= ROUND(COUNT(*) OVER () * (:A/100)) THEN '#E8F5E9'
           WHEN ROW_NUMBER() OVER (ORDER BY VALOR DESC) <= ROUND(COUNT(*) OVER () * (:A/100)) + ROUND(COUNT(*) OVER () * (:B/100)) THEN '#FFF3E0'
           ELSE '#FFEBEE'
         END AS BKCOLOR,
         (VALOR / NULLIF(KG, 0)) AS VALORMEDIO,
         SUM(KG) OVER () AS QTDTOTAL,
         COUNT(*) OVER () AS QTDPRODUTO
  FROM BASE
)
SELECT *
FROM FINAL
ORDER BY VALOR DESC
