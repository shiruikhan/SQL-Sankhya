/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFEST_TGFGXE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER EACH ROW INSERT OR UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/02/2022.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFEST_TGFGXE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_TGFGXE" 
AFTER INSERT OR UPDATE 
ON TGFEST 
FOR EACH ROW
DECLARE
    P_COUNT     NUMBER(05);
    
BEGIN    
  
    SELECT COUNT(1) INTO P_COUNT 
    FROM TGFGXE
    WHERE CODPROD = :NEW.CODPROD;
 
    IF (P_COUNT > 0) THEN
       RAISE_APPLICATION_ERROR(-20101, 'Não é permitido movimentação de estoque para produto genérico. Produto: ' || TO_CHAR(:NEW.CODPROD) || '.');
    END IF;

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_TGFGXE" ENABLE;
