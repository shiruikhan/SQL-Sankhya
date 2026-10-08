/*==============================================================================
  Nome do Script : TRG_DLT_TGFSER
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFSER.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 20/04/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFSER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFSER" BEFORE DELETE ON TGFSER REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
DECLARE
    P_COUNT                     NUMBER(10);
    ERRMSG                      VARCHAR2(4000);
    ERROR                       EXCEPTION;
BEGIN
  IF NOT FPODEVALIDAR('TGFSER') THEN
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF TGFCAB_PKG.V_CONTADOR = 0 THEN
    IF ((:OLD.NUMCONTRATO <> 0) AND (:OLD.INTEGSERCON<>'N')) THEN
      BEGIN
        SELECT COUNT(1) INTO P_COUNT FROM TCSCON CON WHERE CON.NUMCONTRATO = :OLD.NUMCONTRATO;
        IF P_COUNT = 0 THEN
          ERRMSG := 'Contrato não preparado para receber os produtos.';
          RAISE ERROR;
        END IF;
  
        IF (:OLD.INTEGSERCON = 'E') THEN
              DELETE FROM TCSPSS
              WHERE CODPROD = :OLD.CODPROD
              AND SERIE = :OLD.SERIE
              AND NUMCONTRATO = :OLD.NUMCONTRATO;
          
        ELSIF (:OLD.INTEGSERCON = 'B') THEN
          BEGIN
            /*
              Insere o produto na TCSPSC do contrato caso ele nao exista
            */
            SELECT COUNT(1) INTO P_COUNT FROM TCSPSC PS WHERE PS.NUMCONTRATO = :OLD.NUMCONTRATO AND PS.CODPROD=:OLD.CODPROD;
              IF P_COUNT = 0 THEN
                INSERT INTO TCSPSC  (NUMCONTRATO, CODPROD, SITPROD, DTALTER)
                VALUES(:OLD.NUMCONTRATO, :OLD.CODPROD, 'A', SYSDATE);
              END IF;
            SELECT COUNT(1) INTO P_COUNT FROM TCSPSS PSS WHERE PSS.NUMCONTRATO=:OLD.NUMCONTRATO AND PSS.CODPROD=:OLD.CODPROD AND PSS.SERIE=:OLD.SERIE;
              IF P_COUNT = 0 THEN
                INSERT INTO TCSPSS (NUMCONTRATO, CODPROD, SERIE, ATIVO, CODUSU, DTALTER)
                VALUES (:OLD.NUMCONTRATO, :OLD.CODPROD, :OLD.SERIE, 'S', :OLD.CODUSU, :OLD.DTALTER);
              END IF;
          END;
        END IF;
      END;
    END IF;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFSER" ENABLE;
