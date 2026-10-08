/*==============================================================================
  Nome do Script : OBTEM_NUFIN_SITE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Gera e retorna o proximo NUFIN via STP_KEYGEN_NUFIN.
  Assinatura     : OBTEM_NUFIN_SITE RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEM_NUFIN_SITE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEM_NUFIN_SITE RETURN NUMBER 
IS P_NUFIN NUMBER;
BEGIN
	BEGIN
		STP_KEYGEN_NUFIN(P_NUFIN);
		RETURN(P_NUFIN);
	END;
END;
