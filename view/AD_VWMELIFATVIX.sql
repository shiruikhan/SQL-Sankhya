    CREATE OR REPLACE VIEW AD_VWMELIFATVIX AS SELECT
        0 AS ID					,
        
				C.NUMNOTA				,
        
				C.NUNOTA				,
        
				C.SERIENOTA				,
        
				C.DTFATUR				,
        
				C.STATUSNFE				,
        
				C.AD_PEDIDOMKTPLACE		,
        
				c.AD_MELISHIPID AS AD_SHIPID			,
        
				C.CHAVENFE				,
        
				C.CODVEND				,
        
				C.CODEMP				,
        
				N.XMLENVCLI	AS NOTAXML
FROM TGFCAB C 
    INNER JOIN
        TGFNFE N 
            ON C.NUNOTA = N.NUNOTA
WHERE	C.TIPMOV	= 'V' 
            AND C.CODVEND	= 5 
			--AND C.CODEMP = 1
            AND C.AD_PEDIDOMKTPLACE IS NOT NULL
AND C.STATUSNFE = 'A' 
            AND C.DTFATUR >= SYSDATE-7
AND C.NUNOTA NOT IN (
                SELECT
                    CODATA 
                     
            FROM
                TSIATA
                     
            WHERE
                DESCRICAO  like '%Etiqueta%' 
                     
                AND TIPO ='N' 
        );