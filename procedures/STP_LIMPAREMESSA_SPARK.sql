create or replace PROCEDURE "STP_LIMPAREMESSA_SPARK" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_LIMPAREMESSA_SPARK
  Descrição      : Remove os vínculos de remessa entre notas fiscais no sistema,
                   utilizando dados de uma sessão de interface.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 23/05/2025
  Última Revisão : 23/05/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/
       FIELD_NUNOTA NUMBER;
       V_NUREM TGFCAB.NUREM%TYPE;
BEGIN
    FOR I IN 1..P_QTDLINHAS LOOP
        BEGIN
            -- Recupera o número da nota informado na interface
            FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

            -- Busca a remessa vinculada à nota
            SELECT NUREM INTO V_NUREM
              FROM TGFCAB
             WHERE NUNOTA = FIELD_NUNOTA;

            -- Remove o vínculo de remessa das duas notas
            UPDATE TGFCAB
               SET NUREM = NULL
             WHERE NUNOTA IN (FIELD_NUNOTA, V_NUREM);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                P_MENSAGEM := 'Nota fiscal não encontrada para NUNOTA: ' || FIELD_NUNOTA;
                ROLLBACK;
                RETURN;

            WHEN OTHERS THEN
                P_MENSAGEM := 'Erro inesperado ao processar NUNOTA: ' || FIELD_NUNOTA || 
                              ' - ' || SQLERRM;
                ROLLBACK;
                RETURN;
        END;
    END LOOP;

    P_MENSAGEM := 'Vínculo removido com sucesso';
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro geral: ' || SQLERRM;
        ROLLBACK;
END;