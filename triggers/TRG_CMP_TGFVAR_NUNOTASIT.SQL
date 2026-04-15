create or replace TRIGGER TRG_CMP_TGFVAR_NUNOTASIT
    FOR INSERT OR UPDATE OR DELETE ON TGFVAR
COMPOUND TRIGGER
/*==============================================================================
  Nome do Script : TRG_CMP_TGFVAR_NUNOTASIT
  Tipo           : Trigger
  Descrição      : Atualiza NUNOTASIT em AD_TGSCTF e TGFCAB (COMPOUND TRIGGER).
                  Sincroniza status 'F' ou 'A' baseado em existência de variacões linkadas.
  Tabela         : TGFVAR
  Evento         : FOR INSERT OR UPDATE OR DELETE (COMPOUND TRIGGER)
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

    TYPE t_nunota_set IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
    g_nunotaorig_set t_nunota_set;

    PROCEDURE add_nunotaorig(p_nunota NUMBER) IS
        v_key PLS_INTEGER;
    BEGIN
        IF p_nunota IS NOT NULL THEN
            v_key := TRUNC(p_nunota);
            g_nunotaorig_set(v_key) := TRUE; -- de-duplifica por chave
        END IF;
    END;

AFTER EACH ROW IS
BEGIN
    IF INSERTING THEN
        add_nunotaorig(:NEW.NUNOTAORIG);
    ELSIF UPDATING THEN
        add_nunotaorig(:NEW.NUNOTAORIG);
        add_nunotaorig(:OLD.NUNOTAORIG);
    ELSIF DELETING THEN
        add_nunotaorig(:OLD.NUNOTAORIG);
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_status   CHAR(1);
    v_key   PLS_INTEGER;
BEGIN
    v_key := g_nunotaorig_set.FIRST;
    WHILE v_key IS NOT NULL LOOP
        BEGIN
            SELECT CASE WHEN EXISTS (SELECT 1 FROM TGFVAR WHERE NUNOTAORIG = v_key AND STATUSNOTA = 'L')
                        THEN 'F' ELSE 'A' END
              INTO v_status
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN v_status := 'A';
        END;

        UPDATE AD_TGSCTF
           SET NUNOTASIT = v_status
         WHERE NUNOTA = v_key;

        UPDATE TGFCAB
           SET AD_NUNOTASIT = v_status
         WHERE NUNOTA = v_key
            AND TIPMOV = 'P'
            AND CODTIPOPER <> 900;

        v_key := g_nunotaorig_set.NEXT(v_key);
    END LOOP;
END AFTER STATEMENT;

END TRG_CMP_TGFVAR_NUNOTASIT;