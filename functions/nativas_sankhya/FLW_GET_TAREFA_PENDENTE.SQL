/*==============================================================================
  Nome do Script : FLW_GET_TAREFA_PENDENTE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o nome do elemento (tarefa) pendente mais antigo de
                  uma instancia de processo do workflow.
  Assinatura     : FLW_GET_TAREFA_PENDENTE (P_INSTANCIA_PROCESSO NUMBER) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FLW_GET_TAREFA_PENDENTE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FLW_GET_TAREFA_PENDENTE (P_INSTANCIA_PROCESSO NUMBER)
RETURN VARCHAR2
AS  
    P_VALOR VARCHAR(4000);
BEGIN
    BEGIN
        SELECT NOME INTO P_VALOR FROM (SELECT ELE_SUB.NOME
		FROM TWFITAR ITAR_SUB
	    INNER JOIN TWFIPRN IRPN_SUB ON (IRPN_SUB.IDINSTPRN = ITAR_SUB.IDINSTPRN) 
	    INNER JOIN TWFELE ELE_SUB ON (ELE_SUB.CODPRN = IRPN_SUB.CODPRN AND ELE_SUB.VERSAO = IRPN_SUB.VERSAO AND ELE_SUB.IDELEMENTO = ITAR_SUB.IDELEMENTO AND ELE_SUB.CODPRN = IRPN_SUB.CODPRN)
		WHERE ITAR_SUB.DHCONCLUSAO IS NULL
              AND ITAR_SUB.IDINSTPRN = P_INSTANCIA_PROCESSO
              ORDER BY ITAR_SUB.DHCRIACAO ASC) WHERE rownum <= 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    
    RETURN P_VALOR;
END;
