/*==============================================================================
  Nome do Script : F_CONVERTELONG
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte a coluna LONG DATA_DEFAULT de USER_TAB_COLUMNS em
                  texto (ate 2000 caracteres).
  Assinatura     : F_CONVERTELONG ( P_TABELA IN VARCHAR2, P_CAMPO IN VARCHAR2 )
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_CONVERTELONG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_CONVERTELONG (
	P_TABELA IN VARCHAR2,
	P_CAMPO IN VARCHAR2
)
RETURN VARCHAR2
IS
	P_LONG LONG;
	P_VAR VARCHAR2 (2000);
BEGIN
	BEGIN  
		SELECT DATA_DEFAULT INTO P_LONG
		FROM USER_TAB_COLUMNS
		WHERE TABLE_NAME = P_TABELA
		AND COLUMN_NAME = P_CAMPO;
	EXCEPTION WHEN NO_DATA_FOUND THEN
		RETURN '';		
	END;			
		
	P_VAR := SUBSTR(P_LONG,1,2000);	
	RETURN P_VAR;
END;
