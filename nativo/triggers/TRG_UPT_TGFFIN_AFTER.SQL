/*==============================================================================
  Nome do Script : TRG_UPT_TGFFIN_AFTER
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER STATEMENT UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_UPT_TGFFIN_AFTER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_AFTER" AFTER UPDATE ON TGFFIN
DECLARE
  P_COUNT          INT;
  P_CODPARC        INT;
  P_SOMA    FLOAT;
  P_RECDESP_D      DECIMAL(5, 0);
  P_RECDESP        DECIMAL(5, 0);
  P_TIPMARCCHEQ_D  VARCHAR2(1);
  P_TIPMARCCHEQ    VARCHAR2(1);
  ERRMSG            VARCHAR2(4000);
  ERROR             EXCEPTION;
  P_VALIDAR BOOLEAN;
  CURSOR PARCEIROS IS SELECT CODPARC, TIPMARCCHEQ_D, TIPMARCCHEQ, RECDESP_D, RECDESP FROM TGFFIN_UPD;
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  
  /* 
  sincronização de dados
  */
  P_VALIDAR := FPODEVALIDAR('TGFFIN');
  OPEN PARCEIROS;
  DELETE FROM TGFFIN_UPD;
  LOOP
   FETCH PARCEIROS INTO P_CODPARC, P_TIPMARCCHEQ_D, P_TIPMARCCHEQ, P_RECDESP_D, P_RECDESP;
   EXIT WHEN PARCEIROS%NOTFOUND;
    IF ((P_TIPMARCCHEQ_D = 'B') AND (P_RECDESP_D = -1) ) OR
     ( (P_TIPMARCCHEQ = 'B') AND (P_RECDESP = 1)) THEN
       SELECT NVL(SUM(VLRDESDOB * RECDESP), 0)  INTO P_SOMA
       FROM TGFFIN
       WHERE (CODPARC = P_CODPARC)
         AND (DHBAIXA IS NULL)
         AND (TIPMARCCHEQ = 'B');
       IF (P_SOMA >= 0) THEN
          ERRMSG := 'Na somatória dos titulos marcados para emissão de cheque Vários nominal ao fornecedor as despesas devem superar as receitas.';
          RAISE ERROR;
        END IF;
    END IF;
  END LOOP;
  CLOSE PARCEIROS;

  RETURN;
   
EXCEPTION
  WHEN OTHERS THEN
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
ALTER TRIGGER "SPARKPRD"."TRG_UPT_TGFFIN_AFTER" ENABLE;
