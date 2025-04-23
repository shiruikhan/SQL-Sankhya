create or replace PROCEDURE "STP_REABRIRPENDENTE_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS

/*==============================================================================
  Nome do Script : STP_REABRIRPENDENTE_SPARK
  Descrição      : MARCAR O ITEM DE UMA MOVIMENTAÇÃO COMO PENDENTE RESOLVENDO 
                   ASSIM O PROBLEMA GERADO DURANTE AS TRANSFERENCIAS DE MATEIAL 
                   ONDE O SALDO RESTANDO NÃO ESTAVA SENDO GERADO.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 21/03/2022
  Última Revisão : 23/04/2025 - Padronização, tratamento de exceções e legibilidade
==============================================================================*/

       FIELD_NUNOTA NUMBER;
       FIELD_SEQUENCIA NUMBER;
BEGIN
       FOR I IN 1..P_QTDLINHAS
       LOOP
           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
           FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');
           UPDATE TGFITE SET PENDENTE = 'S' WHERE NUNOTA = FIELD_NUNOTA AND SEQUENCIA = FIELD_SEQUENCIA;
       END LOOP;
END;