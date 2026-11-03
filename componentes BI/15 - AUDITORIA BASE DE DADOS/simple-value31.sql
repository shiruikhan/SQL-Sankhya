SELECT CASE WHEN B.COM = 0 THEN 0 ELSE( (B.COM * 100) / (B.SEM + B.COM) ) END AS PERCENTUAL
   FROM ( SELECT NVL(SUM(CASE WHEN A.QTDE = 0 THEN 1 ELSE 0 END),0) AS SEM,  
                 NVL(SUM(CASE WHEN A.QTDE > 0 THEN 1 ELSE 0 END),0) AS COM
            FROM ( SELECT DISTINCT TGFTOP.CODTIPOPER TOP, 
                         ( SELECT COUNT(TGFCAB.NUNOTA) 
                             FROM TGFCAB 
                            WHERE TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER ) QTDE
                     FROM TGFTOP 
                    WHERE TGFTOP.CODTIPOPER <> 0 
                      AND TGFTOP.TIPMOV IN ( 'F' )
                 GROUP BY TGFTOP.CODTIPOPER ) A ) B
