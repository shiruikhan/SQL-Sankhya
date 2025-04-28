CREATE OR REPLACE PROCEDURE "STP_REABRIRPENDENTE_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS

/*==============================================================================
  Nome do Script : STP_REABRIRPENDENTE_SPARK
  Descrição      : Marca o item de uma movimentação como pendente, corrigindo 
                   problemas de saldo remanescente em transferências de material.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 21/03/2022
  Última Revisão : 23/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/

    FIELD_NUNOTA     NUMBER;
    FIELD_SEQUENCIA  NUMBER;
BEGIN
    -- Inicializa a mensagem de retorno
    P_MENSAGEM := NULL;

    -- Percorre todas as linhas informadas
    FOR I IN 1..P_QTDLINHAS LOOP
        -- Recupera o número da nota da linha atual da sessão
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        -- Recupera a sequência do item da linha atual da sessão
        FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');

        -- Atualiza o item da nota, marcando-o como pendente
        UPDATE TGFITE
           SET PENDENTE = 'S'
         WHERE NUNOTA = FIELD_NUNOTA
           AND SEQUENCIA = FIELD_SEQUENCIA;
    END LOOP;

    -- Define mensagem de sucesso
    P_MENSAGEM := 'Itens reabertos com sucesso.';

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, define a mensagem de erro e propaga a exceção
        P_MENSAGEM := 'Erro ao reabrir itens: ' || SQLERRM;
        RAISE;
END;
