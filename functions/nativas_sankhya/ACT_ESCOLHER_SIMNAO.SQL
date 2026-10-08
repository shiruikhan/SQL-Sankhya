/*==============================================================================
  Nome do Script : ACT_ESCOLHER_SIMNAO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Le a escolha Sim/Nao da sessao de acao em EXECPARAMS; se
                  ainda nao houve resposta, levanta ORA-20101 para abrir o
                  popup.
  Assinatura     : ACT_ESCOLHER_SIMNAO (P_TITULO VARCHAR2, P_TEXTO VARCHAR2,
                  P_CHAVE VARCHAR2, P_SEQUENCIA NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'ACT_ESCOLHER_SIMNAO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION ACT_ESCOLHER_SIMNAO (P_TITULO VARCHAR2, P_TEXTO VARCHAR2, P_CHAVE VARCHAR2, P_SEQUENCIA NUMBER)
RETURN VARCHAR2
IS  
	P_STATUS VARCHAR2(1);
BEGIN
    BEGIN
         SELECT TEXTO INTO P_STATUS
         FROM EXECPARAMS
         WHERE IDSESSAO = P_CHAVE 
		   AND SEQUENCIA = P_SEQUENCIA 
		   AND NOME = '__ESCOLHA_SIMNAO__';
    EXCEPTION WHEN NO_DATA_FOUND THEN
	    RAISE_APPLICATION_ERROR(-20101, '__TITULO__' || P_TITULO || '__TEXTO__' || P_TEXTO || '__SEQUENCIA__' || P_SEQUENCIA || '__OPCAON__S__');        
    END;
	
    RETURN P_STATUS;
END;
