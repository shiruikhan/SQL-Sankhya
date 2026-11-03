SELECT SUM(A.QTDE) QTDE
            FROM ( SELECT DISTINCT TGFTOP.CODTIPOPER TOP,
                          COUNT( TGFCAB.NUNOTA ) QTDE
                     FROM TGFTOP INNER JOIN TGFCAB ON TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER 
                                                  AND TGFCAB.DHTIPOPER = TGFTOP.DHALTER
                    WHERE TGFTOP.TIPMOV IN ( 'P','D','V' )
                      AND TGFCAB.TIPMOV <> 'Z'
                 GROUP BY TGFTOP.CODTIPOPER ) A
