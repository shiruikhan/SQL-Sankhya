CREATE OR REPLACE PROCEDURE "STP_ALT_CFOP_TGFITE" (
    P_CODUSU    NUMBER,        -- Código do usuário logado
    P_IDSESSAO  VARCHAR2,      -- Identificador da execução. Serve para buscar informações dos parâmetros/campos da execução.
    P_QTDLINHAS NUMBER,        -- Informa a quantidade de registros selecionados no momento da execução.
    P_MENSAGEM  OUT VARCHAR2   -- Caso seja passada uma mensagem aqui, ela será exibida como uma informação ao usuário.
) AS
/*==============================================================================
  Nome do Script : STP_ALT_CFOP_TGFITE
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Altera o CFOP (TGFITE.CODCFO) dos itens de nota selecionados
                   para o novo CFOP informado pelo parâmetro do formulário.
                   A atualização é feita item a item, usando NUNOTA e SEQUENCIA
                   como regra de localização do registro.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução (usado por ACT_INT_PARAM / ACT_INT_FIELD)
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Tabelas        : TGFITE — item de nota (atualizado via NUNOTA + SEQUENCIA)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 08/07/2026
  Última Revisão : Julho/2026 — Criação

  Observações    : - CFOP é sempre numérico com no máximo 4 dígitos; o parâmetro
                     NEW_CFOP é validado quanto ao tamanho antes de qualquer
                     atualização.
==============================================================================*/
    PARAM_NEW_CFOP      NUMBER;
    FIELD_NUNOTA         NUMBER;
    FIELD_SEQUENCIA      NUMBER;
    V_TOTAL_ATUALIZADO   NUMBER := 0;
BEGIN

    PARAM_NEW_CFOP := ACT_INT_PARAM(P_IDSESSAO, 'new_CFOP');

    ---------------------------------------------------------------------------
    -- 1. Validação do CFOP informado
    ---------------------------------------------------------------------------
    IF PARAM_NEW_CFOP IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Informe o novo CFOP antes de executar a ação.');
    END IF;

    IF LENGTH(TO_CHAR(PARAM_NEW_CFOP)) > 4 THEN
        RAISE_APPLICATION_ERROR(-20002, 'O CFOP informado (' || PARAM_NEW_CFOP || ') é inválido: deve conter no máximo 4 dígitos.');
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Atualização dos itens selecionados
    ---------------------------------------------------------------------------
    FOR I IN 1..P_QTDLINHAS
    LOOP
        FIELD_NUNOTA    := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');

        UPDATE TGFITE
           SET CODCFO    = PARAM_NEW_CFOP
         WHERE NUNOTA    = FIELD_NUNOTA
           AND SEQUENCIA = FIELD_SEQUENCIA;

        V_TOTAL_ATUALIZADO := V_TOTAL_ATUALIZADO + SQL%ROWCOUNT;
    END LOOP;

    P_MENSAGEM := 'CFOP alterado com sucesso para ' || PARAM_NEW_CFOP || ' em ' || V_TOTAL_ATUALIZADO || ' item(ns).';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        P_MENSAGEM := 'Erro ao alterar o CFOP: ' || SQLERRM;
END;
