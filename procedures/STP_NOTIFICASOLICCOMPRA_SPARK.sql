CREATE OR REPLACE PROCEDURE STP_NOTIFICASOLICCOMPRA_SPARK (
    P_TIPOEVENTO INT,
    P_IDSESSAO   VARCHAR2,
    P_CODUSU     INT
) AS
/*==============================================================================
  Nome do Script : STP_NOTIFICA_SOLIC_COMPRA_SPARK
  Descrição      : Dispara notificações por e-mail nos seguintes eventos:
                   - Inclusão de nova solicitação de compra
                   - Aprovação da solicitação
                   - Finalização da compra (preenchimento do NUNOTA)
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 04/08/2025
==============================================================================*/

    BEFORE_INSERT INT;
    AFTER_INSERT  INT;
    BEFORE_DELETE INT;
    AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
    AFTER_UPDATE  INT;
    BEFORE_COMMIT INT;

    -- Variáveis principais
    V_NUSOL        NUMBER;
    V_SOLICITANTE  NUMBER;
    V_DTSOL        DATE;
    V_JUSTIFICATIVA VARCHAR2(4000);
    V_STATUS       VARCHAR2(2);
    V_NOME_USU     VARCHAR2(100);
    V_EMAIL_USU    VARCHAR2(100);
    V_NUNOTA       NUMBER;
    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(4000);
    V_CODFILA      NUMBER;

BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;

    V_NUSOL := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUSOL');    

    -- Inclusão de nova solicitação
    IF P_TIPOEVENTO = AFTER_INSERT THEN        

        -- Geração de novo ID de fila
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        SELECT NOMEUSU INTO V_NOME_USU
        FROM TSIUSU WHERE CODUSU = P_CODUSU;

        SELECT DTSOL, JUSTIFICATIVA INTO V_DTSOL, V_JUSTIFICATIVA
        FROM AD_TGSSCP WHERE NUSOL = V_NUSOL;

        V_TITULO := 'Nova Solicitação de Compra - #' || V_NUSOL;
        V_CONTEUDO := 
        '<h3>Nova Solicitação de Compra</h3>' ||
        '<p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>' ||
        '<p><strong>Data:</strong> ' || TO_CHAR(V_DTSOL, 'DD/MM/YYYY') || '</p>' ||
        '<p><strong>Justificativa:</strong> ' || V_JUSTIFICATIVA || '</p>' ||
        '<p><strong>ID da Solicitação:</strong> ' || V_NUSOL || '</p>';

        -- Envia para Compras
        STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
        -- Envia para Administrativo (Aprovação)
        STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, 'administrativo@spark.ind.br', NULL);

    END IF;

    -- Alterações após UPDATE
    IF P_TIPOEVENTO = AFTER_UPDATE THEN

        SELECT SC.STATUS, SC.NUNOTA, SC.DTSOL, SC.OBSAPROVADOR INTO V_STATUS, V_NUNOTA, V_DTSOL, V_JUSTIFICATIVA
        FROM AD_TGSSCP SC WHERE NUSOL = V_NUSOL;

        SELECT NOMEUSU, EMAIL INTO V_NOME_USU, V_EMAIL_USU
        FROM TSIUSU WHERE CODUSU = P_CODUSU;

        -- 1. Aprovação (STATUS mudou de EA para A)
        IF V_STATUS = 'A' THEN

            -- Geração de novo ID de fila
            SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;
        
            V_TITULO := 'Solicitação de Compra Aprovada - #' || V_NUSOL;
            V_CONTEUDO := 
            '<h3>Sua Solicitação de Compra foi Aprovada</h3>' ||
            '<p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>' ||
            '<p><strong>ID:</strong> ' || V_NUSOL || '</p>';

            -- Envia para Compras
            STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
            -- Envia para o solicitante
            STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
        END IF;

        -- 2. Compra Realizada (NUNOTA foi preenchido)
        IF V_STATUS = 'CR' THEN

            -- Geração de novo ID de fila
            SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

            V_TITULO := 'Compra Finalizada - Solicitação #' || V_NUSOL;
            V_CONTEUDO := 
            '<h3>Compra Realizada</h3>' ||
            '<p>Sua solicitação de compra foi finalizada e convertida em pedido de compra.</p>' ||
            '<p><strong>ID da Solicitação:</strong> ' || V_NUSOL || '</p>' ||
            '<p><strong>Número Único da Nota:</strong> ' || V_NUNOTA || '</p>';

            -- Envia para o solicitante
            STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
        END IF;

        -- 3. Compra Cancelada (STATUS mudou de EA para C)
        IF V_STATUS = 'C' THEN

            -- Geração de novo ID de fila
            SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

            V_TITULO := 'Solicitação de Compra Cancelada - #' || V_NUSOL;
            V_CONTEUDO := 
            '<h3>Sua Solicitação de Compra foi Cancelada</h3>' ||
            '<p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>' ||
            '<p><strong>ID:</strong> ' || V_NUSOL || '</p>' ||
            '<p><strong>Justificativa:</strong> ' || V_JUSTIFICATIVA || '</p>';

            -- Envia para Compras
            STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
            -- Envia para o solicitante
            STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
        END IF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Usuário ou solicitação não encontrada.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Erro em STP_NOTIFICA_SOLIC_COMPRA_SPARK: ' || SQLERRM);
END;