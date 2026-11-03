SELECT AD_CODANTERIOR, CODPROD, DESCRPROD, G.CODGRUPOPROD, DECODE(USOPROD,'M','Matéria Prima','C','Consumo','S','Serviço','V','Venda Fabricação',USOPROD) AS USADOCOMO, G.DESCRGRUPOPROD
FROM TGFPRO  P INNER JOIN TGFGRU G ON (P.CODGRUPOPROD = G.CODGRUPOPROD) WHERE TRANSLATE(DESCRPROD,'`}a~xÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÏÖÑÝåáçéíóúàèìòùâêîôûãõëüïöñýÿ"',
                                                'SZszYACEIOUAEIOUAEIOUAOEUIONYaaceiouaeiouaeiouaoeuionyy') LIKE '%'||:A_DESCRPROD||'%'
ORDER BY 3
