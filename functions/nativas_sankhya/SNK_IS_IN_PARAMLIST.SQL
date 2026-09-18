/*==============================================================================
  Nome do Script : SNK_IS_IN_PARAMLIST
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Verifica se um valor esta presente em uma lista configurada em parametro
                  de sistema (TSIPAR).
  Assinatura     : SNK_IS_IN_PARAMLIST (P_PARAM VARCHAR, P_VALUE VARCHAR, P_EMPTY CHAR)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_IS_IN_PARAMLIST', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_IS_IN_PARAMLIST (P_PARAM VARCHAR, P_VALUE VARCHAR, P_EMPTY CHAR)
RETURN CHAR
IS
    P_PARAMLIST VARCHAR2(255);
BEGIN
    P_PARAMLIST := REPLACE(GET_TSIPAR_TEXTO(P_PARAM), ' ', '');
    
    IF (NVL(P_PARAMLIST, ' ') = ' ') THEN
        RETURN P_EMPTY;
    ELSE
        P_PARAMLIST := (',' || P_PARAMLIST || ',');
        
        RETURN CASE WHEN INSTR(P_PARAMLIST, (',' || P_VALUE || ',')) > 0 THEN 'S' ELSE 'N' END;
    END IF;
    
    RETURN 'S';	
END;
