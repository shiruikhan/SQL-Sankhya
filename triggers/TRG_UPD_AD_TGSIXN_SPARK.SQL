CREATE OR REPLACE TRIGGER TRG_UPD_AD_TGSIXN_SPARK
BEFORE UPDATE ON AD_TGSIXN
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_UPD_AD_TGSIXN_SPARK
  Tipo           : Trigger
  Descrição      : Impede a edição dos dados de identidade do apontamento de
                   conferência após sua criação (NUCONF, CODUSUINC, NUARQUIVO,
                   DTINI, CODEMP, NUMNOTA, DHEMISS). O apontamento é único e imutável nesses campos: uma
                   vez gravado (tela de AD_TGSIXN), só pode ser fechado
                   automaticamente pelo próprio sistema. Exceções controladas:
                   CODFUNC (conferente) pode ser preenchido uma única vez
                   via UPDATE após o INSERT inicial — depois de setado, não
                   pode mais ser alterado. OBSERVACAO é livremente editável a
                   qualquer momento (anotações do conferente durante o processo).
  Tabela         : AD_TGSIXN
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSIXN -- registro validado via :OLD/:NEW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Inclusão de DHEMISS na checagem de imutabilidade
==============================================================================*/
BEGIN
    IF :NEW.NUCONF != :OLD.NUCONF
       OR NVL(:NEW.CODUSUINC, -1) != NVL(:OLD.CODUSUINC, -1)
       OR NVL(:NEW.NUARQUIVO, -1) != NVL(:OLD.NUARQUIVO, -1)
       OR NVL(:NEW.DTINI, DATE '0001-01-01') != NVL(:OLD.DTINI, DATE '0001-01-01')
       OR NVL(:NEW.CODEMP, -1) != NVL(:OLD.CODEMP, -1)
       OR NVL(:NEW.NUMNOTA, -1) != NVL(:OLD.NUMNOTA, -1)
       OR NVL(:NEW.DHEMISS, DATE '0001-01-01') != NVL(:OLD.DHEMISS, DATE '0001-01-01')
    THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Apontamento de conferência (NUCONF ' || :OLD.NUCONF || ') não pode ser alterado após criado.');
    END IF;

    -- CODFUNC só pode ser preenchido uma vez (NULL -> valor); depois de
    -- setado, uma tentativa de troca ou remocao tambem e bloqueada
    IF :OLD.CODFUNC IS NOT NULL AND NVL(:NEW.CODFUNC, -1) != :OLD.CODFUNC THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Conferente do apontamento (NUCONF ' || :OLD.NUCONF || ') já foi definido e não pode ser alterado.');
    END IF;
END;
