/*==============================================================================
  Nome do Script : SNK_GET_ICMS_ESPECIAL_CAB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Recalcula o valor de ICMS do cabecalho da nota quando ha regime especial
                  de aliquota configurado (TGFAEI).
  Assinatura     : SNK_GET_ICMS_ESPECIAL_CAB (P_NUNOTA NUMBER, P_ICMS_ORIG FLOAT, P_CODINC NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ICMS_ESPECIAL_CAB', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ICMS_ESPECIAL_CAB (P_NUNOTA NUMBER, P_ICMS_ORIG FLOAT, P_CODINC NUMBER)
   RETURN FLOAT IS
   V_ICMS    FLOAT := 0;
   V_COUNT INT;
BEGIN

	IF VARIAVEIS_PKG.V_HABALIQESPICMS AND NVL(P_NUNOTA, 0) <> 0 AND P_ICMS_ORIG > 0 THEN
		SELECT COUNT(*)
		INTO V_COUNT
		FROM TGFCAB CAB 
		, TGFAEI AEI
		WHERE CAB.NUNOTA = P_NUNOTA
		AND CAB.CODEMP = AEI.CODEMP
		AND CAB.DTNEG BETWEEN AEI.DTINI	AND NVL(AEI.DTFIN, CAB.DTNEG)
		AND NOT EXISTS (SELECT 1 FROM TGFAEPAR AEPAR WHERE AEPAR.CODAEI = AEI.CODAEI AND AEPAR.CODPARC = CAB.CODPARC)
		AND NOT EXISTS (SELECT 1 FROM TGFAETOP AETOP WHERE AETOP.CODAEI = AEI.CODAEI AND AETOP.CODTIPOPER = CAB.CODTIPOPER);
		IF V_COUNT > 0 THEN
			SELECT 
			ROUND(NVL(SUM(D.BASERED * SNK_BUSCA_ALIQ_REGIME_ESP(P_NUNOTA, D.SEQUENCIA, D.ALIQUOTA)),0),2) INTO V_ICMS
			FROM TGFDIN D
			WHERE D.CODIMP = 1 --ICMS
			AND D.CODINC = P_CODINC --OU UMA OUTRA INCIDENCIA ESPECÍFICA (EMBALAGEM, ETC) = 1 == PRODUTO, 6 == EMBALAGEM
			AND D.NUNOTA = P_NUNOTA;
		END IF;
	END IF;


	IF (V_ICMS = 0) THEN
		V_ICMS := P_ICMS_ORIG;
	END IF;
	
   	RETURN NVL(V_ICMS, 0);
   
END;
