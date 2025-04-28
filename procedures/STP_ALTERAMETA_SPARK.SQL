CREATE OR REPLACE PROCEDURE "STP_ALTERAMETA_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_ALTERAMETA_SPARK
  Descrição      : Realiza a alteração da data de referência dos produtos
                   na tabela AD_TGFMET de acordo com a data informada na sessão.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 25/01/2023
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
    PARAM_NOVADATA DATE;
    FIELD_CODMETA  NUMBER;
    FIELD_DTREF    DATE;
    FIELD_CODEMP   NUMBER;
    FIELD_CODPROD  NUMBER;
    P_COUNT        INT DEFAULT 0;
BEGIN
    -- Recupera a nova data de referência da sessão
    PARAM_NOVADATA := ACT_DTA_PARAM(P_IDSESSAO, 'NOVADATA');

    -- Percorre cada linha da sessão
    FOR I IN 1..P_QTDLINHAS LOOP
        -- Coleta informações da linha corrente
        FIELD_CODMETA := ACT_INT_FIELD(P_IDSESSAO, I, 'CODMETA');
        FIELD_DTREF   := ACT_DTA_FIELD(P_IDSESSAO, I, 'DTREF');
        FIELD_CODEMP  := ACT_INT_FIELD(P_IDSESSAO, I, 'CODEMP');
        FIELD_CODPROD := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPROD');

        -- Atualiza o registro correspondente
        UPDATE AD_TGFMET
           SET DTREF = PARAM_NOVADATA
         WHERE CODMETA = FIELD_CODMETA
           AND CODEMP = FIELD_CODEMP
           AND CODPROD = FIELD_CODPROD
           AND DTREF = FIELD_DTREF;

        -- Soma o número de registros atualizados
        P_COUNT := P_COUNT + SQL%ROWCOUNT;
    END LOOP;

    -- Retorna a mensagem final
    P_MENSAGEM := 'Total de registros alterados: ' || P_COUNT;

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao alterar as metas: ' || SQLERRM;
END;
