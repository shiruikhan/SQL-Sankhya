CREATE OR REPLACE PROCEDURE STP_VLROUTROSIMP_SPARK (
    P_CODUSU    NUMBER,          -- Código do usuário logado
    P_IDSESSAO  VARCHAR2,        -- Identificador da execução (parâmetros/campos da ação)
    P_QTDLINHAS NUMBER,          -- Quantidade de notas selecionadas
    P_MENSAGEM  OUT VARCHAR2     -- Mensagem exibida ao usuário
) AS
/*==============================================================================
  Nome do Script : STP_VLROUTROSIMP_SPARK
  Tipo           : Procedure (Botão de Ação)
  Descrição      : Grava em TGFCAB.VLROUTROS o valor dos gastos extras de
                   exportação informado pelo usuário, em cada nota selecionada.
                   O valor informado é gravado integralmente em cada nota (não
                   é rateado entre as notas selecionadas).

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de notas selecionadas
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)
                   Parâmetro da ação: P_VLROUTROS (Decimal) — valor dos gastos
                   extras de exportação

  Tabelas        : TGFCAB       -- cabeçalho da nota (leitura e atualização)
  Tabela de Log  : AD_LOG_ERROS -- erros inesperados
  Dependencias   : ACT_DEC_PARAM, ACT_INT_FIELD (functions nativas Sankhya)
  Uso            : Botão de ação sobre notas (campo NUNOTA da seleção)

  Autor          : Lucas Gabriel
  Revisor        : Silvio Vieira — Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 06/11/2026
  Última Revisão : Novembro/2026 — Corrigida variável não declarada
                   (PARAM_P_VLROUTOS) e nome do parâmetro da ação; recusa nota
                   confirmada; log em AD_LOG_ERROS; cabeçalho padronizado.

  Observações    : - O parâmetro da ação precisa se chamar exatamente
                     P_VLROUTROS e ser do tipo Decimal: ACT_DEC_PARAM lê NUMDEC
                     e devolve NULL, sem erro, quando o nome não confere.
                   - Nota confirmada (STATUSNOTA = 'L') é recusada: a trigger
                     nativa TRG_UPD_TGFCAB não protege VLROUTROS, e alterar
                     depois da confirmação deixaria o cabeçalho divergente do
                     XML, do VLRNOTA e do financeiro.
                   - As regras STP_ALTCAMOUTROS_SPARK e
                     STP_ALTCAMOUTROS_SPARK_COMP também gravam VLROUTROS (soma
                     dos itens). Se estiverem vinculadas à mesma TOP,
                     sobrescrevem o valor gravado aqui.
                   - Tudo ou nada: qualquer erro desfaz as notas já gravadas
                     nesta execução. Sem COMMIT; a transação é do Sankhya.
==============================================================================*/

    -- Variáveis (devem preceder qualquer subprograma)
    V_VLROUTROS      TGFCAB.VLROUTROS%TYPE;
    V_NUNOTA         TGFCAB.NUNOTA%TYPE;
    V_NUMNOTA        TGFCAB.NUMNOTA%TYPE;
    V_STATUSNOTA     TGFCAB.STATUSNOTA%TYPE;
    V_QTDATUALIZADAS NUMBER := 0;
    V_MSG_VALIDACAO  VARCHAR2(4000);
    V_ERRO           VARCHAR2(4000);

    -- Erro de validação: mensagem direta ao usuário, sem log
    E_VALIDACAO      EXCEPTION;

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
            V_IDLOG, 'STP_VLROUTROSIMP_SPARK', P_OPERACAO, P_NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    ---------------------------------------------------------------------------
    -- 1. Recupera e valida o valor informado na ação
    ---------------------------------------------------------------------------
    V_VLROUTROS := ACT_DEC_PARAM(P_IDSESSAO, 'P_VLROUTROS');

    IF V_VLROUTROS IS NULL THEN
        V_MSG_VALIDACAO := 'Informe o valor dos gastos extras de exportação.';
        RAISE E_VALIDACAO;
    END IF;

    IF V_VLROUTROS < 0 THEN
        V_MSG_VALIDACAO := 'O valor dos gastos extras não pode ser negativo.';
        RAISE E_VALIDACAO;
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Valida a seleção de notas
    ---------------------------------------------------------------------------
    IF NVL(P_QTDLINHAS, 0) <= 0 THEN
        V_MSG_VALIDACAO := 'Nenhuma nota foi selecionada para atualização.';
        RAISE E_VALIDACAO;
    END IF;

    ---------------------------------------------------------------------------
    -- 3. Grava o valor em cada nota selecionada
    ---------------------------------------------------------------------------
    FOR I IN 1 .. P_QTDLINHAS LOOP

        V_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        -- Situação da nota (removida entre a seleção e a execução: ignora)
        BEGIN
            SELECT  CAB.STATUSNOTA
                   ,CAB.NUMNOTA
              INTO  V_STATUSNOTA
                   ,V_NUMNOTA
              FROM  TGFCAB CAB
             WHERE  CAB.NUNOTA = V_NUNOTA;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_STATUSNOTA := NULL;
        END;

        IF V_STATUSNOTA IS NOT NULL THEN

            -- Nota confirmada não pode ser alterada (ver Observações)
            IF V_STATUSNOTA = 'L' THEN
                V_MSG_VALIDACAO := 'A nota ' || V_NUMNOTA || ' (nº único ' || V_NUNOTA
                                || ') já está confirmada. Informe os gastos extras antes'
                                || ' de confirmar a nota. Nenhuma nota foi alterada.';
                RAISE E_VALIDACAO;
            END IF;

            UPDATE TGFCAB
               SET VLROUTROS = V_VLROUTROS
             WHERE NUNOTA    = V_NUNOTA;

            V_QTDATUALIZADAS := V_QTDATUALIZADAS + SQL%ROWCOUNT;

        END IF;

    END LOOP;

    ---------------------------------------------------------------------------
    -- 4. Mensagem de retorno
    ---------------------------------------------------------------------------
    P_MENSAGEM := 'Gastos extras de exportação gravados com sucesso. '
               || 'Notas atualizadas: ' || V_QTDATUALIZADAS
               || '. Valor gravado em cada nota: R$ '
               || TO_CHAR(V_VLROUTROS, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''');

EXCEPTION
    WHEN E_VALIDACAO THEN
        RAISE_APPLICATION_ERROR(-20001, V_MSG_VALIDACAO);

    WHEN OTHERS THEN
        V_ERRO := SQLERRM;
        LOG_ERRO(
            P_OPERACAO      => 'VLROUTROS',
            P_NUNOTA        => V_NUNOTA,
            P_ERR_CODE      => SQLCODE,
            P_ERR_MSG       => V_ERRO,
            P_ERR_BACKTRACE => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            P_CALL_STACK    => DBMS_UTILITY.FORMAT_CALL_STACK
        );
        RAISE_APPLICATION_ERROR(-20002,
            'Erro ao gravar os gastos extras de exportação (NUNOTA ' || V_NUNOTA || '): ' || V_ERRO);
END STP_VLROUTROSIMP_SPARK;
