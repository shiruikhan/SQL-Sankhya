create or replace PROCEDURE STP_REGRA_VALID_FINAN_SPARK_C (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) AS
BEGIN
    DECLARE
        P_VLRNOTA   NUMBER;
        P_VLRFIN    NUMBER;
        P_CODPARC   NUMBER;
    BEGIN
    
        BEGIN
            SELECT NVL(VLRNOTA,0) + NVL(VLROUTROS,0) + NVL(AD_VLROUTROSFRETE,0), CODPARC INTO P_VLRNOTA, P_CODPARC
            FROM TGFCAB 
            WHERE NUNOTA = P_NUNOTA;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_VLRNOTA := 0;
        END;
        
        BEGIN
            SELECT SUM(NVL(VLRDESDOB,0)) INTO P_VLRFIN
            FROM TGFFIN 
            WHERE NUNOTA = P_NUNOTA
                AND RECDESP = -1
                AND CODPARC = P_CODPARC;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_VLRFIN := 0;
        END;
    
        P_SUCESSO := 'S';
    
        IF ROUND(P_VLRFIN,2) <> ROUND(P_VLRNOTA,2) THEN
            P_MENSAGEM := 'Valor Total da nota diferente do valor total do financeiro.';
            P_SUCESSO := 'N';
        END IF;
    
     --P_MENSAGEM := 'A REGRA FALHOU DE PROPÓSITO, SÓ PARA TESTAR.';
    
     --SE FOR NECESSÁRIO DETERMINAR O LIBERADOR BASTA ATRIBUIR:
    
    -- P_CODUSULIB := 10;
    END;
    
END;