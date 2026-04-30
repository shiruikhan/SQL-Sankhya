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
    IF NVL(:NEW.QTDNEG, 0) = 0 THEN RETURN; END IF;

    -- 1. TENTA PEGAR DA MEMÓRIA (PACKAGE) PARA EVITAR ORA-04091
    IF PKG_SPARK_MOEDA.V_NUNOTA = :NEW.NUNOTA THEN
        V_CODTIPOPER := PKG_SPARK_MOEDA.V_CODTIPOPER;
        V_VLRMOEDA   := PKG_SPARK_MOEDA.V_VLRMOEDA;
    ELSE
        -- 2. SE NÃO ESTIVER NA MEMÓRIA (EX: INSERÇÃO MANUAL), BUSCA NO BANCO.
        --    Guard WHEN OTHERS / -4091: caso este caminho seja atingido enquanto
        --    TGFCAB estiver mutante (situação residual), aborta silenciosamente.
        BEGIN
            SELECT CODTIPOPER, VLRMOEDA INTO V_CODTIPOPER, V_VLRMOEDA
            FROM TGFCAB WHERE NUNOTA = :NEW.NUNOTA;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RETURN;
            WHEN OTHERS THEN
                IF SQLCODE = -4091 THEN RETURN; END IF;
                RAISE;
        END;
    END IF;
    
    -- 3. APLICA O CÁLCULO
    IF V_CODTIPOPER IN (1008, 1009) AND NVL(V_VLRMOEDA, 0) > 0 THEN
        :NEW.VLRUNITMOE := ((NVL(:NEW.VLRTOT, 0) - NVL(:NEW.VLRDESC, 0)) / :NEW.QTDNEG) / V_VLRMOEDA;
        :NEW.VLRTOTMOE  := :NEW.VLRUNITMOE * :NEW.QTDNEG;
    END IF;
END;