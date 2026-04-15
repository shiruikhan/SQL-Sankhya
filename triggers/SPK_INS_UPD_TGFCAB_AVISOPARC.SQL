create or replace TRIGGER SPK_INS_UPD_TGFCAB_AVISOPARC 
BEFORE INSERT OR UPDATE ON TGFCAB 
FOR EACH ROW
/*==============================================================================
  Nome do Script : SPK_INS_UPD_TGFCAB_AVISOPARC
  Tipo           : Trigger
  Descrição      : Copia automaticamente observações do parceiro (TGFPAR) para o campo AD_AVISOPARC do cabecalho da nota.
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_AVISOPARC VARCHAR2(4000);
BEGIN
    BEGIN
        SELECT OBSERVACOES 
        INTO P_AVISOPARC 
        FROM TGFPAR 
        WHERE CODPARC = :NEW.CODPARC;
        
        :NEW.AD_AVISOPARC := P_AVISOPARC;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            :NEW.AD_AVISOPARC := NULL;
    END;
END SPK_INS_UPD_TGFCAB_AVISOPARC;