/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_TCIBEM
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 06/09/2023)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 06/09/2023, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_TCIBEM', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TCIBEM" 
AFTER UPDATE ON TGFCAB 
FOR EACH ROW
DECLARE P_COUNT     NUMBER(10);
        P_CODPROD   NUMBER(10);
        P_CODBEM    VARCHAR2(30);
        P_MSGERR    VARCHAR2(255);
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_TCIBEM = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  IF (:NEW.CODEMP <> :OLD.CODEMP) AND (:NEW.TIPMOV = 'T') THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TCIIBE IBE    
    WHERE IBE.NUNOTA = :NEW.NUNOTA;
    
    IF P_COUNT > 0 THEN    
      RAISE_APPLICATION_ERROR(-20101, 'Não é possível alterar Empresa de Origem em transferência de Bem, que já tenha bem relacionado. Nota de Nro único: '|| TO_CHAR(:NEW.NUNOTA) ||'.');
    END IF;
  END IF;
  
  IF (:NEW.CODEMPNEGOC <> :OLD.CODEMPNEGOC) AND (:NEW.TIPMOV = 'T') THEN
    SELECT COUNT(1) INTO P_COUNT
    FROM TCIIBE IBE
    WHERE IBE.NUNOTA = :NEW.NUNOTA;
         
    IF P_COUNT > 0 THEN    
      BEGIN
        SELECT ITE.CODPROD, IBE.CODBEM
          INTO P_CODPROD, P_CODBEM 
        FROM TCIIBE IBE
           , TGFITE ITE
        WHERE ITE.NUNOTA = :NEW.NUNOTA
          AND IBE.NUNOTA = ITE.NUNOTA
          AND IBE.SEQUENCIA = ITE.SEQUENCIA
          AND IBE.NUNOTA <> (SELECT MAX(NUNOTA)
                             FROM TCIIBE I
                             WHERE I.CODPROD = IBE.CODPROD
                               AND I.CODBEM = IBE.CODBEM);
                             
      EXCEPTION WHEN NO_DATA_FOUND THEN                        
        P_CODPROD := 0;
        P_CODBEM  := '';
      END;
      
      IF P_CODPROD > 0 THEN
        P_MSGERR := 'Nota não pode ser alterada pois o produto: '||TO_CHAR(P_CODPROD)||', bem: '|| P_CODBEM || ', já foi movimentado. Nota de Nro único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
        RAISE_APPLICATION_ERROR(-20101, P_MSGERR);
      ELSE        
        UPDATE TCIBEM SET CODEMP = :NEW.CODEMPNEGOC        
        WHERE EXISTS(SELECT 1
                     FROM TCIIBE IBE
                        , TGFITE ITE
                     WHERE ITE.NUNOTA = :NEW.NUNOTA
                       AND IBE.NUNOTA = ITE.NUNOTA
                       AND IBE.SEQUENCIA = ITE.SEQUENCIA
                       AND TCIBEM.CODBEM = IBE.CODBEM
                       AND TCIBEM.CODPROD = IBE.CODPROD);
        
        SELECT COUNT(1) INTO P_COUNT 
        FROM TCILOC LOC            
           , TGFITE ITE
           , TCIIBE IBE
        WHERE ITE.NUNOTA    = :NEW.NUNOTA
          AND IBE.NUNOTA    = ITE.NUNOTA
          AND IBE.SEQUENCIA = ITE.SEQUENCIA
          AND LOC.NUNOTA    = ITE.NUNOTA
          AND LOC.CODPROD   = ITE.CODPROD
          AND LOC.SEQUENCIA = ITE.SEQUENCIA                      
          AND LOC.CODBEM    = IBE.CODBEM;
         
        IF P_COUNT > 0 THEN     
          UPDATE TCILOC SET CODEMP = :NEW.CODEMPNEGOC          
          WHERE EXISTS(SELECT 1             
                FROM TGFITE ITE
                          , TCIIBE IBE
                       WHERE ITE.NUNOTA     = :NEW.NUNOTA
                         AND IBE.NUNOTA     = ITE.NUNOTA
                         AND IBE.SEQUENCIA  = ITE.SEQUENCIA
                         AND TCILOC.NUNOTA     = ITE.NUNOTA
                         AND TCILOC.CODPROD    = ITE.CODPROD
                         AND TCILOC.SEQUENCIA  = ITE.SEQUENCIA
                         AND TCILOC.CODBEM     = IBE.CODBEM);
        END IF;
            
      END IF;
    END IF;
  END IF;
    
  IF (:OLD.NUMNOTA <> :NEW.NUMNOTA) THEN 
    UPDATE TCIBEM SET NUMNOTA = :NEW.NUMNOTA
    WHERE NUNOTA = :NEW.NUNOTA; 
  
    UPDATE TCIBEM SET NUMNOTABAIXA = :NEW.NUMNOTA
    WHERE NUNOTABAIXA = :NEW.NUNOTA;
  END IF;
  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_TCIBEM" ENABLE;
