/*==============================================================================
  Nome do Script : TRG_UPD_DLT_TGFCAB_EC
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 04/04/2023 — referência)
  Descrição      : Trigger BEFORE EACH ROW UPDATE OR DELETE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 04/04/2023, última alteração em 20/04/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_DLT_TGFCAB_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_DLT_TGFCAB_EC" BEFORE UPDATE OR DELETE ON TGFCAB
FOR EACH ROW  WHEN (OLD.CODPEDLV IS NOT NULL AND OLD.CODPEDLV > 0 AND OLD.TIPMOV = 'P') BEGIN

    IF DELETING THEN

        INSERT INTO TECCAN(NUNOTA, CODPEDLV, STPEDLV, DTALTER)
        VALUES (:OLD.NUNOTA, :OLD.CODPEDLV, 3, SYSDATE);  -- insere como pedido cancelado

        INSERT INTO TECLOG (NUNOTA, TIPO)
        SELECT :OLD.NUNOTA, 'S' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'S' AND NUNOTA = :OLD.NUNOTA));
        /* força atualização */
        UPDATE TECLOG SET INTEGRADO = 'N'
        WHERE TIPO = 'S'
        AND INTEGRADO <> 'N'
        AND NUNOTA = :OLD.NUNOTA;

    ELSE


        IF UPDATING ('STPEDLV') AND (:NEW.STPEDLV <> :OLD.STPEDLV) THEN
            INSERT INTO TECLOG (NUNOTA, TIPO)
            SELECT :NEW.NUNOTA, 'S' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'S' AND NUNOTA = :NEW.NUNOTA));
            /* força atualização */
            UPDATE TECLOG SET INTEGRADO = 'N'
            WHERE TIPO = 'S'
            AND INTEGRADO <> 'N'
            AND NUNOTA = :NEW.NUNOTA;
        END IF;
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_DLT_TGFCAB_EC" ENABLE;
