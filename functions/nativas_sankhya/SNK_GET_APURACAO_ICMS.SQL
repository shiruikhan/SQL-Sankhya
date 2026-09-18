/*==============================================================================
  Nome do Script : SNK_GET_APURACAO_ICMS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a base de apuracao de ICMS (atualmente repassa o valor de
                  P_BASEICMS recebido).
  Assinatura     : SNK_GET_APURACAO_ICMS ( P_NUNOTA NUMBER, P_ORIGEM VARCHAR2, P_SEQUENCIA NUMBER, P_CODEMP NUMBER, P_CODCFO NUMBER, P_BASEICMS FLOAT, P_CODIGOTAA NUMBER)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_APURACAO_ICMS', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_APURACAO_ICMS (
    P_NUNOTA NUMBER, 
    P_ORIGEM VARCHAR2, 
    P_SEQUENCIA NUMBER, 
    P_CODEMP NUMBER, 
    P_CODCFO NUMBER, 
    P_BASEICMS FLOAT,
    P_CODIGOTAA NUMBER) 
RETURN FLOAT 
IS 

P_VLRAPURACAO FLOAT(126); 

BEGIN 

    P_VLRAPURACAO := NVL(P_BASEICMS, 0.00); 

    RETURN P_VLRAPURACAO; 

END;
