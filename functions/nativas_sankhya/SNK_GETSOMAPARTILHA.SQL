/*==============================================================================
  Nome do Script : SNK_GETSOMAPARTILHA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma as aliquotas de partilha do Simples Nacional
                  (IRPJ/CSLL/COFINS/PIS/CPP/IPI/ISS) aplicaveis a um item de nota.
  Assinatura     : SNK_GETSOMAPARTILHA (P_NUNOTA NUMBER, P_SEQUENCIA NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETSOMAPARTILHA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETSOMAPARTILHA (P_NUNOTA       NUMBER,
                                                P_SEQUENCIA    NUMBER)
   RETURN NUMBER
IS
   P_PARTILHA   NUMBER;
   P_COUNT      INTEGER;
   P_CODEMP     INTEGER;
   P_DTNEG      DATE;
   P_USOPROD    VARCHAR (1);
   P_TIPOSN     INTEGER;
   P_CODPROD    INTEGER;
BEGIN
    IF (P_NUNOTA = 0) OR (P_SEQUENCIA = 0) THEN
        RETURN (0);
    END IF;

    SELECT CODEMP, DTNEG
     INTO P_CODEMP, P_DTNEG
     FROM TGFCAB
    WHERE NUNOTA = P_NUNOTA;

    SELECT COUNT (DISTINCT PSN.TIPOSN)
        , NVL(SUM(  NVL (PSN.ALIQIRPJ, 0)
              + NVL (PSN.ALIQCSLL, 0)
              + NVL (PSN.ALIQCOFINS, 0)
              + NVL (PSN.ALIQPISPASEP, 0)
              + NVL (PSN.ALIQCPP, 0)
              + NVL (PSN.ALIQIPI, 0)
              + NVL (PSN.ALIQISS, 0)),0)
    INTO P_COUNT, P_PARTILHA
    FROM TGFEMPSN EXP, TGFPSN PSN
    WHERE EXP.CODEMP = P_CODEMP
    AND EXP.DTREF = (SELECT MAX (E1.DTREF) FROM TGFEMPSN E1 WHERE E1.CODEMP = P_CODEMP AND E1.DTREF <= P_DTNEG)
    AND PSN.NUPARTILHA = EXP.NUPARTILHA;

    IF P_COUNT > 1 THEN
        SELECT ITE.CODPROD, ITE.USOPROD
        INTO P_CODPROD, P_USOPROD
        FROM TGFITE ITE
        WHERE ITE.NUNOTA = P_NUNOTA AND ITE.SEQUENCIA = P_SEQUENCIA;
		

        IF P_USOPROD = 'S' THEN
            SELECT CASE WHEN SEM.TIPOSN IS NOT NULL THEN SEM.TIPOSN ELSE PRO.TIPOSN END
              INTO P_TIPOSN
              FROM TGFPRO PRO
              LEFT JOIN TGFSEM SEM ON SEM.CODPROD = P_CODPROD AND SEM.CODEMP = P_CODEMP
            WHERE PRO.CODPROD = P_CODPROD;
        ELSIF P_USOPROD <> 'V' THEN
            P_TIPOSN := 1;
        ELSE
            P_TIPOSN := 2;
        END IF;

        SELECT (  NVL (PSN.ALIQIRPJ, 0)
                + NVL (PSN.ALIQCSLL, 0)
                + NVL (PSN.ALIQCOFINS, 0)
                + NVL (PSN.ALIQPISPASEP, 0)
                + NVL (PSN.ALIQCPP, 0)
                + NVL (PSN.ALIQIPI, 0)
                + NVL (PSN.ALIQISS, 0))
        INTO P_PARTILHA
        FROM TGFEMPSN EXP, TGFPSN PSN
        WHERE  EXP.CODEMP = P_CODEMP
        AND PSN.NUPARTILHA = EXP.NUPARTILHA
        AND PSN.TIPOSN = P_TIPOSN
        AND EXP.DTREF =
                      (SELECT MAX (E1.DTREF)
                         FROM TGFEMPSN E1, TGFPSN P1
                        WHERE E1.CODEMP = P_CODEMP
                          AND E1.NUPARTILHA = P1.NUPARTILHA
                          AND P1.TIPOSN = P_TIPOSN
                          AND E1.DTREF <= P_DTNEG)
		AND EXP.NUPARTILHA =
                      (SELECT MAX (E1.NUPARTILHA)
                         FROM TGFEMPSN E1, TGFPSN P1
                        WHERE E1.CODEMP = P_CODEMP
                          AND E1.NUPARTILHA = P1.NUPARTILHA
                          AND P1.TIPOSN = P_TIPOSN
                          AND E1.DTREF <= P_DTNEG);
    END IF;

   RETURN (P_PARTILHA);
END;
