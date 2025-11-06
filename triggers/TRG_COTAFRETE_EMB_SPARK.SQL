create or replace TRIGGER TRG_COTAFRETE_EMB_SPARK
AFTER INSERT OR UPDATE ON AD_TGSCTF
FOR EACH ROW
DECLARE
    -- Cursor: codprodemb e quantidade de caixas distintas para a nota
    CURSOR C_EMB IS
        SELECT CODPRODEMB,
               COUNT(DISTINCT IDCAIXA) AS QTD_CAIXAS
          FROM AD_EMBPED
         WHERE NUNOTA = :NEW.NUNOTA
         GROUP BY CODPRODEMB;

    -- Dimensões obtidas de TGFPRO
    V_ESPESSURA TGFPRO.ESPESSURA%TYPE;
    V_ALTURA    TGFPRO.ALTURA%TYPE;
    V_LARGURA   TGFPRO.LARGURA%TYPE;

    -- Controle de índice incremental de embalagem
    V_NEXT_IDEMB NUMBER;
    -- Verificador de existência de registros em AD_EMBPED
    V_EXISTS NUMBER;

BEGIN
    -- Não insere nada caso não haja informações em AD_EMBPED para a nota
    BEGIN
        SELECT 1 INTO V_EXISTS
          FROM AD_EMBPED
         WHERE NUNOTA = :NEW.NUNOTA
           AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN; -- Sai do trigger sem inserir
    END;

    -- Em caso de UPDATE, limpa embalagem existente para evitar duplicatas
    IF UPDATING THEN
        DELETE FROM AD_TGSLCB
         WHERE NUCTF = :NEW.NUCTF;
    END IF;

    -- Define o próximo índice incremental (por NUCTF)
    SELECT NVL(MAX(IDEMB), 0) + 1
      INTO V_NEXT_IDEMB
      FROM AD_TGSLCB
     WHERE NUCTF = :NEW.NUCTF;

    -- Percorre produtos de embalagem da nota
    FOR R IN C_EMB LOOP
        -- Busca dimensões no cadastro de produtos
        BEGIN
            SELECT ALTURA / 100, LARGURA / 100, ESPESSURA / 100
              INTO V_ALTURA, V_LARGURA, V_ESPESSURA
              FROM TGFPRO
             WHERE CODPROD = R.CODPRODEMB;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ALTURA := NULL;
                V_LARGURA := NULL;
                V_ESPESSURA := NULL;
        END;

        -- Caso a embalagem (CODPRODEMB) tenha medidas, insere uma linha por embalagem
        IF V_ALTURA IS NOT NULL AND V_LARGURA IS NOT NULL AND V_ESPESSURA IS NOT NULL THEN
            INSERT INTO AD_TGSLCB (
                NUCTF,
                IDEMB,
                COMPRIMENTO,
                ALTURA,
                LARGURA,
                VOLTOT
            ) VALUES (
                :NEW.NUCTF,
                V_NEXT_IDEMB,
                V_ESPESSURA,
                V_ALTURA,
                V_LARGURA,
                R.QTD_CAIXAS
            );

            -- Incrementa o índice de embalagem para o próximo CODPRODEMB
            V_NEXT_IDEMB := V_NEXT_IDEMB + 1;
        ELSE
            -- Fallback: usar medidas do produto (CODPROD) quando CODPRODEMB não tiver medidas
            FOR P IN (
                SELECT CODPROD,
                       COUNT(DISTINCT IDCAIXA) AS QTD_CAIXAS
                  FROM AD_EMBPED
                 WHERE NUNOTA = :NEW.NUNOTA
                   AND (CODPRODEMB = R.CODPRODEMB OR R.CODPRODEMB IS NULL)
                 GROUP BY CODPROD
            ) LOOP
                BEGIN
                    SELECT ALTURA / 100, LARGURA / 100, ESPESSURA / 100
                      INTO V_ALTURA, V_LARGURA, V_ESPESSURA
                      FROM TGFPRO
                     WHERE CODPROD = P.CODPROD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_ALTURA := NULL;
                        V_LARGURA := NULL;
                        V_ESPESSURA := NULL;
                END;

                IF V_ALTURA IS NOT NULL AND V_LARGURA IS NOT NULL AND V_ESPESSURA IS NOT NULL THEN
                    INSERT INTO AD_TGSLCB (
                        NUCTF,
                        IDEMB,
                        COMPRIMENTO,
                        ALTURA,
                        LARGURA,
                        VOLTOT
                    ) VALUES (
                        :NEW.NUCTF,
                        V_NEXT_IDEMB,
                        V_ESPESSURA,
                        V_ALTURA,
                        V_LARGURA,
                        P.QTD_CAIXAS
                    );

                    -- Incrementa o índice para cada produto distinto
                    V_NEXT_IDEMB := V_NEXT_IDEMB + 1;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
END;