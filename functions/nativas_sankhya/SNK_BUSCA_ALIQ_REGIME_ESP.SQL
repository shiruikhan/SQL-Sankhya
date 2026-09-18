/*==============================================================================
  Nome do Script : SNK_BUSCA_ALIQ_REGIME_ESP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a aliquota especial de ICMS aplicavel a um item de nota (regime
                  especial TGFAEI), ou a aliquota padrao se nao houver regra.
  Assinatura     : SNK_BUSCA_ALIQ_REGIME_ESP (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER, P_ALIQUOTA NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_BUSCA_ALIQ_REGIME_ESP', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_BUSCA_ALIQ_REGIME_ESP (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER, P_ALIQUOTA NUMBER)
   RETURN FLOAT IS
   V_ALIQ    FLOAT := 0;
BEGIN
	
	IF VARIAVEIS_PKG.V_HABALIQESPICMS THEN
		SELECT NVL(MAX(AEI.VLRALIQ), P_ALIQUOTA) INTO V_ALIQ 
		FROM TGFAEI AEI
		WHERE EXISTS (
			SELECT 1 
			FROM TGFCAB CAB 
			WHERE CAB.CODEMP = AEI.CODEMP
			AND CAB.NUNOTA = P_NUNOTA
			AND CAB.DTNEG BETWEEN AEI.DTINI	AND NVL(AEI.DTFIN, CAB.DTNEG)
			AND NOT EXISTS (SELECT 1 FROM TGFAEPAR AEPAR WHERE AEPAR.CODAEI = AEI.CODAEI AND AEPAR.CODPARC = CAB.CODPARC)
			AND NOT EXISTS (SELECT 1 FROM TGFAETOP AETOP WHERE AETOP.CODAEI = AEI.CODAEI AND AETOP.CODTIPOPER = CAB.CODTIPOPER)
			AND NOT EXISTS (SELECT 1 FROM TGFAEPRO AEPRO, TGFITE ITE WHERE ITE.NUNOTA = P_NUNOTA AND ITE.SEQUENCIA = P_SEQUENCIA AND ITE.CODPROD = AEPRO.CODPROD AND AEPRO.CODAEI = AEI.CODAEI)
		);
	END IF;

	--CASO NAO ENCONTRE EXECAO VOLTA O P_ALIQ
   
	RETURN (V_ALIQ / 100);
   
END;
