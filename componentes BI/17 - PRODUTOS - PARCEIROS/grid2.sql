SELECT PRO.CODPROD, PRO.DESCRPROD, PRO.CODVOL, PRO.TEMIPICOMPRA, PRO.TEMIPIVENDA, PRO.CODIPI,
       PRO.GRUPOPIS, PRO.GRUPOCOFINS, PRO.NCM,
       (SELECT OPCAO
          FROM TDDOPC OPC
         WHERE OPC.VALOR = PRO.USOPROD
           AND NUCAMPO = (SELECT NUCAMPO
                            FROM TDDCAM
                           WHERE NOMETAB = 'TGFPRO'
                             AND NOMECAMPO = 'USOPROD')) AS USOPROD,
       (SELECT OPCAO
          FROM TDDOPC OPC
         WHERE OPC.VALOR = PRO.TIPSUBST
           AND NUCAMPO = (SELECT NUCAMPO
                            FROM TDDCAM
                           WHERE NOMETAB = 'TGFPRO'
                             AND NOMECAMPO = 'TIPSUBST')) AS TIPSUBST,
       CASE WHEN (PRO.TEMIPICOMPRA = 'S' OR PRO.TEMIPIVENDA = 'S' AND PRO.CODIPI = 0) THEN '/Produto configurado com IPI porém não foi definida a alíquota' END
   	   || CASE WHEN (PRO.TIPSUBST IS NULL) THEN '/Não foi configurado o Tipo de Substituição Tributária' END
   	   || CASE WHEN (PRO.TIPSUBST <> 'N' AND GRUPOICMS IS NULL) THEN '/Produto definido como ST porém não foi definido regra de calculo' END
   	   || CASE WHEN (PRO.GRUPOPIS = 'TODOS') THEN '/Grupo de PIS não pode estar definido como TODOS' END
   	   || CASE WHEN (PRO.GRUPOCOFINS = 'TODOS') THEN '/Grupo de COFINS não pode estar definido como TODOS' END
   	   || CASE WHEN PRO.CODGRUPOPROD = 0 THEN '/Não definido Grupo de Produtos/Serviços' END
   	   || CASE WHEN PRO.NCM IS NULL THEN '/Sem NCM' END
       AS PROBLEMAS
  FROM TGFPRO PRO
 WHERE PRO.CODPROD <> 0
   AND ((PRO.USOPROD IN ('D', 'R', 'V') AND :A_TIPPROD = 'V')
        OR (PRO.USOPROD = 'C' AND :A_TIPROD = 'C')
        OR (PRO.USOPROD = 'I' AND :A_TIPROD = 'I')
        OR (PRO.USOPROD = 'S' AND :A_TIPROD = 'S')
        OR (PRO.USOPROD IN ('1', '2', 'E', 'O', 'P', 'M') AND :A_TIPROD = 'M')
	   )
   AND ((PRO.TEMIPICOMPRA = 'S' OR PRO.TEMIPIVENDA = 'S' AND PRO.CODIPI = 0)
   	    OR (PRO.TIPSUBST IS NULL)
   	    OR (PRO.TIPSUBST <> 'N' AND GRUPOICMS IS NULL)
   	    OR (PRO.GRUPOPIS = 'TODOS')
   	    OR (PRO.GRUPOCOFINS = 'TODOS')
        OR (PRO.CODGRUPOPROD = 0)
        OR (PRO.USOPROD NOT IN ('S','E') AND PRO.NCM IS NULL)
	   )
