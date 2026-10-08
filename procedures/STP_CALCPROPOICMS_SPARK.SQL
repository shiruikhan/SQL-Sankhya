/*==============================================================================
  Nome do Script : STP_CALCPROPOICMS_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Calcular o ICMS Porpocional dos utlimos meses para calcular o estorno de ICMS Baseado no acumulativo dos ultimos 12 meses.
  Autor          : Lucas Gabriel - ONTIME TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 07/07/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_CALCPROPOICMS_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
    PARAM_P_DATAINI  DATE;
    PARAM_P_DATAFIN  DATE;
    FIELD_ID         NUMBER;
    V_ICMS           NUMBER;
    V_ID             NUMBER;
    V_ANO            NUMBER;
    V_MES            NUMBER;
    V_COUNT          NUMBER;
    V_IDOLD          NUMBER;
/*************************************************************************
Autor: Lucas Gabriel - ONTIME TECH 
Data:07/07/2025
Objetivo: Calcular o ICMS Porpocional dos utlimos meses para calcular o estorno
de ICMS Baseado no acumulativo dos ultimos 12 meses.
***************************************************************************/
BEGIN
    PARAM_P_DATAINI := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAINI');
    PARAM_P_DATAFIN := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAFIN');

    FOR I IN 1 .. P_QTDLINHAS LOOP
        FIELD_ID := ACT_INT_FIELD(P_IDSESSAO, I, 'ID');


        SELECT 
            ROUND(SUM(T.BASEICMS) / NULLIF(SUM(T.VLRNOTA + T.BASEICMS), 0), 6)
        INTO V_ICMS
        FROM (
            -- 1. ICMS de todas as saídas
            SELECT
                0 AS VLRNOTA,
                SUM(CASE WHEN DIN.CODIMP = 1 THEN DIN.BASERED ELSE 0 END) AS BASEICMS
            FROM TGFCAB CAB
                INNER JOIN TGFITE ITE 
					ON ITE.NUNOTA = CAB.NUNOTA
                INNER JOIN TGFDIN DIN 
					ON DIN.NUNOTA = ITE.NUNOTA
						AND DIN.SEQUENCIA = ITE.SEQUENCIA
                INNER JOIN TGFPRO PRO 
					ON PRO.CODPROD = ITE.CODPROD
                INNER JOIN TGFLIV LIV 
					ON LIV.NUNOTA = ITE.NUNOTA 
						AND LIV.SEQUENCIA = ITE.SEQUENCIA
            WHERE 
                CAB.DTNEG >= ADD_MONTHS(PARAM_P_DATAINI, -11) 
				AND CAB.DTNEG <= PARAM_P_DATAFIN
                AND CAB.CODEMP = 1
                AND CAB.STATUSNOTA = 'L'
                AND CAB.STATUSNFE = 'A'
                AND CAB.CODTIPOPER <> 1127
                AND PRO.NCM NOT IN (90303390,85371090,85312000)
                AND LIV.CODCFO IN (5101,5116,5151,5401,5910,6101,6107,6116,6118,6401,6910,6949,5927)

            UNION ALL

            -- 2. Saídas com manutenção de crédito ICMS
            SELECT
                CAB.VLRNOTA AS VLRNOTA,
                0 AS BASEICMS
            FROM TGFCAB CAB
            WHERE 
                CAB.DTNEG >= ADD_MONTHS(PARAM_P_DATAINI, -11)  
				AND CAB.DTNEG <= PARAM_P_DATAFIN
                AND CAB.CODEMP = 1
                AND CAB.STATUSNFE = 'A'
                AND CAB.STATUSNOTA = 'L'
                AND CAB.TIPMOV = 'V'
                AND EXISTS (
                    SELECT 1 FROM TGFITE ITE
                    WHERE ITE.CODCFO IN (7101,6109,7949)
                      AND ITE.NUNOTA = CAB.NUNOTA
                )

            UNION ALL

            -- 3. Saídas de produtos não beneficiados
            SELECT
                SUM(CASE WHEN DIN.CODIMP = 1 THEN DIN.BASERED ELSE 0 END) AS VLRNOTA,
                0 AS BASEICMS
            FROM TGFCAB CAB
                INNER JOIN TGFITE ITE
					ON ITE.NUNOTA = CAB.NUNOTA
                INNER JOIN TGFDIN DIN 
					ON DIN.NUNOTA = ITE.NUNOTA 
						AND DIN.SEQUENCIA = ITE.SEQUENCIA
                INNER JOIN TGFPRO PRO
					ON PRO.CODPROD = ITE.CODPROD
            WHERE 
					CAB.DTNEG >= ADD_MONTHS(PARAM_P_DATAINI, -11) 
				AND CAB.DTNEG <= PARAM_P_DATAFIN
                AND CAB.CODEMP = 1
                AND CAB.STATUSNFE = 'A'
                AND CAB.STATUSNOTA = 'L'
                AND CAB.CODTIPOPER <> 1127
                AND PRO.NCM IN (90303390,85371090,85312000)
                AND ITE.CODCFO IN (5101,5116,5151,5401,5910,6101,6107,6116,6118,6401,6910,6949,5927)
        ) T;


        SELECT NVL(MAX(IDIMP), 0) + 1 
			INTO V_ID
		FROM AD_TGFPIM;

        SELECT 
            EXTRACT(YEAR FROM PARAM_P_DATAINI)
            ,EXTRACT(MONTH FROM ADD_MONTHS(PARAM_P_DATAINI, 0))
        INTO V_ANO
		   , V_MES
        FROM DUAL;


        SELECT COUNT(0)
			 , MAX(IDIMP)

        INTO  V_COUNT
		    , V_IDOLD
        FROM AD_TGFPIM
        WHERE ANO = V_ANO 
		  AND MES = V_MES;


        IF V_COUNT > 0 
		   THEN
		  DELETE FROM AD_TGFPIM 
		   WHERE IDIMP = V_IDOLD;

        END IF;


        INSERT INTO AD_TGFPIM (IDIMP
							 , ANO
							 , MES
							 , ICMS)

				     VALUES (V_ID
					       , V_ANO
						   , V_MES
						   , V_ICMS * 100);

    END LOOP;
	P_MENSAGEM := 'O cálculo de proporcionalização foi gerado com sucesso!';
EXCEPTION
    WHEN OTHERS 
		THEN
        P_MENSAGEM := 'Erro durante o cálculo: ' || SQLERRM;
END;
