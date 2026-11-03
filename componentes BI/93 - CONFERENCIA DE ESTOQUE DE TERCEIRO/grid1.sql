/*==============================================================================
  Nome do Script : CONFERENCIA DE ESTOQUE DE TERCEIRO — P1 (Resumo)
  Tipo           : Componente BI
  Descrição      : Consolida, por parceiro e produto, o saldo de movimentação
                   de estoque de terceiros até a data informada. Classifica
                   cada item pela flag ITE.ATUALESTTERC:
                     - P (próprio em terceiro)  -> soma positiva
                     - T (terceiro em próprio)  -> soma positiva
                     - R (retorno próprio em terceiro) -> soma negativa
                     - D (retorno terceiro em próprio) -> soma negativa
                   MOVTERC = SUM(P,T) - SUM(R,D). É decisão de negócio manter
                   os dois estoques (próprio-em-terceiro e terceiro-em-próprio)
                   somados num único número. Só saldos > 0 são exibidos.
                   É a consulta "master"; o detalhe nota a nota está em P2,
                   acionado pelo drill sobre CODPARC + CODPROD.

  Parâmetros     : :P_DATAFIN  — teto do período sobre DTENTSAI (piso fixo em
                                 01/01/2022)
                   :P_CODPARC  — filtra um parceiro (opcional)
                   :P_CODPROD  — filtra um produto (opcional)
                   :P_CODLOCAL — filtra ITE.CODLOCALORIG (opcional)
                   :P_CODEMP   — filtra CAB.CODEMP (opcional)

  Tabelas        : TGFITE -- itens da nota (quantidade, flag de estoque terceiro)
                   TGFCAB -- cabeçalho da nota (período, empresa, parceiro)
                   TGFPAR -- cadastro de parceiros (nome)
                   TGFPRO -- cadastro de produtos (descrição, unidade)

  Uso            : Painel BI "Conferência de Estoque de Terceiro" — linha de
                   resumo; drill para P2 pelos campos CODPARC e CODPROD.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Setembro/2026
  Última Revisão : Setembro/2026 — Centralização da classificação de
                   ATUALESTTERC em CTE, unificação da fórmula do saldo entre
                   SELECT e HAVING, remoção de DISTINCT e de predicado morto
                   (CAB.NUNOTA = ITE.NUNOTA), literal de data com TO_DATE e
                   alinhamento de parâmetros com P2.

  Observações    : - As listas de flags de ATUALESTTERC (P/T positivas,
                     R/D negativas) precisam ser mantidas idênticas às de P2.
                     A CTE MOVIMENTOS é a única fonte da classificação.
                   - O campo do painel ligado a :P_CODPROD deve chamar-se
                     P_CODPROD (o script anterior usava :P_CODPPROD, com P
                     dobrado, e o filtro nunca atuava).
                   - MOVTERC mistura P/R (meu material em terceiro) com T/D
                     (material de terceiro comigo) por decisão de negócio.
==============================================================================*/

WITH MOVIMENTOS AS (
    -- Classifica cada item de nota como entrada (+) ou saída (-) uma única vez
    SELECT
         CAB.CODPARC
        ,PAR.NOMEPARC
        ,ITE.CODPROD
        ,PRO.DESCRPROD
        ,PRO.CODVOL
        ,CASE
             WHEN ITE.ATUALESTTERC IN ('P', 'T') THEN  ITE.QTDNEG
             WHEN ITE.ATUALESTTERC IN ('R', 'D') THEN -ITE.QTDNEG
         END AS QTDMOV
    FROM TGFITE ITE
    INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
    INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE ITE.ATUALESTTERC IN ('P', 'T', 'R', 'D')
      AND CAB.DTENTSAI >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
      AND CAB.DTENTSAI <= :P_DATAFIN
      AND (CAB.CODPARC = :P_CODPARC OR :P_CODPARC IS NULL)
      AND (ITE.CODPROD = :P_CODPROD OR :P_CODPROD IS NULL)
      AND (ITE.CODLOCALORIG = :P_CODLOCAL OR :P_CODLOCAL IS NULL)
      AND (CAB.CODEMP = :P_CODEMP OR :P_CODEMP IS NULL)
)
SELECT
     MOV.CODPARC
    ,MOV.NOMEPARC
    ,MOV.CODPROD
    ,MOV.DESCRPROD
    ,MOV.CODVOL
    ,SUM(MOV.QTDMOV) AS MOVTERC
FROM MOVIMENTOS MOV
GROUP BY
     MOV.CODPARC
    ,MOV.NOMEPARC
    ,MOV.CODPROD
    ,MOV.DESCRPROD
    ,MOV.CODVOL
HAVING SUM(MOV.QTDMOV) > 0
ORDER BY
     MOV.CODPARC
    ,MOV.CODPROD
