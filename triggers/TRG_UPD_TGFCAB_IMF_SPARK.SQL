create or replace TRIGGER TRG_UPD_TGFCAB_IMF_SPARK
BEFORE UPDATE ON TGFCAB
FOR EACH ROW
DECLARE
    P_COUNT     INT;
    P_CODIMP    INT;
    P_COPIA     VARCHAR2(10);
    P_VALORIMP  FLOAT;
    P_TOTFIN    FLOAT;
    P_ALIQ      FLOAT;
    CURSOR CUR_IMN IS
        SELECT CODIMP
        FROM TGFIMN
        WHERE NUNOTA = :NEW.NUNOTA
        GROUP BY CODIMP;

BEGIN

    IF :NEW.TIPMOV = 'C' AND :NEW.STATUSNOTA = 'L' AND UPDATING('STATUSNOTA') THEN        
    
    /*
        SELECT AD_COPIAROUTROSIMP INTO P_COPIA
        FROM TGFPAR
        WHERE CODPARC = :NEW.CODPARC;
        
        IF P_COPIA = 'S' THEN
        */
        
        OPEN CUR_IMN;
        LOOP        
            FETCH CUR_IMN INTO P_CODIMP;
            EXIT WHEN CUR_IMN%NOTFOUND;
        
            SELECT SUM(VALOR) INTO P_VALORIMP
            FROM TGFIMN
            WHERE NUNOTA = :NEW.NUNOTA
              AND CODIMP = P_CODIMP;
              
            SELECT MAX(ALIQUOTA) INTO P_ALIQ
            FROM TGFIMN
            WHERE NUNOTA = :NEW.NUNOTA
              AND CODIMP = P_CODIMP;
              
            SELECT SUM(VLRDESDOB) INTO P_TOTFIN
            FROM TGFFIN F
            WHERE NUNOTA = :NEW.NUNOTA
                AND CODEMP < 500
                AND CODTIPTIT <> 38;
                
            IF P_ALIQ > 0 THEN 
            
                DELETE FROM TGFIMF
                WHERE CODIMP = P_CODIMP
                    AND NUFIN IN (SELECT NUFIN FROM TGFFIN WHERE NUNOTA = :NEW.NUNOTA);
              
                INSERT INTO TGFIMF (NUFIN, CODIMP, BASE, VALOR, ALIQUOTA, TIPIMP, DIGITADO, TIPOINSSESPECIAL, PERCINSSESPECIAL, VLRINSSESPECIAL)
                (   SELECT F.NUFIN, P_CODIMP, F.VLRDESDOB, ROUND(P_VALORIMP*F.VLRDESDOB/P_TOTFIN,2) , P_ALIQ, -1, 'S', NULL, NULL, NULL
                    FROM TGFFIN F
                    WHERE NUNOTA = :NEW.NUNOTA
                        AND CODEMP < 500
                        AND CODTIPTIT <> 38);
                 
            END IF;     
            
        END LOOP;
        CLOSE CUR_IMN;  
              
       -- END IF;       
    
    END IF;

END;