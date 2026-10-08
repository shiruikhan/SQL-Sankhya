/*==============================================================================
  Nome do Script : EH_DIA_UTIL_EMP_GIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Variacao de EH_DIA_UTIL_EMP que considera tambem os dias de
                  folga configurados em TSIPAR (FOLGADOM...FOLGASAB); usada
                  por SNK_QTD_DIAS_UTEIS.
  Assinatura     : EH_DIA_UTIL_EMP_GIRO (P_DTINICIAL IN DATE, P_CODEMP IN
                  NUMBER) RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EH_DIA_UTIL_EMP_GIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EH_DIA_UTIL_EMP_GIRO (P_DTINICIAL IN DATE, P_CODEMP IN NUMBER)
	RETURN INT
IS
	P_PAIS		INT;
	P_ESTADO	INT;
	P_CIDADE	INT;
	P_COUNT		INT;
	P_DATAINI	DATE;
	P_DIA		INT;
	P_MES		INT;
	P_FOLGA		CHAR(1);
BEGIN

	IF P_DTINICIAL IS NULL	THEN
		RETURN 0;
	END IF;
	
	SELECT NVL(MAX(LOGICO), 'N')
	INTO P_FOLGA
	FROM (
		SELECT
            CASE CHAVE
                WHEN 'FOLGADOM' THEN 1
                WHEN 'FOLGASEG' THEN 2
                WHEN 'FOLGATER' THEN 3
                WHEN 'FOLGAQUA' THEN 4
                WHEN 'FOLGAQUI' THEN 5
                WHEN 'FOLGASEX' THEN 6
                WHEN 'FOLGASAB' THEN 7
            ELSE 0
            END DIA,
            LOGICO
		FROM TSIPAR
		WHERE CHAVE LIKE 'FOLGA%'
	) FOLGA
	WHERE DIA = TO_NUMBER(TO_CHAR(P_DTINICIAL, 'D'));

	IF P_FOLGA = 'S' THEN
		RETURN 0;
	END IF;

	P_DATAINI := TRUNC(P_DTINICIAL);
	
	SELECT UFS.CODUF, UFS.CODPAIS, CID.CODCID
	INTO P_ESTADO, P_PAIS, P_CIDADE
	FROM TSIUFS UFS, TSICID CID, TSIEMP EMP
	WHERE EMP.CODEMP = P_CODEMP
	AND EMP.CODCID = CID.CODCID
	AND CID.UF = UFS.CODUF;
	
	--CONTANDO OS FERIADOS NAO RECORRENTES.
	SELECT COUNT(1)
	INTO P_COUNT
	FROM TSIFER
	WHERE DTFERIADO = P_DATAINI 
	AND RECORRENTE = 'N'
	AND (CODPAIS = P_PAIS OR CODUF = P_ESTADO OR CODCID = P_CIDADE OR NACIONAL = 'I');
	
	IF P_COUNT > 0 THEN
		RETURN 0;
	END IF;
	
	--FERIADO RECORRENTE
	P_DIA := TO_NUMBER(TO_CHAR(P_DATAINI, 'DD'));
	P_MES := TO_NUMBER(TO_CHAR(P_DATAINI, 'MM'));
	
	IF P_MES = 2 AND P_DIA = 29 THEN
		P_DATAINI := TO_DATE('1900-03-01', 'YYYY-MM-DD');
	ELSE
		P_DATAINI := TO_DATE('1900-' || TO_CHAR(P_MES) || '-' || TO_CHAR(P_DIA), 'YYYY-MM-DD');
	END IF;
	
	SELECT COUNT (1)
	INTO P_COUNT
	FROM TSIFER
	WHERE DTFERIADO = P_DATAINI
	AND RECORRENTE = 'S'
	AND (CODPAIS = P_PAIS OR CODUF = P_ESTADO OR CODCID = P_CIDADE OR NACIONAL = 'I');
	IF P_COUNT > 0 THEN
		RETURN 0;
	END IF;
	
	RETURN 1;
END;
