/*==============================================================================
  Nome do Script : TRG_UPD_TGFITE_TCIBEM
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPD_TGFITE_TCIBEM', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFITE_TCIBEM" 
BEFORE UPDATE ON TGFITE FOR EACH ROW
DECLARE
  P_COUNT       NUMBER;
  ERROR         EXCEPTION;
  ERRMSG        VARCHAR2(4000);
  P_VALIDAR     BOOLEAN;
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

  IF UPDATING('VLRUNIT') OR UPDATING('VLRDESC') THEN
    /* 
    sincronização de dados
    */
    P_VALIDAR := FPODEVALIDAR('TGFITE');
    SELECT COUNT(1)  INTO P_COUNT
      FROM TCIIBE I, TCIMOV M, TCIBEM B
     WHERE I.NUNOTA = :NEW.NUNOTA
       AND I.SEQUENCIA = :NEW.SEQUENCIA
       AND I.CODPROD = M.CODPROD
       AND I.CODBEM = M.CODBEM
       AND I.CODPROD = B.CODPROD
       AND I.CODBEM = B.CODBEM
       AND B.NUNOTA = :NEW.NUNOTA;   
    IF P_COUNT > 0 THEN
       ERRMSG := 'Bem possui depreciação, não pode alterar o valor de aquisição.';
     RAISE ERROR;
    END IF;
  END IF;
  
  RETURN;
  
EXCEPTION
  WHEN ERROR THEN
    /* 
    Sincronização de dados não faz validações
    */
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFITE_TCIBEM" ENABLE;
