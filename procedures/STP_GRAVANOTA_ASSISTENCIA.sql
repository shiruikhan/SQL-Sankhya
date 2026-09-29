CREATE OR REPLACE PROCEDURE STP_GRAVANOTA_ASSISTENCIA (
    P_CODUSU    NUMBER,        -- Código do usuário logado
    P_IDSESSAO  VARCHAR2,      -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,        -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM  OUT VARCHAR2   -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_GRAVANOTA_ASSISTENCIA
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Vincula a nota de serviço à O.S. de assistência técnica
                   selecionada em AD_TGFASS. O usuário informa o Nro. Único da
                   nota (NUNOTA) no parâmetro de tela; a procedure valida se o
                   lançamento existe em TGFCAB e, existindo, grava o valor em
                   AD_TGFASS.NUNOTA. Se o Nro. Único for inválido ou não
                   existir, a execução é abortada com mensagem de erro e
                   nada é gravado.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_TXT_PARAM / ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de O.S. selecionadas em AD_TGFASS (exige exatamente 1)
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Parâmetro de tela (ACT_TXT_PARAM):
                   NUNOTA — Nro. Único da nota de serviço a vincular à O.S.

  Tabelas        : AD_TGFASS    -- atualização (NUNOTA) da O.S. selecionada
                   TGFCAB       -- leitura (validação da existência do NUNOTA)
  Tabela de Log  : AD_LOG_ERROS -- somente erros inesperados (falhas de
                                   validação não são registradas)

  Uso            : Botão de ação na tela de O.S. de assistência (AD_TGFASS)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 29/09/2026
  Última Revisão : Setembro/2026 — Criação

  Observações    : - Baseada no template gerado pelo Sankhya; o nome da
                     procedure foi mantido sem o sufixo _SPARK porque já está
                     vinculado ao botão de ação.
                   - Valida apenas a existência do NUNOTA em TGFCAB (não
                     restringe TIPMOV/CODTIPOPER).
                   - Exige uma única O.S. selecionada, para não gravar a mesma
                     nota em várias O.S. por engano.
                   - Se a O.S. já tiver NUNOTA, o valor é substituído.
==============================================================================*/

    V_NUNOTA_TXT  VARCHAR2(4000);
    V_NUNOTA      TGFCAB.NUNOTA%TYPE;
    V_NUMOS       AD_TGFASS.NUMOS%TYPE;

    V_MSG_NEGOCIO VARCHAR2(4000);
    E_NEGOCIO     EXCEPTION;

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
            V_IDLOG, 'STP_GRAVANOTA_ASSISTENCIA', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    ---------------------------------------------------------------------------
    -- 1. Valida a selecao (exatamente 1 O.S.) e le o parametro informado
    ---------------------------------------------------------------------------
    IF P_QTDLINHAS <> 1 THEN
        V_MSG_NEGOCIO := 'Selecione apenas uma O.S. para vincular a nota de serviço.';
        RAISE E_NEGOCIO;
    END IF;

    V_NUMOS      := ACT_INT_FIELD(P_IDSESSAO, 1, 'NUMOS');
    V_NUNOTA_TXT := TRIM(ACT_TXT_PARAM(P_IDSESSAO, 'NUNOTA'));

    IF V_NUNOTA_TXT IS NULL THEN
        V_MSG_NEGOCIO := 'Informe o Nro. Único da nota de serviço.';
        RAISE E_NEGOCIO;
    END IF;

    IF NOT REGEXP_LIKE(V_NUNOTA_TXT, '^[0-9]{1,10}$') THEN
        V_MSG_NEGOCIO := 'Nro. Único inválido: "' || V_NUNOTA_TXT || '". Informe apenas números.';
        RAISE E_NEGOCIO;
    END IF;

    V_NUNOTA := TO_NUMBER(V_NUNOTA_TXT);

    ---------------------------------------------------------------------------
    -- 2. Valida a existencia do lancamento em TGFCAB
    ---------------------------------------------------------------------------
    BEGIN
        SELECT CAB.NUNOTA
          INTO V_NUNOTA
          FROM TGFCAB CAB
         WHERE CAB.NUNOTA = V_NUNOTA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_MSG_NEGOCIO := 'O Nro. Único ' || V_NUNOTA || ' não existe. Nada foi gravado.';
            RAISE E_NEGOCIO;
    END;

    ---------------------------------------------------------------------------
    -- 3. Grava o NUNOTA na O.S. selecionada
    ---------------------------------------------------------------------------
    UPDATE AD_TGFASS
       SET NUNOTA = V_NUNOTA
     WHERE NUMOS = V_NUMOS;

    IF SQL%ROWCOUNT = 0 THEN
        V_MSG_NEGOCIO := 'O.S. ' || V_NUMOS || ' não encontrada em AD_TGFASS. Nada foi gravado.';
        RAISE E_NEGOCIO;
    END IF;

    COMMIT;

    P_MENSAGEM := 'Nota de serviço ' || V_NUNOTA || ' vinculada à O.S. ' || V_NUMOS || '.';

EXCEPTION
    WHEN E_NEGOCIO THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, V_MSG_NEGOCIO);
    WHEN OTHERS THEN
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => 'GRAVA_NUNOTA',
            P_NUNOTA        => V_NUNOTA,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20002,
            'Erro em STP_GRAVANOTA_ASSISTENCIA (O.S. ' || V_NUMOS || '): ' || SQLERRM);
END STP_GRAVANOTA_ASSISTENCIA;
