WITH DT_REF AS (
    /*-- Ultima data util (seg-sex) anterior a hoje ------------------------*/
    SELECT  MAX(D.DIA) AS DTREF
      FROM  (SELECT  TRUNC(SYSDATE) - LEVEL AS DIA
               FROM  DUAL
            CONNECT BY LEVEL <= 10) D
     WHERE  TO_CHAR(D.DIA, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN')
),
BOLETOS AS (
    /*-- Boletos a vencer (em aberto na DTREF, vencimento >= DTREF) --------*/
    SELECT  'A VENCER'          AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC    >= R.DTREF

    UNION ALL
    /*-- Boletos vencidos (em aberto na DTREF, vencimento < DTREF) --------*/
    SELECT  'VENCIDO'           AS STATUS
           ,COUNT(0)            AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)   AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 4
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC     < R.DTREF

    UNION ALL
    /*-- Boletos em cartorio (titulo protestado, vencimento < DTREF) ------*/
    SELECT  'BOLETO EM CARTORIO' AS STATUS
           ,COUNT(0)             AS CONTAGEM
           ,SUM(F.VLRLIQUIDO)    AS TOTAL
      FROM  TGFFIN FIN
            CROSS JOIN DT_REF R
            INNER JOIN TSICTA CTA
                ON  CTA.CODCTABCOINT = FIN.CODCTABCOINT
            INNER JOIN VGFFIN F
                ON  F.NUFIN = FIN.NUFIN
     WHERE  FIN.RECDESP    = 1
       AND  FIN.PROVISAO   = 'N'
       AND  FIN.CODTIPTIT  = 48
       AND  FIN.NOSSONUM  IS NOT NULL
       AND (FIN.DHBAIXA   IS NULL OR FIN.DHBAIXA >= R.DTREF + 1)
       AND  FIN.DTNEG     <= R.DTREF
       AND  FIN.DTVENC     < R.DTREF
)
SELECT  NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN CONTAGEM END), 0) AS VENCER_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'A VENCER'           THEN TOTAL    END), 0) AS VENCER_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN CONTAGEM END), 0) AS VENCIDO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'VENCIDO'            THEN TOTAL    END), 0) AS VENCIDO_TOT
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN CONTAGEM END), 0) AS CARTORIO_QTD
       ,NVL(SUM(CASE WHEN STATUS = 'BOLETO EM CARTORIO' THEN TOTAL    END), 0) AS CARTORIO_TOT
  FROM  BOLETOS
