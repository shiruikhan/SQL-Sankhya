create or replace TRIGGER "SPARKPRD"."TRG_INS_UPD_DLT_TPRIMPS_SPARK" 
BEFORE INSERT OR UPDATE ON TPRIMPS
FOR EACH ROW
DECLARE
  P_NUMPS NUMBER(10);
  P_COUNT INT;

BEGIN

SELECT COUNT(*) INTO P_COUNT  FROM TGFCAB WHERE AD_NUMPS = :NEW.NUMPS;

           IF  P_COUNT > 0 THEN
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML('Ação não permitida!',
                    'Já foi realizado geração Lista Materiais, não é permitido gerar novamente. Caso necessário exclua os pedidos requisição gerados deste plano, execute o MRP e gere a Lista',
                    'Nro Plano:'||:NEW.NUMPS));    
            END IF;



END;




