create or replace TRIGGER "SPARKPRD"."TRG_TGFCON2_SPARK" 
BEFORE INSERT OR UPDATE ON TGFCON2
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGFCON2_SPARK
  Tipo           : Trigger
  Descrição      : Insere série em TGFSER ao finalizar conferência
  Tabela         : TGFCON2
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
P_COUNT      INT;

BEGIN

    IF :NEW.STATUS = 'F' AND :OLD.STATUS <> :NEW.STATUS THEN 

    SELECT COUNT(*) INTO P_COUNT
      FROM TGFSER
    WHERE NUNOTA = :NEW.NUNOTAORIG;

        IF P_COUNT = 0 THEN 

        INSERT INTO TGFSER ( NUNOTA, CODPROD , SEQUENCIA, SERIE, ATUALESTOQUE, TIPCONTEST, CODUSU, DTALTER)
        (SELECT :NEW.NUNOTAORIG, S.CODPROD, (SELECT MAX(SEQUENCIA) FROM TGFITE WHERE NUNOTA = :NEW.NUNOTAORIG AND CODPROD = S.CODPROD), S.CODBARRA, 0, 'N', STP_GET_CODUSULOGADO(), SYSDATE
           FROM TGFCOI2 S
         WHERE NUCONF = :NEW.NUCONF);

        END IF;

    END IF;

END UNKNOWN;
