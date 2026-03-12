CREATE OR REPLACE TRIGGER TRG_REFORCA_NAT_FIN
AFTER INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
BEGIN
    -- Reforça a natureza e centro de custo na TGFFIN baseada na TGFCAB
    -- Utiliza NUNOTA e CODPARC como parâmetros de ligação
    
    IF :NEW.CODNAT IS NOT NULL OR :NEW.CODCENCUS IS NOT NULL THEN
        UPDATE TGFFIN
           SET CODNAT = CASE WHEN :NEW.CODNAT IS NOT NULL THEN :NEW.CODNAT ELSE CODNAT END,
               CODCENCUS = CASE WHEN :NEW.CODCENCUS IS NOT NULL THEN :NEW.CODCENCUS ELSE CODCENCUS END
         WHERE NUNOTA = :NEW.NUNOTA
           AND CODPARC = :NEW.CODPARC
           -- Mantém a regra de exclusão dos tipos isentos (34, 35, 36, 15)
           AND CODTIPTIT NOT IN (34, 35, 36, 15)
           AND NURENEG IS NULL
           -- Validação: O update só pode acontecer SE o financeiro não for rateado
           AND NOT EXISTS (
               SELECT 1 
               FROM TGFRAT 
               WHERE TGFRAT.NUFIN = TGFFIN.NUFIN
           );
    END IF;
END;
