create or replace TRIGGER TRG_INC_TPRCOI_SPARK2
BEFORE INSERT ON TPRCOI 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TPRCOI_SPARK2
  Tipo           : Trigger
  Descrição      : Valida correspondência entre código de barras e lote de produção (14 ou 15 dígitos)
  Tabela         : TPRCOI
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 
P_COUNT  INT;
P_IDIATV TPRIATV.IDIATV%TYPE;
P_IDIPROC      INT;
P_LOTE         VARCHAR2(100);

--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    SELECT MAX(IDIATV) INTO P_IDIATV
      FROM TPRCONF
    WHERE NUCONF = :NEW.NUCONF;
    
    SELECT MAX(IDIPROC) INTO P_IDIPROC
      FROM TPRIATV
     WHERE IDIATV = P_IDIATV;

    SELECT MAX(NROLOTE) INTO P_LOTE
      FROM TPRIPA
     WHERE IDIPROC = P_IDIPROC;
     
     IF LENGTH(:NEW.CODBARRA) = 14 THEN
        IF SUBSTR(:NEW.CODBARRA, 3, 8) <> LTRIM(P_LOTE) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Esse Código de Barras não pertence a esse Lote!');
        END IF;
    ELSIF LENGTH(:NEW.CODBARRA) = 15 THEN
        IF SUBSTR(:NEW.CODBARRA, 3, 9) <> LTRIM(P_LOTE) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Esse Código de Barras não pertence a esse Lote!');
        END IF;
    END IF;

END TRG_INC_TPRCOI_SPARK2;