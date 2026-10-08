/*==============================================================================
  Nome do Script : TRG_DLT_TGFVAR_AFTER
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger AFTER STATEMENT DELETE sobre TGFVAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TGFVAR_AFTER', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TGFVAR_AFTER" 
AFTER DELETE ON TGFVAR 
DECLARE
 P_NUNOTAORIG      INT;
 P_SEQUENCIAORIG   SMALLINT;
 P_QTDATENDIDA     FLOAT;
 P_FIXACAO         VARCHAR2(1);
 P_COUNT           INT; 
 CURSOR DELVAR IS SELECT NUNOTAORIG, SEQUENCIAORIG, QTDATENDIDA, FIXACAO FROM TGFVAR_DLT;
BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;
  OPEN DELVAR;
  DELETE FROM TGFVAR_DLT;  
  LOOP
    FETCH DELVAR INTO P_NUNOTAORIG, P_SEQUENCIAORIG, P_QTDATENDIDA, P_FIXACAO;
    EXIT WHEN DELVAR%NOTFOUND;
    UPDATE TGFITE SET QTDENTREGUE = (QTDENTREGUE -(CASE WHEN P_FIXACAO = 'S' THEN 0 ELSE P_QTDATENDIDA END))
                    , QTDFIXADA = (NVL(QTDFIXADA, 0) -(CASE  WHEN P_FIXACAO = 'S' THEN P_QTDATENDIDA ELSE 0 END))
    WHERE (NUNOTA = P_NUNOTAORIG)
      AND (SEQUENCIA = P_SEQUENCIAORIG);
  END LOOP;
  CLOSE DELVAR;

END;
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TGFVAR_AFTER" ENABLE;
