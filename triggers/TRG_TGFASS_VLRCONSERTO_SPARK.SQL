CREATE OR REPLACE TRIGGER TRG_TGFASS_VLRCONSERTO_SPARK
BEFORE INSERT OR UPDATE ON AD_TGFASS
FOR EACH ROW
FOLLOWS SPK_TGFASS_INC
/*==============================================================================
  Nome do Script : TRG_TGFASS_VLRCONSERTO_SPARK
  Tipo           : Trigger
  Descrição      : Preenche dois valores da O.S. de assistência técnica a
                   partir do preço vigente do produto (T_CODPROD), via a
                   function nativa SNK_PRECO:
                     - VLRCONSERTO      via SNK_PRECO(14, T_CODPROD) — tabela
                       de preços padrão de serviços.
                     - VLRSERVTECNICO   via SNK_PRECO(15, T_CODPROD) — tabela
                       de preços específica de AD_TGFASS.
                   A function já resolve o NUTAB vigente (DTVIGOR <= SYSDATE)
                   e obtém o preço através de STP_OBTEM_PRECO2.
  Tabela         : AD_TGFASS
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGFASS -- cadastro de O.S. de assistência (alterado via :NEW)

  Dependencias   : SPK_TGFASS_INC -- popula T_CODPROD na inclusão; esta trigger
                   usa FOLLOWS para garantir que T_CODPROD já esteja
                   preenchido antes de buscar o preço
                   SNK_PRECO (function nativa Sankhya) -- resolve o preço
                   vigente do produto na tabela informada (CODTAB, CODPROD)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 17/09/2026
  Última Revisão : Setembro/2026 — CODTAB de VLRCONSERTO corrigido para 14
                   (tabela padrão de serviços) e adicionado preenchimento de
                   VLRSERVTECNICO (novo campo) via CODTAB = 15.

  Observações    : - Cada campo só é preenchido se estiver nulo ou zerado
                     (não sobrescreve valor já preenchido/ajustado); os dois
                     são avaliados de forma independente.
                   - Exige T_CODPROD preenchido; sem produto, os campos
                     permanecem inalterados.
                   - Tabelas de preços são fixas: CODTAB = 14 (VLRCONSERTO) e
                     CODTAB = 15 (VLRSERVTECNICO).
                   - Se SNK_PRECO retornar 0 (sem NUTAB vigente ou sem preço
                     cadastrado para o produto), o respectivo campo permanece
                     inalterado.
==============================================================================*/
DECLARE
    V_PRECO AD_TGFASS.VLRCONSERTO%TYPE;
BEGIN
    IF :NEW.T_CODPROD IS NOT NULL THEN

        IF NVL(:NEW.VLRCONSERTO, 0) = 0 THEN
            V_PRECO := SNK_PRECO(14, :NEW.T_CODPROD);

            IF NVL(V_PRECO, 0) > 0 THEN
                :NEW.VLRCONSERTO := V_PRECO;
            END IF;
        END IF;

        IF NVL(:NEW.VLRSERVTECNICO, 0) = 0 THEN
            V_PRECO := SNK_PRECO(15, :NEW.T_CODPROD);

            IF NVL(V_PRECO, 0) > 0 THEN
                :NEW.VLRSERVTECNICO := V_PRECO;
            END IF;
        END IF;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger TRG_TGFASS_VLRCONSERTO_SPARK: ' || SQLERRM);
END;
