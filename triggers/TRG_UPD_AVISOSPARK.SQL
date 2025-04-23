create or replace TRIGGER TRG_UPD_AVISOSPARK
BEFORE UPDATE ON SPARKPRD.TGFCON2
FOR EACH ROW
DECLARE
    v_message VARCHAR2(100);
BEGIN
    IF :NEW.STATUS = 'F' AND :NEW.QTDVOL = 1 THEN
        v_message := 'Lembre-se de corrigir a quantidade de volumes caso necessário';
        DBMS_OUTPUT.PUT_LINE(v_message);
    END IF;
END;