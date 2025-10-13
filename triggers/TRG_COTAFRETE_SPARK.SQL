create or replace TRIGGER TRG_COTAFRETE_SPARK
BEFORE INSERT OR UPDATE OR DELETE ON TGFCAB 
FOR EACH ROW
DECLARE
  V_NUCTF AD_TGSCTF.NUCTF%TYPE;
  V_DOCORIG TSIEMP.CGC%TYPE;
  V_DOCDEST TGFPAR.CGC_CPF%TYPE;
  V_CEPORIG TSIEMP.CEP%TYPE;
  V_CEPDEST TGFPAR.CEP%TYPE;
  V_NUNOTASIT AD_TGSCTF.NUNOTASIT%TYPE;
  V_CNT NUMBER;

BEGIN  
  IF INSERTING THEN
    IF :NEW.TIPMOV = 'P' AND :NEW.STATUSNOTA = 'A' AND :NEW.CODPARCDEST = 0 AND :NEW.CIF_FOB = 'C' AND :NEW.CODPARCTRANSP = 1085 THEN

        BEGIN
            SELECT NVL(MAX(NUCTF), 0) + 1 INTO V_NUCTF FROM AD_TGSCTF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_NUCTF := 1;
        END;

        BEGIN
            SELECT CEP, CGC INTO V_CEPORIG, V_DOCORIG FROM TSIEMP WHERE CODEMP = :NEW.CODEMP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CEPORIG := '38190000';
                V_DOCORIG := '11849626000193';
        END;     

        BEGIN
            SELECT CEP, CGC_CPF INTO V_CEPDEST, V_DOCDEST FROM TGFPAR WHERE CODPARC = :NEW.CODPARC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CEPDEST := NULL;
                V_DOCDEST := NULL;
        END;

        -- Calcula o status NUNOTASIT com base em TGFVAR (EXISTS para melhor desempenho)
        BEGIN
            SELECT CASE WHEN EXISTS (SELECT 1 FROM TGFVAR WHERE NUNOTAORIG = :NEW.NUNOTA)
                        THEN 'F' ELSE 'A' END
              INTO V_NUNOTASIT
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN V_NUNOTASIT := 'A';
        END;

      INSERT INTO AD_TGSCTF (
          NUCTF,
          DOCORIG,
          DOCDEST,
          APIDEST,
          MODAL,
          TIPFRETE,
          DOCCONSIG,
          CEPORIG,
          CEPDEST,
          VLRTOT,
          PESOTOT,
          VOLTOT,
          NUNOTA,
          NUNOTASIT,
          VLRFRETEPED
      ) VALUES (
          V_NUCTF,
          V_DOCORIG,
          V_DOCDEST,
          'B',
          'R',
          1,
          NULL,
          V_CEPORIG,
          V_CEPDEST,
          :NEW.VLRNOTA,
          :NEW.PESOBRUTO,
          NVL(:NEW.QTDVOL, 0),
          :NEW.NUNOTA,
          V_NUNOTASIT,
          :NEW.VLRFRETE
      );
    END IF;
  ELSIF UPDATING THEN
    -- Detecta alterações relevantes e mantém a integridade reinserindo os dados
    IF (NVL(:NEW.CODPARC, -1) <> NVL(:OLD.CODPARC, -1)
        OR NVL(:NEW.CODEMP, -1) <> NVL(:OLD.CODEMP, -1)
        OR NVL(:NEW.VLRNOTA, 0) <> NVL(:OLD.VLRNOTA, 0)
        OR NVL(:NEW.PESOBRUTO, 0) <> NVL(:OLD.PESOBRUTO, 0)
        OR NVL(:NEW.QTDVOL, 0) <> NVL(:OLD.QTDVOL, 0)
        OR NVL(:NEW.VLRFRETE,0) = 0) THEN

      -- Caso o NOVO registro esteja dentro do filtro, limpa e reinsere
      IF :NEW.TIPMOV = 'P' AND :NEW.STATUSNOTA = 'A' AND :NEW.CODPARCDEST = 0 AND :NEW.CIF_FOB = 'C' AND :NEW.CODPARCTRANSP = 1085 THEN 
        DELETE FROM AD_TGSLCB WHERE NUCTF = (SELECT DISTINCT NUCTF FROM AD_TGSCTF WHERE NUNOTA IN (:OLD.NUNOTA, :NEW.NUNOTA));
        DELETE FROM AD_TGSCTF WHERE NUNOTA IN (:OLD.NUNOTA, :NEW.NUNOTA);        

        BEGIN
            SELECT NVL(MAX(NUCTF), 0) + 1 INTO V_NUCTF FROM AD_TGSCTF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN V_NUCTF := 1;
        END;

        BEGIN
            SELECT CEP, CGC INTO V_CEPORIG, V_DOCORIG FROM TSIEMP WHERE CODEMP = :NEW.CODEMP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CEPORIG := '38190000';
                V_DOCORIG := '11849626000193';
        END;     

        BEGIN
            SELECT CEP, CGC_CPF INTO V_CEPDEST, V_DOCDEST FROM TGFPAR WHERE CODPARC = :NEW.CODPARC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_CEPDEST := NULL;
                V_DOCDEST := NULL;
        END;

        -- Calcula o status NUNOTASIT com base em TGFVAR (EXISTS para melhor desempenho)
        BEGIN
            SELECT CASE WHEN EXISTS (SELECT 1 FROM TGFVAR WHERE NUNOTAORIG = :NEW.NUNOTA)
                        THEN 'F' ELSE 'A' END
              INTO V_NUNOTASIT
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN V_NUNOTASIT := 'A';
        END;

        INSERT INTO AD_TGSCTF (
            NUCTF,
            DOCORIG,
            DOCDEST,
            APIDEST,
            MODAL,
            TIPFRETE,
            DOCCONSIG,
            CEPORIG,
            CEPDEST,
            VLRTOT,
            PESOTOT,
            VOLTOT,
            NUNOTA,
            NUNOTASIT,
            VLRFRETEPED
        ) VALUES (
            V_NUCTF,
            V_DOCORIG,
            V_DOCDEST,
            'B',
            'R',
            1,
            NULL,
            V_CEPORIG,
            V_CEPDEST,
            :NEW.VLRNOTA,
            :NEW.PESOBRUTO,
            NVL(:NEW.QTDVOL, 0),
            :NEW.NUNOTA,
            V_NUNOTASIT,
            :NEW.VLRFRETE
        );
      -- Caso o NOVO registro não esteja dentro do filtro, mas o ANTIGO estava, limpa o antigo para evitar dados obsoletos
      ELSIF :OLD.TIPMOV = 'P' AND :OLD.STATUSNOTA = 'A' AND :OLD.CODPARCDEST = 0 AND :OLD.CIF_FOB = 'C' AND :OLD.CODPARCTRANSP = 1085 THEN       
        DELETE FROM AD_TGSLCB WHERE NUCTF = (SELECT DISTINCT NUCTF FROM AD_TGSCTF WHERE NUNOTA IN (:OLD.NUNOTA, :NEW.NUNOTA));
        DELETE FROM AD_TGSCTF WHERE NUNOTA = :OLD.NUNOTA;
      END IF;
    END IF;
  ELSIF DELETING THEN
    -- Mantém consistência ao remover a nota apenas quando a nota atende ao filtro
    IF :OLD.TIPMOV = 'P' AND :OLD.STATUSNOTA = 'A' AND :OLD.CODPARCDEST = 0 AND :OLD.CIF_FOB = 'C' THEN      
      DELETE FROM AD_TGSLCB WHERE NUCTF = (SELECT DISTINCT NUCTF FROM AD_TGSCTF WHERE NUNOTA IN (:OLD.NUNOTA, :NEW.NUNOTA));
      DELETE FROM AD_TGSCTF WHERE NUNOTA = :OLD.NUNOTA;
    END IF;
  END IF;
END;