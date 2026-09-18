/*==============================================================================
  Nome do Script : SNK_TEM_VLR_LIQUIDO_ITEM_NFE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Resolve, por hierarquia de configuracao (cabecalho > parceiro > TOP >
                  empresa), se o item deve informar valor liquido na NF-e/NFC-e.
  Assinatura     : SNK_TEM_VLR_LIQUIDO_ITEM_NFE (P_CODMODDOC NUMBER, P_VLRLIQITEMCAB VARCHAR2, P_VLRLIQITEMNFEPARCEIRO VARCHAR2, P_VLRLIQITEMNFCEPARCEIRO VARCHAR2, P_VLRLIQITEMTOP VARCHAR2, P_VLRLIQITEMNFEEMPRESA VARCHAR2, P_VLRLIQITEMNFCEEMPRESA VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TEM_VLR_LIQUIDO_ITEM_NFE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TEM_VLR_LIQUIDO_ITEM_NFE (P_CODMODDOC					NUMBER,
                                                        P_VLRLIQITEMCAB				VARCHAR2,
                                                        P_VLRLIQITEMNFEPARCEIRO		VARCHAR2,
                                                        P_VLRLIQITEMNFCEPARCEIRO	VARCHAR2,
                                                        P_VLRLIQITEMTOP				VARCHAR2,
                                                        P_VLRLIQITEMNFEEMPRESA		VARCHAR2,
                                                        P_VLRLIQITEMNFCEEMPRESA		VARCHAR2)
RETURN VARCHAR2
AS
	P_RESULT         VARCHAR2(1);
BEGIN
	IF NVL(P_VLRLIQITEMCAB, '*') = '*' THEN
		IF P_CODMODDOC = 55 THEN /*DOC_FISCAL_NFE*/ 
		    P_RESULT := P_VLRLIQITEMNFEPARCEIRO;

			IF P_RESULT IS NULL OR P_RESULT = 'E' THEN
				P_RESULT := P_VLRLIQITEMTOP;

				IF P_RESULT IS NULL OR P_RESULT = 'E' THEN
					P_RESULT := P_VLRLIQITEMNFEEMPRESA;
				END IF;
			END IF;
		ELSIF P_CODMODDOC = 65 THEN /*DOC_FISCAL_NFCE*/
		    P_RESULT := P_VLRLIQITEMNFCEPARCEIRO;

			IF P_RESULT IS NULL OR P_RESULT = 'E' THEN
			    P_RESULT := P_VLRLIQITEMTOP;

				IF P_RESULT IS NULL OR P_RESULT = 'E' THEN
				    P_RESULT := P_VLRLIQITEMNFCEEMPRESA;
				END IF;
			END IF;
		END IF;
	ELSE 
	    P_RESULT := P_VLRLIQITEMCAB;
	END IF;

	IF P_RESULT IS NULL OR P_RESULT <> 'S' THEN
	    P_RESULT := 'N';
	END IF;

  RETURN P_RESULT;
END;
