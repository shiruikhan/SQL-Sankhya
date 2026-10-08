/*==============================================================================
  Nome do Script : TRG_DLT_TGFCAB_ECF
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFCAB_ECF', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_ECF" BEFORE DELETE ON TGFCAB FOR EACH ROW
DECLARE
  P_COUNT   INT;
  ERRMSG    VARCHAR2(255);
  ERROR     EXCEPTION;
  P_VALIDAR BOOLEAN;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  /* 
  Sincronizac?o de dados
  */
  P_VALIDAR := FPODEVALIDAR('TGFCAB');
  SELECT NVL(COUNT(1),0) INTO P_COUNT 
    FROM TSIPAR  PAR
   WHERE PAR.CHAVE = 'MODELOCUPOM'
   AND PAR.INTEIRO = :OLD.NUNOTA;
  
  IF (P_COUNT<>0) THEN
    ERRMSG := 'Modelo nao pode ser excluido, esta configurado para uso do FAST, verifique o parametro [ MODELOCUPOM ]. Nota de Nro Unico: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END IF;
  
  RETURN;
EXCEPTION
  WHEN ERROR THEN
    /* 
    Sincronizac?o de dados n?o faz validac?es
    */
    IF (P_VALIDAR) THEN 
      RAISE_APPLICATION_ERROR(-20101, ERRMSG);
    END IF; 
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_ECF" ENABLE;
