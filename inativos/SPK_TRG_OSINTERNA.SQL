create or replace TRIGGER SPK_TRG_OSINTERNA 
BEFORE UPDATE ON AD_OSINTERNA
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_TRG_OSINTERNA
  Tipo           : Trigger
  Descrição      : Envia notificações por email ao atualizar status de Ordem de Serviço.
                  Gera fila de envio para status em andamento, cancelado, programado e finalizado.
  Tabela         : AD_OSINTERNA
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODUSUCRI     AD_OSINTERNA.CODUSUCRI%TYPE := :OLD.CODUSUCRI;
    P_CODUSUALT     AD_OSINTERNA.CODUSUALT%TYPE := :NEW.CODUSUALT;
    P_STATUSOLD     AD_OSINTERNA.STATUS%TYPE := :OLD.STATUS;
    P_STATUSNEW     AD_OSINTERNA.STATUS%TYPE := :NEW.STATUS;
    P_PROBAPONTADO  AD_OSINTERNA.PROBAPONTADO%TYPE := :NEW.PROBAPONTADO;
    P_OBSERVACAO    AD_OSINTERNA.OBSERVACAO%TYPE := :NEW.OBSERVACAO;
    P_DTPROGRAMADA  AD_OSINTERNA.DTPROGRAMADA%TYPE := :NEW.DTPROGRAMADA;
    P_NUMOS         AD_OSINTERNA.NUMOS%TYPE := :NEW.NUMOS;
    P_MAXFILA       NUMBER;
    P_EMAIL         VARCHAR2(60);
BEGIN
    SELECT MAX(CODFILA) + 1 INTO P_MAXFILA FROM TMDFMG;
    SELECT EMAIL INTO P_EMAIL FROM TSIUSU WHERE CODUSU = P_CODUSUCRI;
    
    IF P_CODUSUCRI <> P_CODUSUALT AND P_STATUSOLD <> P_STATUSNEW AND P_EMAIL IS NOT NULL THEN
        
        CASE P_STATUSNEW
            WHEN 'A' THEN
                IF P_STATUSOLD = 'I' THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Atualização da sua O.S. de número - ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Nova atualização na Ordem de Serviço</h2>
                            <p>A O.S. ' || P_NUMOS || ' teve seu status alterado para <strong>Em andamento</strong>.</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;
            WHEN 'C' THEN
                IF P_OBSERVACAO IS NOT NULL THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Cancelamento da sua O.S. de número - ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Cancelamento da Ordem de Serviço</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi <strong>Cancelada</strong>.</p>
                            <div style="margin-top: 20px;">
                                <h3 style="background-color: #f2f2f2; padding: 10px; border-radius: 5px;">Motivo</h3>
                                <p style="border: 1px solid #ccc; padding: 10px; background-color: #f9f9f9; border-radius: 5px;">' || P_OBSERVACAO || '</p>
                            </div>
                        </div>',
                        P_EMAIL, NULL);
                END IF;
            WHEN 'P' THEN
                IF P_DTPROGRAMADA IS NOT NULL THEN
                    STP_GRAVA_FILA_BI2(P_MAXFILA,
                        'Programação da sua O.S. de número - ' || P_NUMOS,
                        '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                            <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Ordem de Serviço Programada</h2>
                            <p>A O.S. ' || P_NUMOS || ' foi marcada como <strong>Programada</strong>, com previsão de execução em ' || TO_CHAR(P_DTPROGRAMADA, 'DD/MM/YYYY') || '.</p>
                        </div>',
                        P_EMAIL, NULL);
                END IF;
            WHEN 'F' THEN
                STP_GRAVA_FILA_BI2(P_MAXFILA,
                    'Finalização da sua O.S. de número - ' || P_NUMOS,
                    '<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; line-height: 1.5;">
                        <h2 style="color: #0056b3; border-bottom: 2px solid #0056b3; padding-bottom: 5px;">Ordem de Serviço Finalizada</h2>
                        <p>A O.S. ' || P_NUMOS || ' foi <strong>Finalizada</strong>.</p>
                    </div>',
                    P_EMAIL, NULL);
        END CASE;
    END IF;
END SPK_TRG_OSINTERNA;