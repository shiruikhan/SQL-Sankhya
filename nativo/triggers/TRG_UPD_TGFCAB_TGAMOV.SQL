/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_TGAMOV
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 19/09/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_TGAMOV', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TGAMOV" 
BEFORE UPDATE ON TGFCAB REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
      WHEN (NEW.TIPMOV IN ('8','N','1','2','3','4') AND
       ((OLD.DTNEG <> NEW.DTNEG) OR (OLD.CODPARC <> NEW.CODPARC))) BEGIN
  DECLARE
  P_DTREFENT DATE;
  P_DTREFCOB DATE;
  P_COUNT    NUMBER(5);

BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_TGAMOV = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  STP_OBTEM_DATAS_ARMAZEM( :NEW.TIPMOV, :NEW.DTNEG, :NEW.NUMCONTRATO, P_DTREFENT, P_DTREFCOB );
      
  SELECT COUNT(1)
    INTO P_COUNT
  FROM TGAMOV
  WHERE NUNOTA = :NEW.NUNOTA;

  IF P_COUNT > 0 THEN
    UPDATE TGAMOV SET
      DTNEG = :NEW.DTNEG,
      CODPARC = :NEW.CODPARC,
      DTREFENT = P_DTREFENT,
      DTREFCOB = P_DTREFCOB
    WHERE NUNOTA = :NEW.NUNOTA;
  END IF;
  
END;  

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TGAMOV" ENABLE;
