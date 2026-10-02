/*==============================================================================
  Nome do Script : DRYRUN_CORRIGEAPONTAMENTO
  Tipo           : Script de simulação (somente leitura)
  Descrição      : Simula a STP_CORRIGEAPONTAMENTO_SPARK sem alterar nada.
                   Aplica exatamente o mesmo universo e as mesmas regras da
                   procedure (conferências finalizadas, OP não cancelada,
                   janela P_DIAS ou OP específica) e mostra, para cada
                   conferência, a AÇÃO que a procedure tomaria. Lista APENAS
                   as falhas (apontamento existente cuja QTDAPONTADA/QTDFAT
                   diverge do nº de séries); conferências corretas ou sem nada
                   a corrigir (sem NUAPO, sem séries, sem linha em TPRAPA) não
                   aparecem. Resultado vazio = nenhuma falha no escopo.

                   Valores de ACAO:
                     AJUSTARIA          — a procedure faria o UPDATE (ver
                                          SQL_EQUIVALENTE)
                     IGNORADO_MULTICONF — apontamento atende >1 conferência
                                          finalizada; só seria registrado
                     IGNORADO_MULTISEQ  — >1 linha em TPRAPA p/ o mesmo PA; só
                                          seria registrado
                     OP_FINALIZADA      — apontamento diverge, mas a OP está
                                          finalizada (STATUSPROC 'F'); a
                                          procedure NÃO altera, só informa aqui

  Parâmetros     : Editar a CTE PARAMS abaixo:
                     P_DIAS    — janela em dias pela finalização da conferência
                     P_IDIPROC — OP específica (NULL = varre pela janela; quando
                                 informado a janela é ignorada, como na procedure)
  Tabelas        : TPRCONF, TPRIATV, TPRIPROC, AD_TPRCOI, TPRAPA (leitura)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação do script
                   Outubro/2026 — OP finalizada ('F') nunca recebe ação
                   (ACAO = OP_FINALIZADA); coluna STATUSPROC adicionada
                   Outubro/2026 — Passa a listar somente as falhas (removidas
                   as situações OK, SEM_NUAPO, SEM_SERIES e SEM_TPRAPA)

  Observações    : Ordens canceladas ('C') e em cancelamento ('C2') ficam fora
                   da listagem, como na procedure. Ordens finalizadas ('F') com falha são listadas
                   (coluna STATUSPROC) mas nunca recebem SQL_EQUIVALENTE.
                   Para ver também as conferências sem falha, ou sem vínculo
                   (SEM_NUAPO/SEM_SERIES/SEM_TPRAPA), use
                   scripts/DIAG_APONTAMENTO_VS_CONFERENCIA.SQL.
                   Manter a lógica sincronizada com o cursor C_DIVERG de
                   procedures/STP_CORRIGEAPONTAMENTO_SPARK.SQL. Para um resumo
                   por ação, envolva a consulta em
                   SELECT ACAO, COUNT(*) FROM (...) GROUP BY ACAO.
==============================================================================*/

WITH PARAMS AS (
    SELECT  120  AS P_DIAS      -- janela de varredura em dias
           ,NULL AS P_IDIPROC   -- ex.: 33743 para uma OP específica
    FROM    DUAL
),
SERIES_CONF AS (
    -- Séries distintas do PA consolidadas por conferência
    SELECT  COI.NUCONF
           ,COI.CODPROD
           ,COUNT(DISTINCT COI.CODBARRA) AS QTD_SERIES
           ,MAX(COI.DTINCLUSAO)          AS DHINC
    FROM    AD_TPRCOI COI
    GROUP BY COI.NUCONF
            ,COI.CODPROD
),
BASE AS (
    SELECT  CNF.NUCONF
           ,ATV.IDIPROC
           ,PROC.STATUSPROC
           ,CNF.NUAPO
           ,APA.SEQAPA
           ,SER.CODPROD
           ,SER.QTD_SERIES
           ,APA.QTDAPONTADA
           ,APA.QTDFAT
           ,(SELECT COUNT(*)
               FROM TPRCONF C2
              WHERE C2.NUAPO  = CNF.NUAPO
                AND C2.STATUS = 'F')            AS QTD_CONF_APO
           ,(SELECT COUNT(*)
               FROM TPRAPA A2
              WHERE A2.NUAPO     = CNF.NUAPO
                AND A2.CODPRODPA = SER.CODPROD) AS QTD_SEQ_APO
    FROM    TPRCONF CNF
            CROSS JOIN PARAMS PRM
            INNER JOIN TPRIATV     ATV  ON ATV.IDIATV   = CNF.IDIATV
            INNER JOIN TPRIPROC    PROC ON PROC.IDIPROC = ATV.IDIPROC
            LEFT  JOIN SERIES_CONF SER  ON SER.NUCONF   = CNF.NUCONF
            LEFT  JOIN TPRAPA      APA  ON APA.NUAPO     = CNF.NUAPO
                                       AND APA.CODPRODPA = SER.CODPROD
    WHERE   CNF.STATUS       = 'F'
    AND     PROC.STATUSPROC NOT IN ('C', 'C2')
    -- Somente falhas: apontamento existente que diverge do nº de séries
    AND     SER.NUCONF IS NOT NULL
    AND     APA.NUAPO  IS NOT NULL
    AND     (   APA.QTDAPONTADA <> SER.QTD_SERIES
             OR APA.QTDFAT      <> SER.QTD_SERIES)
    AND     (   ATV.IDIPROC = PRM.P_IDIPROC
             OR (    PRM.P_IDIPROC IS NULL
                 AND COALESCE(CNF.DHFINCONF, SER.DHINC) >= TRUNC(SYSDATE) - PRM.P_DIAS))
)
SELECT  BAS.IDIPROC
       ,BAS.STATUSPROC
       ,BAS.NUCONF
       ,BAS.NUAPO
       ,BAS.SEQAPA
       ,BAS.CODPROD
       ,NVL(BAS.QTD_SERIES, 0) AS SERIES_EM_AD_TPRCOI
       ,BAS.QTDAPONTADA
       ,BAS.QTDFAT
       ,BAS.QTD_CONF_APO
       ,BAS.QTD_SEQ_APO
       ,CASE
            WHEN BAS.STATUSPROC = 'F'    THEN 'OP_FINALIZADA'
            WHEN BAS.QTD_CONF_APO > 1    THEN 'IGNORADO_MULTICONF'
            WHEN BAS.QTD_SEQ_APO  > 1    THEN 'IGNORADO_MULTISEQ'
            ELSE 'AJUSTARIA'
        END AS ACAO
       ,CASE
            WHEN BAS.STATUSPROC   <> 'F'
             AND BAS.QTD_CONF_APO <= 1
             AND BAS.QTD_SEQ_APO  <= 1
            THEN 'UPDATE TPRAPA SET QTDAPONTADA = ' || BAS.QTD_SERIES
              || ', QTDFAT = ' || BAS.QTD_SERIES
              || ' WHERE NUAPO = ' || BAS.NUAPO
              || ' AND SEQAPA = ' || BAS.SEQAPA || ';'
        END AS SQL_EQUIVALENTE
FROM    BASE BAS
ORDER BY BAS.IDIPROC
        ,BAS.NUCONF;
