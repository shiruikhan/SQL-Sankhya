/*==============================================================================
  Nome do Script : GET_DIA_UTIL_EC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a proxima data (a partir da informada) que e dia
                  util para a empresa, usando EH_DIA_UTIL_EMP.
  Assinatura     : GET_DIA_UTIL_EC (P_DATA DATE, P_CODEMP NUMBER) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_DIA_UTIL_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_DIA_UTIL_EC (P_DATA DATE, P_CODEMP NUMBER) RETURN DATE 
IS   
 P_DATATEMP DATE;
 P_COUNT    NUMBER;
BEGIN
	P_COUNT := 1;
	P_DATATEMP := P_DATA;
	WHILE P_COUNT = 1 LOOP
		IF(Eh_Dia_Util_Emp(P_DATATEMP, P_CODEMP) = 1) THEN
			P_COUNT := 0;
		ELSE
			P_DATATEMP := P_DATATEMP + 1;
		END IF;
	END LOOP;
	RETURN P_DATATEMP;
END;
