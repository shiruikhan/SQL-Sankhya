/*==============================================================================
  Nome do Script : SNK_TGFTOKCAM
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se existe configuracao de tokenizacao de campo para uma tabela
                  (TGFTOKCAM).
  Assinatura     : SNK_TGFTOKCAM ( P_TABELA IN VARCHAR2 )
                   RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TGFTOKCAM', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TGFTOKCAM (
    P_TABELA IN VARCHAR2
)
RETURN BOOLEAN
AS
    P_COUNT NUMBER(5);
    P_RETORNO BOOLEAN;
BEGIN
		SELECT COUNT(*) INTO P_COUNT FROM TGFTOKCAM C WHERE C.CODCFG = 0 AND C.TABELA=P_TABELA;
        
		IF P_COUNT > 0 THEN	
            P_RETORNO := TRUE;
		ELSE 
			P_RETORNO := FALSE;
    END IF;

	RETURN P_RETORNO;

END;
