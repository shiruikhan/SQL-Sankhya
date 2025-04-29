CREATE OR REPLACE PROCEDURE STP_ATTCOTACAO_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_ATTCOTACAO_SPARK
  Descrição      : Atualiza o valor de cotação de moeda no módulo financeiro.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 23/03/2023
  Última Revisão : 29/04/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/

    -- Parâmetro obtido da sessão com o novo valor da cotação
    V_VLRMOEDA FLOAT;

    -- Código do lançamento financeiro
    V_NUFIN NUMBER;

BEGIN
    -- Obtém o valor da moeda a ser atualizado
    V_VLRMOEDA := ACT_DEC_PARAM(P_IDSESSAO, 'P_VLRMOEDA');

    -- Loop para processar todas as linhas enviadas
    FOR I IN 1 .. P_QTDLINHAS LOOP
        -- Obtém o código NUFIN da linha atual
        V_NUFIN := ACT_INT_FIELD(P_IDSESSAO, I, 'NUFIN');

        -- Atualiza o valor da moeda para o NUFIN correspondente
        UPDATE TGFFIN
           SET VLRMOEDA = V_VLRMOEDA
         WHERE NUFIN = V_NUFIN;
    END LOOP;

    -- Retorno de sucesso
    P_MENSAGEM := 'Valor de cotação atualizado com sucesso!';

-- Tratamento de exceções
EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao atualizar valor de cotação: ' || SQLERRM;
END STP_ATTCOTACAO_SPARK;
