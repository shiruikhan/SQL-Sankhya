CREATE OR REPLACE TRIGGER TRG_UPD_TGFPAR_UF_SPARK
BEFORE UPDATE ON TGFPAR
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_UPD_TGFPAR_UF_SPARK
  Tipo           : Trigger
  Descrição      : Valida impossibilidade de alteração de UF de parceiro
  Tabela         : TGFPAR
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    V_UF_OLD VARCHAR2(10);
    V_UF_NEW VARCHAR2(10);
BEGIN
    IF (:OLD.CODCID IS NULL AND :NEW.CODCID IS NULL) THEN
        RETURN;
    END IF;
    IF TO_CHAR(:OLD.CODCID) = TO_CHAR(:NEW.CODCID) THEN
        RETURN;
    END IF;
    SELECT
        (SELECT c.UF FROM TSICID c WHERE TO_CHAR(c.CODCID) = TRIM(TO_CHAR(:OLD.CODCID))) AS UF_OLD,
        (SELECT c.UF FROM TSICID c WHERE TO_CHAR(c.CODCID) = TRIM(TO_CHAR(:NEW.CODCID))) AS UF_NEW
    INTO V_UF_OLD, V_UF_NEW
    FROM DUAL;
    IF NVL(V_UF_OLD, '~') <> NVL(V_UF_NEW, '~') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Não é possível alterar UF de Parceiro - Favor criar um novo cadastro');
    END IF;
END TRG_UPD_TGFPAR_UF_SPARK;
