/*==============================================================================
  Nome do Script : SNK_GET_VLRTOT_ITENS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o valor total dos itens de uma nota, considerando regras de kit e
                  itens embutidos.
  Assinatura     : SNK_GET_VLRTOT_ITENS (P_NUNOTA NUMBER ,P_FSTEMBUT CHAR ,P_TEMKIT CHAR)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_VLRTOT_ITENS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_VLRTOT_ITENS (P_NUNOTA 		NUMBER
											   ,P_FSTEMBUT		CHAR
											   ,P_TEMKIT		CHAR)
RETURN FLOAT
AS
	P_RESULT         FLOAT;
BEGIN
	P_RESULT := 0;

	BEGIN
		SELECT SUM(ITE.VLRTOT) INTO P_RESULT
		FROM TGFITE ITE
		WHERE ITE.NUNOTA = P_NUNOTA
		  AND ITE.SEQUENCIA > 0
		  AND ITE.VLRTOT > 0
		  AND (	(P_FSTEMBUT = 'S' AND (ITE.USOPROD = 'D' OR P_TEMKIT  = 'N')) OR
				(P_FSTEMBUT = 'N' AND ITE.USOPROD <> 'D')
			   )
		  AND ITE.USOPROD <> '*';
	EXCEPTION WHEN NO_DATA_FOUND THEN
		P_RESULT := 0;
	END;

  RETURN P_RESULT;
END;
