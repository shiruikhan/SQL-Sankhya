/*==============================================================================
  Nome do Script : DANFE_BUILDRAZAOSOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Duplicata de DANFE_BUILDDRAZAOSOCIAL (mesmo comportamento,
                  nome sem o D extra).
  Assinatura     : DANFE_BUILDRAZAOSOCIAL ( TIPO NUMBER , RAZAO VARCHAR2 ,
                  NOMEFANT VARCHAR2 ) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'DANFE_BUILDRAZAOSOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION DANFE_BUILDRAZAOSOCIAL ( TIPO NUMBER , RAZAO VARCHAR2 , NOMEFANT VARCHAR2 ) 
RETURN VARCHAR2 IS
BEGIN
	IF TIPO = 2 THEN 
		RETURN (RAZAO || '/' || NOMEFANT);
	ELSIF TIPO = 1 THEN
		RETURN NOMEFANT;
	END IF;
RETURN RAZAO;
END;
