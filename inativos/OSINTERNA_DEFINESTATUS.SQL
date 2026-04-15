/*==============================================================================
  Nome do Script : OSINTERNA_DEFINESTATUS
  Tipo           : Stored Procedure (Botão de Ação) — INATIVA
  Descrição      : Botão de ação para definição manual de status de O.S. Interna.
                   Atualizava o campo STATUS em AD_OSINTERNA para o valor
                   informado pelo usuário via parâmetro P_STATUS.
                   DESATIVADO — funcionalidade incorporada em outro fluxo.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Motivo inativo : Botão desativado — substituído por outro mecanismo de controle
  Preservado em  : inativos/ apenas para referência histórica

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

/*BOTÃO DESATIVADO
create or replace PROCEDURE "OSINTERNA_DEFINESTATUS" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       PARAM_STATUS VARCHAR2(4000);
       FIELD_NUMOS NUMBER;
BEGIN
       PARAM_STATUS := ACT_TXT_PARAM(P_IDSESSAO, 'STATUS');

       FOR I IN 1..P_QTDLINHAS
       LOOP
           FIELD_NUMOS := ACT_INT_FIELD(P_IDSESSAO, I, 'NUMOS');


           UPDATE AD_OSINTERNA SET STATUS = PARAM_STATUS WHERE NUMOS = FIELD_NUMOS;
           P_MENSAGEM := 'Dados Atualizados!';
            


       END LOOP;


END;
*/