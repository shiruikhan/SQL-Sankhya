/*==============================================================================
  Nome do Script : TRG_TGFCAB_INC_UPD_TIMFK
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_TGFCAB_INC_UPD_TIMFK', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_TIMFK" 
   BEFORE INSERT OR UPDATE
   ON TGFCAB
   FOR EACH ROW
DECLARE
   P_COUNT     INT;
   P_VALIDAR   BOOLEAN;
   P_ERRMSG    VARCHAR (255);
   ERROR EXCEPTION;
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB
   THEN
      RETURN;
   END IF;

   IF STP_GET_ATUALIZANDO ()
   THEN
      RETURN;
   END IF;

   P_VALIDAR := FPODEVALIDAR ('TGFCAB');


   INSERT INTO TGFCAB_INC_UPD_TIMFK (NUNOTA,
                                     TIMCONTRATOLTV,
                                     TIMCONTRATOVENDA,
                                     TIMNUFINORIG)
      SELECT :NEW.NUNOTA,
             :OLD.TIMCONTRATOLTV,
             :OLD.TIMCONTRATOVENDA,
             :OLD.TIMNUFINORIG
        FROM DUAL
       WHERE NOT EXISTS (SELECT 1
                           FROM TGFCAB_INC_UPD_TIMFK
                          WHERE NUNOTA = :NEW.NUNOTA);
EXCEPTION
   WHEN ERROR
   THEN
      IF P_VALIDAR
      THEN
         RAISE_APPLICATION_ERROR (-20201, P_ERRMSG);
      END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_TGFCAB_INC_UPD_TIMFK" ENABLE;
