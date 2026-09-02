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
                   Relatório fixo, sem parâmetros de tela: o período é
                   resolvido internamente (01/01/2022 a 31/12/2026).
                   Os totalizadores de valor e quantidade são LÍQUIDOS de
                   devolução: as devoluções (TIPMOV = 'D', CODTIPOPER IN
                   1200, 1201, 1216, 1217, 1272) são somadas com sinal
                   negativo no mês em que ocorreram, abatendo o mês/ano
                   correspondente. Critérios de devolução replicados do
                   componente validado "Faturamento por período Gestão"
                   (p2.sql).

  Tabelas        : TGFITE, TGFCAB, TGFPRO, TGFGRU, TGFVEN, TGFPAR, TSICID

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Setembro/2026 - Totalizadores de valor e quantidade
                   passaram a abater as devoluções. Adicionado o ramo
                   TIPMOV = 'D' / CODTIPOPER IN (1200, 1201, 1216, 1217,
                   1272) na leitura de TGFCAB e sinal negativo aplicado a
                   VLRNOTA e QTDNEG para esses movimentos, seguindo os
                   critérios de p2.sql.
                   Julho/2026 - Removidos os parâmetros de tela (:PERIODO.INI
                   / :PERIODO.FIN); período fixado em código. Corrigido
                   filtro de produto para PRO.USOPROD = 'V'. Corrigido filtro
                   de data para TRUNC(CAB.DTNEG) BETWEEN ..., pois DTNEG
                   carrega hora. Adicionados INNER JOIN com TGFGRU, TGFVEN,
                   TGFPAR e TSICID. Ajustada a soma de VLRNOTA para
                   SUM(VLRTOT - VLRDESC) + SUM(NVL(AD_VLROUTROS,0)). Incluído
                   o filtro (CAB.CODEMP = 501 OR CAB.STATUSNFE <> 'D'),
                   replicando correção feita em p1.sql: sem ele, notas
                   fiscais denegadas pela SEFAZ (STATUSNFE = 'D') eram
                   somadas como venda válida, inflando valor e quantidade ?
                   essa era a causa raiz da discrepância, não os filtros de
                   data/produto ajustados antes. Todos os critérios seguem o
                   componente validado "Faturamento por período Gestão"
                   (p1.sql).

  Observações    : Colunas de ano cobertas: 2022 a 2026. Para adicionar um
                   novo ano, incluir o par VLR_AAAA / QTD_AAAA seguindo o
                   padrão das colunas existentes na seção de pivot e
                   estender o período fixo abaixo.
==============================================================================*/

WITH BASE AS (
    ---------------------------------------------------------------------------
    -- 1. Dados brutos: valor e quantidade agrupados por mês, ano e AD_LINHA.
    --    Vendas entram com sinal +; devoluções (TIPMOV = 'D') com sinal -,
    --    abatendo o mês/ano em que ocorreram.
    ---------------------------------------------------------------------------
    SELECT
         TO_CHAR(CAB.DTNEG, 'MM')                                              AS MES_ORDEM
        ,TO_CHAR(CAB.DTNEG, 'Mon')                                             AS MES_NOME
        ,EXTRACT(YEAR FROM CAB.DTNEG)                                          AS ANO
        ,NVL(PRO.AD_LINHA, 'SEM LINHA')                                        AS AD_LINHA
        ,SUM(CASE WHEN CAB.TIPMOV = 'D'
                  THEN -((ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS, 0))
                  ELSE  ((ITE.VLRTOT - ITE.VLRDESC) + NVL(ITE.AD_VLROUTROS, 0))
             END)                                                              AS VLRNOTA
        ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN -ITE.QTDNEG ELSE ITE.QTDNEG END)  AS QTDNEG
    FROM       TGFPRO PRO
    INNER JOIN TGFITE ITE  ON ITE.CODPROD     = PRO.CODPROD
    INNER JOIN TGFCAB CAB  ON CAB.NUNOTA      = ITE.NUNOTA
                          AND (
                                  (CAB.TIPMOV = 'V' AND CAB.CODTIPOPER IN (1100, 2200, 1111, 1190, 1124, 2202))
                               OR (CAB.TIPMOV = 'D' AND CAB.CODTIPOPER IN (1200, 1201, 1216, 1217, 1272))
                              )
    INNER JOIN TGFGRU  GRU  ON GRU.CODGRUPOPROD = PRO.CODGRUPOPROD
    INNER JOIN TGFVEN  VEN  ON VEN.CODVEND      = CAB.CODVEND
    INNER JOIN TGFPAR  PAR  ON PAR.CODPARC      = CAB.CODPARC
    INNER JOIN TSICID  CID  ON CID.CODCID       = PAR.CODCID
    WHERE TRUNC(CAB.DTNEG) BETWEEN TO_DATE('01/01/2022', 'DD/MM/YYYY')
                                AND TO_DATE('31/12/2026', 'DD/MM/YYYY')
      AND PRO.USOPROD = 'V'
      AND (CAB.CODEMP = 501 OR CAB.STATUSNFE <> 'D')
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