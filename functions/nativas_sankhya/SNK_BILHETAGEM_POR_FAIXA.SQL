/*==============================================================================
  Nome do Script : SNK_BILHETAGEM_POR_FAIXA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o valor total de bilhetagem de um contrato por faixa de preco,
                  respeitando faturamento minimo (TCSCON/TGFBIL/TCSPPF).
  Assinatura     : SNK_BILHETAGEM_POR_FAIXA ( P_NUMCONTRATO IN NUMBER, P_CODPROD IN NUMBER, P_PRECO IN FLOAT, P_DTFIMMED IN DATE)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_BILHETAGEM_POR_FAIXA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_BILHETAGEM_POR_FAIXA (
  P_NUMCONTRATO IN NUMBER,
  P_CODPROD IN NUMBER,
  P_PRECO IN FLOAT,
  P_DTFIMMED IN DATE)
RETURN FLOAT
IS  P_PRECOUNIT    FLOAT;
    P_VLRTOT       FLOAT;
    P_VLRFATMIN    FLOAT;
	P_QTD          FLOAT;
	P_DIAFIMMED    NUMBER;
BEGIN
  SELECT NVL(DIAFIMMED,0)
  INTO P_DIAFIMMED
  FROM TCSCON
  WHERE NUMCONTRATO = P_NUMCONTRATO;
  
  SELECT SUM(QTDNEG)
  INTO P_QTD 
  FROM TGFBIL BIL
  WHERE BIL.NUMCONTRATO = P_NUMCONTRATO
  AND BIL.CODPROD = P_CODPROD
  AND BIL.NUNOTAFATUR IS NULL
  AND BIL.DTMOV <= (P_DTFIMMED + P_DIAFIMMED);

  IF P_QTD > 0 THEN 
    SELECT NVL(MAX(PRECOUNIT),0), NVL(MAX(VLRFATMIN),0) 
    INTO P_PRECOUNIT, P_VLRFATMIN 
    FROM TCSPPF
    WHERE CODPROD = P_CODPROD
    AND NUMCONTRATO = P_NUMCONTRATO
    AND QTDINICIAL <= P_QTD
    AND QTDFINAL >= P_QTD;

	P_VLRTOT := ROUND(P_PRECOUNIT * P_QTD,2);
    IF P_VLRTOT > P_VLRFATMIN THEN
      RETURN (P_VLRTOT);
    ELSE 
	  RETURN (P_VLRFATMIN);
    END IF;
  ELSE
    RETURN (0);
  END IF; 
EXCEPTION WHEN NO_DATA_FOUND THEN 
  RETURN (0);
END;

 
 
