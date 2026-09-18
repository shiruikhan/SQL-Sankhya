/*==============================================================================
  Nome do Script : SNK_TGFTOKCFG
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se a tokenizacao esta habilitada globalmente no sistema
                  (TGFTOKCFG).
  Assinatura     : SNK_TGFTOKCFG (sem parametros)
                   RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TGFTOKCFG', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TGFTOKCFG 
RETURN BOOLEAN
AS
    P_COUNT NUMBER(5);
	  P_RETORNO BOOLEAN;
BEGIN
		SELECT COUNT(1) INTO P_COUNT 
					FROM TGFTOKCFG 
					WHERE CODCFG = 0;
		IF P_COUNT > 0 THEN	
      P_RETORNO := TRUE;
		ELSE 
			P_RETORNO := FALSE;
    END IF;

	RETURN P_RETORNO;

END;
