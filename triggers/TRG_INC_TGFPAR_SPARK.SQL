CREATE OR REPLACE TRIGGER TRG_INC_TGFPAR_SPARK
BEFORE INSERT ON TGFPAR
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFPAR_SPARK
  Tipo           : Trigger
  Descrição      : No cadastro de parceiros do tipo Pessoa Física (TIPPESSOA = 'F')
                   sem vendedor associado (CODVEND = 0), força os campos
                   APLICLEITRANSP e IPIINCICMS para 'S', garantindo que a lei de
                   transporte e a inclusão de IPI no ICMS sejam habilitadas
                   automaticamente para esse perfil de parceiro.
                   Também replica o EMAIL principal no campo EMAILNFE
                   (E-mail p/ envio NF-e/NFS-e/CT-e).
  Tabela         : TGFPAR
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW

  Tabelas        : TGFPAR -- cadastro de parceiros (alterado via :NEW)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 25/05/2026
  Última Revisão : Maio/2026 — Criação

  Observações    : - Atua apenas quando TIPPESSOA = 'F' e CODVEND = 0.
                   - Não interfere em pessoas jurídicas nem em PF com vendedor.
                   - EMAILNFE recebe o valor de EMAIL; se EMAIL for nulo,
                     EMAILNFE permanece nulo.
==============================================================================*/
BEGIN
    IF :NEW.TIPPESSOA = 'F' AND NVL(:NEW.CODVEND, 0) = 0 THEN
        :NEW.APLICLEITRANSP := 'S';
        :NEW.IPIINCICMS     := 'S';
        :NEW.EMAILNFE       := :NEW.EMAIL;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,
            'TRG_INC_TGFPAR_SPARK: Erro ao definir flags de PF sem vendedor. ' ||
            'CODPARC=' || :NEW.CODPARC || ' — ' || SQLERRM);
END;
/
