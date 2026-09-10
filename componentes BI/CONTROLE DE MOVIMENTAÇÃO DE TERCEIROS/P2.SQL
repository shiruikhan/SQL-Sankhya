/*==============================================================================
  Nome do Script : CONTROLE DE MOVIMENTAÇÃO DE TERCEIROS — P2 (Detalhe)
  Tipo           : Componente BI
  Descrição      : Lista nota a nota a movimentação de um produto em poder de
                   terceiros no período. É o detalhe (drill-down) de P1:
                   recebe o produto selecionado em :A_CODPROD e honra os
                   mesmos filtros de painel (período, parceiro, status).
                   Classificação por CODTIPOPER, idêntica a P1:
                     - RETORNO : 1202, 1212, 1213  -> QTDNEG positiva
                     - REMESSA : 1108, 2208, 1123   -> QTDNEG negativa
                   SUM(QTDNEG) deste detalhe = QTDREC + QTDENV da linha de P1.
                   A coluna SALDO acumula QTDNEG linha a linha (ordem
                   cronológica), mostrando quanto do produto permanece em poder
                   do terceiro após cada operação.

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — intervalo sobre DTENTSAI
                   :A_CODPROD — produto selecionado na linha de P1 (obrigatório)
                   :P_CODPARC — filtra um parceiro (opcional)

  Colunas        : NUNOTA / NUMNOTA / DTENTSAI — identificação da nota
                   PARCEIRO   — codigo + razão social do terceiro
                   CODPROD / DESCRPROD / CODVOL — produto e unidade
                   QTDNEG     — quantidade da operação com sinal
                                (+ retorno / - remessa)
                   SITUACAO   — RETORNO ou REMESSA
                   SALDO      — saldo acumulado de QTDNEG até a linha

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFPAR -- cadastro de parceiros (razão social)
                   TGFITE -- itens da nota (quantidade)
                   TGFPRO -- cadastro de produtos (descrição, unidade)

  Uso            : Painel BI "Controle de Movimentação de Terceiros" — detalhe
                   acionado pelo drill de P1 sobre CODPROD.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 10/09/2026
  Última Revisão : Setembro/2026 — Classificação de CODTIPOPER explícita em CTE
                   (elimina o ELSE aberto) e alinhamento com P1.
                   Setembro/2026 — Nova coluna SALDO (saldo acumulado por linha).

  Observações    : - As listas de CODTIPOPER de RETORNO e REMESSA precisam ser
                     mantidas idênticas às de P1. A CTE MOVIMENTOS é a única
                     fonte da classificação neste script.
                   - CODTIPOPER 2223 está fora do escopo (comentada); se
                     reativada, incluir em MOVIMENTOS (aqui e em P1).
                   - REMESSA é exibida com QTDNEG negativa por convenção do
                     painel, para reconciliar com QTDENV de P1.
                   - SALDO é acumulado por CODPROD na ordem DTENTSAI, NUNOTA;
                     como o painel filtra um único produto, o valor da última
                     linha equivale ao saldo total do período. Se o produto já
                     tinha material em terceiros antes de :P_PERIODO.INI, o
                     SALDO representa apenas a variação dentro do período.
==============================================================================*/

WITH MOVIMENTOS AS (
    -- Classifica cada item de nota como RETORNO ou REMESSA uma única vez
    SELECT
         CAB.NUNOTA
        ,CAB.NUMNOTA
        ,CAB.DTENTSAI
        ,PAR.CODPARC || ' - ' || PAR.RAZAOSOCIAL AS PARCEIRO
        ,ITE.CODPROD
        ,PRO.DESCRPROD
        ,PRO.CODVOL
        ,CASE
             WHEN CAB.CODTIPOPER IN (1202, 1212, 1213) THEN 'RETORNO'
             WHEN CAB.CODTIPOPER IN (1108, 2208, 1123) THEN 'REMESSA'
         END AS SITUACAO
        ,CASE
             WHEN CAB.CODTIPOPER IN (1202, 1212, 1213) THEN  ITE.QTDNEG
             WHEN CAB.CODTIPOPER IN (1108, 2208, 1123) THEN -ITE.QTDNEG
         END AS QTDMOV
    FROM TGFCAB CAB
    INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
    INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE CAB.DTENTSAI >= :P_PERIODO.INI
      AND CAB.DTENTSAI <= :P_PERIODO.FIN
      AND ITE.CODPROD = :A_CODPROD
      AND CAB.STATUSNOTA = 'L'
      AND CAB.CODTIPOPER IN (1202, 1108, 2208, 1123, 1212, 1213 /*, 2223*/)
      AND (CAB.CODPARC = :P_CODPARC OR :P_CODPARC IS NULL)
)
SELECT
     MOV.NUNOTA
    ,MOV.NUMNOTA
    ,MOV.DTENTSAI
    ,MOV.PARCEIRO
    ,MOV.CODPROD
    ,MOV.DESCRPROD
    ,MOV.CODVOL
    ,MOV.QTDMOV AS QTDNEG
    ,MOV.SITUACAO
    ,SUM(MOV.QTDMOV) OVER (
         PARTITION BY MOV.CODPROD
         ORDER BY MOV.DTENTSAI, MOV.NUNOTA
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
     ) AS SALDO
FROM MOVIMENTOS MOV
ORDER BY MOV.DTENTSAI, MOV.NUNOTA
