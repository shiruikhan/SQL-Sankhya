CREATE OR REPLACE TRIGGER TRG_FRETE_CIF_MTKPL_SPARK
BEFORE INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_FRETE_CIF_MTKPL_SPARK
  Tipo           : Trigger
  Descrição      : Força CIF_FOB = 'C' e TIPFRETE = 'N' nas notas da empresa 2
                   com tipo de venda 78, tipo de operação 1005 e vendedor 5.
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Maio/2026
  Última Revisão : Maio/2026
==============================================================================*/
DECLARE
    V_OPERACAO VARCHAR2(10);

    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA, NUMNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'TRG_FRETE_CIF_MTKPL_SPARK', P_OPERACAO, :NEW.NUNOTA, :NEW.NUMNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END LOG_ERRO;

BEGIN
    IF INSERTING THEN
        V_OPERACAO := 'INSERT';
    ELSIF UPDATING THEN
        V_OPERACAO := 'UPDATE';
    END IF;

    IF  :NEW.CODEMP     = 2
    AND :NEW.CODTIPVENDA = 78
    AND :NEW.CODTIPOPER = 1005
    AND :NEW.CODVEND    = 5
    THEN
        :NEW.CIF_FOB  := 'C';
        :NEW.TIPFRETE := 'N';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(V_OPERACAO, SQLCODE, SQLERRM,
                 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                 DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20100, 'Erro na trigger TRG_FRETE_CIF_MTKPL_SPARK: ' || SQLERRM);
END TRG_FRETE_CIF_MTKPL_SPARK;
