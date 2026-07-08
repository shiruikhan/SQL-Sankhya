CREATE OR REPLACE PROCEDURE STP_ATUALIZADTFIM_TGSIXN_SPARK AS
/*==============================================================================
  Nome do Script : STP_ATUALIZADTFIM_TGSIXN_SPARK
  Tipo           : Stored Procedure (Agendada)
  Descrição      : Reavalia os apontamentos de conferência em aberto em
                   AD_TGSIXN (STATUS = 1). Para cada um, localiza a chave de
                   acesso do arquivo (TGFIXN.CHAVEACESSO) pelo NUARQUIVO e
                   busca, com essa chave, a nota lançada correspondente em
                   TGFCAB (CHAVENFE, STATUSNOTA = 'L'). Quando encontra,
                   grava TGFCAB.DTMOV em DTFIM, fechando o apontamento
                   (TRG_INC_UPD_AD_TGSIXN_SPARK deriva STATUS = 2 a partir
                   disso). Em seguida recalcula DURACAO_DIAS_UTEIS (dias
                   úteis entre DTINI e DTFIM, ou entre DTINI e SYSDATE
                   enquanto ainda aberto), desconsiderando sábado/domingo.

  Parâmetros     : [Procedure agendada - sem parâmetros de entrada]

  Tabelas        : AD_TGSIXN -- apontamentos reavaliados (leitura e UPDATE)
                   TGFIXN    -- leitura de CHAVEACESSO a partir de NUARQUIVO
                   TGFCAB    -- leitura de DTMOV/STATUSNOTA a partir de CHAVENFE
  Tabela de Log  : AD_LOG_ERROS -- erros por apontamento, sem abortar o lote

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
==============================================================================*/

    V_QTD_AVALIADOS NUMBER := 0; -- apontamentos abertos encontrados nesta execucao
    V_QTD_FECHADOS  NUMBER := 0; -- dentre esses, quantos foram fechados agora

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
    -- 1. Percorre os apontamentos em aberto, ja com o DTFIM da nota lancada
    --    (quando existir) calculado na propria consulta
    ---------------------------------------------------------------------------
    FOR R_CONF IN (
        SELECT  TGS.NUCONF
               ,TGS.DTINI
               ,(SELECT MAX(CAB.DTMOV)
                   FROM TGFCAB CAB
                  WHERE CAB.CHAVENFE   = IXN.CHAVEACESSO
                    AND CAB.STATUSNOTA = 'L') AS DTFIM_NOVO
        FROM    AD_TGSIXN TGS
        INNER JOIN TGFIXN IXN ON IXN.NUARQUIVO = TGS.NUARQUIVO
        WHERE   TGS.STATUS = '1'
    ) LOOP
        V_QTD_AVALIADOS := V_QTD_AVALIADOS + 1;
        BEGIN
            -----------------------------------------------------------------
            -- 2. Fecha o apontamento (DTFIM) quando a nota ja foi lancada, e
            --    recalcula a duracao em dias uteis com o DTFIM resultante
            -----------------------------------------------------------------
            UPDATE AD_TGSIXN
               SET DTFIM = NVL(R_CONF.DTFIM_NOVO, DTFIM)
                  ,DURACAO_DIAS_UTEIS =
                       (SELECT COUNT(*)
                          FROM (SELECT TRUNC(R_CONF.DTINI) + LEVEL - 1 AS DIA
                                  FROM DUAL
                                CONNECT BY LEVEL <= TRUNC(NVL(R_CONF.DTFIM_NOVO, SYSDATE))
                                                  - TRUNC(R_CONF.DTINI) + 1)
                         WHERE TO_CHAR(DIA, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') NOT IN ('SAT', 'SUN'))
             WHERE NUCONF = R_CONF.NUCONF;

            IF R_CONF.DTFIM_NOVO IS NOT NULL THEN
                V_QTD_FECHADOS := V_QTD_FECHADOS + 1;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                LOG_ERRO(
                    P_OPERACAO      => 'ATU_DTFIM',
                    P_NUNOTA        => R_CONF.NUCONF,
                    P_ERR_CODE      => SQLCODE,
                    P_ERR_MSG       => SQLERRM,
                    P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                    P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
                );
        END;
    END LOOP;

    -----------------------------------------------------------------------
    -- 3. Registra a execucao em AD_LOG_ERROS (mesmo sem erro), para dar
    --    visibilidade do historico de rodadas do job -- inclusive quando
    --    nao ha nenhum apontamento aberto para avaliar
    -----------------------------------------------------------------------
    LOG_ERRO(
        P_OPERACAO      => 'EXEC_OK',
        P_NUNOTA        => NULL,
        P_ERR_CODE      => 0,
        P_ERR_MSG       => 'Execucao concluida: ' || V_QTD_AVALIADOS || ' apontamento(s) avaliado(s), '
                            || V_QTD_FECHADOS || ' fechado(s) nesta execucao, '
                            || (V_QTD_AVALIADOS - V_QTD_FECHADOS) || ' permanece(m) em aberto.',
        P_ERR_BACKTRACE => NULL,
        P_CALL_STACK    => NULL
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => 'LOOP_PRINC',
            P_NUNOTA        => NULL,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20001,
            'Erro em STP_ATUALIZADTFIM_TGSIXN_SPARK: ' || SQLERRM);
END STP_ATUALIZADTFIM_TGSIXN_SPARK;
