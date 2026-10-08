/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TGFEST_EC
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 04/04/2023 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE OR DELETE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 04/04/2023, última alteração em 27/02/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_DLT_TGFEST_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFEST_EC" BEFORE INSERT OR UPDATE OR DELETE ON TGFEST FOR EACH ROW
DECLARE
 P_USADOLV      TGFPRO.USADOLV%TYPE;
BEGIN
    IF UPDATING ('ESTOQUE') OR UPDATING('RESERVADO') OR INSERTING THEN
        SELECT USADOLV INTO P_USADOLV
        FROM TGFPRO
        WHERE CODPROD = NVL(:NEW.CODPROD, :OLD.CODPROD);

        IF P_USADOLV = 'S' THEN
            INSERT INTO TECLOG (CODPROD, TIPO) SELECT NVL(:NEW.CODPROD, :OLD.CODPROD), 'E'  FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'E'  AND CODPROD = NVL(:NEW.CODPROD, :OLD.CODPROD)));
            /* força atualização de preço e estoque no caso de edição do produto */
            UPDATE TECLOG SET INTEGRADO = 'N'
            WHERE TIPO IN ('E')
            AND INTEGRADO <> 'N'
            AND CODPROD = NVL(:NEW.CODPROD, :OLD.CODPROD);
        END IF;
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_DLT_TGFEST_EC" ENABLE;
