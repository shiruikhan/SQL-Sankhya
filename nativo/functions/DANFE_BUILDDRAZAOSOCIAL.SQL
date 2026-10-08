/*==============================================================================
  Nome do Script : DANFE_BUILDDRAZAOSOCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o nome do emitente do DANFE (razao, fantasia ou
                  razao/fantasia conforme o tipo).
  Assinatura     : DANFE_BUILDDRAZAOSOCIAL ( TIPO NUMBER , RAZAO VARCHAR2 ,
                  NOMEFANT VARCHAR2 ) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'DANFE_BUILDDRAZAOSOCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION DANFE_BUILDDRAZAOSOCIAL ( TIPO NUMBER , RAZAO VARCHAR2 , NOMEFANT VARCHAR2 ) 
RETURN VARCHAR2 IS
BEGIN
	IF TIPO = 2 THEN 
		RETURN (RAZAO || '/' || NOMEFANT);
	ELSIF TIPO = 1 THEN
		RETURN NOMEFANT;
	END IF;
RETURN RAZAO;
END;
