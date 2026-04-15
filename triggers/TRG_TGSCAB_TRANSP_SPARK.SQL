create or replace TRIGGER TRG_TGSCAB_TRANSP_SPARK 
BEFORE INSERT OR UPDATE ON AD_TGSCAB 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGSCAB_TRANSP_SPARK
  Tipo           : Trigger
  Descrição      : Atribui código de parceiro transportador padrão
                   quando transportador é informado
  Tabela         : AD_TGSCAB
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
    IF (INSERTING OR UPDATING('TRANSP')) THEN
        IF NVL(:NEW.CODPARCTRANSP, 0) = 0 THEN
            IF :NEW.TRANSP IS NOT NULL THEN
                :NEW.CODPARCTRANSP := 1087;
            END IF;
        END IF;
    END IF;
END TRG_TGSCAB_TRANSP_SPARK;