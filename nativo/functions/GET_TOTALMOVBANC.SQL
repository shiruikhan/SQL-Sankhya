/*==============================================================================
  Nome do Script : GET_TOTALMOVBANC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Totaliza movimentos bancarios (TGFMBC) de uma conta e
                  periodo por tipo, convertendo moedas.
  Assinatura     : GET_TOTALMOVBANC (P_TIPO VARCHAR, P_RECDESP NUMBER,
                  P_CODCTABCOINT NUMBER, P_CODMOEDA NUMBER, P_CODMOEDA_SEL
                  NUMBER, P_DATINI DATE, P_DATFIM DATE, P_DTCONVMOEDA DATE)
                  RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TOTALMOVBANC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TOTALMOVBANC (P_TIPO VARCHAR, 
                                            P_RECDESP NUMBER,
                                            P_CODCTABCOINT NUMBER,
                                            P_CODMOEDA NUMBER,
                                            P_CODMOEDA_SEL NUMBER,
                                            P_DATINI DATE, 
                                            P_DATFIM DATE,
                                            P_DTCONVMOEDA DATE)
RETURN FLOAT
IS
  CURSOR CUR_CONSULTA IS 
    SELECT DTLANC, VLRMOEDA, SUM(VLRLANC) AS TOTAL
    FROM TGFMBC
    WHERE CODCTABCOINT = P_CODCTABCOINT
      AND DTLANC >= TRUNC (P_DATINI)
      AND DTLANC < TRUNC (P_DATFIM + 1)
      AND ((P_TIPO = 'RECPAG' AND ORIGMOV = 'F') OR (P_TIPO = 'CREDDEB' AND ORIGMOV <> 'F'))
      AND RECDESP = P_RECDESP
    GROUP BY DTLANC, VLRMOEDA;
  P_VLRTOTALACUM  FLOAT;
  P_DTLANC        DATE;
  P_VLRMOEDA      FLOAT;
  P_TOTAL         FLOAT;
  P_DTMOEDA       DATE;
  P_VLRMOEDAUTIL  FLOAT;
  P_ERRMSG        VARCHAR2(4000);
BEGIN
  P_VLRTOTALACUM := 0;
  OPEN CUR_CONSULTA;
  LOOP 
    FETCH CUR_CONSULTA INTO P_DTLANC, P_VLRMOEDA, P_TOTAL;
    EXIT WHEN CUR_CONSULTA%NOTFOUND;
    
    IF P_TOTAL <> 0 AND P_CODMOEDA <> P_CODMOEDA_SEL THEN
      P_DTMOEDA := TRUNC(NVL(P_DTCONVMOEDA, TRUNC(P_DTLANC)));
      IF P_CODMOEDA <> 0 THEN
        IF P_VLRMOEDA > 0 AND P_DTMOEDA = TRUNC(P_DTLANC) THEN
          P_VLRMOEDAUTIL := P_VLRMOEDA;
        ELSE
          P_VLRMOEDAUTIL := GET_PRECOMOEDA(P_CODMOEDA, TRUNC(P_DTLANC));
        END IF;
        
        IF P_VLRMOEDAUTIL <> 0 THEN
          P_TOTAL := ROUND(P_TOTAL * P_VLRMOEDAUTIL, 2);
        END IF;
      END IF; 
      
      IF P_CODMOEDA_SEL <> 0 THEN
        P_VLRMOEDAUTIL := GET_PRECOMOEDA(P_CODMOEDA_SEL, P_DTMOEDA);
        IF P_VLRMOEDAUTIL = 0 THEN
          P_ERRMSG := 'A moeda de código ' || P_CODMOEDA_SEL || ' na data ' || TO_CHAR(P_DTMOEDA, 'DD/MM/YYYY')|| 'está com a cotação zerada ou não está cadastrada!';
          RAISE_APPLICATION_ERROR(-20101, P_ERRMSG);
        END IF;          
        
        P_TOTAL := P_TOTAL / P_VLRMOEDAUTIL;
      END IF;
    END IF;
    P_VLRTOTALACUM := P_VLRTOTALACUM + P_TOTAL;         
  END LOOP;

  RETURN P_VLRTOTALACUM;
END;
