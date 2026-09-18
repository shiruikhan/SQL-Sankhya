/*==============================================================================
  Nome do Script : SNK_GETTIMEZONE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o timezone atual do servidor de banco (formato TZR).
  Assinatura     : SNK_GETTIMEZONE (sem parametros)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETTIMEZONE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETTIMEZONE 
RETURN VARCHAR2
IS P_RESULTADO VARCHAR2(6);
BEGIN
  /*BEGIN
    SELECT TO_CHAR(SYSTIMESTAMP,'TZD') INTO P_RESULTADO FROM DUAL WHERE TO_CHAR(SYSTIMESTAMP,'TZD') IS NOT NULL;
  EXCEPTION WHEN NO_DATA_FOUND THEN*/
    SELECT TO_CHAR(SYSTIMESTAMP,'TZR') INTO P_RESULTADO FROM DUAL;     
  --END;
  RETURN P_RESULTADO;  
END;

 
 
