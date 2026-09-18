CREATE OR REPLACE TRIGGER TRG_SPKCAE_VLRCONSERTO_SPARK
BEFORE INSERT OR UPDATE ON AD_SPKCAE
FOR EACH ROW
FOLLOWS TRG_SPKCAE_INC_SPARK
/*==============================================================================
  Nome do Script : TRG_SPKCAE_VLRCONSERTO_SPARK
  Tipo           : Trigger
  Descrição      : Preenche o valor do conserto (VLRCONSERTO) quando o registro
                   é incluído ou alterado com STATUS = 'C', buscando o preço
                   vigente do produto (T_CODPROD) via a function nativa
                   SNK_PRECO, informando a tabela de preços padrão de serviços
                   (CODTAB = 14). A function já resolve o NUTAB vigente
                   (DTVIGOR <= SYSDATE) e obtém o preço através de
                   STP_OBTEM_PRECO2.
  Tabela         : AD_SPKCAE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_SPKCAE -- cadastro de conserto/assistência (alterado via :NEW)

  Dependencias   : TRG_SPKCAE_INC_SPARK -- popula T_CODPROD na inclusão; esta
                   trigger usa FOLLOWS para garantir que T_CODPROD já esteja
                   preenchido antes de buscar o preço
                   SNK_PRECO (function nativa Sankhya) -- resolve o preço
                   vigente do produto na tabela informada (CODTAB, CODPROD)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 14/09/2026
  Última Revisão : Setembro/2026 — Busca de preço trocada da consulta manual
                   em VGFTAB/TGFEXC (sem considerar vigência) para a function
                   nativa SNK_PRECO(14, T_CODPROD), que resolve o NUTAB vigente
                   e aplica a regra de preço de STP_OBTEM_PRECO2.

  Observações    : - Só atua quando STATUS = 'C' e VLRCONSERTO está nulo ou
                     zerado (não sobrescreve valor já preenchido/ajustado).
                   - Exige T_CODPROD preenchido; sem produto, o campo permanece
                     inalterado.
                   - Tabela de preços padrão de serviços é fixa: CODTAB = 14.
                   - Se SNK_PRECO retornar 0 (sem NUTAB vigente ou sem preço
                     cadastrado para o produto), o campo permanece inalterado.
==============================================================================*/
DECLARE
    V_VLRCONSERTO FLOAT;
BEGIN
    -- Só atua no fechamento do conserto (STATUS = 'C') e com valor ainda não preenchido
    IF :NEW.STATUS = 'C' AND NVL(:NEW.VLRCONSERTO, 0) = 0 AND :NEW.T_CODPROD IS NOT NULL THEN

        V_VLRCONSERTO := SNK_PRECO(14, :NEW.T_CODPROD);

        IF NVL(V_VLRCONSERTO, 0) > 0 THEN
            :NEW.VLRCONSERTO := V_VLRCONSERTO;
        END IF;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger TRG_SPKCAE_VLRCONSERTO_SPARK: ' || SQLERRM);
END;
