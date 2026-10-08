/*==============================================================================
  Nome do Script : TRG_INC_TGFVAR_BLOQ_SAFRA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW INSERT sobre TGFVAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_TGFVAR_BLOQ_SAFRA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_TGFVAR_BLOQ_SAFRA" 
BEFORE INSERT ON TGFVAR
FOR EACH ROW
DECLARE
   P_CODPROJ     TGFCAB.CODPROJ%TYPE;
   P_TIPMOV      TGFCAB.TIPMOV%TYPE;
   P_BLOQUEAR    TGABDLC.BLOQUEAR%TYPE;
   P_OBS         TGABDLC.OBS%TYPE;
   P_DESCRDIG    TGADIG.DESCRDIG%TYPE;
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
   P_VALIDAR := Fpodevalidar('TGFVAR'); 

 IF ((:NEW.SEQUENCIA = 0) AND (:NEW.SEQUENCIAORIG = 0) AND (:NEW.QTDATENDIDA = 0)) THEN
   RETURN;
 END IF;

 BEGIN
     SELECT TIPMOV, CODPROJ 
     INTO P_TIPMOV, P_CODPROJ
     FROM TGFCAB
     WHERE NUNOTA = :NEW.NUNOTAORIG;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN;
 END;

 IF (P_TIPMOV = 'P' AND P_CODPROJ <> 0)  THEN
   BEGIN
     SELECT BLC.BLOQUEAR, MOT.DESCRDIG, BLC.OBS 
     INTO P_BLOQUEAR, P_DESCRDIG, P_OBS 
     FROM TGABDLC BLC
     , TGADIG MOT
     WHERE BLC.CODPROJ = P_CODPROJ
     AND BLC.SEQUENCIA = (SELECT MAX(SEQUENCIA) FROM TGABDLC LM WHERE CODPROJ = P_CODPROJ)
     AND BLC.TIPO = MOT.TIPO
     AND BLC.NUDIG = MOT.NUDIG;
   EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN;
   END;
   
   IF P_BLOQUEAR = 'S' THEN
     ERRMSG := 'Pedido bloqueado. Motivo:'|| P_DESCRDIG || '. Obs.:'|| P_OBS || '.';
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
     RAISE_APPLICATION_ERROR(-20101, ERRMSG);
   END IF; 
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_TGFVAR_BLOQ_SAFRA" ENABLE;
