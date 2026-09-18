/*==============================================================================
  Nome do Script : SNK_GET_CODCFO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Resolve o codigo de CFO de um item combinando classificacao do parceiro,
                  TOP e as regras de SNK_GET_CFO/SNK_GET_CFO_NOTA.
  Assinatura     : SNK_GET_CODCFO (P_CODCFO NUMBER ,P_NUNOTA NUMBER ,P_ENTSAI VARCHAR2 ,P_TIPMOV VARCHAR2 ,P_CLASSIFICMS VARCHAR2 ,P_TIPSUBST VARCHAR2 ,P_USOPROD VARCHAR2 ,P_BASESUBSTIT FLOAT ,P_BASEICMS FLOAT ,P_CODTRIB NUMBER ,P_CODGRUPOPROD NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODCFO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODCFO (P_CODCFO 			NUMBER
										 ,P_NUNOTA			NUMBER
										 ,P_ENTSAI			VARCHAR2
										 ,P_TIPMOV			VARCHAR2
										 ,P_CLASSIFICMS 	VARCHAR2
										 ,P_TIPSUBST		VARCHAR2
										 ,P_USOPROD			VARCHAR2
										 ,P_BASESUBSTIT		FLOAT
										 ,P_BASEICMS		FLOAT
										 ,P_CODTRIB			NUMBER
										 ,P_CODGRUPOPROD	NUMBER)
RETURN NUMBER
AS
	P_RESULT		FLOAT;
	P_CLASSSIF		VARCHAR2(1);
BEGIN
	P_RESULT := NVL(P_CODCFO, 0);
	P_CLASSSIF := '';

	IF NVL(P_CODCFO, 0) = 0 THEN
		IF P_CLASSIFICMS IS NOT NULL THEN
			P_CLASSSIF := P_CLASSIFICMS;
		ELSE
			BEGIN
				SELECT PAR.CLASSIFICMS INTO P_CLASSSIF
				FROM TGFCAB CAB
					INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
				WHERE CAB.NUNOTA = P_NUNOTA;
			EXCEPTION WHEN NO_DATA_FOUND THEN
				P_CLASSSIF := '';
			END;

			P_RESULT := SNK_GET_CFO(P_TIPSUBST
								   ,P_CLASSSIF
								   ,P_USOPROD
								   ,P_TIPMOV
								   ,P_BASESUBSTIT
								   ,P_BASEICMS
								   ,P_CODTRIB
								   ,SNK_GET_CFO_NOTA(P_NUNOTA)
								   ,SNK_GET_GRUPO_ICMS(P_CODGRUPOPROD)
								   ,0
								   ,'N');
		END IF;
	END IF;

	IF NVL(P_ENTSAI, '*') = 'E' THEN
		P_RESULT := NVL(P_RESULT, 0);

		IF P_RESULT >= 5000 THEN
			P_RESULT := P_RESULT - 4000;

		ELSIF P_RESULT >= 500 AND P_RESULT < 1000 THEN
			P_RESULT := P_RESULT - 400;

		END IF;
	END IF;

	RETURN P_RESULT;
END;
