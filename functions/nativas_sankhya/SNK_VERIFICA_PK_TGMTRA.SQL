/*==============================================================================
  Nome do Script : SNK_VERIFICA_PK_TGMTRA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica colisao de chave em TGMTRA (NUMTRANSF/SEQUENCIA/SEQUENCIAITE) e
                  retorna um novo NUMTRANSF livre se necessario.
  Assinatura     : SNK_VERIFICA_PK_TGMTRA (P_NUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_SEQUENCIA IN NUMBER, P_SEQITE IN NUMBER)
                   RETURN TGMTRA
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VERIFICA_PK_TGMTRA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VERIFICA_PK_TGMTRA (P_NUMTRANSF TGMTRA.NUMTRANSF%TYPE, P_SEQUENCIA IN NUMBER, P_SEQITE IN NUMBER)
RETURN TGMTRA.NUMTRANSF%TYPE
AS
  P_COUNT   NUMBER(10);
  P_NEWNUMTRANSF TGMTRA.NUMTRANSF%TYPE := P_NUMTRANSF;
BEGIN
	  P_COUNT := 0;
	  SELECT COUNT(1) INTO P_COUNT FROM TGMTRA WHERE NUMTRANSF = P_NUMTRANSF AND SEQUENCIA = P_SEQUENCIA AND SEQUENCIAITE = P_SEQITE;
	    IF(P_COUNT > 0) THEN
	        SELECT MAX(NUMTRANSF)+1 INTO P_NEWNUMTRANSF FROM TGMTRA;
	    END IF;
  RETURN P_NEWNUMTRANSF; 
END;
