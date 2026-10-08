/*==============================================================================
  Nome do Script : GET_LINK_TELA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta um link HTML (#app/<tela>/<pk>) em Base64 para abrir
                  uma tela do Sankhya a partir de uma consulta.
  Assinatura     : GET_LINK_TELA (P_RESOURCE_ID VARCHAR2, P_LINK_TEXT VARCHAR2,
                  P_JSON_PK VARCHAR2) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_LINK_TELA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_LINK_TELA (P_RESOURCE_ID VARCHAR2, P_LINK_TEXT VARCHAR2, P_JSON_PK VARCHAR2)
RETURN VARCHAR2
IS  
    V_BASE64_P_RESOURCE_ID VARCHAR2(1000);
    V_BASE64_P_JSON_PK VARCHAR2(1000);
BEGIN

    V_BASE64_P_RESOURCE_ID := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(P_RESOURCE_ID)));
    V_BASE64_P_JSON_PK := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(P_JSON_PK)));

    RETURN CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT('<a href=#app/',V_BASE64_P_RESOURCE_ID),'/'),V_BASE64_P_JSON_PK),'>'),P_LINK_TEXT),'</a>');
END;
