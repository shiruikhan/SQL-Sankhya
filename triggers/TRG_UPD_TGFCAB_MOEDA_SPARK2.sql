CREATE OR REPLACE TRIGGER TRG_UPD_TGFCAB_MOEDA_SPARK2
/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_MOEDA_SPARK2
  Tipo           : Compound Trigger
  Descrição      : Recalcula VLRUNITMOE/VLRTOTMOE dos itens quando VLRMOEDA
                   é alterado no cabeçalho da nota (TOPs 1008/1009).

                   Compound trigger obrigatório para evitar ORA-04091:
                   o UPDATE em TGFITE e os seus triggers (ex: TRG_TGFITE_SPARK1)
                   precisam ler TGFCAB. Fazer isso dentro de um AFTER ROW trigger
                   de TGFCAB colocaria TGFCAB em estado mutante. Ao mover o
                   UPDATE para AFTER STATEMENT, TGFCAB já não está mutante e
                   qualquer SELECT em TGFCAB disparado pelos triggers de TGFITE
                   é seguro.

  Autor          : Silvio Vieira
  Empresa        : Spark Eletrônica
  Última Revisão : Abril/2026
==============================================================================*/
FOR UPDATE OF VLRMOEDA ON TGFCAB
COMPOUND TRIGGER

    -- Coleta as linhas elegíveis durante a fase AFTER EACH ROW.
    -- NUNOTA é PK de TGFCAB, portanto sem duplicatas por statement.
    TYPE t_row IS RECORD (
        nunota     TGFCAB.NUNOTA%TYPE,
        vlrmoeda   TGFCAB.VLRMOEDA%TYPE,
        codtipoper TGFCAB.CODTIPOPER%TYPE
    );
    TYPE t_tab IS TABLE OF t_row INDEX BY PLS_INTEGER;

    g_rows t_tab;
    g_idx  PLS_INTEGER := 0;

  -- -------------------------------------------------------------------------
  AFTER EACH ROW IS
  -- -------------------------------------------------------------------------
  BEGIN
      IF :NEW.CODTIPOPER IN (1008, 1009) AND NVL(:NEW.VLRMOEDA, 0) > 0 THEN
          g_idx := g_idx + 1;
          g_rows(g_idx).nunota     := :NEW.NUNOTA;
          g_rows(g_idx).vlrmoeda   := :NEW.VLRMOEDA;
          g_rows(g_idx).codtipoper := :NEW.CODTIPOPER;
      END IF;
  END AFTER EACH ROW;

  -- -------------------------------------------------------------------------
  AFTER STATEMENT IS
  -- TGFCAB já não está mutante aqui — os triggers de TGFITE podem ler TGFCAB
  -- sem ORA-04091.
  -- -------------------------------------------------------------------------
  BEGIN
      FOR i IN 1 .. g_idx LOOP
          -- Expõe os valores no package para TRG_INC_UPD_TGFITE_SPARK2
          -- evitar um SELECT desnecessário em TGFCAB.
          PKG_SPARK_MOEDA.V_NUNOTA     := g_rows(i).nunota;
          PKG_SPARK_MOEDA.V_VLRMOEDA   := g_rows(i).vlrmoeda;
          PKG_SPARK_MOEDA.V_CODTIPOPER := g_rows(i).codtipoper;

          UPDATE TGFITE
             SET VLRUNITMOE = ((NVL(VLRTOT, 0) - NVL(VLRDESC, 0)) / QTDNEG) / g_rows(i).vlrmoeda,
                 VLRTOTMOE  = (((NVL(VLRTOT, 0) - NVL(VLRDESC, 0)) / QTDNEG) / g_rows(i).vlrmoeda) * QTDNEG
           WHERE NUNOTA = g_rows(i).nunota
             AND NVL(QTDNEG, 0) > 0;
      END LOOP;

      -- Limpa o package e o estado interno do compound trigger
      PKG_SPARK_MOEDA.V_NUNOTA := NULL;
      g_idx := 0;
      g_rows.DELETE;
  END AFTER STATEMENT;

END TRG_UPD_TGFCAB_MOEDA_SPARK2;
