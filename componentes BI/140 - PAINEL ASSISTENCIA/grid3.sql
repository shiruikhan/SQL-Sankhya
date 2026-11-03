SELECT * 
FROM (SELECT V.AD_AGRUPADOR AS RFINTERNA,
			NVL(SUM(V.QTD),0) AS QTD,
			(CASE WHEN DEFEITO = 'ATT' THEN 'Necessidade de Atualização'
								WHEN V.DEFEITO = 'MU' THEN 'Mau Uso'
								WHEN V.DEFEITO = 'DC' THEN 'Desgaste (Cronológico)'
								WHEN V.DEFEITO = 'FAB' THEN 'Montagem (Fábrica)'
								WHEN V.DEFEITO = 'SD' THEN 'Sem Defeito' 
								ELSE 'Não identificado ainda' END) AS DEFEITO
		FROM (SELECT (SELECT P.AD_AGRUPADOR FROM TGFPRO P WHERE P.CODPROD = ASS.T_CODPROD OR ASS.T_CODPROD = P.AD_CODANTERIOR) AS AD_AGRUPADOR,	
							COUNT(ASS.T_CODPROD) AS QTD,
							ASS.DEFEITO
						FROM AD_TGFASS ASS
						WHERE ASS.DTRECEB <= :P_DTENTSAI.FIN 
							AND ASS.DTRECEB >= :P_DTENTSAI.INI
						GROUP BY ASS.T_CODPROD, ASS.DEFEITO) V
		GROUP BY V.AD_AGRUPADOR,
			V.DEFEITO) T
PIVOT (SUM(QTD) FOR DEFEITO IN (
		'Necessidade de Atualização' AS ATUALIZACAO,
		'Mau Uso' AS MAUUSO,
		'Desgaste (Cronológico)' AS CRONO,
		'Montagem (Fábrica)' AS FABR,
		'Sem Defeito' AS SEMDEF,
		'Não identificado ainda' AS NDA))
