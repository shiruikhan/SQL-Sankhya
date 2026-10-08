/*==============================================================================
  Nome do Script : FLW_GET_RESPONSAVEL_TAREFA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do usuario dono da tarefa pendente mais
                  antiga de uma instancia de processo do workflow (TWFITAR).
  Assinatura     : FLW_GET_RESPONSAVEL_TAREFA (P_INSTANCIA_PROCESSO NUMBER)
                  RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FLW_GET_RESPONSAVEL_TAREFA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FLW_GET_RESPONSAVEL_TAREFA (P_INSTANCIA_PROCESSO NUMBER)
RETURN NUMBER
AS  
    P_VALOR NUMBER(10);
BEGIN
    BEGIN
        SELECT CODUSUDONO INTO P_VALOR FROM (
            SELECT 
                ITAR_SUB.CODUSUDONO 
            FROM 
                TWFITAR ITAR_SUB
            WHERE 
                ITAR_SUB.DHCONCLUSAO IS NULL
                AND ITAR_SUB.CODUSUDONO IS NOT NULL
                AND ITAR_SUB.IDINSTPRN = P_INSTANCIA_PROCESSO
                ORDER BY ITAR_SUB.DHCRIACAO ASC
        ) WHERE rownum <= 1;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END;
    
    RETURN P_VALOR;
END;
