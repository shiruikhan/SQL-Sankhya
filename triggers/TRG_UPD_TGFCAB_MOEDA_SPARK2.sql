CREATE OR REPLACE TRIGGER TRG_UPD_TGFCAB_MOEDA_SPARK2
AFTER UPDATE OF VLRMOEDA ON TGFCAB
FOR EACH ROW
BEGIN
    -- 1. Verifica se a TOP é a correta e se o valor da moeda realmente mudou e é maior que zero
    IF :NEW.CODTIPOPER IN (1008, 1009) AND 
       NVL(:NEW.VLRMOEDA, 0) > 0 AND 
       NVL(:NEW.VLRMOEDA, 0) != NVL(:OLD.VLRMOEDA, 0) THEN
       
        -- 2. Atualiza todos os itens pertencentes a esta nota com a nova cotação
        UPDATE TGFITE
        SET VLRUNITMOE = ((NVL(VLRTOT, 0) - NVL(VLRDESC, 0)) / QTDNEG) / :NEW.VLRMOEDA,
            VLRTOTMOE  = (((NVL(VLRTOT, 0) - NVL(VLRDESC, 0)) / QTDNEG) / :NEW.VLRMOEDA) * QTDNEG
        WHERE NUNOTA = :NEW.NUNOTA
          AND NVL(QTDNEG, 0) > 0; -- Garante que não vai dividir por zero nos itens
          
    END IF;
END;