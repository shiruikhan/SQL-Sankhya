/*==============================================================================
  Nome do Script : SNK_GET_DESCPROD_PARC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub sem implementacao — sempre retorna NULL.
  Assinatura     : SNK_GET_DESCPROD_PARC (P_CODPARC IN NUMBER, P_CODPROD IN NUMBER, P_NUNOTA IN NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DESCPROD_PARC', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DESCPROD_PARC (P_CODPARC IN NUMBER, P_CODPROD IN NUMBER, P_NUNOTA IN NUMBER)
RETURN VARCHAR2 IS 
BEGIN
    RETURN NULL;
END;
