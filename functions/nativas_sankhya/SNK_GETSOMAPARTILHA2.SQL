/*==============================================================================
  Nome do Script : SNK_GETSOMAPARTILHA2
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Variante de SNK_GETSOMAPARTILHA recebendo empresa/data/produto/uso/tipoSN
                  diretamente, sem NUNOTA/SEQUENCIA.
  Assinatura     : SNK_GETSOMAPARTILHA2 (P_CODEMP NUMBER, P_DTNEG DATE, P_CODPROD NUMBER, P_USOPROD VARCHAR2, P_TIPOSN INTEGER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETSOMAPARTILHA2', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETSOMAPARTILHA2 (P_CODEMP NUMBER, P_DTNEG DATE, P_CODPROD NUMBER, P_USOPROD VARCHAR2, P_TIPOSN INTEGER)
   RETURN NUMBER
IS
   P_PARTILHA   NUMBER;
   P_COUNT      INTEGER;
   P_TIPOSNAUX  INTEGER;
BEGIN
    SELECT COUNT (DISTINCT PSN.TIPOSN)
        , SUM(  NVL (PSN.ALIQIRPJ, 0)
              + NVL (PSN.ALIQCSLL, 0)
              + NVL (PSN.ALIQCOFINS, 0)
              + NVL (PSN.ALIQPISPASEP, 0)
              + NVL (PSN.ALIQCPP, 0)
              + NVL (PSN.ALIQIPI, 0)
              + NVL (PSN.ALIQISS, 0))
    INTO P_COUNT, P_PARTILHA
    FROM TGFEMPSN EXP, TGFPSN PSN
    WHERE EXP.CODEMP = P_CODEMP
    AND EXP.DTREF = (SELECT MAX (E1.DTREF) FROM TGFEMPSN E1 WHERE E1.CODEMP = P_CODEMP AND E1.DTREF <= P_DTNEG)
    AND PSN.NUPARTILHA = EXP.NUPARTILHA;

    IF P_COUNT > 1 THEN
        IF P_USOPROD = 'S' THEN
            SELECT MIN(CASE WHEN SEM.TIPOSN IS NOT NULL THEN SEM.TIPOSN ELSE P_TIPOSN END)
            INTO P_TIPOSNAUX
            FROM TGFSEM SEM
            WHERE SEM.CODPROD = P_CODPROD
            AND SEM.CODEMP = P_CODEMP;
        ELSIF P_USOPROD <> 'V' THEN
            P_TIPOSNAUX := 1;
        ELSE
            P_TIPOSNAUX := 2;
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
        AND PSN.TIPOSN = P_TIPOSNAUX
        AND EXP.DTREF =
                      (SELECT MAX (E1.DTREF)
                         FROM TGFEMPSN E1, TGFPSN P1
                        WHERE E1.CODEMP = P_CODEMP
                          AND E1.NUPARTILHA = P1.NUPARTILHA
                          AND P1.TIPOSN = P_TIPOSNAUX
                          AND E1.DTREF <= P_DTNEG);
    END IF;

   RETURN (P_PARTILHA);
END;
