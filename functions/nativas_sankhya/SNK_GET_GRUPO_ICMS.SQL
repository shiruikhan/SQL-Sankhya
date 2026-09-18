/*==============================================================================
  Nome do Script : SNK_GET_GRUPO_ICMS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Valida e retorna o codigo de grupo de produto para ICMS, ou 0 se nao
                  existir em TGFGRU.
  Assinatura     : SNK_GET_GRUPO_ICMS (P_CODGRUPOPROD NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_GRUPO_ICMS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_GRUPO_ICMS (P_CODGRUPOPROD	NUMBER)
RETURN NUMBER
AS
	P_RESULT		NUMBER;
BEGIN
	BEGIN
		SELECT CODGRUPOPROD INTO P_RESULT
		FROM TGFGRU
		WHERE CODGRUPOPROD = P_CODGRUPOPROD;

	EXCEPTION WHEN NO_DATA_FOUND THEN
		P_RESULT := 0;
	END;

	RETURN P_RESULT;
END;
