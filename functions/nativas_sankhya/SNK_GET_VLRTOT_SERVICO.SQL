/*==============================================================================
  Nome do Script : SNK_GET_VLRTOT_SERVICO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o valor total (menos desconto) dos itens de servico (USOPROD = 'S')
                  de uma nota.
  Assinatura     : SNK_GET_VLRTOT_SERVICO (P_NUNOTA NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_VLRTOT_SERVICO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_VLRTOT_SERVICO (P_NUNOTA 	NUMBER)
RETURN FLOAT
AS
	P_RESULT         FLOAT;
BEGIN
	P_RESULT := 0;

	BEGIN
		SELECT SUM(ITE.VLRTOT - ITE.VLRDESC) INTO P_RESULT
		FROM TGFITE ITE
		WHERE ITE.NUNOTA = P_NUNOTA
			AND ITE.SEQUENCIA > 0
			AND ITE.VLRTOT > 0
			AND ITE.USOPROD = 'S';
	EXCEPTION WHEN NO_DATA_FOUND THEN
		P_RESULT := 0;
	END;

  RETURN P_RESULT;
END;
