/*==============================================================================
  Nome do Script : SNK_GET_PROX_SEQ_TGMTRA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a proxima sequencia disponivel de transferencia (TGMTRA) dentro de
                  uma faixa (range) informada.
  Assinatura     : SNK_GET_PROX_SEQ_TGMTRA (P_NUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_SEQUENCIA INT, P_RANGE NUMBER)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PROX_SEQ_TGMTRA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PROX_SEQ_TGMTRA (P_NUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_SEQUENCIA INT, P_RANGE NUMBER)
RETURN NUMBER
IS  
  P_RETURN	 NUMBER(10) := 0;  
BEGIN  
    SELECT NVL(MAX(T2.SEQUENCIA), P_RANGE) + 1
    INTO P_RETURN
    FROM TGMTRA T2
    WHERE T2.NUMTRANSF = P_NUMTRANSF
      AND T2.SEQUENCIA >= P_RANGE + 1
      AND T2.SEQUENCIA <= P_RANGE + 999
	  AND T2.SEQUENCIAITE = P_SEQUENCIA;
  RETURN P_RETURN; 
END;
