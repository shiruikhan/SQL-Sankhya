CREATE OR REPLACE PROCEDURE STP_APROVA_SOLIC_COMPRA (
    P_CODUSU     NUMBER,        -- Código do usuário logado
    P_IDSESSAO   VARCHAR2,      -- ID da execução
    P_QTDLINHAS  NUMBER,        -- Quantidade de registros selecionados
    P_MENSAGEM   OUT VARCHAR2   -- Mensagem de retorno ao usuário
) AS
    PARAM_P_STATUS    VARCHAR2(4000);
    PARAM_P_JUTIFIC   VARCHAR2(4000);
    FIELD_NUSOL       NUMBER;
    V_STATUS_ATUAL    VARCHAR2(2);
BEGIN
    -- Captura os parâmetros informados pelo usuário
    PARAM_P_STATUS  := ACT_TXT_PARAM(P_IDSESSAO, 'P_STATUS');
    PARAM_P_JUTIFIC := ACT_TXT_PARAM(P_IDSESSAO, 'P_JUTIFIC');

    -- Validação do status informado
    IF PARAM_P_STATUS NOT IN ('A', 'C') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Status inválido. Use A (Aprovado) ou C (Cancelado).');
    END IF;

    -- Loop em cada linha selecionada
    FOR I IN 1 .. P_QTDLINHAS LOOP
        -- Recupera o campo chave da linha
        FIELD_NUSOL := ACT_INT_FIELD(P_IDSESSAO, I, 'NUSOL');

        -- Verifica o status atual da solicitação
        SELECT STATUS INTO V_STATUS_ATUAL
        FROM AD_TGSSCP
        WHERE NUSOL = FIELD_NUSOL
        FOR UPDATE;

        IF V_STATUS_ATUAL != 'EA' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Somente solicitações com status EA podem ser aprovadas ou canceladas.');
        END IF;

        -- Tratamento conforme o novo status
        IF PARAM_P_STATUS = 'A' THEN
            UPDATE AD_TGSSCP
            SET STATUS       = 'A',
                APROVADOR    = P_CODUSU,
                DTAPROVACAO  = SYSDATE
            WHERE NUSOL = FIELD_NUSOL;

        ELSIF PARAM_P_STATUS = 'C' THEN
            IF PARAM_P_JUTIFIC IS NULL OR TRIM(PARAM_P_JUTIFIC) IS NULL THEN
                RAISE_APPLICATION_ERROR(-20003, 'Justificativa obrigatória para cancelamento.');
            END IF;

            UPDATE AD_TGSSCP
            SET STATUS        = 'C',
                APROVADOR     = P_CODUSU,
                DTAPROVACAO   = SYSDATE,
                OBSAPROVADOR  = PARAM_P_JUTIFIC
            WHERE NUSOL = FIELD_NUSOL;
        END IF;
    END LOOP;

    P_MENSAGEM := 'Solicitação(ões) atualizada(s) com sucesso.';
END;
