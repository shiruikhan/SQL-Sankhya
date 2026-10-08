/*==============================================================================
  Nome do Script : TRG_UPD_TGFFIN_GRAVAR
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFFIN_GRAVAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_GRAVAR" 
BEFORE UPDATE ON TGFFIN
FOR EACH ROW
    WHEN (NEW.TIMORIGEM = 'AL' 
    AND NVL(NEW.TIMORIGRENEG,'N') = 'N' 
    AND NEW.TIMCONTRATOLOC IS NOT NULL 
    AND NEW.TIMNEGOCIACAO IS NOT NULL) DECLARE
    P_GARANTIDO CHAR(1);
    P_QTDEGARANTIDA VARCHAR2(2);
      P_EHBAIXA CHAR(1);
BEGIN
   IF NOT STP_GET_TIMUTILIZAIMOB()
   THEN
      RETURN;
   END IF;

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    
    IF :NEW.DHBAIXA IS NOT NULL AND :OLD.DHBAIXA IS NULL THEN
        P_EHBAIXA := 'S';
    ELSIF :NEW.DHBAIXA IS NULL AND :OLD.DHBAIXA IS NOT NULL THEN
        P_EHBAIXA := 'N';
    ELSE
        RETURN;
    END IF;

    SELECT 
        NVL(LOCGARANTIDO, 'N'), 
        LOCQTDEGARANTIDA 
        INTO 
        P_GARANTIDO, 
        P_QTDEGARANTIDA
    FROM TIMLOC 
    WHERE LOCCODIGO = :NEW.TIMCONTRATOLOC;

    IF P_GARANTIDO = 'S' AND NVL(P_QTDEGARANTIDA, 'N') <> 'S' THEN
        INSERT INTO TIMGAV(
            GAVNUFIN, 
            GAVCONTRATOLOC, 
            GAVFINGARANTORIG, 
            GAVBAIXA, 
            GAVNEGOCIACAO
        ) VALUES(
            :NEW.NUFIN, 
            :NEW.TIMCONTRATOLOC, 
            :NEW.TIMFINGARANTORIG, 
            P_EHBAIXA, 
            :NEW.TIMNEGOCIACAO
        );
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFFIN_GRAVAR" ENABLE;
