CREATE OR REPLACE PROCEDURE STP_ATUALIZA_FRETE_COTA(
    P_NUNOTA IN NUMBER
) AS
    V_VLRFRETE NUMBER;
BEGIN
    -- Busca o VLRFRETE da cotação associada a nota
    -- Utiliza ROWNUM = 1 para garantir apenas um registro caso existam múltiplos
    BEGIN
        SELECT VLRFRETE 
        INTO V_VLRFRETE
        FROM AD_TGSCTF 
        WHERE NUNOTA = P_NUNOTA 
        AND ROWNUM = 1;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            V_VLRFRETE := NULL;
    END;

    IF V_VLRFRETE IS NOT NULL THEN
        -- Atualiza o valor do frete na TGFCAB
        UPDATE TGFCAB 
        SET VLRFRETE = V_VLRFRETE
        WHERE NUNOTA = P_NUNOTA;
    END IF;
END;
/
