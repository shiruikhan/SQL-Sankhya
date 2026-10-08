/*==============================================================================
  Nome do Script : GET_TEM_RASTSTULTENTRADA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o rastreamento por ultima entrada (parametro
                  RASTSTULTENTRA) se aplica a empresa/produto/TOP.
  Assinatura     : GET_TEM_RASTSTULTENTRADA (P_CODEMP INT, P_CODPROD INT,
                  P_CODTIPOPER INT, P_DHTIPOPER DATE) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TEM_RASTSTULTENTRADA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TEM_RASTSTULTENTRADA (P_CODEMP INT, P_CODPROD INT, P_CODTIPOPER INT, P_DHTIPOPER DATE)
RETURN CHAR
IS
  P_COUNT  NUMBER(10) := 0;
  P_RESULT CHAR(1) := 'N';
  P_NAO_DEFINIDO CHAR(1) := '*';
BEGIN

    IF (VARIAVEIS_PKG.V_RASTSTULTENTRA = P_NAO_DEFINIDO) THEN
        VARIAVEIS_PKG.V_RASTSTULTENTRA := NVL(GET_TSIPAR_LOGICO('RASTSTULTENTRA'), 'N');
    END IF;


    IF (VARIAVEIS_PKG.V_RASTSTULTENTRA = 'S') THEN
    	SELECT COUNT(1) INTO P_COUNT
		FROM TGFRASTEMP;
		IF P_COUNT > 0 THEN
			SELECT COUNT(1) INTO P_COUNT
	        FROM TGFRASTEMP
	        WHERE CODEMP = P_CODEMP
	        AND CODPROD = P_CODPROD
	        AND NVL(TIPORASTR, '*') = 'U';
	    END IF;
	    IF (P_COUNT > 0) THEN
            SELECT COUNT(1) INTO P_COUNT
            FROM TGFTOP TPO
            WHERE TPO.CODTIPOPER = P_CODTIPOPER
            AND TPO.DHALTER = P_DHTIPOPER
            AND TPO.ATUALEST IN ('B', 'E')
            AND TPO.ATUALLIVFIS IN ('E', 'S', 'A');

            IF (P_COUNT > 0) THEN
                P_RESULT := 'S';
            END IF;
        END IF;
    END IF;

    RETURN P_RESULT;
END;
