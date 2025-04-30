CREATE OR REPLACE TRIGGER TRG_UPD_OSINTERNA 
BEFORE UPDATE ON AD_OSINTERNA
FOR EACH ROW
DECLARE
/*==============================================================================
  Nome do Script : TRG_UPD_OSINTERNA
  Descrição      : Envia e-mail ao criador da O.S. quando há mudança de status.
  Revisor        : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : 13/03/2025
  Última Revisão : 30/04/2025
==============================================================================*/
    P_CODUSUCRI     AD_OSINTERNA.CODUSUCRI%TYPE := :OLD.CODUSUCRI;
    P_CODUSUALT     AD_OSINTERNA.CODUSUALT%TYPE := :NEW.CODUSUALT;
    P_STATUSOLD     AD_OSINTERNA.STATUS%TYPE    := :OLD.STATUS;
    P_STATUSNEW     AD_OSINTERNA.STATUS%TYPE    := :NEW.STATUS;
    P_PROBAPONTADO  AD_OSINTERNA.PROBAPONTADO%TYPE := :NEW.PROBAPONTADO;
    P_OBSERVACAO    AD_OSINTERNA.OBSERVACAO%TYPE := :NEW.OBSERVACAO;
    P_DTPROGRAMADA  AD_OSINTERNA.DTPROGRAMADA%TYPE := :NEW.DTPROGRAMADA;
    P_NUMOS         AD_OSINTERNA.NUMOS%TYPE := :NEW.NUMOS;
    P_MAXFILA       NUMBER;
    P_EMAIL         VARCHAR2(60);
BEGIN
    -- Geração de código de fila e recuperação do e-mail
    BEGIN
        SELECT MAX(CODFILA) + 1 INTO P_MAXFILA FROM TMDFMG;
        SELECT EMAIL INTO P_EMAIL FROM TSIUSU WHERE CODUSU = P_CODUSUCRI;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Nenhum e-mail encontrado; aborta trigger
            RETURN;
        WHEN OTHERS THEN
            -- Log de erro pode ser adicionado aqui se necessário
            RETURN;
    END;

    -- Envia e-mail se o status foi alterado por outro usuário e existe e-mail válido
    IF P_CODUSUCRI <> P_CODUSUALT AND P_STATUSOLD <> P_STATUSNEW AND P_EMAIL IS NOT NULL THEN
        CASE P_STATUSNEW
            WHEN 'A' THEN
                IF P_STATUSOLD = 'I' THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Atualização da sua O.S. nº ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3;">Nova atualização na Ordem de Serviço</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi alterada para <strong>Em andamento</strong>.</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;

            WHEN 'C' THEN
                IF P_OBSERVACAO IS NOT NULL THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Cancelamento da sua O.S. nº ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3;">Cancelamento da Ordem de Serviço</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi <strong>Cancelada</strong>.</p>
                            <h3 style="margin-top:20px;">Motivo</h3>
                            <p style="background:#f9f9f9; padding:10px;">' || P_OBSERVACAO || '</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;

            WHEN 'P' THEN
                IF P_DTPROGRAMADA IS NOT NULL THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Programação da sua O.S. nº ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3;">Ordem de Serviço Programada</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi marcada como <strong>Programada</strong>, prevista para ' || TO_CHAR(P_DTPROGRAMADA, 'DD/MM/YYYY') || '.</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;

            WHEN 'F' THEN
                STP_GRAVA_FILA_BI2(P_MAXFILA,
                    'Finalização da sua O.S. nº ' || P_NUMOS,
                    '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                        <h2 style="color: #0056b3;">Ordem de Serviço Finalizada</h2>
                        <p>A O.S. ' || P_NUMOS || ' foi <strong>Finalizada</strong>.</p>
                    </div>',
                    P_EMAIL, NULL);
        END CASE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro inesperado, impede falha na transação principal
        NULL;
END;