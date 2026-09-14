CREATE OR REPLACE TRIGGER TRG_SPKCAE_VLRCONSERTO_SPARK
BEFORE INSERT OR UPDATE ON AD_SPKCAE
FOR EACH ROW
FOLLOWS TRG_SPKCAE_INC_SPARK
/*==============================================================================
  Nome do Script : TRG_SPKCAE_VLRCONSERTO_SPARK
  Tipo           : Trigger
  Descrição      : Preenche o valor do conserto (VLRCONSERTO) quando o registro
                   é incluído ou alterado com STATUS = 'C', buscando o preço
                   vigente do produto (T_CODPROD) na tabela de preços padrão de
                   serviços (VGFTAB.CODTAB = 14). O valor é obtido em
                   TGFEXC.VLRVENDA, localizado pelo NUTAB da tabela 14 e pelo
                   CODPROD correspondente a T_CODPROD.
  Tabela         : AD_SPKCAE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_SPKCAE -- cadastro de conserto/assistência (alterado via :NEW)
                   VGFTAB    -- tabelas de preço (leitura, localiza NUTAB da tabela 14)
                   TGFEXC    -- itens de tabela de preço (leitura, localiza VLRVENDA)

  Dependencias   : TRG_SPKCAE_INC_SPARK -- popula T_CODPROD na inclusão; esta
                   trigger usa FOLLOWS para garantir que T_CODPROD já esteja
                   preenchido antes de buscar o preço

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Criação. Nome encurtado de
                   TRG_INC_UPD_AD_SPKCAE_VLRCONSERTO_SPARK (39 caracteres) para
                   TRG_SPKCAE_VLRCONSERTO_SPARK (28) — a trigger de auditoria
                   DDL_OBJETOS grava o nome do objeto em DDL_LOG.OBJETO
                   (VARCHAR2(30)) e rejeitava (ORA-12899) nomes acima de 30.

  Observações    : - Só atua quando STATUS = 'C' e VLRCONSERTO está nulo ou
                     zerado (não sobrescreve valor já preenchido/ajustado).
                   - Exige T_CODPROD preenchido; sem produto, o campo permanece
                     inalterado.
                   - Tabela de preços padrão de serviços é fixa: CODTAB = 14.
                   - Sem NUTAB para a tabela 14, ou sem o produto cadastrado em
                     TGFEXC para esse NUTAB, o campo permanece inalterado.
==============================================================================*/
DECLARE
    V_NUTAB    VGFTAB.NUTAB%TYPE;
    V_VLRVENDA TGFEXC.VLRVENDA%TYPE;
BEGIN
    -- Só atua no fechamento do conserto (STATUS = 'C') e com valor ainda não preenchido
    IF :NEW.STATUS = 'C' AND NVL(:NEW.VLRCONSERTO, 0) = 0 AND :NEW.T_CODPROD IS NOT NULL THEN

        -- Localiza o NUTAB da tabela padrão de preços de serviços (CODTAB = 14)
        BEGIN
            SELECT TAB.NUTAB
              INTO V_NUTAB
              FROM VGFTAB TAB
             WHERE TAB.CODTAB = 14;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_NUTAB := NULL;
        END;

        IF V_NUTAB IS NOT NULL THEN

            -- Localiza o preço de venda do produto na tabela de preços encontrada
            BEGIN
                SELECT EXC.VLRVENDA
                  INTO V_VLRVENDA
                  FROM TGFEXC EXC
                 WHERE EXC.NUTAB = V_NUTAB
                   AND EXC.CODPROD = :NEW.T_CODPROD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_VLRVENDA := NULL;
            END;

            IF V_VLRVENDA IS NOT NULL THEN
                :NEW.VLRCONSERTO := V_VLRVENDA;
            END IF;

        END IF;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger TRG_SPKCAE_VLRCONSERTO_SPARK: ' || SQLERRM);
END;
