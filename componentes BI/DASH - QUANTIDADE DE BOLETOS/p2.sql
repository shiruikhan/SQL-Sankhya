WITH DT_REF AS (
    /*-- Ultima data util (seg-sex) anterior a hoje ----------------------*/
    SELECT  MAX(D.DIA) AS DTREF
      FROM  (SELECT  TRUNC(SYSDATE) - LEVEL AS DIA
               FROM  DUAL
            CONNECT BY LEVEL <= 10) D
     WHERE  TO_CHAR(D.DIA, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN')
)
------------------------------------------------------------------------------
-- Boletos a vencer (em aberto na DTREF, vencimento >= DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'A VENCER'          AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos vencidos (em aberto na DTREF, vencimento < DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'VENCIDO'           AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

UNION ALL
------------------------------------------------------------------------------
-- Boletos em cartorio (titulo protestado, vencimento < DTREF)
------------------------------------------------------------------------------
SELECT  FIN.CODCTABCOINT
       ,CTA.DESCRICAO
       ,'BOLETO EM CARTORIO' AS STATUS
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
 GROUP BY FIN.CODCTABCOINT
         ,CTA.DESCRICAO

ORDER BY 1, 3
