/*==============================================================================
  Nome do Script : ACT_INT_FIELD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le um parametro inteiro (NUMINT) de uma linha especifica da
                  sessao de acao em EXECPARAMS.
  Assinatura     : ACT_INT_FIELD (P_CHAVE VARCHAR2, P_LINHA NUMBER, P_NOME
                  VARCHAR2) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'ACT_INT_FIELD', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION ACT_INT_FIELD (P_CHAVE VARCHAR2, P_LINHA NUMBER, P_NOME VARCHAR2)
RETURN NUMBER
IS  
	P_VALOR NUMBER;
BEGIN
    BEGIN
         SELECT NUMINT INTO P_VALOR
         FROM EXECPARAMS
         WHERE IDSESSAO = P_CHAVE 
		   AND SEQUENCIA = P_LINHA 
		   AND NOME = P_NOME;
    EXCEPTION WHEN NO_DATA_FOUND THEN
		 RETURN NULL;        
    END;
	
    RETURN P_VALOR;		
END;
