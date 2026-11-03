SELECT DISTINCT TGFTOP.CODTIPOPER TOP,  
                 TGFTOP.DESCROPER,
        ( SELECT COUNT(TGFCAB.NUNOTA)
            FROM TGFCAB
           WHERE TGFCAB.CODTIPOPER <> 0 
              AND TGFCAB.TIPMOV <> 'Z'
              AND TGFCAB.CODUSU = :A_CODUSU
              AND TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER) qtde,         
        CASE WHEN ( SELECT COUNT(TGFCAB.NUNOTA)
            FROM TGFCAB
           WHERE TGFCAB.CODTIPOPER <> 0 
              AND TGFCAB.TIPMOV <> 'Z'
              AND TGFCAB.CODUSU = :A_CODUSU
              AND TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER) = 0 THEN 0 
          ELSE        
        ((( SELECT COUNT(TGFCAB.NUNOTA)
            FROM TGFCAB
           WHERE TGFCAB.CODTIPOPER <> 0 
              AND TGFCAB.TIPMOV <> 'Z'
              AND TGFCAB.CODUSU = :A_CODUSU
              AND TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER) * 100 ) /
        ( SELECT COUNT(TGFCAB.NUNOTA) 
           FROM TGFCAB 
          WHERE TGFCAB.CODUSU = :A_CODUSU
            AND ((:A_DESCRICAO = 'Compras' AND TGFCAB.TIPMOV IN ('C','O','E'))
               OR (:A_DESCRICAO = 'Vendas' AND TGFCAB.TIPMOV IN ('P','D','V'))
               OR (:A_DESCRICAO = 'Transferência' AND TGFCAB.TIPMOV IN ('T'))
               OR (:A_DESCRICAO = 'Requisição' AND TGFCAB.TIPMOV IN ('J','Q','L'))
               OR (:A_DESCRICAO = 'Produção' AND TGFCAB.TIPMOV IN ('F')) ))) END PERCENTUAL
   FROM TGFTOP 
  WHERE TGFTOP.CODTIPOPER <> 0 
    AND ((:A_DESCRICAO = 'Compras' AND TGFTOP.TIPMOV IN ('C','O','E'))
               OR (:A_DESCRICAO = 'Vendas' AND TGFTOP.TIPMOV IN ('P','D','V'))
               OR (:A_DESCRICAO = 'Transferência' AND TGFTOP.TIPMOV IN ('T'))
               OR (:A_DESCRICAO = 'Requisição' AND TGFTOP.TIPMOV IN ('J','Q','L'))
               OR (:A_DESCRICAO = 'Produção' AND TGFTOP.TIPMOV IN ('F')))
GROUP BY TGFTOP.CODTIPOPER, TGFTOP.DESCROPER
ORDER BY TGFTOP.CODTIPOPER
