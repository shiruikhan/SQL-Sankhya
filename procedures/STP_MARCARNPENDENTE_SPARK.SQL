create or replace PROCEDURE "STP_MARCARNPENDENTE_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_MARCARNPENDENTE_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Marca itens de nota fiscal como não pendentes e atualiza
                   campo de observação com valor capturado do parâmetro.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 21/03/2022
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
       PARAM_OBSERVACAO VARCHAR2(4000);
       FIELD_NUNOTA NUMBER;
       FIELD_SEQUENCIA NUMBER;

BEGIN
       PARAM_OBSERVACAO := ACT_TXT_PARAM(P_IDSESSAO, 'OBSERVACAO');

       FOR I IN 1..P_QTDLINHAS
       LOOP
              FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
              FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');
              UPDATE TGFITE SET PENDENTE = 'N', OBSERVACAO = PARAM_OBSERVACAO WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;
       END LOOP;
END;