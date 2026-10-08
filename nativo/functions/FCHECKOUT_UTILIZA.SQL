/*==============================================================================
  Nome do Script : FCHECKOUT_UTILIZA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o cliente utiliza Sankhya Checkout (existe PDV
                  configurado em TFXPDV).
  Assinatura     : FCHECKOUT_UTILIZA RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FCHECKOUT_UTILIZA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FCHECKOUT_UTILIZA 
RETURN BOOLEAN
IS 
  P_COUNT NUMBER(10);
BEGIN
	
	SELECT NVL(COUNT(1), 0)
	INTO P_COUNT
	  FROM  TFXPDV 
	WHERE CONFIGURADO = 'S';

	IF (P_COUNT > 0) THEN
        RETURN(TRUE);
    ELSE 
        RETURN(FALSE);
    END IF;
END;
