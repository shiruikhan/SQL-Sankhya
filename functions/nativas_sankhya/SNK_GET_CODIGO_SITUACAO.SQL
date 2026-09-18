/*==============================================================================
  Nome do Script : SNK_GET_CODIGO_SITUACAO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo de situacao do documento fiscal (tabela 4.1.2 do SPED)
                  conforme cancelamento, extemporaneidade e demais flags.
  Assinatura     : SNK_GET_CODIGO_SITUACAO (P_CODMODDOC VARCHAR2, P_SERIE VARCHAR2, P_ORIGEM VARCHAR2, P_STATUSNFE VARCHAR2, P_COMPLEMENTO VARCHAR2, P_CODCFO NUMBER, P_EXTEMPORANEO CHAR, P_NFEEXTORNO CHAR, P_CANCEXTEMPORANEO CHAR, P_CANCEXTEMPORANEOESPECIAL CHAR)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODIGO_SITUACAO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODIGO_SITUACAO (P_CODMODDOC					VARCHAR2,
												   P_SERIE						VARCHAR2,
												   P_ORIGEM						VARCHAR2,
												   P_STATUSNFE					VARCHAR2,
												   P_COMPLEMENTO				VARCHAR2,
												   P_CODCFO						NUMBER,
												   P_EXTEMPORANEO				CHAR,
												   P_NFEEXTORNO					CHAR,
												   P_CANCEXTEMPORANEO			CHAR,
												   P_CANCEXTEMPORANEOESPECIAL	CHAR)    
RETURN VARCHAR2
AS
    P_RESULT         VARCHAR2(2);
BEGIN
	/*
	Tabela 4.1.2
	00 Documento regular
	01 Documento regular extemporÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½neo
	02 Documento cancelado
	03 Documento cancelado extemporÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½neo
	04 NFe denegada
	05 NFe ÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½ NumeraÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½ÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½o inutilizada
	06 Documento Fiscal Complementar
	07 Documento Fiscal Complementar extemporÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½neo.
	08 Documento Fiscal emitido com base em Regime Especial ou Norma EspecÃƒÆ’Ã‚Â¯Ãƒâ€šÃ‚Â¿Ãƒâ€šÃ‚Â½fica
	*/

	IF NVL(P_STATUSNFE, '*') = 'D' THEN
		P_RESULT := '04';

	ELSIF NVL(P_ORIGEM, '*') = 'C' THEN
	    IF NVL(P_CANCEXTEMPORANEOESPECIAL, '*') = 'S' THEN
			P_RESULT := '08';

		ELSIF NVL(P_EXTEMPORANEO, '*') = 'S' OR 
			  NVL(P_CANCEXTEMPORANEO, '*') = 'S' THEN
			P_RESULT := '03';

		ELSE
			P_RESULT := '02';
		END IF;
	ELSIF NVL(P_COMPLEMENTO, '*') = 'A' OR 
		  NVL(P_CODMODDOC, '*') = '1B' OR
		  NVL(P_NFEEXTORNO, '*') = 'S' OR 
		  (NVL(P_CODMODDOC, '*') = '55' AND  P_SERIE IN ('890', '891', '892', '893', '894', '895', '896', '897', '898', '899')) THEN
		P_RESULT := '08';

	ELSIF NVL(P_ORIGEM, '*') = 'A' THEN
	    IF NVL(P_EXTEMPORANEO, '*') = 'S' THEN
			P_RESULT := '07';
		ELSE
			P_RESULT := '06';
		END IF;
    ELSIF P_CODCFO IN (5929, 6929) THEN
		P_RESULT := '08';

	ELSIF NVL(P_EXTEMPORANEO, '*') = 'S' THEN
	    P_RESULT := '01';

	ELSE 
		P_RESULT := '00';
	END IF;

  RETURN P_RESULT;
END;
