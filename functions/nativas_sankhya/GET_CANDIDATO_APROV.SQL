/*==============================================================================
  Nome do Script : GET_CANDIDATO_APROV
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se o candidato ja foi aprovado em alguma selecao
                  (TRSCAN/TRSSEL).
  Assinatura     : GET_CANDIDATO_APROV (P_NUCURRICULO INT, P_NUSELECAO INT)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_CANDIDATO_APROV', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_CANDIDATO_APROV (P_NUCURRICULO INT, P_NUSELECAO  INT)
RETURN VARCHAR2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_COUNT		NUMBER(10);
  P_RETURN		VARCHAR2(1);
BEGIN
  SELECT COUNT(1) INTO P_COUNT
  FROM TRSCAN C
     , TRSSEL S
  WHERE C.NUCURRICULO = P_NUCURRICULO
    AND C.NUSELECAO = S.NUSELECAO
    AND C.STATUSAPROV = 'A'
    AND (S.SITSELECAO IN (1, 2) OR C.NUSELECAO = P_NUSELECAO);
  COMMIT;
  IF P_COUNT > 0 THEN
    P_RETURN := 'S';
  ELSE
    P_RETURN := 'N';
  END IF;
  RETURN P_RETURN;	
END;
