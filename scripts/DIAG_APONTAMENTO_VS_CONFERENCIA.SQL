/*==============================================================================
  Nome do Script : DIAG_APONTAMENTO_VS_CONFERENCIA
  Tipo           : Script de diagnóstico (somente leitura)
  Descrição      : Confronta, por conferência (TPRCONF) de uma OP (IDIPROC),
                   o nº de séries consolidadas em AD_TPRCOI com as quantidades
                   do apontamento vinculado (TPRAPA.QTDAPONTADA / QTDFAT).
                   Aponta os apontamentos divergentes (normalmente zerados ou
                   com quantidade incorreta, o que dispara a validação do
                   Sankhya) e devolve, na coluna SQL_CORRECAO, o UPDATE pronto
                   para revisão e execução manual.

                   Regra de "correto": QTDAPONTADA = QTDFAT = nº de séries
                   distintas (CODBARRA) do PA em AD_TPRCOI da conferência.

  Parâmetros     : :P_IDIPROC — ID da OP (TPRIPROC.IDIPROC) alvo do problema
  Tabelas        : TPRCONF, TPRIATV, AD_TPRCOI, TPRAPA (leitura)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação do script

  Observações    : - O script NÃO executa nenhuma correção; apenas gera o texto
                     do UPDATE. Revisar a coluna SITUACAO antes de rodar.
                   - Situações: OK | DIVERGENTE | SEM_NUAPO (conferência sem
                     apontamento vinculado) | SEM_SERIES (conferência sem
                     séries em AD_TPRCOI, ex.: ainda aberta) | SEM_TPRAPA
                     (NUAPO vinculado sem linha de TPRAPA para o PA).
                   - O UPDATE em TPRAPA dispara TRG_INC_UPD_DLT_TPRAPA_SPARK:
                     apaga e recria TPRSERPA da OP/PA e, com QTDFAT > 0,
                     insere novas séries em AD_TPRSERAPO. Rodar o UPDATE uma
                     única vez por apontamento e conferir TPRSERPA depois.
                   - Se um mesmo apontamento (NUAPO) atender mais de uma
                     conferência, o script lista ambas; avaliar manualmente.
==============================================================================*/

WITH SERIES_CONF AS (
    -- Séries distintas do PA consolidadas por conferência
    SELECT  COI.NUCONF
           ,COI.CODPROD
           ,COUNT(DISTINCT COI.CODBARRA) AS QTD_SERIES
    FROM    AD_TPRCOI COI
    GROUP BY COI.NUCONF
            ,COI.CODPROD
)
SELECT  CNF.NUCONF
       ,CNF.STATUS
       ,CNF.NUAPO
       ,APA.SEQAPA
       ,SER.CODPROD
       ,NVL(SER.QTD_SERIES, 0)  AS SERIES_EM_AD_TPRCOI
       ,APA.QTDAPONTADA
       ,APA.QTDFAT
       ,CASE
            WHEN CNF.NUAPO IS NULL     THEN 'SEM_NUAPO'
            WHEN SER.NUCONF IS NULL    THEN 'SEM_SERIES'
            WHEN APA.NUAPO IS NULL     THEN 'SEM_TPRAPA'
            WHEN APA.QTDAPONTADA <> SER.QTD_SERIES
              OR APA.QTDFAT      <> SER.QTD_SERIES THEN 'DIVERGENTE'
            ELSE 'OK'
        END AS SITUACAO
       ,CASE
            WHEN APA.NUAPO IS NOT NULL
             AND SER.NUCONF IS NOT NULL
             AND (APA.QTDAPONTADA <> SER.QTD_SERIES
               OR APA.QTDFAT      <> SER.QTD_SERIES)
            THEN 'UPDATE TPRAPA SET QTDAPONTADA = ' || SER.QTD_SERIES
              || ', QTDFAT = ' || SER.QTD_SERIES
              || ' WHERE NUAPO = ' || APA.NUAPO
              || ' AND SEQAPA = ' || APA.SEQAPA || ';'
        END AS SQL_CORRECAO
FROM    TPRCONF CNF
        INNER JOIN TPRIATV     ATV ON ATV.IDIATV    = CNF.IDIATV
        LEFT  JOIN SERIES_CONF SER ON SER.NUCONF    = CNF.NUCONF
        LEFT  JOIN TPRAPA      APA ON APA.NUAPO     = CNF.NUAPO
                                  AND APA.CODPRODPA = SER.CODPROD
WHERE   ATV.IDIPROC = :P_IDIPROC
ORDER BY CNF.NUCONF;
