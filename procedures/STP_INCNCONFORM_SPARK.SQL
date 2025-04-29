CREATE OR REPLACE PROCEDURE STP_INCNCONFORM_SPARK (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_INCNCONFORM_SPARK
  Descrição      : Realiza o lançamento de não conformidades na tabela AD_TGFNCO,
                   associando a nota fiscal e o produto informado.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 16/05/2024
  Última Revisão : 29/04/2025
  Melhorias      : Padronização, tratamento de exceções, legibilidade e lógica
==============================================================================*/

    -- Parâmetros da sessão
    PARAM_DESCNCO  NUMBER;
    PARAM_CODPROD  NUMBER;
    PARAM_QTDNC    NUMBER;

    -- Campos de controle
    FIELD_NUNOTA   NUMBER;
    P_COUNT        NUMBER;
    P_FIM          NUMBER;

    -- Campos derivados da nota
    P_CODPARC      NUMBER;
    P_CODPARCT     NUMBER;
    P_DTRECEB      DATE;
    P_NUMNOTA      NUMBER;
    P_DTNCO        DATE;

BEGIN
    -- Recupera parâmetros da sessão
    PARAM_DESCNCO := ACT_INT_PARAM(P_IDSESSAO, 'DESCNCO');
    PARAM_CODPROD := ACT_INT_PARAM(P_IDSESSAO, 'CODPROD');
    PARAM_QTDNC   := ACT_INT_PARAM(P_IDSESSAO, 'QTDNC');

    -- Inicializa contador com próximo NUNCO disponível
    SELECT NVL(MAX(NUNCO), 0) + 1 INTO P_COUNT FROM AD_TGFNCO;

    FOR I IN 1..P_QTDLINHAS LOOP
        -- Recupera número da nota atual
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        -- Coleta dados relacionados à nota
        SELECT C.CODPARC, C.CODPARCTRANSP, C.NUMNOTA, C.DTENTSAI
          INTO P_CODPARC, P_CODPARCT, P_NUMNOTA, P_DTRECEB
          FROM TGFCAB C
         WHERE C.NUNOTA = FIELD_NUNOTA;

        -- Data atual como data da NC
        P_DTNCO := SYSDATE;

        -- Insere não conformidade
        INSERT INTO AD_TGFNCO (
            NUNCO, NUNOTA, CODUSU, NUMNOTA, DTRECEB,
            CODPARC, CODPROD, QTDNC, DTNCO, NCOAPO, TRANSP
        ) VALUES (
            P_COUNT, FIELD_NUNOTA, P_CODUSU, P_NUMNOTA, P_DTRECEB,
            P_CODPARC, PARAM_CODPROD, PARAM_QTDNC, P_DTNCO, PARAM_DESCNCO, P_CODPARCT
        );
    END LOOP;

    -- Verificação da inclusão
    SELECT MAX(NUNCO) INTO P_FIM FROM AD_TGFNCO;

    IF P_FIM = P_COUNT THEN
        P_MENSAGEM := 'Apontamento de Não Conformidade realizado com sucesso e pode ser visualizado na tela de Não Conformidades sobre o Nº ' || P_COUNT;
    ELSE
        P_MENSAGEM := 'Apontamento não pôde ser incluído. Favor tentar novamente. Se o erro persistir, informe o setor de TI.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao processar apontamento de não conformidade: ' || SQLERRM;
END;