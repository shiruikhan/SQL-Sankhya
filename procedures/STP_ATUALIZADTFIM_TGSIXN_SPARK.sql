create or replace PROCEDURE STP_ATUALIZADTFIM_TGSIXN_SPARK AS
/*==============================================================================
  Nome do Script : STP_ATUALIZADTFIM_TGSIXN_SPARK
  Tipo           : Stored Procedure (Agendada)
  Descrição      : Reavalia os apontamentos de conferência em aberto em
                   AD_TGSIXN (STATUS = 1). A trigger TRG_INC_UPD_TGSIXN_DTFIM_SPARK
                   só preenche DTFIM no momento em que a linha é gravada; se a
                   nota vinculada ainda não estava lançada (STATUSNOTA <> 'L')
                   nesse momento, o apontamento fica aberto indefinidamente sem
                   um novo evento que o reavalie. Esta procedure força essa
                   reavaliação periodicamente: para cada apontamento aberto,
                   executa um UPDATE que aciona novamente as triggers de
                   DTFIM/STATUS, sem duplicar a lógica de busca (que permanece
                   centralizada na trigger).

  Parâmetros     : [Procedure agendada - sem parâmetros de entrada]

  Tabelas        : AD_TGSIXN -- apontamentos reavaliados (UPDATE dispara triggers)
  Tabela de Log  : AD_LOG_ERROS -- erros por apontamento, sem abortar o lote

  Dependências   : TRG_INC_UPD_TGSIXN_DTFIM_SPARK -- calcula DTFIM
                   TRG_INC_UPD_AD_TGSIXN_SPARK     -- deriva STATUS de DTFIM

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Criação

  Observações    : - Recomenda-se agendar com frequência compatível com o volume
                     de conferências em aberto (ex.: a cada 30-60 minutos).
                   - Erro em um apontamento é registrado e o lote continua.
==============================================================================*/

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_NUNOTA        NUMBER,
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
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'STP_ATUALIZADTFIM_TGSIXN_SPARK', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    ---------------------------------------------------------------------------
    -- 1. Percorre os apontamentos de conferencia ainda em aberto
    ---------------------------------------------------------------------------
    FOR R_CONF IN (
        SELECT NUCONF
        FROM   AD_TGSIXN
        WHERE  STATUS = '1'
    ) LOOP
        BEGIN
            -----------------------------------------------------------------
            -- 2. Forca a reavaliacao de DTFIM/STATUS via triggers da tabela
            -----------------------------------------------------------------
            UPDATE AD_TGSIXN
               SET DTFIM = DTFIM
             WHERE NUCONF = R_CONF.NUCONF;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_ERRO(
                    P_OPERACAO      => 'ATUALIZA_DTFIM',
                    P_NUNOTA        => R_CONF.NUCONF,
                    P_ERR_CODE      => SQLCODE,
                    P_ERR_MSG       => SQLERRM,
                    P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                    P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
                );
        END;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => 'LOOP_PRINCIPAL',
            P_NUNOTA        => NULL,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20001,
            'Erro em STP_ATUALIZADTFIM_TGSIXN_SPARK: ' || SQLERRM);
END STP_ATUALIZADTFIM_TGSIXN_SPARK;
