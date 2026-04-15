create or replace TRIGGER TRG_INC_UPD_TPRCONF_SPARK
BEFORE INSERT OR UPDATE OR DELETE
ON TPRCONF
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TPRCONF_SPARK
  Tipo           : Trigger
  Descrição      : Insere códigos de barras consolidados ao finalizar conferência de ordem de produção
  Tabela         : TPRCONF
  Evento         : BEFORE INSERT OR UPDATE OR DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 
P_COUNT        INT;

BEGIN


IF :NEW.STATUS='F' THEN

INSERT INTO AD_TPRCOI (NUCONF,CODBARRA,CODPROD,CODUSU,DTINCLUSAO)
SELECT NUCONF,CODBARRA,CODPROD,STP_GET_CODUSULOGADO(), SYSDATE FROM TPRCOI COI WHERE NUCONF = :NEW.NUCONF
AND NOT EXISTS (SELECT 1 FROM AD_TPRCOI C WHERE C.NUCONF = COI.NUCONF AND C.CODPROD = COI.CODPROD AND C.CODBARRA = COI.CODBARRA);

UPDATE TPRCOI SET CONTROLE= ' ' WHERE NUCONF = :NEW.NUCONF;   

UPDATE TPRCOI SET QTDCONF=(SELECT SUM(QTDCONF) FROM TPRCOI WHERE NUCONF=:NEW.NUCONF) WHERE NUCONF = :NEW.NUCONF
AND ROWNUM = 1;   

DELETE TPRCOI C WHERE EXISTS (
SELECT * FROM(
SELECT COI.*, ROWNUM AS SEQ FROM TPRCOI COI WHERE NUCONF = :NEW.NUCONF
ORDER BY NUCONF,CODBARRA) D WHERE SEQ >1 AND C.NUCONF = D.NUCONF AND C.CODBARRA = D.CODBARRA AND C.CODPROD = D.CODPROD)
AND C.NUCONF = :NEW.NUCONF;


END IF;

END TRG_INC_UPD_TPRCONF_SPARK; 