create or replace TRIGGER TRG_UPD_TGSLOGLIB_SPARK 
BEFORE UPDATE ON TSILIB 
FOR EACH ROW 
/*==============================================================================
  Nome do Script : TRG_UPD_TGSLOGLIB_SPARK
  Tipo           : Trigger
  Descrição      : Registra log de liberação de crédito ao autorizar nota
                   fiscal de venda
  Tabela         : TSILIB
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
WHEN (NEW.DHLIB IS NOT NULL AND NEW.EVENTO = 3) 
DECLARE
    V_VLRTOTFIN TGFFIN.VLRDESDOB%TYPE;
    V_VLRTOTPED TGFCAB.VLRNOTA%TYPE;
    V_CODPARC TGFPAR.CODPARC%TYPE;
    V_CODPARCMATRIZ TGFPAR.CODPARCMATRIZ%TYPE;
    V_EXISTE NUMBER;
BEGIN

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;
    
    BEGIN
        SELECT C.CODPARC INTO V_CODPARC
        FROM TGFCAB C
        WHERE C.NUNOTA = :NEW.NUCHAVE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CODPARC := 0;
    END TRG_UPD_TGSLOGLIB_SPARK;
    
    BEGIN
        SELECT P.CODPARCMATRIZ INTO V_CODPARCMATRIZ
        FROM TGFPAR P
        WHERE P.CODPARC = V_CODPARC;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CODPARCMATRIZ := 0;
    END;
    
    BEGIN
        SELECT SUM(VLRDESDOB) INTO V_VLRTOTFIN 
        FROM TGFFIN
        WHERE CODPARC = V_CODPARC
            AND RECDESP = 1
            AND PROVISAO = 'N'
            AND DHBAIXA IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_VLRTOTFIN := 0;
    END;
    
    SELECT (VLRNOTA + NVL(VLROUTROS,0) + NVL(AD_VLROUTROSFRETE,0)) INTO V_VLRTOTPED
    FROM TGFCAB
    WHERE NUNOTA = :NEW.NUCHAVE;
    
   SELECT COUNT(0) INTO V_EXISTE
    FROM TGSLOGLIB
    WHERE NUNOTA = :NEW.NUCHAVE AND DHLIB = :NEW.DHLIB;
    
    IF V_EXISTE = 0 THEN
        INSERT INTO TGSLOGLIB (NUNOTA, DHLIB, CODUSULIB, VLRLIBERADO, VLRTOTPED, OBSLIB, VLRLIMITE, VLRTOTFIN, CODPARC, CODPARCMATRIZ)
        VALUES (:NEW.NUCHAVE, :NEW.DHLIB, :NEW.CODUSULIB, :NEW.VLRLIBERADO, V_VLRTOTPED, :NEW.OBSLIB, :NEW.VLRLIMITE, V_VLRTOTFIN, V_CODPARC, V_CODPARCMATRIZ);
    END IF;
END;