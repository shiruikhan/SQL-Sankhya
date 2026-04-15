create or replace TRIGGER TRG_INS_UPD_CODLOCALDEST
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_INS_UPD_CODLOCALDEST
  Tipo           : Trigger
  Descrição      : Define automaticamente o CODLOCALORIG para 199 em itens de operação tipo 712 com sequência maior que zero.
  Tabela         : TGFITE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODTIPOPER INT;
    P_SEQUENCIA NUMBER;
BEGIN
    SELECT DISTINCT CAB.CODTIPOPER INTO P_CODTIPOPER 
    FROM TGFCAB CAB 
    WHERE CAB.NUNOTA = :NEW.NUNOTA;
    
    P_SEQUENCIA := :NEW.SEQUENCIA;

    IF P_CODTIPOPER = 712 AND P_SEQUENCIA > 0 THEN
        :NEW.CODLOCALORIG := 199;
    END IF;
END SPK_INS_UPD_CODLOCALDEST;