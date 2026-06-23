/*==============================================================================
  Nome do Script : EVOLUÇÃO DE VENDAS POR PRODUTO - ANUAL
  Tipo           : Componente BI ? Tabela
  Dashboard      : Análise de Vendas
  Descrição      : Evolução de vendas com eixos invertidos em relação ao
                   componente original EVOLUÇÃO DE VENDAS POR PRODUTO:
                   linhas = meses do ano, colunas = anos do período.
                   Cada linha é a combinação mês + linha de produto (AD_LINHA),
                   permitindo comparar o desempenho do mesmo mês entre anos
                   consecutivos. Não realiza cálculo de percentual.

  Parâmetros     : :PERIODO.INI ? Data inicial do período analisado
                   :PERIODO.FIN ? Data final do período analisado

  Tabelas        : TGFITE, TGFCAB, TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : ?

  Observações    : Colunas de ano cobertas: 2022 a 2026. Para adicionar um
                   novo ano, incluir o par VLR_AAAA / QTD_AAAA seguindo o
                   padrão das colunas existentes na seção de pivot.
==============================================================================*/

WITH BASE AS (
    ---------------------------------------------------------------------------
    -- 1. Dados brutos: valor e quantidade agrupados por mês, ano e AD_LINHA
    ---------------------------------------------------------------------------
    SELECT
         TO_CHAR(CAB.DTNEG, 'MM')                                              AS MES_ORDEM
        ,TO_CHAR(CAB.DTNEG, 'Mon')                                             AS MES_NOME
        ,EXTRACT(YEAR FROM CAB.DTNEG)                                          AS ANO
        ,NVL(PRO.AD_LINHA, 'SEM LINHA')                                        AS AD_LINHA
        ,SUM( (ITE.VLRTOT - NVL(ITE.VLRDESC, 0)) + NVL(ITE.AD_VLROUTROS, 0) ) AS VLRNOTA
        ,SUM(ITE.QTDNEG)                                                       AS QTDNEG
    FROM       TGFPRO PRO
    INNER JOIN TGFITE ITE  ON ITE.CODPROD     = PRO.CODPROD
    INNER JOIN TGFCAB CAB  ON CAB.NUNOTA      = ITE.NUNOTA
                          AND CAB.TIPMOV      = 'V'
                          AND CAB.CODTIPOPER IN (1100, 2200, 1111, 1190, 1124, 2202)
    WHERE CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN
      AND SUBSTR(TO_CHAR(PRO.CODPROD), 1, 1) = '3'
    GROUP BY
         TO_CHAR(CAB.DTNEG, 'MM')
        ,TO_CHAR(CAB.DTNEG, 'Mon')
        ,EXTRACT(YEAR FROM CAB.DTNEG)
        ,NVL(PRO.AD_LINHA, 'SEM LINHA')
)
---------------------------------------------------------------------------
-- 2. Pivot: distribui os anos em colunas, mantendo mês + AD_LINHA nas linhas
---------------------------------------------------------------------------
SELECT
     B.MES_ORDEM
    ,B.MES_NOME                                                                AS MES
    ,B.AD_LINHA
    ,SUM(CASE WHEN B.ANO = 2022 THEN B.VLRNOTA ELSE 0 END)                    AS VLR_2022
    ,SUM(CASE WHEN B.ANO = 2022 THEN B.QTDNEG  ELSE 0 END)                    AS QTD_2022
    ,SUM(CASE WHEN B.ANO = 2023 THEN B.VLRNOTA ELSE 0 END)                    AS VLR_2023
    ,SUM(CASE WHEN B.ANO = 2023 THEN B.QTDNEG  ELSE 0 END)                    AS QTD_2023
    ,SUM(CASE WHEN B.ANO = 2024 THEN B.VLRNOTA ELSE 0 END)                    AS VLR_2024
    ,SUM(CASE WHEN B.ANO = 2024 THEN B.QTDNEG  ELSE 0 END)                    AS QTD_2024
    ,SUM(CASE WHEN B.ANO = 2025 THEN B.VLRNOTA ELSE 0 END)                    AS VLR_2025
    ,SUM(CASE WHEN B.ANO = 2025 THEN B.QTDNEG  ELSE 0 END)                    AS QTD_2025
    ,SUM(CASE WHEN B.ANO = 2026 THEN B.VLRNOTA ELSE 0 END)                    AS VLR_2026
    ,SUM(CASE WHEN B.ANO = 2026 THEN B.QTDNEG  ELSE 0 END)                    AS QTD_2026
FROM  BASE B
GROUP BY
     B.MES_ORDEM
    ,B.MES_NOME
    ,B.AD_LINHA
ORDER BY
     B.MES_ORDEM
    ,B.AD_LINHA