/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFEST_BAR
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFEST_BAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_BAR" 
BEFORE INSERT OR UPDATE ON TGFEST 
FOR EACH ROW
         WHEN (NVL(NEW.CODBARRA, ' ') <> NVL(OLD.CODBARRA, ' ')) DECLARE P_COUNT  NUMBER(10); 
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  IF GET_TSIPAR_LOGICO('INTCODBARDTSYNC') = 'N' THEN
    RETURN;
  END IF;
  
  IF Variaveis_Pkg.CODBARRA_EST <> 'BAR' THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFESTBAR
    WHERE CODEMP = :NEW.CODEMP
      AND CODPROD = :NEW.CODPROD
      AND CODLOCAL = :NEW.CODLOCAL
      AND CONTROLE = :NEW.CONTROLE
      AND CODPARC = :NEW.CODPARC
      AND TIPO = :NEW.TIPO;
    Variaveis_Pkg.CODBARRA_EST := 'EST';    
    IF P_COUNT > 0 THEN      
      UPDATE TGFESTBAR SET CODBARRA = :NEW.CODBARRA
      WHERE CODEMP = :NEW.CODEMP
        AND CODPROD = :NEW.CODPROD
        AND CODLOCAL = :NEW.CODLOCAL
        AND CONTROLE = :NEW.CONTROLE
        AND CODPARC = :NEW.CODPARC
        AND TIPO = :NEW.TIPO;
    ELSE
      INSERT INTO TGFESTBAR (CODEMP, CODPROD, CODLOCAL, CONTROLE, CODPARC, TIPO, CODBARRA)
                     VALUES (:NEW.CODEMP, :NEW.CODPROD, :NEW.CODLOCAL, :NEW.CONTROLE, :NEW.CODPARC, :NEW.TIPO, :NEW.CODBARRA);
    END IF;
    Variaveis_Pkg.CODBARRA_EST := ' ';
  END IF;    
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFEST_BAR" ENABLE;
