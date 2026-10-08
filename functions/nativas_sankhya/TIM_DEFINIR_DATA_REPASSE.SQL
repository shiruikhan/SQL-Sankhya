/*==============================================================================
  Nome do Script : TIM_DEFINIR_DATA_REPASSE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Define a data de repasse (dias corridos ou uteis, conforme
                  contrato e parametro) a partir de uma data e quantidade de
                  dias.
  Assinatura     : TIM_DEFINIR_DATA_REPASSE (P_DATA DATE, P_QTDDIAS INT,
                  P_CODEMP INT, P_ADMNUCONTRATO INT, P_ORIGEM VARCHAR2) RETURN
                  DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_DEFINIR_DATA_REPASSE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_DEFINIR_DATA_REPASSE (P_DATA DATE, P_QTDDIAS INT, P_CODEMP INT, P_ADMNUCONTRATO INT, P_ORIGEM VARCHAR2) 
RETURN DATE
IS
	P_PARAMFC TSIPAR.INTEIRO%TYPE;
	P_DATATEMP DATE;
	P_ADMDIASUTEIS VARCHAR(10);
BEGIN

	SELECT ADMDIASUTEIS INTO P_ADMDIASUTEIS
	FROM TIMADM
	WHERE ADMNUCONTRATO = P_ADMNUCONTRATO;

	IF P_ORIGEM = 'FC' THEN
		P_PARAMFC := NVL(TIM_GET_TSIPAR_INTEIRO('TIMTPDIASREPFC'),0);
	
		P_ADMDIASUTEIS := CASE 	WHEN P_PARAMFC = 0 THEN P_ADMDIASUTEIS
								WHEN P_PARAMFC = 1 THEN 'UT'
								WHEN P_PARAMFC = 2 THEN 'CO'
								WHEN P_PARAMFC = 3 THEN 'CR'
								ELSE P_ADMDIASUTEIS END;
	END IF;

	IF(P_ADMDIASUTEIS = 'CO') THEN
		P_DATATEMP := TIM_SOMA_DIA_COMERCIAL(P_DATA, P_QTDDIAS);
	ELSIF(P_ADMDIASUTEIS = 'UT') THEN
		P_DATATEMP := Soma_Dia_Util(P_DATA, P_QTDDIAS, P_CODEMP);
	ELSE
		P_DATATEMP := P_DATA + P_QTDDIAS;
	END IF;
	
	RETURN P_DATATEMP;
END;
