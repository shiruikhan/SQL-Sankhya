/*==============================================================================
  Nome do Script : GET_PRECOMOEDA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a cotacao da moeda (TSICOT) na data, seguindo o
                  parametro PROCMOE e o tratamento para cotacao inexistente
                  (PROCMOEINEX).
  Assinatura     : GET_PRECOMOEDA (P_CODMOEDA INTEGER, P_DATANEGOC DATE) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_PRECOMOEDA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_PRECOMOEDA (P_CODMOEDA INTEGER, P_DATANEGOC DATE) 
RETURN FLOAT
IS
  P_PROCMOEDA               NUMBER(10);
  P_DATMOEDA                DATE;
  P_VALORMOEDA              FLOAT;
  P_COTACAO                 FLOAT;
  P_COTACAOANT              FLOAT;
  P_COTACAOPROX             FLOAT;
  P_PROCMOEDAINEXISTENTE    NUMBER(10);
BEGIN
  P_PROCMOEDA := GET_TSIPAR_INTEIRO('PROCMOE');
  IF (P_PROCMOEDA = 2) AND (P_DATANEGOC IS NOT NULL) THEN
    P_DATMOEDA := P_DATANEGOC;
  ELSE
    P_DATMOEDA := TRUNC(SYSDATE);
    IF P_PROCMOEDA = 3 THEN
      P_DATMOEDA := TRUNC(P_DATMOEDA, 'MM'); --INICIO DO MES
    ELSIF P_PROCMOEDA = 4 THEN
      P_DATMOEDA := LAST_DAY(P_DATMOEDA); --FIM DO MES
    END IF;
  END IF;
  P_VALORMOEDA := 0;
    
  BEGIN
    SELECT NVL(COTACAO, 0) INTO P_COTACAO 
    FROM TSICOT
    WHERE CODMOEDA = P_CODMOEDA
      AND DTMOV = P_DATMOEDA;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    P_COTACAO := 0;
  END;
  
  IF P_COTACAO = 0 THEN
    P_PROCMOEDAINEXISTENTE := GET_TSIPAR_INTEIRO('PROCMOEINEX');
    IF P_PROCMOEDAINEXISTENTE = 0 THEN        
      BEGIN
        SELECT COTACAO INTO P_COTACAO
        FROM TSICOT C1
        WHERE CODMOEDA = P_CODMOEDA
          AND DTMOV = (SELECT MAX(C2.DTMOV) 
                       FROM TSICOT C2
                       WHERE C2.CODMOEDA = P_CODMOEDA
                         AND C2.DTMOV  = P_DATMOEDA);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        P_COTACAO := 0;
      END;
      P_VALORMOEDA := P_COTACAO;
    ELSIF P_PROCMOEDAINEXISTENTE = 1 THEN
      BEGIN
        SELECT COTACAO INTO P_COTACAO
        FROM TSICOT C1
        WHERE CODMOEDA = P_CODMOEDA
          AND DTMOV = (SELECT MIN(C2.DTMOV) 
                       FROM TSICOT C2
                       WHERE C2.CODMOEDA = P_CODMOEDA
                         AND C2.DTMOV  = P_DATMOEDA);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        P_COTACAO := 0;
      END;
      P_VALORMOEDA := P_COTACAO;
    ELSIF P_PROCMOEDAINEXISTENTE = 2 THEN
      BEGIN
        SELECT COTACAO INTO P_COTACAOANT
        FROM TSICOT C1
        WHERE CODMOEDA = P_CODMOEDA
          AND DTMOV = (SELECT MAX(C2.DTMOV) 
                       FROM TSICOT C2
                       WHERE C2.CODMOEDA = P_CODMOEDA
                         AND C2.DTMOV  = P_DATMOEDA);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        P_COTACAOANT := 0;
      END;

      BEGIN
        SELECT COTACAO INTO P_COTACAOPROX
        FROM TSICOT C1
        WHERE CODMOEDA = P_CODMOEDA
          AND DTMOV = (SELECT MIN(C2.DTMOV) 
                       FROM TSICOT C2
                       WHERE C2.CODMOEDA = P_CODMOEDA
                         AND C2.DTMOV  = P_DATMOEDA);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        P_COTACAOPROX := 0;
      END;
      
      IF P_COTACAOANT = 0 THEN
        P_VALORMOEDA := P_COTACAOPROX;
      ELSIF P_COTACAOPROX = 0 THEN 
        P_VALORMOEDA := P_COTACAOANT;
      ELSE
        P_VALORMOEDA := (P_COTACAOANT + P_COTACAOPROX) / 2; 
      END IF;
    END IF;
    
  ELSE 
    P_VALORMOEDA := P_COTACAO;
  END IF;
  
  RETURN P_VALORMOEDA;
END;
