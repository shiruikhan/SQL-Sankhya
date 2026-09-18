/*==============================================================================
  Nome do Script : SNK_GETVLRTGFDINSIMPLES
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o valor liquido de ICMS (valor menos reducao) de um item para
                  contribuintes do Simples Nacional com CST preenchido.
  Assinatura     : SNK_GETVLRTGFDINSIMPLES ( P_NUNOTA NUMBER, P_SEQUENCIA NUMBER )
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETVLRTGFDINSIMPLES', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETVLRTGFDINSIMPLES (
    P_NUNOTA    NUMBER,
    P_SEQUENCIA NUMBER
	)
RETURN NUMBER
 IS P_VLRAUX     NUMBER;    
BEGIN
  IF (P_NUNOTA = 0) THEN
     RETURN( 0 );
  END IF;

  SELECT NVL(ROUND(SUM(VALOR - VLRREPRED),2),0) INTO P_VLRAUX
  FROM TGFDIN 
  WHERE NUNOTA = P_NUNOTA 
  AND SEQUENCIA = P_SEQUENCIA
  AND CODIMP = 1
  AND NVL(CST,0) <> 0;
  
  RETURN (P_VLRAUX);
END;
