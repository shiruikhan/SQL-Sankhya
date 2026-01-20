CREATE OR REPLACE TRIGGER TRG_NUMCHEQUE_TGFECQ_SPARK
AFTER INSERT OR UPDATE ON TGFECQ
FOR EACH ROW
DECLARE
    V_NUMCHEQUE   TGFCHQ.NUMCHEQUE%TYPE;
    V_NUBCO       NUMBER;
    V_NUMTRANSF   NUMBER;
BEGIN
    -- 1. Captura o NUMCHEQUE da tabela vinculada
    SELECT NUMCHEQUE INTO V_NUMCHEQUE
    FROM TGFCHQ
    WHERE NUCHQ = :NEW.NUCHQ;

    -- 2. Extrai os parâmetros do campo JSON (DETALHE)
    V_NUBCO     := TO_NUMBER(JSON_VALUE(:NEW.DETALHE, '$.evento.financeiro.NUBCO'));
    V_NUMTRANSF := TO_NUMBER(JSON_VALUE(:NEW.DETALHE, '$.evento.financeiro.NUMTRANSF'));

    -- 3. Update pelo NUBCO (Movimentação direta)
    IF V_NUBCO IS NOT NULL THEN
        UPDATE TGFMBC
        SET NUMDOC = V_NUMCHEQUE
        WHERE NUBCO = V_NUBCO;
    END IF;

    -- 4. Update pelo NUMTRANSF (Movimentação de transferência/origem)
    IF V_NUMTRANSF IS NOT NULL THEN
        UPDATE TGFMBC
        SET NUMDOC = V_NUMCHEQUE
        WHERE NUMTRANSF = V_NUMTRANSF;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- Evita erro se o cheque não for encontrado
    WHEN OTHERS THEN
        NULL; -- Evita que falhas no log travem a operação principal
END;