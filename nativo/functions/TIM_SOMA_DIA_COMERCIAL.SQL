/*==============================================================================
  Nome do Script : TIM_SOMA_DIA_COMERCIAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma N dias a uma data usando o calendario comercial de 30
                  dias por mes.
  Assinatura     : TIM_SOMA_DIA_COMERCIAL (DATAINI DATE, QTDDIAS NUMBER )
                  RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_SOMA_DIA_COMERCIAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_SOMA_DIA_COMERCIAL (DATAINI DATE, QTDDIAS NUMBER ) RETURN DATE 
IS   
    P_RETURN DATE;
   
	P_QTDMESES INT;
	P_DIASRESTANTES INT;
	P_DATAMES DATE;
   
BEGIN
	
	P_QTDMESES := (EXTRACT(DAY FROM DATAINI) + QTDDIAS) / 30;
	P_DIASRESTANTES := MOD((EXTRACT(DAY FROM DATAINI) + QTDDIAS), 30);

	IF(P_DIASRESTANTES = 0) THEN
	
		P_QTDMESES := P_QTDMESES - 1;
		P_DIASRESTANTES := 30;
		P_DATAMES := ADD_MONTHS(DATAINI, P_QTDMESES);
		
		IF(EXTRACT(MONTH FROM P_DATAMES) = 2) THEN
			P_DATAMES := ADD_MONTHS(DATAINI, 1);
			P_RETURN := TIM_TRUNCMONTH(P_DATAMES);
		ELSE
			P_RETURN := TIM_TRUNCMONTH(P_DATAMES) + (P_DIASRESTANTES - 1);
		END IF;
	
	ELSE
	
		P_DATAMES := ADD_MONTHS(DATAINI, P_QTDMESES);
	
		IF (P_DIASRESTANTES = 29 AND EXTRACT(MONTH FROM P_DATAMES) = 2 AND MOD(EXTRACT(YEAR FROM P_DATAMES), 4) <> 0 ) THEN
			P_DATAMES := ADD_MONTHS(DATAINI, 1);
			P_RETURN := TIM_TRUNCMONTH(P_DATAMES);
		ELSE
			P_RETURN := TIM_TRUNCMONTH(P_DATAMES) + (P_DIASRESTANTES - 1);
		END IF;
	
	END IF;
   
RETURN P_RETURN;
END;
