create or replace TRIGGER SPK_INS_UPD_TWFIVAR_CODIGONOVO 
BEFORE INSERT OR UPDATE ON TWFIVAR 
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_INS_UPD_TWFIVAR_CODIGONOVO
  Tipo           : Trigger
  Descrição      : Atualiza código de produto na tabela TGFPRO_WF quando NOME='CODPROD_NEW' e NUMINT é fornecido na variável de workflow.
  Tabela         : TWFIVAR
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODPROD INTEGER;
    P_IDINSTPRN INTEGER;
BEGIN
    IF :NEW.NUMINT > 0 AND :NEW.NOME = 'CODPROD_NEW' THEN
        P_CODPROD := :NEW.NUMINT;
        P_IDINSTPRN := :NEW.IDINSTPRN;
    END IF;
    --IF P_CODPROD > 0 THEN
        UPDATE TGFPRO_WF SET CODPROD = P_CODPROD WHERE SW_IDINSTPRN = P_IDINSTPRN;
    --END IF;
END SPK_INS_UPD_TWFIVAR_CODIGONOVO;