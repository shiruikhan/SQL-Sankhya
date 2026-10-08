/*==============================================================================
  Nome do Script : TIM_ACUMULAINDICEPROP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Acumula indices de uma moeda/indexador (TSICOT) entre duas
                  datas, aplicando o primeiro mes proporcionalmente.
  Assinatura     : TIM_ACUMULAINDICEPROP (QINDICE IN NUMBER, QDTINIC IN DATE,
                  QDTFIM IN DATE) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_ACUMULAINDICEPROP', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_ACUMULAINDICEPROP (QINDICE IN NUMBER, QDTINIC IN DATE, QDTFIM IN DATE) 
RETURN NUMBER IS
    
	CURSOR RSIDV IS
	SELECT NVL(COTACAO,0) COTACAO, DTMOV 
	FROM TSICOT 
	WHERE CODMOEDA = QINDICE 
	AND DTMOV BETWEEN TRUNC(QDTINIC, 'MM') AND QDTFIM 
	ORDER BY DTMOV;
	
	VALVOLTA NUMBER;
	ULTVALOR NUMBER;
	NUMDIAS NUMBER;
BEGIN
	VALVOLTA := 1;
	ULTVALOR := 0;
	
	FOR IDV IN RSIDV LOOP   
		VALVOLTA := VALVOLTA * (1 + IDV.COTACAO / 100);
		ULTVALOR := IDV.COTACAO;
	END LOOP;
	
	NUMDIAS := TO_NUMBER(TO_CHAR(QDTFIM, 'DD'));
	
	IF NUMDIAS > 1 THEN
		ULTVALOR := 1 + (ULTVALOR / 30 * NUMDIAS) / 100;
		VALVOLTA := VALVOLTA * ULTVALOR;
	END IF;
	
	RETURN VALVOLTA;
END;
