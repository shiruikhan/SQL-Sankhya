/*==============================================================================
  Nome do Script : FN_GET_ULTIMO_CUSTO_SPARK1
  Tipo           : Function (customizacao -- fora do padrao _SPARK de autoria interna)
  Descricao      : Busca o ultimo custo realizado da planilha de custos
                  (AD_TGSCIT/AD_TGSCUS) com DTREF <= data informada e CUSTOREL
                  > 0; P_TIPO escolhe o componente: 0 custo MP fiscal, 1 custo
                  MP real, 2 mao de obra, 3 ICMS, 4 IPI, 5 frete fixo. Retorna
                  0 se nao houver registro. Criada por Lucas Gabriel (ONTIME
                  TECH) em 30/10/2025. Usada no relatorio 33 - ORCAMENTO DE
                  VENDA LUCAS (ORCAMENTO V04.jrxml).
  Assinatura     : FN_GET_ULTIMO_CUSTO_SPARK1 ( P_CODPROD IN NUMBER, P_TIPO IN
                  NUMBER, P_DATA IN DATE ) RETURN NUMBER
  Observacoes    : - Capturada do banco em 08/10/2026 (copia fiel do objeto
                    em producao, sem alteracoes), via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FN_GET_ULTIMO_CUSTO_SPARK1', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FN_GET_ULTIMO_CUSTO_SPARK1 (
    P_CODPROD IN NUMBER,
    P_TIPO    IN NUMBER,
	P_DATA    IN DATE
) RETURN NUMBER IS
    V_CUSTOFIS  AD_TGSCIT.CUSTOFIS%TYPE  := 0;
    V_CUSTOREL  AD_TGSCIT.CUSTOREL%TYPE  := 0;
    V_MOE       AD_TGSCIT.MOE%TYPE       := 0;
    V_VLRICMS   AD_TGSCIT.VLRICMS%TYPE   := 0;
    V_VLRIPI    AD_TGSCIT.VLRIPI%TYPE    := 0;
	V_CUSFRETE  AD_TGSCIT.CUSFRETE%TYPE  := 0;

	
/**********************************************************************************
Autor: Lucas Gabriel 
Data:30/10/2025
Objetivo: Buscar os ultimos dados do custo realizado na planilha de custo em excel.
**********************************************************************************/
BEGIN
    
    BEGIN
        SELECT
			CIT.CUSTOFIS,
			CIT.CUSTOREL,
			CIT.MOE,
			CIT.VLRICMS,
			CIT.VLRIPI,
			CIT.CUSFRETE

			
		INTO V_CUSTOFIS
			,V_CUSTOREL
			,V_MOE
			,V_VLRICMS
			,V_VLRIPI
			,V_CUSFRETE

			
		FROM AD_TGSCIT CIT
		INNER JOIN AD_TGSCUS CUS
			ON CIT.CODREG = CUS.CODREG
		WHERE CIT.CODPROD = P_CODPROD
		AND CIT.CUSTOREL > 0
		AND CUS.DTREF = (
						  SELECT MAX(CUS2.DTREF)
						  FROM AD_TGSCUS CUS2
						  INNER JOIN AD_TGSCIT CIT2
						  	ON CIT2.CODREG = CUS2.CODREG
						  WHERE CIT2.CODPROD = CIT.CODPROD
						  AND CIT2.CUSTOREL > 0
						  AND CUS2.DTREF <= P_DATA
						);
    EXCEPTION
        WHEN NO_DATA_FOUND 
		THEN
            NULL; 
    END;

  IF P_TIPO = 0       --CUSTO MP FISCAL
	THEN
    RETURN(NVL(V_CUSTOFIS,0));
	
  ELSIF P_TIPO = 1   -- CUSTO MP REAL
	THEN
    RETURN(NVL(V_CUSTOREL,0));
	
  ELSIF P_TIPO = 2   -- MÃO DE OBRA
	THEN
    RETURN(NVL(V_MOE,0));
	
  ELSIF P_TIPO = 3   -- VLR ICMS
	THEN
    RETURN(NVL(V_VLRICMS,0));
	
  ELSIF P_TIPO = 4    -- VLR IPI
	THEN
    RETURN(NVL(V_VLRIPI,0));
	
  ELSIF P_TIPO = 5    -- Frete Fixo
	THEN
    RETURN(NVL(V_CUSFRETE,0));	
	
  ELSE
    RETURN (0);
  END IF;
  
EXCEPTION
   WHEN NO_DATA_FOUND 
	THEN RETURN (0);
END;
