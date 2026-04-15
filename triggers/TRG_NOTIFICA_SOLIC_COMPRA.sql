create or replace TRIGGER TRG_NOTIFICA_SOLIC_COMPRA
AFTER INSERT OR UPDATE ON AD_TGSSCP
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_NOTIFICA_SOLIC_COMPRA
  Tipo           : Trigger
  Descrição      : Envia notificações por e-mail em mudanças de status de solicitação (nova, aprovada, cancelada, compra realizada).
  Tabela         : AD_TGSSCP
  Evento         : AFTER INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(4000);
    V_CODFILA      NUMBER;
    V_NOME_USU     VARCHAR2(100);
    V_EMAIL_USU    VARCHAR2(100);
    V_DTPREVENT    DATE;
    V_PRODUTOS     VARCHAR2(4000);
    CURSOR C_PRODUTOS IS
        SELECT CODPROD
        FROM AD_TGSISCP
        WHERE NUSOL = :NEW.NUSOL
        ORDER BY CODPROD;
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
            '<p><strong>Status:</strong> Em Aberto</p>
            <p><strong>Justificativa:</strong> ' || :NEW.JUSTIFICATIVA || '</p>' ||
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
            '<p><strong>Status:</strong> Aprovada</p>' || 
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
            '<p><strong>Status:</strong> Cancelada</p>
            <p><strong>Justificativa:</strong> ' || :NEW.OBSAPROVADOR || '</p>' ||
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
        -- Concatena todos os códigos de produtos com formatação melhorada
        V_PRODUTOS := '';
        FOR R_PRODUTO IN C_PRODUTOS LOOP
            IF V_PRODUTOS IS NOT NULL AND LENGTH(V_PRODUTOS) > 0 THEN
                V_PRODUTOS := V_PRODUTOS || ', ';
            END IF;
            V_PRODUTOS := V_PRODUTOS || R_PRODUTO.CODPROD;
        END LOOP;
        
        -- Se não encontrou produtos, define mensagem padrão
        IF V_PRODUTOS IS NULL OR LENGTH(V_PRODUTOS) = 0 THEN
            V_PRODUTOS := 'Nenhum produto encontrado';
        END IF;

        SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;

        SELECT DTPREVENT INTO V_DTPREVENT FROM TGFCAB WHERE NUNOTA = :NEW.NUNOTA;

        V_TITULO := 'Compra Finalizada - Solicitação #' || :NEW.NUSOL;
        V_CONTEUDO := '
            <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
            <p><strong>Solicitante:</strong> ' || V_NOME_USU || '</p>
            <p><strong>ID da Solicitação:</strong> ' || :NEW.NUSOL || '</p>' ||
            '<p><strong>Status:</strong> Compra Realizada</p>
            <p><strong>Número Único da Nota:</strong> ' || :NEW.NUNOTA || '</p>' ||
            '<p><strong>Data da Previsão de Entrega:</strong> ' || TO_CHAR(V_DTPREVENT, 'DD/MM/YYYY') || '</p>' ||
            '<p><strong>Códigos dos Produtos:</strong></p>
            <div style="background-color: #fff; padding: 10px; border-radius: 4px; border-left: 4px solid #0056b3; margin: 10px 0;">' || V_PRODUTOS || '</div>
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
END TRG_NOTIFICA_SOLIC_COMPRA;