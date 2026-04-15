create or replace TRIGGER TRG_UPD_AVISOSPARK
BEFORE UPDATE ON SPARKPRD.TGFCON2
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_UPD_AVISOSPARK
  Tipo           : Trigger
  Descrição      : Alerta sobre necessidade de corrigir quantidade de volumes
                   ao finalizar conferência
  Tabela         : SPARKPRD
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    v_message VARCHAR2(100);
BEGIN
    IF :NEW.STATUS = 'F' AND :NEW.QTDVOL = 1 THEN
        v_message := 'Lembre-se de corrigir a quantidade de volumes caso necessário';
        DBMS_OUTPUT.PUT_LINE(v_message);
    END IF;
END TRG_UPD_AVISOSPARK;