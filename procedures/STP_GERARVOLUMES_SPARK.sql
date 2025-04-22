create or replace PROCEDURE STP_GERARVOLUMES_SPARK (
    P_NUNOTA    INT
) AS
    FIELD_NUNOTA    NUMBER;
    
    V_CODPROD       INT;
    V_SEQUENCIA     INT;
    V_QTDNEG        FLOAT;
    V_CODPRODEMB    INT;
    V_QTDEMB        INT;
    V_QTDITENS      INT;
    V_MAXSEQ        INT;
    V_COUNT         INT;
    V_COUNTEMB      INT;
    V_EMBPADRAO     INT;
    V_M3            FLOAT;
    V_M3EMB         FLOAT;
    V_M3ACUMULADO   FLOAT;
    V_PESOACUMULADO FLOAT;
    V_PESOBRUTO     FLOAT;
    V_IDCAIXA       INT;
    V_IDCAIXAEMB    INT;
    V_NOVACAIXA     BOOLEAN;
    
    CURSOR CUR_ITENS IS
        SELECT ITE.CODPROD, SUM(ITE.QTDNEG) QTDNEG
        FROM TGFITE ITE
        WHERE ITE.NUNOTA = FIELD_NUNOTA
        GROUP BY ITE.CODPROD
        ORDER BY ITE.CODPROD;
        
    CURSOR CUR_EMB IS
        SELECT 
            PED.SEQ, PED.CODPROD, PRO.AD_CODPRODEMB,
            CASE WHEN MOD(ROWNUM,PRO.AD_QTDEMB) = 0 
                THEN TRUNC(ROWNUM / PRO.AD_QTDEMB) 
                ELSE TRUNC(ROWNUM / PRO.AD_QTDEMB) + 1 
                END
        FROM AD_EMBPED PED
        JOIN TGFPRO PRO ON PED.CODPROD = PRO.CODPROD
        JOIN (
            SELECT PRO.AD_CODPRODEMB, PRO.AD_QTDEMB, COUNT(*) QTDITENS
            FROM AD_EMBPED PED
            JOIN TGFPRO PRO ON PED.CODPROD = PRO.CODPROD
            WHERE PED.NUNOTA = FIELD_NUNOTA
                AND PED.CODPRODEMB IS NULL
            GROUP BY PRO.AD_CODPRODEMB, PRO.AD_QTDEMB) ITE ON PRO.AD_CODPRODEMB = ITE.AD_CODPRODEMB AND PRO.AD_QTDEMB = ITE.AD_QTDEMB
        WHERE PED.NUNOTA = FIELD_NUNOTA
            AND PED.CODPRODEMB IS NULL
            AND ROWNUM <= TRUNC(ITE.QTDITENS / PRO.AD_QTDEMB) * PRO.AD_QTDEMB
        ORDER BY PED.CODPROD;      
        
    CURSOR CUR_SOBRA IS
        SELECT 
            PED.SEQ, PED.CODPROD, PED.M3, PRO.PESOBRUTO,
            (SELECT M3 FROM TGFPRO P WHERE CODPROD = V_EMBPADRAO) AS M3EMB
        FROM AD_EMBPED PED 
        JOIN TGFPRO PRO ON PED.CODPROD = PRO.CODPROD
        WHERE PED.NUNOTA = FIELD_NUNOTA 
            AND PED.CODPRODEMB IS NULL    
        ORDER BY PED.M3 DESC;
        
BEGIN
    FIELD_NUNOTA := P_NUNOTA;
    V_EMBPADRAO := 546117;
    V_NOVACAIXA := TRUE;

    -- Limpar volumes existentes
    DELETE FROM AD_EMBPED
    WHERE NUNOTA = FIELD_NUNOTA
    AND TIPO <> 'A';

    COMMIT; 
    
    -- Processar itens principais
    OPEN CUR_ITENS;
    LOOP
        FETCH CUR_ITENS INTO V_CODPROD, V_QTDNEG;
        EXIT WHEN CUR_ITENS%NOTFOUND;

        SELECT NVL(MAX(SEQ),0) INTO V_MAXSEQ
        FROM AD_EMBPED
        WHERE NUNOTA = FIELD_NUNOTA;

        SELECT NVL(MAX(IDCAIXA),0) INTO V_IDCAIXA
        FROM AD_EMBPED
        WHERE NUNOTA = FIELD_NUNOTA;

        INSERT INTO AD_EMBPED (NUNOTA, SEQ, CODPROD, PESOBRUTO, M3, CODPRODEMB, IDCAIXA, TIPO)
        (   SELECT 
                ITE.NUNOTA, V_MAXSEQ + ROWNUM, ITE.CODPROD, PRO.PESOBRUTO, PRO.M3, 
                CASE WHEN TRUNC(ITE.QTDNEG / PRO.AD_QTDEMB) * PRO.AD_QTDEMB >= ROWNUM THEN PRO.AD_CODPRODEMB END,
                CASE WHEN TRUNC(ITE.QTDNEG / PRO.AD_QTDEMB) * PRO.AD_QTDEMB >= ROWNUM THEN 
                    CASE WHEN MOD(ROWNUM,PRO.AD_QTDEMB) = 0 
                        THEN TRUNC(ROWNUM / PRO.AD_QTDEMB) + V_IDCAIXA
                        ELSE TRUNC(ROWNUM / PRO.AD_QTDEMB) + 1 + V_IDCAIXA
                    END 
                END,
                CASE WHEN TRUNC(ITE.QTDNEG / PRO.AD_QTDEMB) * PRO.AD_QTDEMB >= ROWNUM THEN 'P' END
            FROM TGFITE ITE
            JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD
            JOIN TGFPAR PAR ON ROWNUM <= ITE.QTDNEG
            WHERE ITE.CODPROD = PRO.CODPROD
                AND ITE.NUNOTA = FIELD_NUNOTA
                AND ITE.CODPROD = V_CODPROD
        );                            
        
    END LOOP;
    CLOSE CUR_ITENS;          
    
    -- Processar embalagens
    SELECT NVL(MAX(IDCAIXA),0) INTO V_IDCAIXA
    FROM AD_EMBPED
    WHERE NUNOTA = FIELD_NUNOTA;
    
    OPEN CUR_EMB;
    LOOP
        FETCH CUR_EMB INTO V_SEQUENCIA, V_CODPROD, V_CODPRODEMB, V_IDCAIXAEMB;
        EXIT WHEN CUR_EMB%NOTFOUND;

        UPDATE AD_EMBPED 
        SET CODPRODEMB = V_CODPRODEMB,
            IDCAIXA = V_IDCAIXA + V_IDCAIXAEMB,
            TIPO = 'E'
        WHERE NUNOTA = FIELD_NUNOTA
            AND CODPROD = V_CODPROD
            AND SEQ = V_SEQUENCIA;                            
        
    END LOOP;
    CLOSE CUR_EMB; 
    
    -- Processar sobras
    V_COUNT := 0;
    
    SELECT COUNT(*) INTO V_COUNTEMB 
    FROM AD_EMBPED 
    WHERE NUNOTA = FIELD_NUNOTA 
        AND CODPRODEMB IS NULL;
    
    WHILE V_COUNTEMB > 0 AND V_COUNT < 5
    LOOP
        V_COUNT := V_COUNT + 1;
        
        SELECT NVL(MAX(IDCAIXA),0) + 1 INTO V_IDCAIXA
        FROM AD_EMBPED
        WHERE NUNOTA = FIELD_NUNOTA;
        
        BEGIN
            SELECT MIN(P.CODPROD) INTO V_CODPRODEMB
            FROM TGFPRO P
            WHERE CODGRUPOPROD = 5461000
                AND CODPROD IN (546116,546117)
                AND P.M3 = (
                    SELECT MIN(M3)
                    FROM TGFPRO
                    WHERE CODGRUPOPROD = 5461000
                        AND CODPROD IN (546116,546117)
                        AND M3 > (SELECT SUM(PED.M3) FROM AD_EMBPED PED WHERE PED.NUNOTA = FIELD_NUNOTA AND PED.CODPRODEMB IS NULL));
        EXCEPTION WHEN NO_DATA_FOUND THEN
            V_CODPRODEMB := 0;
        END;
        
        IF NVL(V_CODPRODEMB,0) > 0 THEN
            UPDATE AD_EMBPED 
            SET CODPRODEMB = V_CODPRODEMB,
                IDCAIXA = V_IDCAIXA,
                TIPO = 'S'
            WHERE NUNOTA = FIELD_NUNOTA
                AND CODPRODEMB IS NULL; 
        
        ELSE
            -- Inicializar acumuladores para nova caixa
            V_M3ACUMULADO := 0;
            V_PESOACUMULADO := 0;
            
            OPEN CUR_SOBRA;
            LOOP
                FETCH CUR_SOBRA INTO V_SEQUENCIA, V_CODPROD, V_M3, V_PESOBRUTO, V_M3EMB;
                EXIT WHEN CUR_SOBRA%NOTFOUND;

                -- Verificar se precisa criar nova caixa
                IF (V_PESOACUMULADO + V_PESOBRUTO > 25) THEN
                    V_IDCAIXA := V_IDCAIXA + 1;
                    V_PESOACUMULADO := 0;
                    V_M3ACUMULADO := 0;
                END IF;

                -- Verificar se o item cabe na caixa atual
                IF (V_PESOACUMULADO + V_PESOBRUTO <= 25) AND (V_M3ACUMULADO + V_M3 <= V_M3EMB) THEN
                    UPDATE AD_EMBPED 
                    SET CODPRODEMB = V_EMBPADRAO,
                        IDCAIXA = V_IDCAIXA,
                        TIPO = 'S'
                    WHERE NUNOTA = FIELD_NUNOTA
                        AND CODPROD = V_CODPROD
                        AND SEQ = V_SEQUENCIA;  

                    -- Atualizar acumuladores
                    V_PESOACUMULADO := V_PESOACUMULADO + V_PESOBRUTO;
                    V_M3ACUMULADO := V_M3ACUMULADO + V_M3;
                END IF;
            END LOOP;
            CLOSE CUR_SOBRA;
        END IF;
        
        SELECT COUNT(*) INTO V_COUNTEMB 
        FROM AD_EMBPED 
        WHERE NUNOTA = FIELD_NUNOTA 
            AND CODPRODEMB IS NULL;
        
    END LOOP;
    
    -- Atualizar cabeçalho
    UPDATE TGFCAB 
    SET QTDVOL = (SELECT COUNT(DISTINCT IDCAIXA)
                FROM AD_EMBPED 
                WHERE NUNOTA = FIELD_NUNOTA),
        PESOBRUTO = (SELECT ROUND(SUM(PESOEMB),2) 
                    FROM(
                        SELECT COUNT(DISTINCT IDCAIXA) * SUM(DISTINCT PRO.PESOBRUTO) AS PESOEMB
                        FROM AD_EMBPED EMB
                            INNER JOIN TGFPRO PRO ON (EMB.CODPRODEMB = PRO.CODPROD)
                        WHERE NUNOTA = FIELD_NUNOTA
                        GROUP BY CODPRODEMB
                        UNION
                        SELECT ROUND(SUM(EMB.PESOBRUTO),2) AS PESOEMB
                        FROM AD_EMBPED EMB
                        WHERE NUNOTA = FIELD_NUNOTA)),
        PESO = (SELECT ROUND(SUM(EMB.PESOBRUTO),2) AS PESOEMB
                FROM AD_EMBPED EMB
                WHERE NUNOTA = FIELD_NUNOTA)            
    WHERE NUNOTA = FIELD_NUNOTA;
END;