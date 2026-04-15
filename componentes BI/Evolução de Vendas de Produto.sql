/*==============================================================================
  Nome do Script : Evolução de Vendas de Produto
  Tipo           : Componente BI — Gráfico de Colunas
  Dashboard      : Análise de Vendas
  Descrição      : Evolução mensal de vendas de um produto específico
                   com valores líquidos e opcional de descontos/impostos.

  Parâmetros     : :DESC — 'S' para incluir descontos
                   :REP — 'S' para incluir reposição
                   :ST — 'S' para incluir substituição
                   :IPI — 'S' para incluir IPI
                   :STATUSNOTA — 'N' para incluir todas as notas
                   :TOP — Grupo de operação
                   :PERIODO.INI — Data inicial
                   :PERIODO.FIN — Data final
                   :PRODUTO — Código do produto (ou NULL para todos)

  Tabelas        : TGFCAB, TGFITE, TGFPRO, TGFPAR, TGFTOP, VGFCAB

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT
SUM (   ((  (ITE.VLRTOT)
                    - (CASE WHEN :DESC = 'S' THEN ITE.VLRDESC ELSE 0 END)
                    - (CASE WHEN :REP = 'S' THEN ITE.VLRREPRED ELSE 0 END)
                    + (CASE WHEN :ST = 'S' THEN ITE.VLRSUBST ELSE 0 END)
                    + (CASE WHEN :IPI = 'S' THEN ITE.VLRIPI ELSE 0 END)
                   )
              * CASE WHEN CAB.TIPMOV = 'D' THEN -1 ELSE 1 END) * VCAB.INDITENS
             ) AS VALOR,
TO_CHAR(CAB.DTNEG, 'Mon/YYYY') AS PER,
 TO_CHAR(CAB.DTNEG, 'YYYYMM') AS ORDEM

FROM TGFCAB CAB
, TGFPAR PAR
, TGFITE ITE
, TGFPRO PRO
, TGFTOP TPO
, VGFCAB VCAB
WHERE   (CAB.STATUSNOTA = 'L' OR :STATUSNOTA = 'N')
AND ITE.USOPROD <> 'D'
AND TPO.GOLSINAL = -1
AND VCAB.NUNOTA= CAB.NUNOTA
AND ((TPO.GRUPO IN :TOP))
AND CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN
AND ((PRO.CODPROD= :PRODUTO) OR (:PRODUTO IS NULL))
AND CAB.CODPARC = PAR.CODPARC
AND CAB.NUNOTA = ITE.NUNOTA
AND ITE.CODPROD = PRO.CODPROD
AND CAB.CODTIPOPER = TPO.CODTIPOPER
AND CAB.DHTIPOPER = TPO.DHALTER
GROUP BY TO_CHAR(CAB.DTNEG, 'Mon/YYYY'),
 TO_CHAR(CAB.DTNEG, 'YYYYMM')

ORDER BY 3