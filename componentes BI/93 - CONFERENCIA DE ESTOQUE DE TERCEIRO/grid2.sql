/*==============================================================================
  Nome do Script : CONFERENCIA DE ESTOQUE DE TERCEIRO — P2 (Detalhe)
  Tipo           : Componente BI
  Descrição      : Lista nota a nota a movimentação de estoque de terceiros de
                   um parceiro + produto até a data informada. É o detalhe
                   (drill-down) de P1: recebe :A_CODPARC e :A_CODPROD e honra
                   os mesmos filtros de painel (data, local, empresa).
                   Classificação por ITE.ATUALESTTERC, idêntica a P1:
                     - P / T -> QTDMOV positiva
                     - R / D -> QTDMOV negativa
                   SALDO acumula QTDMOV linha a linha (ordem cronológica),
                   reproduzindo o MOVTERC de P1 na última linha.

  Parâmetros     : :P_DATAFIN  — teto do período sobre DTENTSAI (piso fixo em
                                 01/01/2022)
                   :A_CODPARC  — parceiro selecionado na linha de P1 (obrigatório)
                   :A_CODPROD  — produto selecionado na linha de P1 (obrigatório)
                   :P_CODLOCAL — filtra ITE.CODLOCALORIG (opcional) — mesmo
                                 filtro de P1, incluído para reconciliar
                   :P_CODEMP   — filtra CAB.CODEMP (opcional)

  Colunas        : NUNOTA / NUMNOTA / DTNEG / DTENTSAI — identificação da nota
                   CODPARC / NOMEPARC — parceiro
                   CODTIPOPER / DESCTOP — tipo de operação e descrição
                   CODPROD / CODVOL — produto e unidade
                   QTDNEG      — quantidade da nota (sempre positiva)
                   CODLOCALORIG / CODLOCALTERC — locais de origem e de terceiro
                   ATUALESTOQUE — flag de atualização de estoque próprio
                   ATUALESTTERC — descrição da flag de estoque de terceiro
                   QTDMOV      — quantidade com sinal (+ P/T  /  - R/D)
                   SALDO       — saldo acumulado de QTDMOV até a linha

  Tabelas        : TGFITE -- itens da nota (quantidade, flag de estoque terceiro)
                   TGFCAB -- cabeçalho da nota (período, empresa, parceiro, TOP)
                   TGFPAR -- cadastro de parceiros (nome)
                   TGFPRO -- cadastro de produtos (unidade)
                   TGFTOP -- tipos de operação (descrição) — 1 linha por TOP

  Uso            : Painel BI "Conferência de Estoque de Terceiro" — detalhe
                   acionado pelo drill de P1 sobre CODPARC + CODPROD.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Setembro/2026
  Última Revisão : Setembro/2026 — Classificação de ATUALESTTERC explícita em
                   CTE (elimina o ELSE aberto), inclusão do filtro de local
                   (:P_CODLOCAL) para fechar com P1, TGFTOP via LEFT JOIN em
                   vez de subconsulta escalar, remoção de coluna redundante
                   (ITE.NUNOTA), literal de data com TO_DATE e nova coluna
                   SALDO (saldo acumulado por linha).

  Observações    : - As listas de flags de ATUALESTTERC (P/T positivas,
                     R/D negativas) precisam ser mantidas idênticas às de P1.
                     A CTE MOVIMENTOS é a única fonte da classificação.
                   - SALDO é acumulado por CODPARC + CODPROD na ordem
                     DTENTSAI, NUNOTA. Como o painel filtra um único parceiro
                     e produto, a última linha equivale ao MOVTERC de P1.
                   - Piso de data fixo em 01/01/2022 (igual a P1); o SALDO
                     reflete a posição a partir dessa data.
==============================================================================*/

WITH MOVIMENTOS AS (
    -- Classifica cada item de nota como entrada (+) ou saída (-) uma única vez
    SELECT
         CAB.NUNOTA
        ,CAB.NUMNOTA
        ,CAB.CODPARC
        ,PAR.NOMEPARC
        ,CAB.DTNEG
        ,CAB.DTENTSAI
        ,CAB.CODTIPOPER
        ,TOP.DESCROPER AS DESCTOP
        ,ITE.CODPROD
        ,PRO.CODVOL
        ,ITE.QTDNEG
        ,ITE.CODLOCALORIG
        ,ITE.CODLOCALTERC
        ,ITE.ATUALESTOQUE
        ,CASE
             WHEN ITE.ATUALESTTERC IN ('P', 'T') THEN  ITE.QTDNEG
             WHEN ITE.ATUALESTTERC IN ('R', 'D') THEN -ITE.QTDNEG
         END AS QTDMOV
        ,CASE ITE.ATUALESTTERC
             WHEN 'P' THEN '(+) PROPRIO EM TERCEIRO'
             WHEN 'R' THEN '(-) PROPRIO EM TERCEIRO'
             WHEN 'T' THEN '(+) TERCEIRO EM PROPRIO'
             WHEN 'D' THEN '(-) TERCEIRO EM PROPRIO'
         END AS ATUALESTTERC
    FROM TGFITE ITE
    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
    INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    LEFT JOIN (SELECT T.CODTIPOPER
                     ,MAX(T.DESCROPER) AS DESCROPER
               FROM TGFTOP T
               GROUP BY T.CODTIPOPER) TOP ON TOP.CODTIPOPER = CAB.CODTIPOPER
    WHERE ITE.ATUALESTTERC IN ('P', 'T', 'R', 'D')
      AND CAB.DTENTSAI >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
      AND CAB.DTENTSAI <= :P_DATAFIN
      AND CAB.CODPARC = :A_CODPARC
      AND ITE.CODPROD = :A_CODPROD
      AND (ITE.CODLOCALORIG = :P_CODLOCAL OR :P_CODLOCAL IS NULL)
      AND (CAB.CODEMP = :P_CODEMP OR :P_CODEMP IS NULL)
)
SELECT
     MOV.NUNOTA
    ,MOV.NUMNOTA
    ,MOV.CODPARC
    ,MOV.NOMEPARC
    ,MOV.DTNEG
    ,MOV.DTENTSAI
    ,MOV.CODTIPOPER
    ,MOV.DESCTOP
    ,MOV.CODPROD
    ,MOV.CODVOL
    ,MOV.QTDNEG
    ,MOV.CODLOCALORIG
    ,MOV.CODLOCALTERC
    ,MOV.ATUALESTOQUE
    ,MOV.ATUALESTTERC
    ,MOV.QTDMOV
    ,SUM(MOV.QTDMOV) OVER (
         PARTITION BY MOV.CODPARC, MOV.CODPROD
         ORDER BY MOV.DTENTSAI, MOV.NUNOTA
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
     ) AS SALDO
FROM MOVIMENTOS MOV
ORDER BY
     MOV.DTENTSAI
    ,MOV.NUNOTA
