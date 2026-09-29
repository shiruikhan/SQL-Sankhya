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
                   Setembro/2026 — Performance: reativado o guard IF
                   P_CODPROD > 0 (estava comentado) em torno do UPDATE
                   TGFPRO_WF. Fora do filtro (NUMINT > 0 AND NOME =
                   'CODPROD_NEW'), P_CODPROD/P_IDINSTPRN ficavam NULL e o
                   UPDATE já não afetava nenhuma linha (WHERE SW_IDINSTPRN =
                   NULL nunca casa) — o guard só evita enviar esse UPDATE
                   sem efeito ao banco em toda inclusão/alteração de
                   TWFIVAR fora do filtro. Comportamento observável
                   inalterado.
==============================================================================*/
DECLARE
    P_CODPROD INTEGER;
    P_IDINSTPRN INTEGER;
BEGIN
    IF :NEW.NUMINT > 0 AND :NEW.NOME = 'CODPROD_NEW' THEN
        P_CODPROD := :NEW.NUMINT;
        P_IDINSTPRN := :NEW.IDINSTPRN;

        UPDATE TGFPRO_WF SET CODPROD = P_CODPROD WHERE SW_IDINSTPRN = P_IDINSTPRN;
    END IF;
END SPK_INS_UPD_TWFIVAR_CODIGONOVO;