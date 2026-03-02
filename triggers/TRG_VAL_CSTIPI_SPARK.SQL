CREATE OR REPLACE TRIGGER TRG_VAL_CSTIPI_SPARK
BEFORE INSERT OR UPDATE ON TGFITE
FOR EACH ROW
DECLARE
    P_CODEMP INT;
    P_TIPMOV VARCHAR2(1);
BEGIN
    -- Valida se o campo CSTIPI é 0 ou nulo
    IF :NEW.CSTIPI IS NULL OR :NEW.CSTIPI = 0 THEN
        BEGIN
            -- Busca CODEMP e TIPMOV na tabela pai TGFCAB
            SELECT CODEMP, TIPMOV
            INTO P_CODEMP, P_TIPMOV
            FROM TGFCAB
            WHERE NUNOTA = :NEW.NUNOTA;

            -- Verifica se é Empresa 1 e Tipo de Movimento 'C'
            IF P_CODEMP = 1 AND P_TIPMOV = 'C' THEN
                RAISE_APPLICATION_ERROR(-20101, 'O campo CST IPI não pode ser 0 ou nulo para esta operação (Empresa 1, Tipo Movimento C).');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Caso não encontre a nota (ex: carga de dados inconsistente), não valida
                NULL;
        END;
    END IF;
END;
