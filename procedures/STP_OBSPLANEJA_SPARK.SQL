CREATE OR REPLACE PROCEDURE STP_OBSPLANEJA_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_OBSPLANEJA_SPARK
  Descrição      : Inclui a observação de planejamento na tabela TPRLPA para os
                   produtos selecionados na tela de planejamento após o plano
                   ter sido gerado.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data Criação   : 06/03/2025
  Última Revisão : 29/04/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/

    -- Variáveis internas
    V_MENSAGEM        VARCHAR2(4000);
    V_IDPROC          NUMBER;
    V_CODPRODPA       NUMBER;
    V_CONTROLEPA      VARCHAR2(4000);

BEGIN
    -- Recupera a mensagem informada na tela
    V_MENSAGEM := ACT_TXT_PARAM(P_IDSESSAO, 'MENSAGEM');

    -- Validação de entrada
    IF P_QTDLINHAS IS NULL OR P_QTDLINHAS <= 0 THEN
        P_MENSAGEM := 'Nenhuma linha informada para atualização.';
        RETURN;
    END IF;

    -- Loop para processar cada linha da sessão
    FOR I IN 1 .. P_QTDLINHAS LOOP
        V_IDPROC      := ACT_INT_FIELD(P_IDSESSAO, I, 'IDPROC');
        V_CODPRODPA   := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPRODPA');
        V_CONTROLEPA  := ACT_TXT_FIELD(P_IDSESSAO, I, 'CONTROLEPA');

        -- Atualiza observação na tabela de planejamento
        UPDATE TPRLPA
           SET AD_OBSPLANEJA = V_MENSAGEM || ' - ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
         WHERE CODPRODPA = V_CODPRODPA
           AND IDPROC = V_IDPROC;
    END LOOP;

    P_MENSAGEM := 'Atualização concluída com sucesso.';

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao atualizar observações: ' || SQLERRM;
END;