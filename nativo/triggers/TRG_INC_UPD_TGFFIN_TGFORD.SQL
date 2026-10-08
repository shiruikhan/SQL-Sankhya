/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFFIN_TGFORD
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFFIN_TGFORD', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_TGFORD" 
BEFORE INSERT OR UPDATE ON TGFFIN 
FOR EACH ROW
         WHEN ( NEW.ORIGEM = 'F' AND NVL(NEW.ORDEMCARGA,0)<>0 ) DECLARE
  P_COUNT           INT := 0;
P_VALIDAR BOOLEAN;
  
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  P_VALIDAR := Fpodevalidar('TGFFIN');
  IF (NOT P_VALIDAR) THEN
    RETURN;
  END IF;

  SELECT COUNT(1) INTO P_COUNT
  FROM TSIPAR
  WHERE CHAVE = 'SBPARCEIRO';
  IF (P_COUNT <> 0) THEN
    RETURN;
  END IF;  
  
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFORD ORD
  WHERE ORD.ORDEMCARGA = :NEW.ORDEMCARGA
    AND ORD.CODEMP = (SELECT CASE WHEN NVL(EMP.CODEMPOC, 0) = 0 THEN EMP.CODEMP 
                          ELSE CODEMPOC END 
                      FROM TGFEMP EMP 
                      WHERE EMP.CODEMP = :NEW.CODEMP);
    
  IF (P_COUNT=0) THEN
     RAISE_APPLICATION_ERROR(-20101, 'N?o existe referencia para essa ordem de carga. Financeiro de Nro Unico: '|| TO_CHAR(:NEW.NUFIN) ||'.');
  END IF;  
  RETURN;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_TGFORD" ENABLE;
