create or replace PROCEDURE "STP_MARCARNPENDENTE_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       PARAM_OBSERVACAO VARCHAR2(4000);
       FIELD_NUNOTA NUMBER;
       FIELD_SEQUENCIA NUMBER;
       
/******************************************************************************************
 * AUTOR       : Silvio Vieira
 * CARGO       : Analista de Sistemas Sênior
 * EMPRESA     : Spark Eletrônica
 *
 * DESCRIÇÃO   : Marca itens de nota fiscal como não pendentes, atualizando também o campo
 *               "OBSERVACAO" com valor definido via parâmetro de sessão.
 *
 * DATA CRIAÇÃO: 21/03/2022
 * ÚLTIMA ALTERAÇÃO: 23/04/2025
 ******************************************************************************************/

BEGIN
       PARAM_OBSERVACAO := ACT_TXT_PARAM(P_IDSESSAO, 'OBSERVACAO');

       FOR I IN 1..P_QTDLINHAS
       LOOP
              FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
              FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');
              UPDATE TGFITE SET PENDENTE = 'N', OBSERVACAO = PARAM_OBSERVACAO WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;
       END LOOP;
END;