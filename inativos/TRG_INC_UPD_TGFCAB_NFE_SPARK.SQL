create or replace TRIGGER TRG_INC_UPD_TGFCAB_NFE_SPARK
BEFORE UPDATE ON TGFCAB 
FOR EACH ROW
DECLARE 
P_COUNT     INT;
P_NUNOTA    INT;
P_SEQUENCIA INT;
P_VLRUNIT   FLOAT;
P_BASEICMS  FLOAT;
P_ALIQICMS  FLOAT;
P_VLRICMS   FLOAT;
P_BASEIPI   FLOAT;
P_ALIQIPI   FLOAT;
P_VLRIPI    FLOAT;

CURSOR CUR_ITENS IS 
SELECT SEQUENCIA, VLRUNIT , BASEICMS, ALIQICMS, VLRICMS, BASEIPI, ALIQIPI, VLRIPI
  FROM TGFITE
 WHERE NUNOTA = :NEW.NUNOTA;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

    IF :NEW.TIPMOV = 'V' AND :NEW.CHAVENFE IS NOT NULL AND :OLD.CHAVENFE IS NULL THEN 
    
        SELECT COUNT(*) INTO P_COUNT
          FROM TGFCAB
         WHERE AD_NUNOTASAI = :NEW.NUNOTA;
         
            IF P_COUNT > 0 THEN 
            
                SELECT MAX(AD_NUNOTAENT) INTO P_NUNOTA
                  FROM TGFCAB
                 WHERE AD_NUNOTASAI = :NEW.NUNOTA;
                 
                 UPDATE TGFCAB SET NUMNOTA = :NEW.NUMNOTA, CHAVENFE = :NEW.CHAVENFE, VLRNOTA = :NEW.VLRNOTA
                  WHERE NUNOTA = P_NUNOTA;
                  
                  COMMIT;
                  
                      OPEN CUR_ITENS;
                       LOOP
                          FETCH CUR_ITENS INTO P_SEQUENCIA, P_VLRUNIT , P_BASEICMS, P_ALIQICMS, P_VLRICMS, P_BASEIPI, P_ALIQIPI, P_VLRIPI;
                          EXIT WHEN CUR_ITENS%NOTFOUND;
                          
                          IF P_BASEIPI > 0 THEN
                          UPDATE TGFITE SET VLRUNIT = P_VLRUNIT, 
                                             VLRTOT = P_VLRUNIT * QTDNEG,
                                           BASEICMS = P_BASEICMS,
                                           ALIQICMS = P_ALIQICMS,
                                            VLRICMS = P_VLRICMS,
                                            CSTIPI = 49,
                                            BASEIPI = P_BASEIPI, 
                                            ALIQIPI = P_ALIQIPI, 
                                             VLRIPI = P_VLRIPI
                               WHERE NUNOTA = P_NUNOTA
                                 AND SEQUENCIA = P_SEQUENCIA;
                               
                               COMMIT;
                           END IF;   
                           IF P_BASEIPI = 0 THEN
                              UPDATE TGFITE SET VLRUNIT = P_VLRUNIT, 
                                                 VLRTOT = P_VLRUNIT * QTDNEG,
                                               BASEICMS = P_BASEICMS,
                                               ALIQICMS = P_ALIQICMS,
                                                VLRICMS = P_VLRICMS,
                                                CSTIPI = 1,
                                                BASEIPI = P_BASEIPI, 
                                                ALIQIPI = P_ALIQIPI, 
                                                 VLRIPI = P_VLRIPI
                                   WHERE NUNOTA = P_NUNOTA
                                     AND SEQUENCIA = P_SEQUENCIA;
                                   
                                   COMMIT;
                           END IF;   
                       END LOOP;
                       CLOSE CUR_ITENS;
                
            
            END IF;
        
    
    END IF;

END;