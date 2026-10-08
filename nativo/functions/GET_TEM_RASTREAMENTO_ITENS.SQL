/*==============================================================================
  Nome do Script : GET_TEM_RASTREAMENTO_ITENS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica ('S'/'N') se o produto/empresa/TOP exige rastreamento
                  de estoque (TGFRASTEMP/TGFEMP).
  Assinatura     : GET_TEM_RASTREAMENTO_ITENS (P_TIPMOV CHAR, P_CODEMP INT,
                  P_CODTIPOPER INT, P_DHTIPOPER DATE, P_CODPROD INT) RETURN
                  CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TEM_RASTREAMENTO_ITENS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TEM_RASTREAMENTO_ITENS (P_TIPMOV CHAR, P_CODEMP INT, P_CODTIPOPER INT, P_DHTIPOPER DATE, P_CODPROD INT)
RETURN CHAR
IS
  P_COUNT  NUMBER(10);
BEGIN
  P_COUNT := 0;
  SELECT COUNT(1) INTO P_COUNT
  FROM TGFRASTEMP;
  IF P_COUNT > 0 THEN
  		SELECT COUNT(1) INTO P_COUNT
	    FROM TGFEMP EMP
	       , TGFTOP TP
	       , TGFRASTEMP P
	    WHERE EMP.CODEMP = P_CODEMP 
	      AND (EMP.RASTRESTOQUE <> 'N')
	      AND TP.CODTIPOPER = P_CODTIPOPER
	      AND TP.DHALTER = P_DHTIPOPER
	      AND (((P_TIPMOV IN ('V', 'E')) AND TP.ATUALLIVFIS = 'S') OR
	           ((P_TIPMOV IN ('C', 'D')) AND TP.ATUALLIVFIS = 'E') OR
	           ((P_TIPMOV = 'T') AND (TP.ATUALLIVFIS = 'A'))
				OR (EMP.RASTRESTOQUE = 'E' AND GET_TSIPAR_LOGICO('DOCNFISCRASTST') = 'S' 
						AND (SNK_IS_IN_PARAMLIST('TOPENTNFISRAST', P_CODTIPOPER, 'S') = 'S' OR SNK_IS_IN_PARAMLIST('TOPSAINFISRAST', P_CODTIPOPER, 'S') = 'S')
					)
	          )      
	      AND P.CODPROD = P_CODPROD
	      AND P.CODEMP = P_CODEMP
	      AND NVL(P.TIPORASTR, '*') IN ('L', 'S', 'C', 'O'); 				   
 END IF;

  IF P_COUNT > 0 THEN
    RETURN 'S';
  ELSE
    RETURN 'N';
  END IF;
END;
