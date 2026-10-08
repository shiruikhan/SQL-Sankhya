/*==============================================================================
  Nome do Script : TRG_DLT_UPD_TGFCUS
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 01/07/2022 — referência)
  Descrição      : Trigger BEFORE EACH ROW UPDATE OR DELETE sobre TGFCUS.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 01/07/2022, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_UPD_TGFCUS', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_UPD_TGFCUS" 
BEFORE DELETE OR UPDATE
ON TGFCUS
FOR EACH ROW
DECLARE P_COUNT INT; 
BEGIN
  IF :OLD.DTATUAL < Variaveis_Pkg.V_DTLIMALTERCUSTO THEN
    IF Stp_Get_Atualizando THEN
      RETURN;
    END IF;

    SELECT COUNT(1) 
    INTO P_COUNT
    FROM TSIPAR
    WHERE CHAVE = 'SBPRODUTO';
    IF (P_COUNT = 0) OR NOT (VARIAVEIS_PKG.V_SBPRODUTO) THEN
      RAISE_APPLICATION_ERROR(-20101,'Não é permitido excluir/alterar custo com data anterior a '|| TO_CHAR(Variaveis_Pkg.V_DTLIMALTERCUSTO)|| ', conforme definido no parâmetro DIASLIMALTCUSTO.');
    END IF;  
  END IF;   
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_UPD_TGFCUS" ENABLE;
