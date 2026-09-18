CREATE OR REPLACE TRIGGER TRG_TGFASS_VLRCONSERTO_SPARK
BEFORE INSERT OR UPDATE ON AD_TGFASS
FOR EACH ROW
FOLLOWS SPK_TGFASS_INC
/*==============================================================================
  Nome do Script : TRG_TGFASS_VLRCONSERTO_SPARK
  Tipo           : Trigger
  Descrição      : Preenche o valor do conserto (VLRCONSERTO) da O.S. de
                   assistência técnica, buscando o preço vigente do produto
                   (T_CODPROD) via a function nativa SNK_PRECO, informando a
                   tabela de preços CODTAB = 15. A function já resolve o NUTAB
                   vigente (DTVIGOR <= SYSDATE) e obtém o preço através de
                   STP_OBTEM_PRECO2.
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
  Última Revisão : Setembro/2026 — Criação

  Observações    : - Só atua com VLRCONSERTO nulo ou zerado (não sobrescreve
                     valor já preenchido/ajustado).
                   - Exige T_CODPROD preenchido; sem produto, o campo permanece
                     inalterado.
                   - Tabela de preços é fixa: CODTAB = 15.
                   - Se SNK_PRECO retornar 0 (sem NUTAB vigente ou sem preço
                     cadastrado para o produto), o campo permanece inalterado.
==============================================================================*/
DECLARE
    V_VLRCONSERTO FLOAT;
BEGIN
    IF :NEW.T_CODPROD IS NOT NULL AND NVL(:NEW.VLRCONSERTO, 0) = 0 THEN

        V_VLRCONSERTO := SNK_PRECO(15, :NEW.T_CODPROD);

        IF NVL(V_VLRCONSERTO, 0) > 0 THEN
            :NEW.VLRCONSERTO := V_VLRCONSERTO;
        END IF;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na trigger TRG_TGFASS_VLRCONSERTO_SPARK: ' || SQLERRM);
END;
