create or replace TRIGGER TRG_INC_UPD_TGFITE_SPARK2
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFITE_SPARK2
  Tipo           : Trigger
  Descrição      : Calcula valores unitários e totais em moeda estrangeira para operações de importação
  Tabela         : TGFITE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    V_CODTIPOPER TGFCAB.CODTIPOPER%TYPE;
    V_VLRMOEDA   TGFCAB.VLRMOEDA%TYPE;
BEGIN
    -- 1. Proteção Matemática: Se a quantidade for zero, aborta o cálculo para não dar erro "divisor is equal to zero"
    IF NVL(:NEW.QTDNEG, 0) = 0 THEN
        RETURN;
    END IF;

    -- 2. Trava Anti-Mutating Table: Se for um UPDATE, só recalcula se os valores base do item mudaram.
    -- Isso permite que a trigger do cabeçalho (abaixo) atualize os itens sem causar erro de recursividade.
    IF UPDATING AND 
       NVL(:NEW.VLRTOT, 0) = NVL(:OLD.VLRTOT, 0) AND 
       NVL(:NEW.VLRDESC, 0) = NVL(:OLD.VLRDESC, 0) AND 
       NVL(:NEW.QTDNEG, 0) = NVL(:OLD.QTDNEG, 0) THEN
        RETURN;
    END IF;

    -- 3. Busca os dados do cabeçalho
    BEGIN
        SELECT CODTIPOPER, VLRMOEDA 
        INTO V_CODTIPOPER, V_VLRMOEDA
        FROM TGFCAB 
        WHERE NUNOTA = :NEW.NUNOTA;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            RETURN;
    END;
    
    -- 4. Aplica a regra de negócio com tratamento de nulos (NVL)
    IF V_CODTIPOPER IN (1008, 1009) AND NVL(V_VLRMOEDA, 0) > 0 THEN
        
        :NEW.VLRUNITMOE := ((NVL(:NEW.VLRTOT, 0) - NVL(:NEW.VLRDESC, 0)) / :NEW.QTDNEG) / V_VLRMOEDA;
        :NEW.VLRTOTMOE  := :NEW.VLRUNITMOE * :NEW.QTDNEG;
        
    END IF;
END;