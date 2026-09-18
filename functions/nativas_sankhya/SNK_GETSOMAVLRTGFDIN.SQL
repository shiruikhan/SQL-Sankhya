/*==============================================================================
  Nome do Script : SNK_GETSOMAVLRTGFDIN
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma os valores de impostos (TGFDIN) de um item, excluindo os codigos de
                  imposto da reforma tributaria (12 a 17).
  Assinatura     : SNK_GETSOMAVLRTGFDIN ( P_NUNOTA NUMBER, P_SEQUENCIA NUMBER )
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETSOMAVLRTGFDIN', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETSOMAVLRTGFDIN (
    P_NUNOTA    NUMBER,
    P_SEQUENCIA NUMBER
	)
RETURN NUMBER
 IS P_VLRAUX  NUMBER;    
BEGIN
  IF (P_NUNOTA = 0) THEN
     RETURN( 0 );
  END IF;

  BEGIN
    SELECT NVL(ROUND(SUM(VALOR),2),0) 
    INTO P_VLRAUX
    FROM TGFDIN 
    WHERE NUNOTA = P_NUNOTA 
    AND SEQUENCIA = P_SEQUENCIA
    AND CODIMP NOT IN (12, 13, 14, 15, 16, 17) -- IMPOSTOS DA REFORMA TRIBUTARIA
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      P_VLRAUX := 0;
  END;
  
  RETURN (P_VLRAUX);
END;
