CREATE OR REPLACE TRIGGER s
AFTER UPDATE ON tgfcab
FOR EACH ROW
DECLARE
    v_count_f NUMBER := 0;
    P_MAXFILA       NUMBER;
    P_EMAIL         VARCHAR2(60);
BEGIN
    -- Condições para acionar a trigger
    IF :NEW.tipmov = 'P' AND :NEW.nuconfatual IS NOT NULL THEN
        -- Verifica se há ao menos um status 'F' na tgfcon2
        SELECT COUNT(*) INTO v_count_f
        FROM tgfcon2
        WHERE nuconf = :NEW.nuconfatual
          AND status = 'F';

        -- Geração de código de fila e recuperação do e-mail
        BEGIN
            SELECT MAX(CODFILA) + 1 INTO P_MAXFILA FROM TMDFMG;
            SELECT EMAIL INTO P_EMAIL FROM TSIUSU WHERE CODUSU = :NEW.CODUSUINC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Nenhum e-mail encontrado; aborta trigger
                RETURN;
            WHEN OTHERS THEN
                -- Log de erro pode ser adicionado aqui se necessário
                RETURN;
        END;

        IF v_count_f > 0 THEN
            -- Chamada da procedure de envio de e-mail
            STP_GRAVA_FILA_BI2(P_MAXFILA,'Finalização de Conferência',
                '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                    <h2 style="color: #0056b3;">Finalização de Conferência</h2>
                    <p>A Conferência referente pedido ' || :NEW.nunota || ' foi finalizada.</p>
                </div>',
                P_EMAIL, NULL);
        END IF;
    END IF;
END;
