/*==============================================================================
  Nome do Script : SNK_VERIFICA_SE_UTILIZA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Executa dinamicamente um COUNT(*) sobre uma tabela/condicao informada e
                  retorna 'S'/'N' conforme existencia de registros.
  Assinatura     : SNK_VERIFICA_SE_UTILIZA (P_FROM VARCHAR, P_WHERE VARCHAR)
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VERIFICA_SE_UTILIZA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VERIFICA_SE_UTILIZA (P_FROM VARCHAR, P_WHERE VARCHAR) 
RETURN VARCHAR IS
    V_QUERY         VARCHAR2(1000);   
    V_RESULT        NUMBER(10); 
BEGIN
    V_QUERY := 'SELECT COUNT(*) FROM ' || P_FROM || CASE WHEN P_WHERE IS NOT NULL THEN ' WHERE ' || P_WHERE ELSE '' END;

    BEGIN
        EXECUTE IMMEDIATE V_QUERY INTO V_RESULT;
    EXCEPTION
        WHEN OTHERS THEN
            V_RESULT := 0;
    END;

    RETURN (CASE WHEN V_RESULT > 0 THEN 'S' ELSE 'N' END);
END;
