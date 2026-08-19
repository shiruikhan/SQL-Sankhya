/*==============================================================================
  Nome do Script : [SPARK] - INDICADOR DE ATENDIMENTO INTERNO
  Tipo           : Componente BI — Tabela
  Descrição      : Indicador de atendimento das solicitações internas
                   (TGFCAB.TIPMOV = 'J'). Para cada solicitação confirmada no
                   período lista o número único, a data de solicitação, a data
                   em que ela ficou totalmente atendida, o tempo de atendimento
                   (em dias úteis e em dias corridos), o setor solicitante
                   (centro de resultado) e a quantidade de códigos de produto
                   solicitados.

                   O atendimento é apurado pela tabela de vínculo TGFVAR, que
                   amarra a solicitação de origem (NUNOTAORIG/SEQUENCIAORIG)
                   às notas que a atenderam (NUNOTA/SEQUENCIA).

  Parâmetros     : :P_PERIODO.INI — data inicial do período (DTNEG da solicitação)
                   :P_PERIODO.FIN — data final do período (DTNEG da solicitação)

  Tabelas        : TGFCAB — cabeçalho da solicitação e das notas de atendimento
                   TGFITE — itens da solicitação (códigos solicitados)
                   TGFVAR — vínculo item a item entre atendimento e solicitação
                   TSICUS — centro de resultado (setor solicitante)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 18/08/2026
  Última Revisão : Agosto/2026 — Criação
==============================================================================*/

WITH SOLICITACOES AS (
    -- Solicitações internas confirmadas no período, exceto as geradas pelo
    -- plano de produção (TOP 402)
    SELECT  CAB.NUNOTA
           ,TRUNC(CAB.DTNEG) AS DT_SOLICITACAO
           ,CAB.CODCENCUS
           ,CUS.DESCRCENCUS
      FROM TGFCAB CAB
      LEFT JOIN TSICUS CUS ON CUS.CODCENCUS = CAB.CODCENCUS
     WHERE CAB.DTNEG >= :P_PERIODO.INI
       AND CAB.DTNEG <= :P_PERIODO.FIN
       AND CAB.TIPMOV = 'J'
       AND CAB.STATUSNOTA = 'L'
       AND CAB.CODTIPOPER <> 402
),
CODIGOS_SOLICITADOS AS (
    -- Quantidade de códigos distintos pedidos em cada solicitação
    SELECT  ITE.NUNOTA
           ,COUNT(DISTINCT ITE.CODPROD) AS QTD_CODIGOS_SOLICITADOS
      FROM TGFITE ITE
     INNER JOIN SOLICITACOES SOL ON SOL.NUNOTA = ITE.NUNOTA
     WHERE ITE.SEQUENCIA > 0
     GROUP BY ITE.NUNOTA
),
VINCULOS_CODIGO AS (
    -- Data do primeiro atendimento de cada código da solicitação. O vínculo
    -- em TGFVAR é por item e pode apontar para notas de atendimento distintas
    SELECT  VAR.NUNOTAORIG        AS NUNOTA
           ,ITO.CODPROD
           ,MIN(TRUNC(ATE.DTNEG)) AS DT_ATENDIMENTO_CODIGO
      FROM TGFVAR VAR
     INNER JOIN SOLICITACOES SOL ON SOL.NUNOTA = VAR.NUNOTAORIG
     INNER JOIN TGFITE ITO ON ITO.NUNOTA = VAR.NUNOTAORIG
                          AND ITO.SEQUENCIA = VAR.SEQUENCIAORIG
     INNER JOIN TGFCAB ATE ON ATE.NUNOTA = VAR.NUNOTA
                          AND ATE.STATUSNOTA = 'L'
     GROUP BY VAR.NUNOTAORIG
             ,ITO.CODPROD
),
ATENDIMENTOS AS (
    -- Consolida os códigos atendidos e a data em que o último deles foi
    -- atendido (conclusão da solicitação)
    SELECT  VIN.NUNOTA
           ,COUNT(*)                       AS QTD_CODIGOS_ATENDIDOS
           ,MAX(VIN.DT_ATENDIMENTO_CODIGO) AS DT_ATENDIMENTO_TOTAL
      FROM VINCULOS_CODIGO VIN
     GROUP BY VIN.NUNOTA
),
BASE AS (
    -- Junta solicitação, códigos pedidos e atendimento; a data de atendimento
    -- só é considerada quando todos os códigos foram atendidos
    SELECT  SOL.NUNOTA
           ,SOL.DT_SOLICITACAO
           ,SOL.CODCENCUS
           ,SOL.DESCRCENCUS
           ,COD.QTD_CODIGOS_SOLICITADOS
           ,NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) AS QTD_CODIGOS_ATENDIDOS
           ,CASE
                WHEN NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) >= COD.QTD_CODIGOS_SOLICITADOS
                    THEN ATD.DT_ATENDIMENTO_TOTAL
            END                               AS DT_ATENDIMENTO
      FROM SOLICITACOES SOL
     INNER JOIN CODIGOS_SOLICITADOS COD ON COD.NUNOTA = SOL.NUNOTA
      LEFT JOIN ATENDIMENTOS ATD ON ATD.NUNOTA = SOL.NUNOTA
)
SELECT  BAS.NUNOTA                              AS NUNOTA
       ,BAS.DT_SOLICITACAO                      AS DT_SOLICITACAO
       ,BAS.DT_ATENDIMENTO                      AS DT_ATENDIMENTO
        -- Dias úteis: semanas ISO completas x 5, mais a posição do dia dentro
        -- da semana limitada a 5 (sábado e domingo contam como sexta-feira)
       ,(TRUNC(BAS.DT_ATENDIMENTO, 'IW')     
         - TRUNC(BAS.DT_SOLICITACAO, 'IW')) / 7 * 5
        + LEAST(BAS.DT_ATENDIMENTO - TRUNC(BAS.DT_ATENDIMENTO, 'IW') + 1, 5)
        - LEAST(BAS.DT_SOLICITACAO - TRUNC(BAS.DT_SOLICITACAO, 'IW') + 1, 5)
                                                AS DIAS_UTEIS_ATENDIMENTO
       ,BAS.DT_ATENDIMENTO - BAS.DT_SOLICITACAO AS DIAS_CORRIDOS_ATENDIMENTO
       ,CASE
            WHEN BAS.CODCENCUS IS NULL THEN NULL
            ELSE BAS.CODCENCUS || ' - ' || BAS.DESCRCENCUS
        END                                     AS SETOR_SOLICITANTE
       ,BAS.QTD_CODIGOS_SOLICITADOS             AS QTD_CODIGOS_SOLICITADOS
       ,BAS.QTD_CODIGOS_ATENDIDOS               AS QTD_CODIGOS_ATENDIDOS
       ,CASE
            WHEN BAS.QTD_CODIGOS_ATENDIDOS = 0 THEN 'PENDENTE'
            WHEN BAS.QTD_CODIGOS_ATENDIDOS < BAS.QTD_CODIGOS_SOLICITADOS THEN 'PARCIAL'
            ELSE 'ATENDIDA'
        END                                     AS SITUACAO
  FROM BASE BAS
 ORDER BY BAS.DT_SOLICITACAO
         ,BAS.NUNOTA
