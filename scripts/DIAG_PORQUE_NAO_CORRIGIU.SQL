/*==============================================================================
  Nome do Script : DIAG_PORQUE_NAO_CORRIGIU
  Tipo           : Script de diagnóstico (somente leitura)
  Descrição      : Explica por que uma OP não foi corrigida pela
                   STP_CORRIGEAPONTAMENTO_SPARK. Para cada conferência da OP
                   avalia, na ordem do cursor da procedure, cada critério de
                   elegibilidade e devolve na coluna MOTIVO o primeiro que a
                   deixa de fora.

                   Valores de MOTIVO (na ordem em que são avaliados):
                     OP_ENCERRADA            — STATUSPROC C, C2 ou F
                     CONFERENCIA_NAO_FINALIZADA — TPRCONF.STATUS <> 'F'
                     SEM_NUAPO               — conferência sem apontamento vinculado
                     SEM_SERIES              — nenhuma série em AD_TPRCOI
                     SEM_TPRAPA              — NUAPO sem linha em TPRAPA para o PA
                     ETAPA_NAO_EXPEDICAO     — apontamento de outra etapa
                     SEM_DIVERGENCIA         — apontamento já confere com as séries
                     FORA_DA_JANELA          — finalizada antes de hoje - P_DIAS
                     IGNORADO_MULTICONF      — mesmo NUAPO em >1 conferência final.
                     IGNORADO_MULTISEQ       — >1 linha em TPRAPA p/ o mesmo PA
                     ELEGIVEL                — a procedure deveria corrigir; ver
                                               consultas 2 e 3 (log/auditoria),
                                               linha bloqueada ou agendamento

  Parâmetros     : Editar a CTE PARAMS abaixo:
                     P_IDIPROC — OP investigada
                     P_DIAS    — mesma janela usada na chamada agendada
  Tabelas        : TPRCONF, TPRIATV, TPRIPROC, TPRAPO, TPREFX, TPRAPA,
                   AD_TPRCOI, AD_CORRAPONTAMENTO, AD_LOG_ERROS (leitura)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação do script

  Observações    : Manter os critérios sincronizados com o cursor C_DIVERG de
                   procedures/STP_CORRIGEAPONTAMENTO_SPARK.SQL. Se o resultado
                   for ELEGIVEL e não houver linha em AD_CORRAPONTAMENTO nem
                   em AD_LOG_ERROS, verifique se o job agendado está ativo e
                   com qual P_DIAS, e se a linha do TPRAPA estava bloqueada
                   (a procedure pula bloqueio em silêncio).
==============================================================================*/

-- Consulta 1: critério que barrou cada conferência da OP
WITH PARAMS AS (
    SELECT  33731 AS P_IDIPROC   -- OP investigada
           ,3     AS P_DIAS      -- janela da chamada agendada
    FROM    DUAL
),
SERIES_CONF AS (
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
           ,CNF.STATUS                AS STATUS_CONF
           ,CNF.DHFINCONF
           ,PROC.STATUSPROC
           ,CNF.NUAPO
           ,APA.SEQAPA
           ,EFX.DESCRICAO             AS ETAPA_APONTAMENTO
           ,SER.QTD_SERIES
           ,APA.QTDAPONTADA
           ,APA.QTDFAT
           ,COALESCE(CNF.DHFINCONF, SER.DHINC) AS DH_REFERENCIA
           ,PRM.P_DIAS
           ,(SELECT COUNT(*)
               FROM TPRCONF C2
              WHERE C2.NUAPO  = CNF.NUAPO
                AND C2.STATUS = 'F')            AS QTD_CONF_APO
           ,(SELECT COUNT(*)
               FROM TPRAPA A2
              WHERE A2.NUAPO     = CNF.NUAPO
                AND A2.CODPRODPA = SER.CODPROD) AS QTD_SEQ_APO
    FROM    PARAMS PRM
            INNER JOIN TPRIATV     ATV  ON ATV.IDIPROC  = PRM.P_IDIPROC
            INNER JOIN TPRIPROC    PROC ON PROC.IDIPROC = ATV.IDIPROC
            INNER JOIN TPRCONF     CNF  ON CNF.IDIATV   = ATV.IDIATV
            LEFT  JOIN SERIES_CONF SER  ON SER.NUCONF   = CNF.NUCONF
            LEFT  JOIN TPRAPA      APA  ON APA.NUAPO     = CNF.NUAPO
                                       AND APA.CODPRODPA = SER.CODPROD
            LEFT  JOIN TPRAPO      APO  ON APO.NUAPO    = APA.NUAPO
            LEFT  JOIN TPRIATV     ATA  ON ATA.IDIATV   = APO.IDIATV
            LEFT  JOIN TPREFX      EFX  ON EFX.IDEFX    = ATA.IDEFX
)
SELECT  BAS.NUCONF
       ,BAS.STATUS_CONF
       ,BAS.DHFINCONF
       ,BAS.STATUSPROC
       ,BAS.NUAPO
       ,BAS.SEQAPA
       ,BAS.ETAPA_APONTAMENTO
       ,NVL(BAS.QTD_SERIES, 0) AS SERIES_EM_AD_TPRCOI
       ,BAS.QTDAPONTADA
       ,BAS.QTDFAT
       ,CASE
            WHEN BAS.STATUSPROC IN ('C', 'C2', 'F')   THEN 'OP_ENCERRADA'
            WHEN BAS.STATUS_CONF <> 'F'               THEN 'CONFERENCIA_NAO_FINALIZADA'
            WHEN BAS.NUAPO IS NULL                    THEN 'SEM_NUAPO'
            WHEN BAS.QTD_SERIES IS NULL               THEN 'SEM_SERIES'
            WHEN BAS.SEQAPA IS NULL                   THEN 'SEM_TPRAPA'
            WHEN BAS.ETAPA_APONTAMENTO IS NULL
              OR BAS.ETAPA_APONTAMENTO NOT IN ('EXPEDIÇÃO/CONFERENCIA', 'EXPEDICAO/CONF')
                                                      THEN 'ETAPA_NAO_EXPEDICAO'
            WHEN BAS.QTDAPONTADA = BAS.QTD_SERIES
             AND BAS.QTDFAT      = BAS.QTD_SERIES     THEN 'SEM_DIVERGENCIA'
            WHEN BAS.DH_REFERENCIA < TRUNC(SYSDATE) - BAS.P_DIAS
                                                      THEN 'FORA_DA_JANELA'
            WHEN BAS.QTD_CONF_APO > 1                 THEN 'IGNORADO_MULTICONF'
            WHEN BAS.QTD_SEQ_APO  > 1                 THEN 'IGNORADO_MULTISEQ'
            ELSE 'ELEGIVEL'
        END AS MOTIVO
FROM    BASE BAS
ORDER BY BAS.NUCONF;

-- Consulta 2: o que a procedure já registrou para a OP (auditoria)
SELECT  COR.*
FROM    AD_CORRAPONTAMENTO COR
WHERE   COR.IDIPROC = 33731   -- mesma OP da CTE PARAMS acima
ORDER BY COR.NUCORR;

-- Consulta 3: erros da procedure nos apontamentos da OP
SELECT  LGE.IDLOG
       ,LGE.DHLOG
       ,LGE.NUNOTA AS NUAPO
       ,LGE.ERROR_CODE
       ,LGE.ERROR_MESSAGE
FROM    AD_LOG_ERROS LGE
WHERE   LGE.TRIGGER_NAME = 'STP_CORRIGEAPONTAMENTO_SPARK'
AND     LGE.NUNOTA IN (SELECT APO.NUAPO
                         FROM TPRAPO APO
                              INNER JOIN TPRIATV ATV ON ATV.IDIATV = APO.IDIATV
                        WHERE ATV.IDIPROC = 33731)  -- mesma OP da CTE PARAMS acima
ORDER BY LGE.IDLOG DESC;
