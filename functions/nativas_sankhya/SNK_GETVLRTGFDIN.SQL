/*==============================================================================
  Nome do Script : SNK_GETVLRTGFDIN
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a soma de um campo especifico de TGFDIN (base, valor, credito
                  etc.), filtrando por imposto, incidencia e opcao pelo Simples Nacional.
  Assinatura     : SNK_GETVLRTGFDIN ( P_NUNOTA NUMBER, P_SEQUENCIA NUMBER, P_CODIMP NUMBER, P_CODINC NUMBER, P_CAMPO VARCHAR, P_SIMPLESNAC VARCHAR)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETVLRTGFDIN', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETVLRTGFDIN (
    P_NUNOTA    NUMBER,
    P_SEQUENCIA NUMBER,
    P_CODIMP    NUMBER,
    P_CODINC    NUMBER,
    P_CAMPO     VARCHAR,
    P_SIMPLESNAC VARCHAR)
RETURN NUMBER
 IS P_VLRAUX     NUMBER;    
BEGIN
  IF (P_NUNOTA = 0) OR (P_CAMPO = '') THEN
     RETURN( 0 );
  END IF;

  SELECT NVL(ROUND(SUM(CASE WHEN P_CAMPO = 'BASE' THEN BASE
                             WHEN P_CAMPO = 'BASERED' THEN BASERED
                             WHEN P_CAMPO = 'VALOR' THEN VALOR
                             WHEN P_CAMPO = 'VLRREPRED' THEN VLRREPRED
                             WHEN P_CAMPO = 'VLRCRED' THEN VLRCRED
							 WHEN P_CAMPO = 'PERCFCPINT' THEN PERCFCPINT
							 WHEN P_CAMPO = 'BASEFCPINT' THEN BASEFCPINT
							 WHEN P_CAMPO = 'BASENORMDIFICMS' THEN BASENORMDIFICMS
							 WHEN P_CAMPO = 'VALORDESON' THEN VALORDESON

                             ELSE 0 END),2),0) INTO P_VLRAUX
  FROM TGFDIN 
  WHERE NUNOTA = P_NUNOTA 
  AND SEQUENCIA > 0
  AND (P_SEQUENCIA = 0 OR SEQUENCIA = P_SEQUENCIA)
  AND (P_CODIMP = 0 OR CODIMP = P_CODIMP)
  AND (P_CODINC = 0 OR CODINC = P_CODINC) 
  AND ( (P_CODIMP <> 1) OR
      (P_SIMPLESNAC = 'S' AND NVL(CST,0) <> 0) OR /*SIMPLES NACIONAL*/
      (P_SIMPLESNAC = 'N' AND NVL(CST,0) = 0) /*NAO SIMPLES NACIONAL*/ );
  
  RETURN (P_VLRAUX);
END;
