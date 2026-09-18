/*==============================================================================
  Nome do Script : SNK_GET_CODIGO_OBSERVACAO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo de observacao/complemento fiscal (CODINF ou
                  CODREFINFCOMPL).
  Assinatura     : SNK_GET_CODIGO_OBSERVACAO (P_CODINF NUMBER, P_CODREFINFCOMPL VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODIGO_OBSERVACAO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODIGO_OBSERVACAO (P_CODINF 			NUMBER,
													 P_CODREFINFCOMPL	VARCHAR2)
RETURN VARCHAR2
AS
	P_RESULT         VARCHAR(100);
BEGIN
	P_RESULT := '';

	IF NVL(P_CODINF, 0) > 0 THEN
		IF NVL(TRIM(P_CODREFINFCOMPL), ' ') = ' ' THEN
			P_RESULT := P_CODINF;
		ELSE
			P_RESULT := P_CODREFINFCOMPL;
		END IF;
	END IF;

  RETURN P_RESULT;
END;
