/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TGFITE_LIB41
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE OR DELETE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 13/11/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_DLT_TGFITE_LIB41', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFITE_LIB41" 
BEFORE INSERT OR UPDATE OR DELETE ON TGFITE 
FOR EACH ROW
DECLARE 
   P_COUNT     INT; 
   ERROR       EXCEPTION;
   ERRMSG      VARCHAR2(4000);
   P_VALIDAR   BOOLEAN;
BEGIN
 
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
   /* 
         sincronização de dados
   */
   P_VALIDAR := FPODEVALIDAR('TGFITE');
   IF NOT (P_VALIDAR) THEN 
      RETURN;
   END IF;
   IF DELETING OR INSERTING OR (
   (:OLD.CODPROD <> :NEW.CODPROD) OR 
   (:OLD.CODLOCALORIG <> :NEW.CODLOCALORIG) OR
   (:OLD.CONTROLE <> :NEW.CONTROLE) OR
   (:OLD.QTDNEG <> :NEW.QTDNEG) OR 
   (:OLD.VLRTOT <> :NEW.VLRTOT)) THEN
      SELECT COUNT(*) 
      INTO P_COUNT 
      FROM TSILIB 
      WHERE EVENTO = 41 
      AND TABELA = 'TGFCAB' 
      AND (DHLIB IS NOT NULL OR REPROVADO = 'S') 
      AND NUCHAVE = NVL(:OLD.NUNOTA,:NEW.NUNOTA); 
      IF (P_COUNT > 0) THEN 
         ERRMSG := 'Pedido/Nota com Liberação por Análise dos Itens não pode ser Alterada ou Excluída.';
         RAISE ERROR;
      END IF;
   END IF;
   RETURN;
EXCEPTION 
    WHEN OTHERS THEN
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFITE_LIB41" ENABLE;
