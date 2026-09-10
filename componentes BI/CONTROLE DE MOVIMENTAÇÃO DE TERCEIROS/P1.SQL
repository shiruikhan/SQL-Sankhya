/*==============================================================================
  Nome do Script : CONTROLE DE MOVIMENTAÇÃO DE TERCEIROS — P1 (Resumo)
  Tipo           : Componente BI
  Descrição      : Consolida, por produto, o saldo de material em poder de
                   terceiros no período informado. Classifica cada nota pela
                   CODTIPOPER:
                     - RETORNO (entrada) : 1202, 1212, 1213  -> soma positiva
                     - REMESSA (saída)   : 1108, 2208, 1123   -> soma negativa
                   QTDREC + QTDENV = saldo líquido em poder do terceiro.
                   É a consulta "master"; o detalhe nota a nota está em P2,
                   acionado pelo drill sobre CODPROD.

  Parâmetros     : :P_PERIODO.INI / :P_PERIODO.FIN — intervalo sobre DTENTSAI
                   :P_CODPARC — filtra um parceiro (opcional)
                   :P_CODPROD — filtra um produto (opcional)

  Tabelas        : TGFCAB -- cabeçalho da nota (período, tipo de operação, status)
                   TGFITE -- itens da nota (quantidade)
                   TGFPRO -- cadastro de produtos (descrição, unidade)

  Uso            : Painel BI "Controle de Movimentação de Terceiros" — linha
                   de resumo; drill para P2 pelo campo CODPROD.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 10/09/2026
  Última Revisão : Setembro/2026 — Centralização da classificação de CODTIPOPER
                   em CTE, remoção do join ocioso com TGFPAR e alinhamento com P2.

  Observações    : - As listas de CODTIPOPER de RETORNO e REMESSA precisam ser
                     mantidas idênticas às de P2. A CTE MOVIMENTOS é a única
                     fonte da classificação neste script.
                   - CODTIPOPER 2223 está fora do escopo (comentada); se
                     reativada, incluir em MOVIMENTOS (aqui e em P2).
                   - QTDENV é retornada negativa por convenção do painel.
==============================================================================*/

WITH MOVIMENTOS AS (
    -- Classifica cada item de nota como RETORNO ou REMESSA uma única vez
    SELECT
         ITE.CODPROD
        ,PRO.DESCRPROD
        ,PRO.CODVOL
        ,ITE.QTDNEG
        ,CASE
             WHEN CAB.CODTIPOPER IN (1202, 1212, 1213) THEN 'RETORNO'
             WHEN CAB.CODTIPOPER IN (1108, 2208, 1123) THEN 'REMESSA'
         END AS TIPO
    FROM TGFCAB CAB
    INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA
    INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
    WHERE CAB.DTENTSAI >= :P_PERIODO.INI
      AND CAB.DTENTSAI <= :P_PERIODO.FIN
      AND CAB.STATUSNOTA = 'L'
      AND CAB.CODTIPOPER IN (1202, 1108, 2208, 1123, 1212, 1213 /*, 2223*/)
      AND (CAB.CODPARC = :P_CODPARC OR :P_CODPARC IS NULL)
      AND (ITE.CODPROD = :P_CODPROD OR :P_CODPROD IS NULL)
)
SELECT
     MOV.CODPROD
    ,MOV.DESCRPROD
    ,MOV.CODVOL
    ,SUM(CASE WHEN MOV.TIPO = 'RETORNO' THEN  MOV.QTDNEG ELSE 0 END) AS QTDREC
    ,SUM(CASE WHEN MOV.TIPO = 'REMESSA' THEN -MOV.QTDNEG ELSE 0 END) AS QTDENV
FROM MOVIMENTOS MOV
GROUP BY
     MOV.CODPROD
    ,MOV.DESCRPROD
    ,MOV.CODVOL
ORDER BY MOV.CODPROD
