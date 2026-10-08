/*==============================================================================
  Nome do Script : SOMA_DIA_UTIL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma N dias uteis a uma data, usando EH_DIA_UTIL_EMP da
                  empresa. [origem a confirmar]
  Assinatura     : SOMA_DIA_UTIL (P_DATA DATE, P_QTDDIAS NUMBER,P_CODEMP NUMBER
                  ) RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SOMA_DIA_UTIL', 'SPARKPRD') FROM dual;
                  - Origem nao confirmada: criada apos a instalacao do ERP, sem
                    marca Spark no fonte. Se for customizacao, mover para
                    functions/.
==============================================================================*/
CREATE OR REPLACE FUNCTION SOMA_DIA_UTIL (P_DATA DATE, P_QTDDIAS NUMBER,P_CODEMP NUMBER ) RETURN DATE 
IS   
    P_DATATEMP DATE;
    P_COUNT      NUMBER;
BEGIN
    P_COUNT :=0;
    P_DATATEMP := P_DATA;
	IF (P_DATA IS NOT NULL) THEN
    	WHILE P_COUNT < P_QTDDIAS LOOP
        	P_DATATEMP := P_DATATEMP+1;
        	IF(Eh_Dia_Util_Emp(P_DATATEMP, P_CODEMP)=1) THEN
            	P_COUNT := P_COUNT + 1;
        	END IF;
    	END LOOP;
	END IF;
RETURN P_DATATEMP;
END;
