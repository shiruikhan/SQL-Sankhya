CREATE OR REPLACE TRIGGER TRG_NOTIFICA_SOLIC_COMPRA
AFTER INSERT OR UPDATE ON AD_TGSSCP
FOR EACH ROW
DECLARE
    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(4000);
    V_CODFILA      NUMBER;
    V_NOME_USU     VARCHAR2(100);
    V_EMAIL_USU    VARCHAR2(100);
BEGIN
    -- Busca nome e e-mail do solicitante
    SELECT NOMEUSU, EMAIL INTO V_NOME_USU, V_EMAIL_USU
    FROM TSIUSU
    WHERE CODUSU = :NEW.SOLICITANTE;

    -- Gera código único para a fila de e-mail
    SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

    -------------------------------------------------------------------
    -- 1. Inclusão da solicitação
    -------------------------------------------------------------------
    IF INSERTING THEN
        V_TITULO := 'Nova Solicitação de Compra - #' || :NEW.NUSOL;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>
            <p><strong>ID da Solicitação:</strong> ' || :NEW.NUSOL || '</p>' ||

            CASE 
                WHEN :NEW.STATUS = 'A' THEN
                '<p><strong>Status:</strong> Aprovada</p>'
                WHEN :NEW.STATUS = 'C' THEN
                '<p><strong>Status:</strong> Cancelada</p>
                <p><strong>Justificativa:</strong> ' || :NEW.OBSAPROVADOR || '</p>'
                WHEN :NEW.STATUS = 'CR' THEN
                '<p><strong>Status:</strong> Compra Realizada</p>
                <p><strong>Número Único da Nota:</strong> ' || :NEW.NUNOTA || '</p>'
                ELSE
                '<p><strong>Status:</strong> Em Aberto</p>
                <p><strong>Justificativa:</strong> ' || :NEW.JUSTIFICATIVA || '</p>'
            END ||

            '<p><strong>Data da Solicitação:</strong> ' || TO_CHAR(:NEW.DTSOL, 'DD/MM/YYYY') || '</p>

            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';
        STP_GRAVA_FILA_BI2(V_CODFILA,     V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
        STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, 'administrativo@spark.ind.br', NULL);
    END IF;

    -------------------------------------------------------------------
    -- 2. Aprovação da solicitação
    -------------------------------------------------------------------
    IF UPDATING AND :OLD.STATUS = 'EA' AND :NEW.STATUS = 'A' THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Solicitação de Compra Aprovada - #' || :NEW.NUSOL;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>
            <p><strong>ID da Solicitação:</strong> ' || :NEW.NUSOL || '</p>' ||

            CASE 
                WHEN :NEW.STATUS = 'A' THEN
                '<p><strong>Status:</strong> Aprovada</p>'
                WHEN :NEW.STATUS = 'C' THEN
                '<p><strong>Status:</strong> Cancelada</p>
                <p><strong>Justificativa:</strong> ' || :NEW.OBSAPROVADOR || '</p>'
                WHEN :NEW.STATUS = 'CR' THEN
                '<p><strong>Status:</strong> Compra Realizada</p>
                <p><strong>Número Único da Nota:</strong> ' || :NEW.NUNOTA || '</p>'
                ELSE
                '<p><strong>Status:</strong> Em Aberto</p>
                <p><strong>Justificativa:</strong> ' || :NEW.JUSTIFICATIVA || '</p>'
            END ||

            '<p><strong>Data da Solicitação:</strong> ' || TO_CHAR(:NEW.DTSOL, 'DD/MM/YYYY') || '</p>

            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';
        STP_GRAVA_FILA_BI2(V_CODFILA,     V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
        STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
    END IF;

    -------------------------------------------------------------------
    -- 3. Cancelamento da solicitação
    -------------------------------------------------------------------
    IF UPDATING AND :OLD.STATUS = 'EA' AND :NEW.STATUS = 'C' THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Solicitação de Compra Cancelada - #' || :NEW.NUSOL;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>
            <p><strong>ID da Solicitação:</strong> ' || :NEW.NUSOL || '</p>' ||

            CASE 
                WHEN :NEW.STATUS = 'A' THEN
                '<p><strong>Status:</strong> Aprovada</p>'
                WHEN :NEW.STATUS = 'C' THEN
                '<p><strong>Status:</strong> Cancelada</p>
                <p><strong>Justificativa:</strong> ' || :NEW.OBSAPROVADOR || '</p>'
                WHEN :NEW.STATUS = 'CR' THEN
                '<p><strong>Status:</strong> Compra Realizada</p>
                <p><strong>Número Único da Nota:</strong> ' || :NEW.NUNOTA || '</p>'
                ELSE
                '<p><strong>Status:</strong> Em Aberto</p>
                <p><strong>Justificativa:</strong> ' || :NEW.JUSTIFICATIVA || '</p>'
            END ||

            '<p><strong>Data da Solicitação:</strong> ' || TO_CHAR(:NEW.DTSOL, 'DD/MM/YYYY') || '</p>

            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';
        STP_GRAVA_FILA_BI2(V_CODFILA,     V_TITULO, V_CONTEUDO, 'compras@spark.ind.br', NULL);
        STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
    END IF;

    -------------------------------------------------------------------
    -- 4. Compra realizada (preenchimento de NUNOTA e STATUS = CR)
    -------------------------------------------------------------------
    IF UPDATING AND :OLD.NUNOTA IS NULL AND :NEW.NUNOTA IS NOT NULL AND :NEW.STATUS = 'CR' THEN
        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        V_TITULO := 'Compra Finalizada - Solicitação #' || :NEW.NUSOL;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>
            <p><strong>ID da Solicitação:</strong> ' || :NEW.NUSOL || '</p>' ||

            CASE 
                WHEN :NEW.STATUS = 'A' THEN
                '<p><strong>Status:</strong> Aprovada</p>'
                WHEN :NEW.STATUS = 'C' THEN
                '<p><strong>Status:</strong> Cancelada</p>
                <p><strong>Justificativa:</strong> ' || :NEW.OBSAPROVADOR || '</p>'
                WHEN :NEW.STATUS = 'CR' THEN
                '<p><strong>Status:</strong> Compra Realizada</p>
                <p><strong>Número Único da Nota:</strong> ' || :NEW.NUNOTA || '</p>'
                ELSE
                '<p><strong>Status:</strong> Em Aberto</p>
                <p><strong>Justificativa:</strong> ' || :NEW.JUSTIFICATIVA || '</p>'
            END ||

            '<p><strong>Data da Solicitação:</strong> ' || TO_CHAR(:NEW.DTSOL, 'DD/MM/YYYY') || '</p>

            <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
            <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
            </div>';
        STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, V_EMAIL_USU, NULL);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Dados não encontrados para envio de e-mail.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Erro na trigger TRG_NOTIFICA_SOLIC_COMPRA: ' || SQLERRM);
END;
