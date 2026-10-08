/*==============================================================================
  Nome do Script : FTEM_KIT_INDEPENDENTE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se a configuracao de kit independente (TSIPAR
                  CONFKITIND) esta ativa.
  Assinatura     : FTEM_KIT_INDEPENDENTE RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FTEM_KIT_INDEPENDENTE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FTEM_KIT_INDEPENDENTE 
RETURN BOOLEAN
IS 
 P_CONFIGKIT   VARCHAR2(1);
BEGIN

	    SELECT NVL(LOGICO, 'N')
		  INTO P_CONFIGKIT
		  FROM TSIPAR
		 WHERE CHAVE = 'CONFKITIND';	

	IF (P_CONFIGKIT = 'S') THEN
		   RETURN(TRUE);
	   ELSE 
		   RETURN(FALSE);
	   END IF;
	   EXCEPTION WHEN NO_DATA_FOUND THEN
		   RETURN(FALSE);
END;
