CREATE OR REPLACE PROCEDURE STP_INCFINASSIST_SPARK (
    P_CODUSU    NUMBER,        -- Código do usuário logado
    P_IDSESSAO  VARCHAR2,      -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,        -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM  OUT VARCHAR2   -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_INCFINASSIST_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Gera lançamentos financeiros avulsos em TGFFIN a partir das
                   Ordens de Serviço de assistência técnica selecionadas em
                   AD_SPKCAE, aglutinando por parceiro (CODPARC): é gerado um
                   único título por parceiro, somando o VLRCONSERTO de todas
                   as O.S. selecionadas daquele parceiro. Após gerar o título,
                   grava o NUFIN resultante em todas as O.S. do grupo — esse
                   campo funciona como marcador de idempotência. Se qualquer
                   O.S. selecionada já tiver NUFIN preenchido, a execução
                   inteira é abortada (nenhum lançamento é gerado) e o
                   usuário é avisado.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_DTA_PARAM / ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de O.S. selecionadas em AD_SPKCAE
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Parâmetro de tela (ACT_DTA_PARAM):
                   DTVENC — data de vencimento informada uma única vez no
                            clique do botão, aplicada a DTVENCINIC e DTVENC
                            de todos os títulos gerados nesta execução

  Tabelas        : AD_SPKCAE    -- leitura (CODPARC, VLRCONSERTO, NUFIN) e atualização (NUFIN)
                   TGFFIN       -- inserção do lançamento financeiro avulso
                   TGFTOP       -- leitura de DHALTER do tipo de operação 1300
  Tabela de Log  : AD_LOG_ERROS

  Dependencias   : SNK_GET_NUFIN (function nativa Sankhya)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 23/09/2026
  Última Revisão : Setembro/2026 — Criação

  Observações    : - Lançamento é avulso: NUNOTA não é preenchido, não gera
                     TGFCAB/TGFITE (diferente de TRG_INCDEVCH_SPARK).
                   - RECDESP = -1 (despesa): é a Spark pagando o prestador da
                     assistência (AD_SPKCAE.CODPARC), não cobrança ao cliente.
                   - Valores fixos por definição de negócio: CODEMP = 501,
                     CODTIPOPER = 1300, CODNAT = 505006, CODCENCUS = 30400,
                     CODTIPTIT = 39, ORIGEM = 'F'.
                   - CODBCO / CODCTABCOINT não são preenchidos: são de contas
                     vinculadas, resolvidas fora deste fluxo.
                   - NUMNOTA / NOSSONUM = concatenação MM+YYYY da data de
                     execução (ex. 092026 para setembro/2026). Repetição do
                     mesmo número entre parceiros diferentes no mesmo mês é
                     aceitável — definição do usuário, pois cada parceiro tem
                     seu próprio NUFIN e não há, por regra de processo, dois
                     lançamentos para o mesmo parceiro no mesmo mês.
==============================================================================*/

    PARAM_DTVENC DATE;

    FIELD_NUMOS   AD_SPKCAE.NUMOS%TYPE;
    V_CODPARC     AD_SPKCAE.CODPARC%TYPE;
    V_VLRCONSERTO AD_SPKCAE.VLRCONSERTO%TYPE;
    V_NUFIN_ATUAL AD_SPKCAE.NUFIN%TYPE;

    V_DHTIPOPER TGFTOP.DHALTER%TYPE;
    V_NUMNOTA   TGFFIN.NUMNOTA%TYPE;
    V_NUFIN     TGFFIN.NUFIN%TYPE;
    V_QTDPARC   PLS_INTEGER := 0;

    TYPE T_NUMOS_TAB    IS TABLE OF AD_SPKCAE.NUMOS%TYPE   INDEX BY PLS_INTEGER;
    TYPE T_CODPARC_TAB  IS TABLE OF AD_SPKCAE.CODPARC%TYPE INDEX BY PLS_INTEGER;
    TYPE T_VLR_POR_PARC IS TABLE OF NUMBER                 INDEX BY PLS_INTEGER;

    V_NUMOS_SEL    T_NUMOS_TAB;
    V_CODPARC_SEL  T_CODPARC_TAB;
    V_VLR_POR_PARC T_VLR_POR_PARC;

    V_CODPARC_ATUAL PLS_INTEGER;

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
            V_IDLOG, 'STP_INCFINASSIST_SPARK', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    PARAM_DTVENC := ACT_DTA_PARAM(P_IDSESSAO, 'DTVENC');

    IF PARAM_DTVENC IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Informe a data de vencimento (DTVENC) antes de gerar o financeiro.');
    END IF;

    ---------------------------------------------------------------------------
    -- 1. Le as O.S. selecionadas, valida idempotencia (NUFIN) e acumula o
    --    valor de conserto por parceiro
    ---------------------------------------------------------------------------
    FOR I IN 1..P_QTDLINHAS LOOP
        FIELD_NUMOS := ACT_INT_FIELD(P_IDSESSAO, I, 'NUMOS');

        BEGIN
            SELECT CODPARC, VLRCONSERTO, NUFIN
              INTO V_CODPARC, V_VLRCONSERTO, V_NUFIN_ATUAL
              FROM AD_SPKCAE
             WHERE NUMOS = FIELD_NUMOS;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20002,
                    'O.S. ' || FIELD_NUMOS || ' não encontrada em AD_SPKCAE.');
        END;

        IF V_NUFIN_ATUAL IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20003,
                'A O.S. ' || FIELD_NUMOS || ' já possui financeiro gerado (NUFIN=' ||
                V_NUFIN_ATUAL || '). Nenhum lançamento foi gerado nesta execução.');
        END IF;

        V_NUMOS_SEL(I)   := FIELD_NUMOS;
        V_CODPARC_SEL(I) := V_CODPARC;

        V_VLR_POR_PARC(V_CODPARC) := NVL(V_VLR_POR_PARC(V_CODPARC), 0) + NVL(V_VLRCONSERTO, 0);
    END LOOP;

    ---------------------------------------------------------------------------
    -- 2. Data de alteracao do TOP usado no lancamento (mesmo padrao adotado
    --    em TRG_INCDEVCH_SPARK) e numero do titulo (MM+YYYY da execucao)
    ---------------------------------------------------------------------------
    SELECT MAX(DHALTER)
      INTO V_DHTIPOPER
      FROM TGFTOP
     WHERE CODTIPOPER = 1300;

    V_NUMNOTA := TO_NUMBER(TO_CHAR(SYSDATE, 'MM') || TO_CHAR(SYSDATE, 'YYYY'));

    ---------------------------------------------------------------------------
    -- 3. Gera um TGFFIN avulso por parceiro e marca o NUFIN nas O.S. do grupo
    ---------------------------------------------------------------------------
    V_CODPARC_ATUAL := V_VLR_POR_PARC.FIRST;

    WHILE V_CODPARC_ATUAL IS NOT NULL LOOP

        V_NUFIN := SNK_GET_NUFIN;

        INSERT INTO TGFFIN (
            NUFIN, CODEMP, NUMNOTA, NOSSONUM, DTNEG, DHMOV,
            DTVENCINIC, DTVENC, DTENTSAI, CODPARC, CODTIPOPER, DHTIPOPER,
            CODNAT, CODCENCUS, VLRDESDOB, RECDESP, PROVISAO, ORIGEM,
            CODTIPTIT, DTALTER, CODUSU
        ) VALUES (
            V_NUFIN, 501, V_NUMNOTA, TO_CHAR(V_NUMNOTA), TRUNC(SYSDATE), SYSDATE,
            PARAM_DTVENC, PARAM_DTVENC, TRUNC(SYSDATE), V_CODPARC_ATUAL, 1300, V_DHTIPOPER,
            505006, 30400, V_VLR_POR_PARC(V_CODPARC_ATUAL), -1, 'N', 'F',
            39, TRUNC(SYSDATE), P_CODUSU
        );

        FOR J IN 1..P_QTDLINHAS LOOP
            IF V_CODPARC_SEL(J) = V_CODPARC_ATUAL THEN
                UPDATE AD_SPKCAE
                   SET NUFIN = V_NUFIN
                 WHERE NUMOS = V_NUMOS_SEL(J);
            END IF;
        END LOOP;

        V_QTDPARC := V_QTDPARC + 1;
        V_CODPARC_ATUAL := V_VLR_POR_PARC.NEXT(V_CODPARC_ATUAL);
    END LOOP;

    COMMIT;

    P_MENSAGEM := 'Financeiro gerado com sucesso: ' || V_QTDPARC || ' lançamento(s), 1 por parceiro.';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        LOG_ERRO(
            P_OPERACAO      => 'GERA_FIN',
            P_NUNOTA        => FIELD_NUMOS,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => SQLERRM,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20004,
            'Erro em STP_INCFINASSIST_SPARK: ' || SQLERRM);
END STP_INCFINASSIST_SPARK;
