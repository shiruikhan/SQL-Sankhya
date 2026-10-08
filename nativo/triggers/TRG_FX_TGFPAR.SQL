/*==============================================================================
  Nome do Script : TRG_FX_TGFPAR
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 24/02/2023)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 24/02/2023, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_FX_TGFPAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_FX_TGFPAR" 
BEFORE INSERT OR UPDATE
ON TGFPAR FOR EACH ROW
DECLARE 
	P_CONTADOR  NUMBER(19);
	P_VALIDAR   BOOLEAN;
	P_TEM_CHECKOUT BOOLEAN;
BEGIN
	IF Stp_Get_Atualizando THEN
		RETURN;
	END IF;
	  
	-- Sincronização de dados
	P_VALIDAR := Fpodevalidar('TGFPAR');
	
	IF (NOT P_VALIDAR) THEN 
		RETURN;
	END IF;
 
	P_TEM_CHECKOUT := FCheckout_Utiliza;
	
	IF (NOT P_TEM_CHECKOUT) THEN
		RETURN;
	END IF;

	IF (NVL(:NEW.ATUNUVERSAO, 'N') = 'S')
	THEN
		SELECT SEQ_GLOBALFOX.NEXTVAL INTO P_CONTADOR FROM DUAL;
		:NEW.NUVERSAO := P_CONTADOR;
		:NEW.ATUNUVERSAO := 'N';
	END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_FX_TGFPAR" ENABLE;
