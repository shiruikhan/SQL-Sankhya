create or replace PROCEDURE STP_GERARVOLUMES_SPARK (
    P_NUNOTA IN NUMBER
) AS
    V_IDCAIXA       NUMBER;
    V_SEQ           NUMBER := 0;
    V_PESO_TOTAL    NUMBER := 0;
    V_EMBPADRAO     CONSTANT NUMBER := 546117;
	V_EMBPADRAO1    CONSTANT NUMBER := 546116;
    V_MAX_PESO      CONSTANT NUMBER := 25;
    V_PED           INT;
	V_PESO_EMB      NUMBER := 0;
    V_MAXSEQ        INT;
    V_CODPROD       NUMBER;
/*************************************************************************
Autor: Lucas Gabriel
Data: 27/05/2025
Obejtivo:Gerar a sugestão de volumetria para cotação do frete.
*************************************************************************/	
BEGIN
    ---------------------------------------------------------------------------
    -- 0. Produtos que vão em sua própria embalagem e possuem QTDNEG = 1
    ---------------------------------------------------------------------------
    SELECT SUM(QTDNEG)
		INTO V_PED FROM TGFITE 
	WHERE NUNOTA = P_NUNOTA;

    IF V_PED = 1 
		THEN
        SELECT MAX(SEQ) INTO V_MAXSEQ 
			FROM AD_EMBPED 
		WHERE NUNOTA = P_NUNOTA;
        IF V_MAXSEQ IS NULL 
		THEN V_MAXSEQ := 0; END IF;

        SELECT CODPROD 
			INTO V_CODPROD 
		FROM TGFITE 
		WHERE NUNOTA = P_NUNOTA;
		
	    DELETE FROM AD_EMBPED 
		WHERE NUNOTA = P_NUNOTA
		 AND TIPO <> 'A';
		
        INSERT INTO AD_EMBPED ( NUNOTA
							  , SEQ
							  , CODPROD
							  , PESOBRUTO
							  , M3
							  , CODPRODEMB
							  , IDCAIXA
							  , TIPO
							  , QTDNEG
							  )
        SELECT  ITE.NUNOTA
               ,V_MAXSEQ + 1
               ,ITE.CODPROD
               ,PRO.PESOBRUTO
               ,PRO.M3
               ,PRO.AD_CODPRODEMBIND
               ,1
               ,'E'
               ,1
			   
          FROM TGFITE ITE
          INNER JOIN TGFPRO PRO 
				ON ITE.CODPROD = PRO.CODPROD
         WHERE ITE.NUNOTA = P_NUNOTA
           AND ITE.CODPROD = V_CODPROD;
        COMMIT;
		
	BEGIN
        UPDATE TGFCAB
           SET QTDVOL = (
               SELECT COUNT(DISTINCT IDCAIXA)
                 FROM AD_EMBPED
                WHERE NUNOTA = P_NUNOTA
                  AND IDCAIXA IS NOT NULL
           )
         WHERE NUNOTA = P_NUNOTA;

        SELECT NVL(SUM(PESOBRUTO), 0)
          INTO V_PESO_TOTAL
          FROM AD_EMBPED
         WHERE NUNOTA = P_NUNOTA;
		 
		SELECT
			SUM(PRO.PESOBRUTO * COUNT(DISTINCT IDCAIXA))
		 INTO V_PESO_EMB
		FROM AD_EMBPED V, TGFPRO PRO, TGFPRO PROD
		WHERE V.CODPRODEMB = PRO.CODPROD
		AND V.CODPROD = PROD.CODPROD
		AND V.NUNOTA = P_NUNOTA
		GROUP BY PRO.CODPROD , PRO.DESCRPROD, PRO.M3, PRO.PESOBRUTO;		 
		 

        UPDATE TGFCAB
           SET PESOBRUTO = ROUND(V_PESO_TOTAL + V_PESO_EMB, 2),
               PESO = ROUND(V_PESO_TOTAL, 2)
         WHERE NUNOTA = P_NUNOTA;
    END;

    COMMIT;
	RETURN;	
    END IF;
	/*
    ---------------------------------------------------------------------------
    -- 0. Produtos que que no total são duas caixas, e sempre são embalados em uma caixa A
    ---------------------------------------------------------------------------
	
	IF V_PED <= 5
	THEN 
		SELECT MAX(SEQ) 
			INTO V_MAXSEQ 
		FROM AD_EMBPED 
		WHERE NUNOTA = P_NUNOTA;
		
	IF V_MAXSEQ IS NULL 
		THEN V_MAXSEQ := 0; 
	END IF;
	
	DELETE FROM AD_EMBPED 
	WHERE NUNOTA = P_NUNOTA
	AND TIPO <> 'A';
	
	INSERT INTO AD_EMBPED ( NUNOTA
						, SEQ
						, CODPROD
						, PESOBRUTO
						, M3
						, CODPRODEMB
						, IDCAIXA
						, TIPO
						, QTDNEG
						)
	SELECT  
		 ITE.NUNOTA
		,ITE.SEQUENCIA
		,ITE.CODPROD
		,PRO.PESOBRUTO * ITE.QTDNEG
		,PRO.M3
		,V_EMBPADRAO1
		,1
		,'E'
		,1
		
	FROM TGFITE ITE
	INNER JOIN TGFPRO PRO 
			ON ITE.CODPROD = PRO.CODPROD
	WHERE ITE.NUNOTA = P_NUNOTA;
	COMMIT;
		
	BEGIN
        UPDATE TGFCAB
           SET QTDVOL = (
               SELECT COUNT(DISTINCT IDCAIXA)
                 FROM AD_EMBPED
                WHERE NUNOTA = P_NUNOTA
                  AND IDCAIXA IS NOT NULL
           )
         WHERE NUNOTA = P_NUNOTA;

        SELECT NVL(SUM(PESOBRUTO), 0)
          INTO V_PESO_TOTAL
          FROM AD_EMBPED
         WHERE NUNOTA = P_NUNOTA;
		 
		SELECT
			SUM(PRO.PESOBRUTO * COUNT(DISTINCT IDCAIXA))
		 INTO V_PESO_EMB
		FROM AD_EMBPED V, TGFPRO PRO, TGFPRO PROD
		WHERE V.CODPRODEMB = PRO.CODPROD
		AND V.CODPROD = PROD.CODPROD
		AND V.NUNOTA = P_NUNOTA
		GROUP BY PRO.CODPROD , PRO.DESCRPROD, PRO.M3, PRO.PESOBRUTO;		 
		 

        UPDATE TGFCAB
           SET PESOBRUTO = ROUND(V_PESO_TOTAL + V_PESO_EMB, 2),
               PESO = ROUND(V_PESO_TOTAL, 2)
         WHERE NUNOTA = P_NUNOTA;
    END;

    COMMIT;
	RETURN;	
	END IF;	
	*/
    ---------------------------------------------------------------------------
    -- 1. Gera caixas completas e sobras por produto
    ---------------------------------------------------------------------------
    DELETE FROM AD_EMBPED 
    WHERE NUNOTA = P_NUNOTA
	AND TIPO <> 'A';

    FOR R_ITENS IN (
					SELECT  ITE.CODPROD
						   ,ITE.QTDNEG
						   ,PRO.AD_QTDEMB
						   ,PRO.AD_CODPRODEMB
						   ,PRO.PESOBRUTO
						   ,PRO.M3
						   ,ITE.SEQUENCIA
						
					FROM TGFITE ITE
						INNER JOIN TGFPRO PRO 
							ON PRO.CODPROD = ITE.CODPROD
					WHERE ITE.NUNOTA = P_NUNOTA
					  AND PRO.AD_CODPRODEMB IS NOT NULL
					  AND PRO.AD_QTDEMB IS NOT NULL
					ORDER BY ITE.SEQUENCIA
    ) LOOP
        DECLARE
            V_EMB_COMPLETAS NUMBER;
            V_SOBRA         NUMBER;
        BEGIN
            V_EMB_COMPLETAS := FLOOR(R_ITENS.QTDNEG / R_ITENS.AD_QTDEMB);
            V_SOBRA         := MOD(R_ITENS.QTDNEG, R_ITENS.AD_QTDEMB);

            FOR I IN 1 .. V_EMB_COMPLETAS 
				LOOP
                V_SEQ := V_SEQ + 1;
                INSERT INTO AD_EMBPED ( NUNOTA
									  , SEQ
									  , CODPROD
									  , PESOBRUTO
									  , M3
									  , CODPRODEMB
									  , IDCAIXA
									  , TIPO
									  , QTDNEG
									  )
							VALUES (  P_NUNOTA
									 , V_SEQ
									 , R_ITENS.CODPROD
									 , R_ITENS.PESOBRUTO * R_ITENS.AD_QTDEMB
									 , R_ITENS.M3 * R_ITENS.AD_QTDEMB
									 , R_ITENS.AD_CODPRODEMB
									 , V_SEQ, 'E', R_ITENS.AD_QTDEMB
									 );
            END LOOP;

            IF V_SOBRA > 0 THEN
                V_SEQ := V_SEQ + 1;
				
                INSERT INTO AD_EMBPED ( NUNOTA
									  , SEQ
									  , CODPROD
									  , PESOBRUTO
									  , M3
									  , CODPRODEMB
									  , IDCAIXA
									  , TIPO
									  , QTDNEG
									  )
							VALUES ( P_NUNOTA
								   , V_SEQ
								   , R_ITENS.CODPROD
								   , R_ITENS.PESOBRUTO * V_SOBRA
								   , R_ITENS.M3 * V_SOBRA
								   , NULL
								   , NULL
								   , 'S'
								   , V_SOBRA
									);
            END IF;
        END;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 2. Agrupa sobras com mesma embalagem para formar novas embalagens completas
    ---------------------------------------------------------------------------
    DECLARE
        CURSOR C_SOBRAS IS
            SELECT  P.AD_CODPRODEMB
                   ,P.AD_QTDEMB
                   ,SUM(E.QTDNEG) AS TOTAL_SOBRA
                   ,SUM(E.PESOBRUTO) AS TOTAL_PESO
				   
              FROM AD_EMBPED E
               INNER JOIN TGFPRO P
					ON P.CODPROD = E.CODPROD
             WHERE E.NUNOTA = P_NUNOTA
               AND E.TIPO = 'S'
               AND E.CODPRODEMB IS NULL
               AND P.AD_CODPRODEMB IS NOT NULL
               AND P.AD_QTDEMB IS NOT NULL
             GROUP BY P.AD_CODPRODEMB, P.AD_QTDEMB;

        V_TOTAL       NUMBER;
        V_SOBRA       NUMBER;
        V_QTDNAEMB    NUMBER;
        V_PESO        NUMBER;
        V_M3          NUMBER;
		
    BEGIN
        FOR R_EMB 
			IN C_SOBRAS
			LOOP
            DELETE FROM AD_EMBPED
             WHERE NUNOTA = P_NUNOTA
               AND CODPRODEMB IS NULL
               AND CODPROD IN (
								SELECT CODPROD 
								  FROM TGFPRO 
								WHERE AD_CODPRODEMB = R_EMB.AD_CODPRODEMB
							   )
               AND TIPO = 'S';

            V_TOTAL := FLOOR(R_EMB.TOTAL_SOBRA / R_EMB.AD_QTDEMB);
            V_SOBRA := MOD(R_EMB.TOTAL_SOBRA, R_EMB.AD_QTDEMB);
            V_QTDNAEMB := NULL;

            IF V_SOBRA >= (R_EMB.AD_QTDEMB - 1)
				THEN
                V_TOTAL := V_TOTAL + 1;
                V_QTDNAEMB := V_SOBRA;
                V_SOBRA := 0;
            END IF;

            SELECT MIN(CODPROD) 
				INTO V_CODPROD 
			FROM TGFPRO 
			WHERE AD_CODPRODEMB = R_EMB.AD_CODPRODEMB;
			
            SELECT AVG(M3) 
				INTO V_M3	
			FROM TGFPRO 
			WHERE AD_CODPRODEMB = R_EMB.AD_CODPRODEMB;

            FOR I IN 1 .. V_TOTAL - CASE WHEN V_QTDNAEMB IS NOT NULL THEN 1 ELSE 0 END LOOP
                V_SEQ := V_SEQ + 1;
                V_PESO := (R_EMB.TOTAL_PESO / R_EMB.TOTAL_SOBRA) * R_EMB.AD_QTDEMB;
                INSERT INTO AD_EMBPED ( NUNOTA
									  , SEQ
									  , CODPROD
									  , PESOBRUTO
									  , M3
									  , CODPRODEMB
									  , IDCAIXA
									  , TIPO
									  , QTDNEG
									  ) 
									  
							  VALUES ( P_NUNOTA
									 , V_SEQ
									 , V_CODPROD
									 , V_PESO
									 , V_M3 * R_EMB.AD_QTDEMB
									 , R_EMB.AD_CODPRODEMB
									 , V_SEQ
									 , 'E'
									 , R_EMB.AD_QTDEMB
									);
            END LOOP;

            IF V_QTDNAEMB IS NOT NULL 
				THEN
                V_SEQ := V_SEQ + 1;
                V_PESO := (R_EMB.TOTAL_PESO / R_EMB.TOTAL_SOBRA) * V_QTDNAEMB;
				
                INSERT INTO AD_EMBPED ( NUNOTA
									  , SEQ
									  , CODPROD
									  , PESOBRUTO
									  , M3
									  , CODPRODEMB
									  , IDCAIXA
									  , TIPO
									  , QTDNEG
									  ) 
									  
							 VALUES ( P_NUNOTA
									, V_SEQ
									, V_CODPROD
									, V_PESO
									, V_M3 * V_QTDNAEMB
									, R_EMB.AD_CODPRODEMB
									, V_SEQ
									, 'E'
									, V_QTDNAEMB
									);
            END IF;

            IF V_SOBRA > 0 THEN
                V_SEQ := V_SEQ + 1;
                V_PESO := (R_EMB.TOTAL_PESO / R_EMB.TOTAL_SOBRA) * V_SOBRA;
                INSERT INTO AD_EMBPED ( NUNOTA
									  , SEQ
									  , CODPROD
									  , PESOBRUTO
									  , M3
									  , CODPRODEMB
									  , IDCAIXA
									  , TIPO
									  , QTDNEG
									  ) 
							VALUES ( P_NUNOTA
								  , V_SEQ
								  , V_CODPROD
								  , V_PESO
								  , V_M3 * V_SOBRA
								  , NULL
								  , NULL
								  , 'S'
								  , V_SOBRA
									);
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    -- 3. Agrupa sobras restantes em caixas padrão respeitando o peso máximo
    ---------------------------------------------------------------------------
    DECLARE
        V_PESO_ATUAL NUMBER := 0;
        V_M3_ATUAL   NUMBER := 0;
    BEGIN
        SELECT NVL(MAX(IDCAIXA), 0) + 1
          INTO V_IDCAIXA
          FROM AD_EMBPED
         WHERE NUNOTA = P_NUNOTA;

        FOR R_SOBRA IN (
            SELECT SEQ
				  , CODPROD
				  , PESOBRUTO
				  , M3
              FROM AD_EMBPED
             WHERE NUNOTA = P_NUNOTA
               AND CODPRODEMB IS NULL
             ORDER BY PESOBRUTO DESC, M3 DESC
        ) LOOP
            IF (V_PESO_ATUAL + R_SOBRA.PESOBRUTO) > V_MAX_PESO 
				THEN
                V_IDCAIXA 	 := V_IDCAIXA + 1;
                V_PESO_ATUAL := 0;
                V_M3_ATUAL 	 := 0;
            END IF;

            UPDATE AD_EMBPED
               SET CODPRODEMB = V_EMBPADRAO1,
                   IDCAIXA = V_IDCAIXA,
                   TIPO = 'S'
             WHERE NUNOTA = P_NUNOTA
               AND SEQ = R_SOBRA.SEQ;

            V_PESO_ATUAL := V_PESO_ATUAL + R_SOBRA.PESOBRUTO;
            V_M3_ATUAL   := V_M3_ATUAL + R_SOBRA.M3;
        END LOOP;
    END;

    ---------------------------------------------------------------------------
    -- 4. Atualiza cabeçalho da nota
    ---------------------------------------------------------------------------
    BEGIN
        UPDATE TGFCAB
           SET QTDVOL = (
               SELECT COUNT(DISTINCT IDCAIXA)
                 FROM AD_EMBPED
                WHERE NUNOTA = P_NUNOTA
                  AND IDCAIXA IS NOT NULL
           )
         WHERE NUNOTA = P_NUNOTA;

        SELECT NVL(SUM(PESOBRUTO), 0)
          INTO V_PESO_TOTAL
          FROM AD_EMBPED
         WHERE NUNOTA = P_NUNOTA;
		 
		SELECT
			SUM(PRO.PESOBRUTO * COUNT(DISTINCT IDCAIXA))
		 INTO V_PESO_EMB
		FROM AD_EMBPED V, TGFPRO PRO, TGFPRO PROD
		WHERE V.CODPRODEMB = PRO.CODPROD
		AND V.CODPROD = PROD.CODPROD
		AND V.NUNOTA = P_NUNOTA
		GROUP BY PRO.CODPROD , PRO.DESCRPROD, PRO.M3, PRO.PESOBRUTO;		 
		 

        UPDATE TGFCAB
           SET PESOBRUTO = ROUND(V_PESO_TOTAL + V_PESO_EMB, 2),
               PESO = ROUND(V_PESO_TOTAL, 2)
         WHERE NUNOTA = P_NUNOTA;
    END;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Erro ao gerar volumes para nota ' || P_NUNOTA || 
                              '. Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || 
                              ' Erro: ' || SQLERRM);
END;