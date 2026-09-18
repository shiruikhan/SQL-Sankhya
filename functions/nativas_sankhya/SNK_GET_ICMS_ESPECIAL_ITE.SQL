/*==============================================================================
  Nome do Script : SNK_GET_ICMS_ESPECIAL_ITE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Recalcula o valor de ICMS de um item da nota quando ha regime especial de
                  aliquota configurado (TGFAEI).
  Assinatura     : SNK_GET_ICMS_ESPECIAL_ITE (P_NUNOTA IN INT, P_SEQUENCIA IN INT, P_ICMS_ORIG FLOAT, P_TIPO VARCHAR)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_ICMS_ESPECIAL_ITE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_ICMS_ESPECIAL_ITE (P_NUNOTA IN INT, P_SEQUENCIA IN INT, P_ICMS_ORIG FLOAT, P_TIPO VARCHAR)
   RETURN FLOAT IS
   V_ICMS       FLOAT := 0;
   V_BASERED    TGFDIN.BASERED%TYPE;
   V_BASE       TGFDIN.BASE%TYPE;
   V_ALIQUOTA   TGFDIN.ALIQUOTA%TYPE;
   V_ALIQESP    TGFDIN.ALIQUOTA%TYPE;
   V_VALORRED   TGFDIN.BASERED%TYPE := 0;
   V_VALORCHEIO TGFDIN.BASE%TYPE := 0;
BEGIN

	IF VARIAVEIS_PKG.V_HABALIQESPICMS AND NVL(P_NUNOTA, 0) <> 0 AND P_ICMS_ORIG > 0 THEN
		BEGIN -- ACESSANDO PELA PK, ENTÃO NÃO PRECISA DE SUM
			SELECT BASERED, BASE, ALIQUOTA
			INTO V_BASERED, V_BASE, V_ALIQUOTA
			FROM TGFDIN D
			WHERE D.CODIMP = 1 --ICMS
			AND D.CODINC = 1 --OU UMA OUTRA INCIDENCIA ESPECÍFICA (EMBALAGEM, ETC)
			AND D.NUNOTA = P_NUNOTA
			AND D.SEQUENCIA = P_SEQUENCIA;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			BEGIN
				V_BASERED := 0;
				V_BASE := 0;
				V_ALIQUOTA := 0;
			END;
		END;

		IF(P_TIPO = 'VLRICMS') THEN
			IF V_BASERED <> 0 THEN
				V_ALIQESP := SNK_BUSCA_ALIQ_REGIME_ESP(P_NUNOTA, P_SEQUENCIA, V_ALIQUOTA);
				V_ICMS := ROUND(V_BASERED * V_ALIQESP, 2);
			END IF; 
		ELSE
			IF V_BASERED <> 0 OR V_BASE <> 0 THEN
				V_ALIQESP := SNK_BUSCA_ALIQ_REGIME_ESP(P_NUNOTA, P_SEQUENCIA, V_ALIQUOTA);
				V_ICMS := ROUND(V_BASE * V_ALIQESP, 2) - ROUND(V_BASERED * V_ALIQESP, 2);
			END IF; 
		END IF;
		IF (V_ICMS = 0) THEN
			V_ICMS := P_ICMS_ORIG;
		END IF;
	ELSE 
		V_ICMS := P_ICMS_ORIG;
	END IF;
	
   	RETURN NVL(V_ICMS, 0);
END;
