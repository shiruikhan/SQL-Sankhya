create or replace TRIGGER TRG_INC_UPD_TGFITE_SPARK2
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_SPARK2
  Tipo           : Trigger
  Descrição      : Calcula valores unitários e totais em moeda estrangeira para operações de importação
  Tabela         : TGFITE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
 P_CODLOCAL NUMBER;
 P_TIPMOV        TGFCAB.TIPMOV%TYPE;
 P_CODTIPOPER    TGFCAB.CODTIPOPER%TYPE;
 P_VLRMOEDA      TGFCAB.VLRMOEDA%TYPE;
-- PRAGMA AUTONOMOUS_TRANSACTION; 

BEGIN

    BEGIN
    SELECT CODTIPOPER, VLRMOEDA INTO P_CODTIPOPER, P_VLRMOEDA
    FROM TGFCAB WHERE NUNOTA = :NEW.NUNOTA;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN;
    END TRG_INC_UPD_TGFITE_SPARK2;
    
    IF P_CODTIPOPER IN (1008,1009) AND P_VLRMOEDA > 0 THEN
    
    :NEW.VLRUNITMOE := ((:NEW.VLRTOT - :NEW.VLRDESC) / :NEW.QTDNEG)  / P_VLRMOEDA;
    
    :NEW.VLRTOTMOE := :NEW.VLRUNITMOE * :NEW.QTDNEG;
    
    END IF;


END;