/*==============================================================================
  Nome do Script : TRG_INC_TGFSER
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT sobre TGFSER.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 19/09/2025.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_TGFSER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_TGFSER" 
BEFORE INSERT ON TGFSER 
REFERENCING NEW AS NEW OLD AS OLD 
FOR EACH ROW
DECLARE
  P_NUMCONTRATO  TCSPSS.NUMCONTRATO%TYPE;
  P_CODUSU       TGFCAB.CODUSU%TYPE;
  P_DTALTER      TGFCAB.DTALTER%TYPE;
  P_INTEGSERCON  TGFTOP.INTEGSERCON%TYPE;
  P_COUNT        NUMBER;
BEGIN
  
  IF NOT FPODEVALIDAR('TGFSER') THEN
    RETURN;
  END IF;

  BEGIN
    SELECT
      CAB.NUMCONTRATO,
      CAB.CODUSU,
      CAB.DTALTER,
      TPO.INTEGSERCON
    INTO
      P_NUMCONTRATO,
      P_CODUSU,
      P_DTALTER,
      P_INTEGSERCON
    FROM
      TGFCAB CAB
    , TGFTOP TPO
    WHERE CAB.NUNOTA = :NEW.NUNOTA
      AND CAB.CODTIPOPER = TPO.CODTIPOPER
      AND CAB.DHTIPOPER = TPO.DHALTER
      AND TPO.INTEGSERCON IN ('B','E');
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_NUMCONTRATO := 0;
  END; 
   
  IF P_NUMCONTRATO <> 0 THEN
    IF P_INTEGSERCON = 'B' THEN
      SELECT COUNT(1)
        INTO P_COUNT
      FROM TCSPSS
      WHERE CODPROD = :NEW.CODPROD
        AND SERIE = :NEW.SERIE
        AND NUMCONTRATO = P_NUMCONTRATO;
      IF P_COUNT > 0 THEN
        DELETE TCSPSS
        WHERE CODPROD = :NEW.CODPROD
        AND SERIE = :NEW.SERIE
        AND NUMCONTRATO = P_NUMCONTRATO;
      END IF;
      
    ELSIF P_INTEGSERCON = 'E' THEN
      SELECT COUNT(*) INTO P_COUNT
      FROM  TCSPSC 
      WHERE NUMCONTRATO = P_NUMCONTRATO
        AND CODPROD = :NEW.CODPROD;
           
      IF P_COUNT=0 THEN
          BEGIN
          /* INSERINDO O PRODUTO CASO NAO EXISTA*/
          INSERT INTO TCSPSC (NUMCONTRATO, CODPROD, SITPROD, DTALTER)
              VALUES ( P_NUMCONTRATO, :NEW.CODPROD, 'A', SYSDATE );
          END;
      END IF;
              
      INSERT INTO TCSPSS (NUMCONTRATO, CODPROD, SERIE, ATIVO, CODUSU, DTALTER)
        VALUES (P_NUMCONTRATO, :NEW.CODPROD, :NEW.SERIE, 'S', P_CODUSU, P_DTALTER);
        
    END IF;
    :NEW.NUMCONTRATO := P_NUMCONTRATO;
    :NEW.INTEGSERCON := P_INTEGSERCON;
    :NEW.CODUSU := P_CODUSU;
    :NEW.DTALTER := P_DTALTER;
  END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_TGFSER" ENABLE;
