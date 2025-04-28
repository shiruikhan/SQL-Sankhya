create or replace PROCEDURE "STP_INCLUIRLANCTO_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_INCLUIRLANCTO_SPARK
  Descrição      : Realiza lançamentos no portal (em testes) para o módulo de
                   controle de manutenção. O procedimento insere dados na tabela
                   AD_PRVCTR com base nos parâmetros fornecidos na sessão.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 09/09/2022
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
    PARAM_DTPREV DATE;
    PARAM_CODBEM VARCHAR2(4000);
    PARAM_CONTROLE NUMBER;
    PARAM_OBSERVACAO VARCHAR2(4000);
    PARAM_TIPOMANUTENCAO VARCHAR2(4000);
    PARAM_OPERADOR VARCHAR2(4000);
    PARAM_CUSTO NUMBER;
    PARAM_NATMENUTANCAO VARCHAR2(4000);
    FIELD_NUPREV NUMBER;
BEGIN
-- Inicialização dos parâmetros a partir da sessão
    PARAM_DTPREV         := ACT_DTA_PARAM(P_IDSESSAO, 'DTPREV');
    PARAM_CODBEM         := ACT_TXT_PARAM(P_IDSESSAO, 'CODBEM');
    PARAM_CONTROLE       := ACT_INT_PARAM(P_IDSESSAO, 'CONTROLE');
    PARAM_OBSERVACAO     := ACT_TXT_PARAM(P_IDSESSAO, 'OBSERVACAO');
    PARAM_TIPOMANUTENCAO := ACT_TXT_PARAM(P_IDSESSAO, 'TIPOMANUTENCAO');
    PARAM_OPERADOR       := ACT_TXT_PARAM(P_IDSESSAO, 'OPERADOR');
    PARAM_CUSTO          := ACT_DEC_PARAM(P_IDSESSAO, 'CUSTO');
    PARAM_NATMANUTENCAO  := ACT_TXT_PARAM(P_IDSESSAO, 'NATMENUTANCAO');

    -- Inserção de registros conforme quantidade informada
    FOR I IN 1..P_QTDLINHAS LOOP
        INSERT INTO AD_PRVCTR (
            DTPREV,
            CODBEM,
            OBSERVACAO,
            TIPOMANUTENCAO,
            OPERADOR,
            CUSTO,
            NATMENUTANCAO
        ) VALUES (
            PARAM_DTPREV,
            PARAM_CODBEM,
            PARAM_OBSERVACAO,
            PARAM_TIPOMANUTENCAO,
            PARAM_OPERADOR,
            PARAM_CUSTO,
            PARAM_NATMANUTENCAO
        );
    END LOOP;

    -- Retorno de sucesso
    P_MENSAGEM := 'Lançamentos inseridos com sucesso.';

EXCEPTION
    WHEN OTHERS THEN
        -- Captura qualquer exceção e retorna a mensagem de erro
        P_MENSAGEM := 'Erro ao incluir lançamentos: ' || SQLERRM;
END;