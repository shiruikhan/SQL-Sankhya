create or replace TRIGGER TRG_INC_TGFIXN_EMAIL_SPARK
AFTER INSERT OR UPDATE ON TGFIXN
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFIXN_EMAIL_SPARK
  Tipo           : Trigger
  Descrição      : Dispara notificações por email para notas de devolução (CFOPs 5201, 5202, 6201, 6202, 5410, 6410)
  Tabela         : TGFIXN
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
    V_OPERACAO     VARCHAR2(10);
    PROCEDURE LOG_ERRO(P_OPERACAO VARCHAR2, P_ERR_CODE NUMBER, P_ERR_MSG VARCHAR2, P_ERR_BACKTRACE VARCHAR2, P_CALL_STACK VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA, NUMNOTA, CFOPXML, CHAVEACESSO, XNOMEEMIT, ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK)
        VALUES (V_IDLOG, 'TRG_INC_TGFIXN_EMAIL_SPARK', P_OPERACAO, :NEW.NUNOTA, :NEW.NUMNOTA, :NEW.CFOPXML, :NEW.CHAVEACESSO, :NEW.XNOMEEMIT, P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END TRG_INC_TGFIXN_EMAIL_SPARK;
BEGIN
    IF INSERTING THEN
        IF :NEW.CFOPXML IS NOT NULL AND (
             :NEW.CFOPXML LIKE '%5201%' OR
             :NEW.CFOPXML LIKE '%5202%' OR
             :NEW.CFOPXML LIKE '%6201%' OR
             :NEW.CFOPXML LIKE '%6202%' OR
             :NEW.CFOPXML LIKE '%5410%' OR
             :NEW.CFOPXML LIKE '%6410%'
           ) THEN
            SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;
            V_TITULO := 'Nova Nota de Devolução Emitida - NF ' || :NEW.NUMNOTA;
            V_CONTEUDO := '
                <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
                <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
                <p><strong>Emitente:</strong> ' || :NEW.XNOMEEMIT || '</p>
                <p><strong>CFOP:</strong> ' || :NEW.CFOPXML || '</p>
                <p><strong>Número da Nota:</strong> ' || :NEW.NUMNOTA || '</p>
                <p><strong>Chave de Acesso:</strong> ' || :NEW.CHAVEACESSO || '</p>
                <p><strong>Data de Emissão:</strong> ' || TO_CHAR(:NEW.DHEMISS, 'DD/MM/YYYY HH24:MI') || '</p>
                <p>Foi detectada a emissão de uma nova nota de devolução.</p>
                <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
                <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
                </div>';
            STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'fiscal@spark.ind.br', NULL);
            STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, 'controladoria@spark.ind.br', NULL);
        END IF;
    ELSIF UPDATING THEN
        IF NVL(:OLD.NUNOTA, -1) <> NVL(:NEW.NUNOTA, -1) THEN
            RETURN;
        END IF;
        IF :NEW.CFOPXML IS NOT NULL AND (
             :NEW.CFOPXML LIKE '%5201%' OR
             :NEW.CFOPXML LIKE '%5202%' OR
             :NEW.CFOPXML LIKE '%6201%' OR
             :NEW.CFOPXML LIKE '%6202%' OR
             :NEW.CFOPXML LIKE '%5410%' OR
             :NEW.CFOPXML LIKE '%6410%'
           ) THEN
            SELECT NVL(MAX(CODFILA), 0) + 1 INTO V_CODFILA FROM TMDFMG;
            V_TITULO := 'Atualização - Nota de Devolução - NF ' || :NEW.NUMNOTA;
            V_CONTEUDO := '
                <div style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px; border-radius: 6px; border: 1px solid #ddd; max-width: 700px; margin: auto;">
                <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">' || V_TITULO || '</h2>
                <p><strong>Emitente:</strong> ' || :NEW.XNOMEEMIT || '</p>
                <p><strong>CFOP:</strong> ' || :NEW.CFOPXML || '</p>
                <p><strong>Número da Nota:</strong> ' || :NEW.NUMNOTA || '</p>
                <p><strong>Chave de Acesso:</strong> ' || :NEW.CHAVEACESSO || '</p>
                <p><strong>Data de Emissão:</strong> ' || TO_CHAR(:NEW.DHEMISS, 'DD/MM/YYYY HH24:MI') || '</p>
                <p>Foi detectada uma atualização em nota de devolução.</p>
                <hr style="margin: 20px 0; border: none; border-top: 1px solid #ccc;" />
                <p style="font-size: 12px; color: #777;">Mensagem automática gerada pelo sistema Sankhya - Spark Eletrônica</p>
                </div>';
            STP_GRAVA_FILA_BI2(V_CODFILA, V_TITULO, V_CONTEUDO, 'fiscal@spark.ind.br', NULL);
            STP_GRAVA_FILA_BI2(V_CODFILA + 1, V_TITULO, V_CONTEUDO, 'controladoria@spark.ind.br', NULL);
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF INSERTING THEN
            V_OPERACAO := 'INSERT';
        ELSIF UPDATING THEN
            V_OPERACAO := 'UPDATE';
        ELSE
            V_OPERACAO := NULL;
        END IF;
        LOG_ERRO(V_OPERACAO, SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20022, 'Dados não encontrados para envio de e-mail (CFOPXML).');
    WHEN OTHERS THEN
        IF INSERTING THEN
            V_OPERACAO := 'INSERT';
        ELSIF UPDATING THEN
            V_OPERACAO := 'UPDATE';
        ELSE
            V_OPERACAO := NULL;
        END IF;
        LOG_ERRO(V_OPERACAO, SQLCODE, SQLERRM, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20097, 'Erro na trigger TRG_INC_TGFIXN_EMAIL_SPARK: ' || SQLERRM);
END;
