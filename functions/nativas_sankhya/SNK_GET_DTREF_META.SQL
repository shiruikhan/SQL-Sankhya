/*==============================================================================
  Nome do Script : SNK_GET_DTREF_META
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina a data de referencia de uma nota para apuracao de meta comercial
                  ou financeira, conforme configuracao em TGMCFG.
  Assinatura     : SNK_GET_DTREF_META (P_NUNOTA TGFCAB.NUNOTA%TYPE, P_CODMETA TGMCFG.CODMETA%TYPE)
                   RETURN TGFCAB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DTREF_META', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DTREF_META (P_NUNOTA TGFCAB.NUNOTA%TYPE,	P_CODMETA TGMCFG.CODMETA%TYPE)
RETURN TGFCAB.DTNEG%TYPE
AS	
	P_TIPODATA		TGMCFG.TIPODATA%TYPE;
	P_TIPMETA		TGMCFG.TIPMETA%TYPE;
	P_PERIODO		TGMCFG.PERIODO%TYPE;
	P_DATAREFNOTA	TGFCAB.DTNEG%TYPE;
	P_DATAREF		TGFCAB.DTNEG%TYPE;
	P_COUNT         INT:= 0;
BEGIN		

	SELECT TIPODATA, TIPMETA, PERIODO
	INTO P_TIPODATA, P_TIPMETA,P_PERIODO
	FROM TGMCFG CFG
	WHERE CFG.CODMETA = P_CODMETA;
	  
	SELECT COUNT(*)
	INTO P_COUNT
	FROM TGFFIN FIN
	WHERE FIN.NUNOTA = P_NUNOTA;
    
	IF( P_COUNT > 0 AND P_TIPMETA='F') THEN
		SELECT DATA 
		INTO P_DATAREFNOTA
		FROM (
			SELECT CASE P_TIPODATA 
				WHEN 'L' THEN CABFIN.DHMOV 
				WHEN 'E' THEN CABFIN.DTENTSAI 
				WHEN 'V' THEN CABFIN.DTVENC 
				WHEN 'B' THEN CABFIN.DHBAIXA 
				ELSE  CABFIN.DTNEG END DATA
			FROM TGFFIN CABFIN	
			WHERE CABFIN.NUNOTA = P_NUNOTA
			ORDER BY CABFIN.DESDOBRAMENTO) --ALINHADO COM PO VALIDAR DA PRIMEIRA PARCELA   
        WHERE ROWNUM=1;
    
	ELSE     --META COMERCIAL OU SEM FINANCEIRO VALIDACOESMETAS.JAVA
		SELECT CASE P_TIPODATA 
			WHEN 'E' THEN CAB.DTENTSAI 
			WHEN 'L' THEN CAB.DTMOV 
			ELSE CAB.DTNEG END
			INTO P_DATAREFNOTA
		FROM TGFCAB CAB
		WHERE CAB.NUNOTA = P_NUNOTA;
	END IF;

	IF (P_PERIODO = 9) THEN 
		P_DATAREF := TRUNC(P_DATAREFNOTA,'YEAR');
	ELSE 
		P_DATAREF := TRUNC(P_DATAREFNOTA,'MONTH');--IMPLEMENTAR DEBITO TECNICO IDENTIFICADO NA OS 4529400
	END IF;

	RETURN P_DATAREF;
    
END;
