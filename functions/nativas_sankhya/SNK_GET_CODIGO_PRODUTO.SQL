/*==============================================================================
  Nome do Script : SNK_GET_CODIGO_PRODUTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do produto a exibir na NF-e (referencia ou codigo
                  interno), conforme configuracao NFE da empresa (TGFEMP/TGFPRO).
  Assinatura     : SNK_GET_CODIGO_PRODUTO (P_PRODUTONFE VARCHAR2, P_CODPROD NUMBER, P_CODEMP NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODIGO_PRODUTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODIGO_PRODUTO (P_PRODUTONFE 	VARCHAR2,
                                                  P_CODPROD		NUMBER,
                                                  P_CODEMP		NUMBER)
RETURN VARCHAR2
AS
	P_DADOSPROD_PRODUTONFE	NUMBER;
	P_DADOSPROD_REFERENCIA	VARCHAR2(15);
	P_COUNT					NUMBER;
    P_RESULT         		VARCHAR2(100);
BEGIN
	IF P_PRODUTONFE IS NULL OR TRIM(P_PRODUTONFE) = '' THEN
		SELECT COUNT(1) INTO P_COUNT
		FROM TGFEMP 
		WHERE CODEMP = P_CODEMP 
			AND NFE IN (1, 2);
	
		IF P_COUNT > 0 THEN 
			BEGIN
				SELECT PRODUTONFE, TRIM(REFERENCIA) 
				INTO P_DADOSPROD_PRODUTONFE, P_DADOSPROD_REFERENCIA
				FROM TGFPRO
				WHERE CODPROD = P_CODPROD;

				IF P_DADOSPROD_PRODUTONFE = 1 /*REFERENCIA*/ AND NVL(P_DADOSPROD_REFERENCIA, '*') <> '*' THEN
					P_RESULT := P_DADOSPROD_REFERENCIA;
				ELSE
					P_RESULT := P_CODPROD;
				END IF;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				P_RESULT := P_CODPROD;
			END;
		ELSIF P_CODPROD IS NOT NULL THEN
			P_RESULT := P_CODPROD;

		ELSE
			P_RESULT := '';
		END IF;
	ELSE
		P_RESULT := TRIM(P_PRODUTONFE);
	END IF;

  RETURN P_RESULT;
END;
