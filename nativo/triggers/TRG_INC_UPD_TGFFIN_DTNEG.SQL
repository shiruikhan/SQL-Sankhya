/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFFIN_DTNEG
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFFIN_DTNEG', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTNEG" 
BEFORE INSERT OR UPDATE ON TGFFIN
FOR EACH ROW
DECLARE
  P_VALIDAR                 BOOLEAN;
  ERRMSG                    VARCHAR2(4000);
  ERROR                      EXCEPTION;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  /*   sincronização de dados  */
  P_VALIDAR := Fpodevalidar('TGFFIN');
  
  IF NVL(:OLD.DTNEG, TO_DATE('01/01/1899', 'DD/MM/YYYY')) <> NVL(:NEW.DTNEG, TO_DATE('01/01/1899', 'DD/MM/YYYY')) AND :NEW.DTNEG <> TRUNC(:NEW.DTNEG) THEN
    RAISE_APPLICATION_ERROR(-20101, 'Data de negociação com Hora, entre em contato com Help Desk. Financeiro de Nro Único: '|| TO_CHAR(:NEW.NUFIN) ||'.');
  END IF;

  RETURN;
   
EXCEPTION

  WHEN OTHERS THEN
    /*    Sincronização de dados não faz validações    */
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFFIN_DTNEG" ENABLE;
