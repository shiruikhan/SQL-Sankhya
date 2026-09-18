/*==============================================================================
  Nome do Script : SNK_GET_INDICADOR_EMITENTE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina se a nota e de emissao propria ou de terceiro (indicador do SPED
                  Fiscal).
  Assinatura     : SNK_GET_INDICADOR_EMITENTE (P_ENTSAI VARCHAR2, P_BASENUMERACAO VARCHAR2, P_TIPMOV VARCHAR2, P_ATUALLIVFIS VARCHAR2, P_NOTADETERCEIRO CHAR)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_INDICADOR_EMITENTE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_INDICADOR_EMITENTE (P_ENTSAI			VARCHAR2,
													  P_BASENUMERACAO	VARCHAR2,
													  P_TIPMOV			VARCHAR2,
													  P_ATUALLIVFIS		VARCHAR2,
													  P_NOTADETERCEIRO	CHAR)
RETURN VARCHAR2
AS
    P_RESULT         VARCHAR2(1);
BEGIN
	/*
	0 - Emissão Própria
	1 - Emissão Terceiros
	*/

	IF NVL(P_ENTSAI, '*') = 'E' THEN
	    IF (NVL(P_TIPMOV, '*') = 'T' AND NVL(P_ATUALLIVFIS, '*') = 'A') OR NVL(P_NOTADETERCEIRO, '*') = 'S' THEN
		  	P_RESULT := '1';

		ELSIF NVL(P_BASENUMERACAO, '*') IN ('V', 'D') THEN
		  	P_RESULT := '0';

		ELSE
		  	P_RESULT := '1';
		END IF;
	ELSE 
	    IF NVL(P_NOTADETERCEIRO, '*') = 'S' THEN
		  	P_RESULT := '1';
		ELSE
		  	P_RESULT := '0';
		END IF;
	END IF;

  RETURN P_RESULT;
END;
