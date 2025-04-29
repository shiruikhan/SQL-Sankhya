CREATE OR REPLACE PROCEDURE STP_INICIADATA_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_INICIADATA_SPARK
  Descrição      : Retroage a data de alteração dos tipos de negociação
                   para 31/01/2022.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data Criação   : 08/06/2022
  Última Revisão : 29/04/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/

    v_codTipVenda  NUMBER;

BEGIN
       -- Recupera o código do tipo de venda e a data original de alteração
       v_codTipVenda := ACT_INT_FIELD(P_IDSESSAO, 1, 'CODTIPVENDA');
       -- Atualiza a data de alteração para 31/01/2022
       UPDATE TGFTPV 
       SET DHALTER = TO_DATE('31/01/2022', 'DD/MM/YYYY')
       WHERE CODTIPVENDA = v_codTipVenda;
       --END LOOP;
       -- Mensagem final
       P_MENSAGEM := 'Dados atualizados com sucesso.';

EXCEPTION
    WHEN OTHERS THEN
       -- Em caso de erro, define mensagem com detalhe do erro
       P_MENSAGEM := 'Erro ao atualizar dados: ' || SQLERRM;
END;
