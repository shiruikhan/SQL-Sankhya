/*==============================================================================
  Nome do Script : FTIM_EXECUTAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se existe empresa (TSIEMP) cadastrada com o CNPJ
                  informado; usada para liberar rotinas do modulo imobiliario.
  Assinatura     : FTIM_EXECUTAR (P_CNPJ VARCHAR) RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FTIM_EXECUTAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FTIM_EXECUTAR (P_CNPJ VARCHAR)
RETURN BOOLEAN
IS
	P_COUNT INT;
BEGIN
	SELECT COUNT(*) INTO P_COUNT
	FROM TSIEMP
	WHERE CGC = P_CNPJ;
	
	RETURN P_COUNT > 0;
END;
