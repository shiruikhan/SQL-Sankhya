create or replace TRIGGER TRG_INC_UPD_INFCOLETA
BEFORE INSERT OR UPDATE ON AD_COLETA 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_INFCOLETA
  Tipo           : Trigger
  Descrição      : Registra data de coleta e atualiza campo AD_COLETADO em notas vinculadas
  Tabela         : AD_COLETA
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_NUNOTA INT;
    P_DHCOLETA DATE;
    P_NUNOTALINK INT;
BEGIN
    P_NUNOTA := :NEW.NUNOTAORIG;
    P_DHCOLETA := :NEW.DHCOLETA;
    SELECT DISTINCT NUNOTA INTO P_NUNOTALINK FROM TGFVAR WHERE NUNOTAORIG = P_NUNOTA AND QTDATENDIDA > 0;
    
    UPDATE TGFCAB SET AD_COLETADO = P_DHCOLETA WHERE NUNOTA = P_NUNOTA;
    
    IF P_NUNOTALINK > 0 THEN
        UPDATE TGFCAB SET AD_COLETADO = P_DHCOLETA WHERE NUNOTA = P_NUNOTALINK;
    END IF;
END TRG_INC_UPD_INFCOLETA;