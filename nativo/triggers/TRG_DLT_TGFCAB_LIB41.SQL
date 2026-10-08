/*==============================================================================
  Nome do Script : TRG_DLT_TGFCAB_LIB41
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 03/07/2024 — referência)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 03/07/2024, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFCAB_LIB41', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_LIB41" BEFORE DELETE ON TGFCAB FOR EACH ROW
DECLARE 
  P_COUNT INT; 
  ERRMSG            VARCHAR2(255);
  ERROR             EXCEPTION;
  P_VALIDAR BOOLEAN;
BEGIN 

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

    /* 
    Sincronização de dados
    */
    P_VALIDAR := FPODEVALIDAR('TGFCAB');
    SELECT COUNT(*) 
    INTO P_COUNT 
    FROM TSILIB 
    WHERE EVENTO = 41 
    AND TABELA = 'TGFCAB' 
    AND (DHLIB IS NOT NULL OR REPROVADO = 'S') 
    AND NUCHAVE = :OLD.NUNOTA; 
    IF P_COUNT > 0 THEN 
      ERRMSG := 'Pedido/Nota com Liberação por Análise dos Itens não pode ser Excluída. Nota de Nro único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
    END IF;
  
    RETURN;
     
EXCEPTION
  WHEN ERROR THEN
    /* 
    Sincronização de dados não faz validações
    */
    IF (P_VALIDAR) THEN 
      RAISE_APPLICATION_ERROR(-20101, ERRMSG);
    END IF; 
   
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFCAB_LIB41" ENABLE;
