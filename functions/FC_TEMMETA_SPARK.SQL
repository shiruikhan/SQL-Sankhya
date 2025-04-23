create or replace FUNCTION FC_TEMMETA_SPARK(P_CODPROD INT)
RETURN VARCHAR2
AS  
    P_COUNT INT;
BEGIN    
    

    SELECT COUNT(*) INTO P_COUNT
      FROM TGMMET 
     WHERE CODMETA = 3 
       AND CODPROD = P_CODPROD;
       
       IF P_COUNT > 0 THEN 
       RETURN 'S';
       END IF;
       
       IF P_COUNT = 0 THEN 
       RETURN 'N';
       END IF;

END; 