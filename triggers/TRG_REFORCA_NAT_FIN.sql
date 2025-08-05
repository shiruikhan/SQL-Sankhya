CREATE OR REPLACE TRIGGER TRG_REFORCA_NAT_FIN
AFTER INSERT OR UPDATE ON TGFFIN
FOR EACH ROW
DECLARE
    v_codnat TGFCAB.CODNAT%TYPE;
BEGIN
    -- Verifica se o título não está entre os tipos isentos e possui nota vinculada
    IF :NEW.CODTIPTIT NOT IN (34, 35, 36, 15)
       AND :NEW.NUNOTA IS NOT NULL THEN

        BEGIN
            -- Busca a natureza da nota de venda (TGFCAB)
            SELECT CODNAT
              INTO v_codnat
              FROM TGFCAB
             WHERE NUNOTA = :NEW.NUNOTA;

            -- Atualiza somente se for diferente
            IF NVL(:NEW.CODNAT, -1) <> NVL(v_codnat, -1) THEN
                UPDATE TGFFIN
                   SET CODNAT = v_codnat
                 WHERE NUFIN = :NEW.NUFIN;
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- Nenhuma nota encontrada, não faz nada
        END;

    END IF;
END;
