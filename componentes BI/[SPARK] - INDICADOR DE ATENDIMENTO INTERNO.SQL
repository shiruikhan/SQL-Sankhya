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
                   às notas que a atenderam (NUNOTA/SEQUENCIA). Notas de
                   atendimento com CODTIPOPER = 409 são desconsideradas: são
                   movimentações automáticas disparadas pelo próprio
                   atendimento via CODTIPOPER 408, não um atendimento real.

                   O campo PENDENTE (preenchimento manual do usuário, presente
                   em TGFCAB e TGFITE) sobrepõe o cálculo automático quando
                   preenchido ('S' ou 'N'):
                   - TGFITE.PENDENTE = 'N' força o código como atendido, mesmo
                     sem vínculo em TGFVAR; = 'S' força o código como não
                     atendido, mesmo havendo vínculo. Em branco, prevalece o
                     cálculo automático via TGFVAR. Havendo mais de um
                     lançamento do mesmo código na solicitação, prevalece o
                     mais restritivo ('S' sobre 'N').
                   - TGFCAB.PENDENTE tem prioridade máxima sobre a situação
                     final: = 'N' força SITUACAO = 'ATENDIDA'; = 'S' garante
                     SITUACAO <> 'ATENDIDA' (fica 'PARCIAL' ou 'PENDENTE',
                     conforme os códigos). Em branco, prevalece o cálculo pelos
                     códigos.
                   - Um código com vínculo real em TGFVAR sempre usa a data
                     desse vínculo, mesmo que o PENDENTE do item esteja
                     preenchido com 'N'. Só quando o código é forçado como
                     atendido SEM nenhum vínculo em TGFVAR é que se usa uma
                     data alternativa: TGFITE.DTALTER (item) ou, se o
                     cabeçalho forçar a solicitação inteira como atendida sem
                     nenhum código com data, TGFCAB.DTALTER (cabeçalho). Um
                     código forçado como NÃO atendido (PENDENTE = 'S') nunca
                     carrega data, mesmo que exista vínculo em TGFVAR.

  Parâmetros     : :P_PERIODO.INI — data inicial do período (DTNEG da solicitação)
                   :P_PERIODO.FIN — data final do período (DTNEG da solicitação)
                   :P_ATENDIMENTO — filtro múltiplo de situação: 'S' = atendidas,
                                    'N' = não atendidas (pendentes), 'P' = parciais

  Tabelas        : TGFCAB — cabeçalho da solicitação e das notas de atendimento
                   TGFITE — itens da solicitação (códigos solicitados)
                   TGFVAR — vínculo item a item entre atendimento e solicitação
                   TSICUS — centro de resultado (setor solicitante)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 18/08/2026
  Última Revisão : Agosto/2026 — Passa a considerar o campo PENDENTE manual
                   (TGFCAB e TGFITE) no cálculo da situação, adiciona o filtro
                   múltiplo :P_ATENDIMENTO (atendida/não atendida/parcial),
                   usa DTALTER como data alternativa para atendimento forçado
                   sem vínculo em TGFVAR (evita perder a data do indicador) e
                   desconsidera notas de atendimento com CODTIPOPER 409
                   (movimentação automática gerada pelo CODTIPOPER 408)
==============================================================================*/

WITH SOLICITACOES AS (
    -- Solicitações internas confirmadas no período, exceto as geradas pelo
    -- plano de produção (TOP 402)
    SELECT  CAB.NUNOTA
           ,TRUNC(CAB.DTNEG) AS DT_SOLICITACAO
           ,CAB.CODCENCUS
           ,CUS.DESCRCENCUS
           ,CAB.PENDENTE     AS PENDENTE_CAB
           ,CAB.DTALTER      AS DTALTER_CAB
      FROM TGFCAB CAB
      LEFT JOIN TSICUS CUS ON CUS.CODCENCUS = CAB.CODCENCUS
     WHERE CAB.DTNEG >= :P_PERIODO.INI
       AND CAB.DTNEG <= :P_PERIODO.FIN
       AND CAB.TIPMOV = 'J'
       AND CAB.STATUSNOTA = 'L'
       AND CAB.CODTIPOPER <> 402
),
ITENS_SOLICITADOS AS (
    -- Códigos distintos pedidos em cada solicitação, com o PENDENTE manual do
    -- item. Havendo mais de um lançamento do mesmo código, prevalece o mais
    -- restritivo ('S' sobre 'N', pois MAX ordena 'S' > 'N')
    SELECT  ITE.NUNOTA
           ,ITE.CODPROD
           ,MAX(ITE.PENDENTE) AS PENDENTE_ITEM
           ,MAX(ITE.DTALTER)  AS DTALTER_ITEM
      FROM TGFITE ITE
     INNER JOIN SOLICITACOES SOL ON SOL.NUNOTA = ITE.NUNOTA
     WHERE ITE.SEQUENCIA > 0
     GROUP BY ITE.NUNOTA
             ,ITE.CODPROD
),
CODIGOS_SOLICITADOS AS (
    -- Quantidade de códigos distintos pedidos em cada solicitação
    SELECT  ISO.NUNOTA
           ,COUNT(*) AS QTD_CODIGOS_SOLICITADOS
      FROM ITENS_SOLICITADOS ISO
     GROUP BY ISO.NUNOTA
),
VINCULOS_CODIGO AS (
    -- Data do primeiro atendimento de cada código da solicitação. O vínculo
    -- em TGFVAR é por item e pode apontar para notas de atendimento distintas.
    -- CODTIPOPER 409 é desconsiderado: são movimentações automáticas geradas
    -- pelo próprio atendimento via CODTIPOPER 408, não um atendimento real
    SELECT  VAR.NUNOTAORIG        AS NUNOTA
           ,ITO.CODPROD
           ,MIN(TRUNC(ATE.DTNEG)) AS DT_ATENDIMENTO_CODIGO
      FROM TGFVAR VAR
     INNER JOIN SOLICITACOES SOL ON SOL.NUNOTA = VAR.NUNOTAORIG
     INNER JOIN TGFITE ITO ON ITO.NUNOTA = VAR.NUNOTAORIG
                          AND ITO.SEQUENCIA = VAR.SEQUENCIAORIG
     INNER JOIN TGFCAB ATE ON ATE.NUNOTA = VAR.NUNOTA
                          AND ATE.STATUSNOTA = 'L'
                          AND ATE.CODTIPOPER <> 409
     GROUP BY VAR.NUNOTAORIG
             ,ITO.CODPROD
),
STATUS_CODIGO AS (
    -- Situação efetiva de cada código: o PENDENTE manual do item sobrepõe o
    -- vínculo automático. O vínculo real em TGFVAR sempre tem prioridade
    -- como data; só se recorre ao DTALTER do item quando o código é forçado
    -- como atendido sem nenhum vínculo. Código forçado como não atendido
    -- nunca carrega data, mesmo havendo vínculo
    SELECT  ISO.NUNOTA
           ,ISO.CODPROD
           ,CASE
                WHEN ISO.PENDENTE_ITEM = 'N' THEN 'S'
                WHEN ISO.PENDENTE_ITEM = 'S' THEN 'N'
                WHEN VIN.CODPROD IS NOT NULL THEN 'S'
                ELSE 'N'
            END AS ATENDIDO
           ,CASE
                WHEN ISO.PENDENTE_ITEM = 'S' THEN NULL
                WHEN VIN.DT_ATENDIMENTO_CODIGO IS NOT NULL THEN VIN.DT_ATENDIMENTO_CODIGO
                WHEN ISO.PENDENTE_ITEM = 'N' THEN TRUNC(ISO.DTALTER_ITEM)
                ELSE NULL
            END AS DT_ATENDIMENTO_CODIGO
      FROM ITENS_SOLICITADOS ISO
      LEFT JOIN VINCULOS_CODIGO VIN ON VIN.NUNOTA  = ISO.NUNOTA
                                    AND VIN.CODPROD = ISO.CODPROD
),
ATENDIMENTOS AS (
    -- Consolida os códigos atendidos e a data em que o último deles foi
    -- atendido (conclusão da solicitação). MAX ignora as datas nulas dos
    -- códigos forçados manualmente sem vínculo real
    SELECT  STC.NUNOTA
           ,COUNT(CASE WHEN STC.ATENDIDO = 'S' THEN 1 END) AS QTD_CODIGOS_ATENDIDOS
           ,MAX(STC.DT_ATENDIMENTO_CODIGO)                 AS DT_ATENDIMENTO_TOTAL
      FROM STATUS_CODIGO STC
     GROUP BY STC.NUNOTA
),
BASE AS (
    -- Junta solicitação, códigos pedidos e atendimento. A situação final
    -- considera primeiro o PENDENTE manual do cabeçalho (prioridade máxima)
    -- e, na ausência dele, a contagem de códigos atendidos
    SELECT  SOL.NUNOTA
           ,SOL.DT_SOLICITACAO
           ,SOL.CODCENCUS
           ,SOL.DESCRCENCUS
           ,COD.QTD_CODIGOS_SOLICITADOS
           ,NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) AS QTD_CODIGOS_ATENDIDOS
           ,CASE
                WHEN SOL.PENDENTE_CAB = 'N' THEN 'ATENDIDA'
                WHEN SOL.PENDENTE_CAB = 'S' THEN
                    CASE WHEN NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) = 0 THEN 'PENDENTE' ELSE 'PARCIAL' END
                WHEN NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) = 0 THEN 'PENDENTE'
                WHEN ATD.QTD_CODIGOS_ATENDIDOS < COD.QTD_CODIGOS_SOLICITADOS THEN 'PARCIAL'
                ELSE 'ATENDIDA'
            END                               AS SITUACAO
           ,CASE
                WHEN SOL.PENDENTE_CAB = 'S' THEN NULL
                WHEN ATD.DT_ATENDIMENTO_TOTAL IS NOT NULL
                    AND (SOL.PENDENTE_CAB = 'N'
                         OR NVL(ATD.QTD_CODIGOS_ATENDIDOS, 0) >= COD.QTD_CODIGOS_SOLICITADOS)
                    THEN ATD.DT_ATENDIMENTO_TOTAL
                -- Cabeçalho forçou a solicitação inteira como atendida, mas
                -- nenhum código ficou com data (todos sem vínculo e sem
                -- PENDENTE de item preenchido): usa o DTALTER do cabeçalho
                WHEN SOL.PENDENTE_CAB = 'N' THEN TRUNC(SOL.DTALTER_CAB)
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
       ,BAS.SITUACAO                            AS SITUACAO
  FROM BASE BAS
 WHERE (CASE BAS.SITUACAO
            WHEN 'ATENDIDA' THEN 'S'
            WHEN 'PENDENTE' THEN 'N'
            WHEN 'PARCIAL'  THEN 'P'
        END) IN :P_ATENDIMENTO
 ORDER BY BAS.DT_SOLICITACAO
         ,BAS.NUNOTA
