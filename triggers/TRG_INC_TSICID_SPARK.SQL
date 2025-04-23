create or replace TRIGGER TRG_INC_TSICID_SPARK
BEFORE INSERT ON TSICID
FOR EACH ROW
DECLARE
  P_COUNT         INT;
  PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

    IF :NEW.CODMUNFIS IS NULL THEN 
    
     raise_application_error(-20101, 'É obrigatório preencher o campo Municipio Fiscal!');
    
    END IF;
    
    SELECT COUNT(*) INTO P_COUNT
      FROM TSICID 
     WHERE UPPER(NOMECID) = UPPER(:NEW.NOMECID)
       AND UF = :NEW.UF
       AND CODCID <> :NEW.CODCID;
       
       IF P_COUNT > 0 THEN 
             
        raise_application_error(-20101, 'Já possui uma cidade com esse nome cadastrado!');
       
       END IF;

END; 