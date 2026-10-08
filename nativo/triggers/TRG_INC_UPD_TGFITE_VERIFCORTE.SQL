/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_VERIFCORTE
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFITE_VERIFCORTE', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_VERIFCORTE" BEFORE INSERT OR UPDATE ON TGFITE FOR EACH ROW
      WHEN ( NEW.QTDCONFERIDA <> 0 AND NVL(OLD.QTDCONFERIDA,0) <> NVL(NEW.QTDCONFERIDA,0) ) DECLARE
  P_PERMITECORTE   VARCHAR2(1);
  P_VALIDAR        BOOLEAN;
  P_COUNT          NUMBER(05);
BEGIN
   BEGIN


  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_VERIFCORTE = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  P_VALIDAR := Fpodevalidar('TGFITE');
  IF (NOT P_VALIDAR) THEN
    RETURN;
  END IF;
  
     SELECT PAR.PERMITECORTE INTO P_PERMITECORTE
     FROM TGFPAR PAR, TGFCAB CAB
     WHERE PAR.CODPARC = CAB.CODPARC
     AND CAB.NUNOTA = :NEW.NUNOTA;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN;
   END;
   IF P_PERMITECORTE <> 'S' THEN
     RAISE_APPLICATION_ERROR(-20101, 'Corte não permitido para o parceiro deste pedido.');
   END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFITE_VERIFCORTE" ENABLE;
