/*==============================================================================
  Nome do Script : [SPARK] - INDICADORES DE ATENDIMENTO DE REQUISIÇÃO
  Tipo           : Componente BI — Tabela
  Descrição      : Indicador de atendimento do almoxarifado. Lista as
                   requisições/transferências atendidas no período (TGFCAB
                   TIPMOV 'Q' e 'T'), com o total de unidades movimentadas
                   (SUM de QTDNEG em TGFITE), e compara com o pedido de
                   requisição de origem, localizado via TGFVAR (NUNOTAORIG).
                   Calcula o percentual de atendimento (unidades atendidas /
                   unidades solicitadas no pedido de origem) e a diferença em
                   dias entre a previsão de entrega do pedido (DTPREVENT) e a
                   entrega efetiva (DTMOV da requisição).

  Parâmetros     : :P_PERIODO.INI — data inicial do período (DTMOV)
                   :P_PERIODO.FIN — data final do período (DTMOV)

  Tabelas        : TGFCAB — cabeçalho das notas (atendimento e pedido)
                   TGFITE — itens das notas (quantidades)
                   TGFVAR — vínculo entre nota de atendimento e pedido origem
                   TGFPRO — unidade padrão do produto (CODVOL)
                   TGFVOA — fator de conversão de unidades alternativas
                   TSICUS — centro de resultado (DESCRCENCUS)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 03/07/2026
  Última Revisão : Julho/2026 — Criação

  Observações    : - O período filtra pela data de movimentação (DTMOV) da
                     nota de atendimento.
                   - Considera apenas requisições confirmadas
                     (STATUSNOTA = 'L').
                   - Quantidades são convertidas para a unidade padrão do
                     produto (TGFPRO.CODVOL): quando TGFITE.CODVOL difere da
                     padrão, aplica o fator de TGFVOA (DIVIDEMULTIPLICA = 'M'
                     divide, senão multiplica QTDNEG por QUANTIDADE), mesma
                     convenção de TRG_TGFITE_SPARK1.
                   - Em transferências os itens são espelhados (entrada e
                     saída): considera apenas TGFITE.SEQUENCIA > 0 para não
                     contar em dobro, e apenas TGFITE.ATUALESTOQUE <> 0
                     (0 = item sem movimentação de estoque). O filtro de
                     ATUALESTOQUE vale só para a nota de atendimento — pedido
                     de requisição não movimenta estoque, então a quantidade
                     solicitada é somada sem esse filtro.
                   - Atendimentos sem vínculo em TGFVAR aparecem com as
                     colunas do pedido nulas (LEFT JOIN).
                   - Se um atendimento estiver vinculado a mais de um pedido
                     de origem, é gerada uma linha por pedido.
                   - DIAS_PREV_X_ENTREGA = DTMOV (entrega efetiva) menos
                     DTPREVENT do pedido: positivo = entregue com atraso;
                     negativo = entregue antes do previsto; nulo quando o
                     pedido não tem previsão de entrega.
==============================================================================*/

WITH ATENDIMENTOS AS (
    -- Requisições/transferências confirmadas no período
    SELECT  CAB.NUNOTA
           ,CAB.DTMOV
           ,CAB.CODCENCUS
           ,CUS.DESCRCENCUS
      FROM TGFCAB CAB
      LEFT JOIN TSICUS CUS ON CUS.CODCENCUS = CAB.CODCENCUS
     WHERE CAB.DTMOV >= :P_PERIODO.INI
       AND CAB.DTMOV <= :P_PERIODO.FIN
       AND CAB.TIPMOV IN ('Q', 'T')
       AND CAB.STATUSNOTA = 'L'
),
VINCULOS AS (
    -- Pedido(s) de requisição de origem de cada atendimento (TGFVAR)
    SELECT DISTINCT
            VAR.NUNOTA
           ,VAR.NUNOTAORIG
      FROM TGFVAR VAR
     INNER JOIN ATENDIMENTOS ATD ON ATD.NUNOTA = VAR.NUNOTA
),
QTD_ATENDIDA AS (
    -- Total de unidades da nota de atendimento, convertido para a unidade
    -- padrão do produto (TGFPRO.CODVOL) via fator de TGFVOA. Considera
    -- apenas itens com movimentação de estoque (ATUALESTOQUE <> 0) e o lado
    -- positivo dos itens espelhados de transferência (SEQUENCIA > 0)
    SELECT  ITE.NUNOTA
           ,SUM(CASE
                    WHEN ITE.CODVOL = PRO.CODVOL OR VOA.CODPROD IS NULL
                        THEN ITE.QTDNEG
                    WHEN VOA.DIVIDEMULTIPLICA = 'M'
                        THEN ITE.QTDNEG / VOA.QUANTIDADE
                    ELSE ITE.QTDNEG * VOA.QUANTIDADE
                END) AS QTD_ATENDIDA
      FROM TGFITE ITE
     INNER JOIN ATENDIMENTOS ATD ON ATD.NUNOTA = ITE.NUNOTA
     INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
      LEFT JOIN TGFVOA VOA ON (VOA.CODPROD = ITE.CODPROD
                           AND VOA.CODVOL = ITE.CODVOL
                           AND ((ITE.CONTROLE IS NULL AND VOA.CONTROLE = ' ')
                             OR (ITE.CONTROLE IS NOT NULL AND ITE.CONTROLE = VOA.CONTROLE)))
     WHERE ITE.SEQUENCIA > 0
       AND ITE.ATUALESTOQUE <> 0
     GROUP BY ITE.NUNOTA
),
QTD_PEDIDO AS (
    -- Total de unidades solicitadas no pedido de origem, na unidade padrão
    -- do produto. Pedido de requisição não movimenta estoque, portanto NÃO
    -- filtra por ATUALESTOQUE
    SELECT  ITE.NUNOTA
           ,SUM(CASE
                    WHEN ITE.CODVOL = PRO.CODVOL OR VOA.CODPROD IS NULL
                        THEN ITE.QTDNEG
                    WHEN VOA.DIVIDEMULTIPLICA = 'M'
                        THEN ITE.QTDNEG / VOA.QUANTIDADE
                    ELSE ITE.QTDNEG * VOA.QUANTIDADE
                END) AS QTD_SOLICITADA
      FROM TGFITE ITE
     INNER JOIN (SELECT DISTINCT VIN.NUNOTAORIG FROM VINCULOS VIN) ORG
             ON ORG.NUNOTAORIG = ITE.NUNOTA
     INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
      LEFT JOIN TGFVOA VOA ON (VOA.CODPROD = ITE.CODPROD
                           AND VOA.CODVOL = ITE.CODVOL
                           AND ((ITE.CONTROLE IS NULL AND VOA.CONTROLE = ' ')
                             OR (ITE.CONTROLE IS NOT NULL AND ITE.CONTROLE = VOA.CONTROLE)))
     WHERE ITE.SEQUENCIA > 0
     GROUP BY ITE.NUNOTA
),
PEDIDOS AS (
    -- Dados e total solicitado de cada pedido de origem
    SELECT  VIN.NUNOTA
           ,VIN.NUNOTAORIG
           ,PED.DTNEG     AS DTNEG_PEDIDO
           ,PED.DTPREVENT AS DTPREVENT_PEDIDO
           ,QTP.QTD_SOLICITADA
      FROM VINCULOS VIN
     INNER JOIN TGFCAB PED ON PED.NUNOTA = VIN.NUNOTAORIG
      LEFT JOIN QTD_PEDIDO QTP ON QTP.NUNOTA = VIN.NUNOTAORIG
)
SELECT  ATD.NUNOTA                                  AS NUNOTA
       ,ATD.DTMOV                                   AS DTMOV
       ,ATD.CODCENCUS                               AS CODCENCUS
       ,ATD.DESCRCENCUS                             AS CENTRO_RESULTADO
       ,NVL(QTA.QTD_ATENDIDA, 0)                    AS QTD_ATENDIDA
       ,PED.NUNOTAORIG                              AS NUNOTA_PEDIDO
       ,PED.DTNEG_PEDIDO                            AS DTNEG_PEDIDO
       ,PED.DTPREVENT_PEDIDO                        AS DTPREVENT
       ,TRUNC(ATD.DTMOV)
        - TRUNC(PED.DTPREVENT_PEDIDO)               AS DIAS_PREV_X_ENTREGA
       ,NVL(PED.QTD_SOLICITADA, 0)                  AS QTD_SOLICITADA
       ,ROUND(NVL(QTA.QTD_ATENDIDA, 0)
              / NULLIF(PED.QTD_SOLICITADA, 0)
              * 100, 2)                             AS PERC_ATENDIMENTO
  FROM ATENDIMENTOS ATD
  LEFT JOIN QTD_ATENDIDA QTA ON QTA.NUNOTA = ATD.NUNOTA
  LEFT JOIN PEDIDOS PED ON PED.NUNOTA = ATD.NUNOTA
 ORDER BY ATD.DTMOV
         ,ATD.NUNOTA
