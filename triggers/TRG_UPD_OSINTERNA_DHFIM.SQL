CREATE OR REPLACE TRIGGER TRG_UPD_OSINTERNA_DHFIM
BEFORE UPDATE ON AD_OSINTERNA
FOR EACH ROW
DECLARE
/*==============================================================================
  Nome do Script : TRG_UPD_OSINTERNA_DHFIM
  Descrição      : Grava data e hora de finalização (DHFIM) quando o STATUS
                   da O.S. interna é alterado para 'F' (Finalizado).
  Revisor        : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : 30/03/2026
  Última Revisão : 30/03/2026
==============================================================================*/
    P_STATUSOLD  AD_OSINTERNA.STATUS%TYPE := :OLD.STATUS;
    P_STATUSNEW  AD_OSINTERNA.STATUS%TYPE := :NEW.STATUS;
BEGIN
    IF P_STATUSNEW = 'F' AND P_STATUSOLD <> 'F' THEN
        :NEW.DHFIM := SYSDATE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro inesperado, impede falha na transação principal
        NULL;
END;
