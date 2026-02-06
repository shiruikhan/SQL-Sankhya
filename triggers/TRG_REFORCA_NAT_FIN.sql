CREATE OR REPLACE TRIGGER TRG_REFORCA_NAT_FIN
AFTER INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
BEGIN
    -- Reforça a natureza na TGFFIN baseada na TGFCAB
    -- Utiliza NUNOTA e CODPARC como parâmetros de ligação
    
    IF :NEW.CODNAT IS NOT NULL THEN
        UPDATE TGFFIN
           SET CODNAT = :NEW.CODNAT
         WHERE NUNOTA = :NEW.NUNOTA
           AND CODPARC = :NEW.CODPARC
           -- Mantém a regra de exclusão dos tipos isentos (34, 35, 36, 15)
           AND CODTIPTIT NOT IN (34, 35, 36, 15)
           -- Validação: O update só pode acontecer SE o financeiro não for rateado
           AND NOT EXISTS (
               SELECT 1 
               FROM TGFRAT 
               WHERE TGFRAT.NUFIN = TGFFIN.NUFIN
           );
    END IF;
END;
