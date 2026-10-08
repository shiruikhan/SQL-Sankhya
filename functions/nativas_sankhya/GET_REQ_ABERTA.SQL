/*==============================================================================
  Nome do Script : GET_REQ_ABERTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Indica se existe outra requisicao de vaga em aberto para a
                  mesma selecao (TRSREQ/TRSRQS).
  Assinatura     : GET_REQ_ABERTA (P_NUREQUISICAO INT) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_REQ_ABERTA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_REQ_ABERTA (P_NUREQUISICAO INT)
RETURN VARCHAR2
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_COUNT		NUMBER(10);
  P_RETURN		VARCHAR2(1);
BEGIN
  SELECT COUNT(1) INTO P_COUNT 
  FROM TRSREQ REQ
     , TRSRQS RQS	 
  WHERE REQ.STATUS <> 'F' 
    AND RQS.NUREQUISICAO = REQ.NUREQUISICAO
    AND RQS.NUSELECAO = (SELECT MIN(NUSELECAO) 
	                     FROM TRSRQS R
						 WHERE R.NUREQUISICAO = P_NUREQUISICAO)
    AND RQS.NUREQUISICAO <> P_NUREQUISICAO; 
  COMMIT;
  IF P_COUNT > 0 THEN
    P_RETURN := 'S';
  ELSE
    P_RETURN := 'N';
  END IF;
  RETURN P_RETURN;
END;
