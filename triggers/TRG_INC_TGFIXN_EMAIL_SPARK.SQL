create or replace TRIGGER TRG_INC_TGFIXN_EMAIL_SPARK
AFTER INSERT ON TGFIXN
FOR EACH ROW
DECLARE
    V_TITULO       VARCHAR2(300);
    V_CONTEUDO     VARCHAR2(4000);
    V_CODFILA      NUMBER;
BEGIN
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
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20022, 'Dados não encontrados para envio de e-mail (CFOPXML).');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20097, 'Erro na trigger TRG_INC_TGFIXN_EMAIL_SPARK: ' || SQLERRM);
END;
