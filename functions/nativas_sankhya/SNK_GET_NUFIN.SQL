/*==============================================================================
  Nome do Script : SNK_GET_NUFIN
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Gera o proximo NUFIN valido para TGFFIN, varrendo lacunas na sequencia e
                  realinhando a sequence quando necessario.
  Assinatura     : SNK_GET_NUFIN (sem parametros)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_NUFIN', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_NUFIN 
RETURN NUMBER
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_LOTE        NUMBER(10,0);
  P_VALOR       NUMBER(10,0);
  P_ULTCOD      NUMBER(10,0);
  P_MINNUFIN    NUMBER(10,0); 
  P_MAXNUFIN    NUMBER(10,0);
  P_COUNT       NUMBER(10,0);
  P_FICA        BOOLEAN;
  P_RECOMECOU   BOOLEAN;
BEGIN

  SELECT SEQ_TGFFIN_NUFIN.NEXTVAL
  INTO P_VALOR
  FROM DUAL;
  
  P_ULTCOD := P_VALOR; --N?o mexer no P_VALOR para verificar no final se o P_ULTCOD foi alterado.
  
  SELECT COUNT(1)
  INTO P_COUNT
  FROM TGFFIN
  WHERE NUFIN = P_ULTCOD;
  IF P_COUNT = 0 THEN
    RETURN P_ULTCOD;     
  END IF;

  P_ULTCOD := P_ULTCOD + 1;
  P_RECOMECOU := FALSE;
  P_LOTE := 100000000; -- 100.000.000
  P_FICA := TRUE;
  --Verifica em lotes se tem algum numero faltando
  WHILE P_FICA LOOP
    SELECT MIN(NUFIN), MAX(NUFIN), COUNT(1)
    INTO P_MINNUFIN, P_MAXNUFIN, P_COUNT
    FROM TGFFIN
    WHERE NUFIN BETWEEN P_ULTCOD AND P_ULTCOD + P_LOTE - 1; -- 1 ate ((1+100-1) = 100)
    
    IF P_MINNUFIN IS NULL OR P_MINNUFIN > P_ULTCOD THEN
      --se MIN(NUFIN) diferente do valor valor pretendido pode sair do loop e utiliza-lo
      P_FICA := FALSE;
    ELSIF P_COUNT < P_LOTE THEN
    
     --Se max(nufin) for menor que 100 sai do loop, se n?o tira um zero do lote ate que ele chegue a 100
      IF P_LOTE > 100 AND P_MAXNUFIN > 100 THEN
        P_LOTE := TRUNC(P_LOTE / 10);
        
        --se o lote for maior que max(nufin) diminui do lote o numero de zeros necessarios para o lote ficar menor que max(nufin) 
        IF P_LOTE > P_MAXNUFIN THEN
          P_LOTE := POWER(10, LENGTH(P_MAXNUFIN)-1);
        END IF;
        P_ULTCOD := P_ULTCOD + 1;
      ELSE
        P_FICA := FALSE;
      END IF;
    
    ELSE
      P_ULTCOD := P_ULTCOD + P_LOTE;
      
      IF P_ULTCOD > 1999999999 THEN --1.999.999.999
        IF P_RECOMECOU THEN
          RAISE_APPLICATION_ERROR (-20101, 'N?o achamos numero disponivel para novos registros na TGFFIN.');
        END IF;
        P_ULTCOD := 1;
        P_LOTE := 100000000;
        P_RECOMECOU := TRUE;
      END IF;
    
    END IF;
  
  END LOOP;
  
  --Se o P_MINNUFIN for maior que o P_ULTCOD n?o precisa procurar mais
  IF NVL(P_MINNUFIN,0) = P_ULTCOD THEN
    P_FICA := TRUE;
  END IF;
  
  WHILE P_FICA LOOP
  
    FOR FIN IN (
      SELECT NUFIN
      FROM TGFFIN
      WHERE NUFIN BETWEEN P_ULTCOD AND P_ULTCOD + 99  -- 1 ate ((1+99) = 100)
      ORDER BY NUFIN)
    LOOP
    
      IF FIN.NUFIN > P_ULTCOD THEN         
        P_FICA := FALSE;
        EXIT;
      ELSE
        P_ULTCOD := P_ULTCOD + 1;
        IF P_ULTCOD > 1999999999 THEN
          RAISE_APPLICATION_ERROR (-20101, 'N?o achamos numero disponivel para novos registros na TGFFIN.');
        END IF;
      END IF;

    END LOOP;

  END LOOP;
    
  IF P_ULTCOD <> P_VALOR THEN
    --Altera a o incremento da sequencia para a diferenca entre o novo valor e valor antigo 
    EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_TGFFIN_NUFIN INCREMENT BY ' || TO_CHAR(P_ULTCOD - P_VALOR) || ' MINVALUE 0';
    --Ajusta o valor da sequencia para a nova sequencia desejada
    EXECUTE IMMEDIATE 'SELECT SEQ_TGFFIN_NUFIN.NEXTVAL FROM DUAL' INTO P_VALOR;
    --Volta o incremento para 1
    EXECUTE IMMEDIATE 'ALTER SEQUENCE SEQ_TGFFIN_NUFIN INCREMENT BY 1 MINVALUE 1';
  END IF;
  
  RETURN P_ULTCOD;     
END;

 
 
