create or replace TRIGGER TRG_CMP_TGFVAR_NUNOTASIT
    FOR INSERT OR UPDATE OR DELETE ON TGFVAR
COMPOUND TRIGGER

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
            SELECT CASE WHEN EXISTS (SELECT 1 FROM TGFVAR WHERE NUNOTAORIG = v_key)
                        THEN 'F' ELSE 'A' END
              INTO v_status
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN v_status := 'A';
        END;

        UPDATE AD_TGSCTF
           SET NUNOTASIT = v_status
         WHERE NUNOTA = v_key;

        v_key := g_nunotaorig_set.NEXT(v_key);
    END LOOP;
END AFTER STATEMENT;

END TRG_CMP_TGFVAR_NUNOTASIT;