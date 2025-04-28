CREATE OR REPLACE PROCEDURE "STP_MUDANCADECODIGO_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_MUDANCADECODIGO_SPARK
  Descrição      : Realiza a limpeza dos números de série da TGFBAR para
                   que a mudança de código funcione corretamente.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 30/09/2022
  Última Revisão : 28/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/
    FIELD_NUNOTA NUMBER;
BEGIN
    FOR I IN 1..P_QTDLINHAS LOOP
        -- Obtém o número da nota fiscal da sessão
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        -- Exclui o número de série relacionado ao número da nota
        DELETE FROM TGFBAR
         WHERE CODBARRA IN (
                  SELECT SER.SERIE
                    FROM TGFSER SER
                   WHERE SER.NUNOTA = FIELD_NUNOTA
               );
    END LOOP;

    -- Define mensagem de sucesso ao final do processamento
    P_MENSAGEM := 'Controle SN excluído com sucesso!';

EXCEPTION
    WHEN OTHERS THEN
        -- Captura e propaga o erro em caso de falha
        RAISE_APPLICATION_ERROR(-20002, 'Erro ao excluir números de série: ' || SQLERRM);
END;
