/*==============================================================================
  Nome do Script : SNK_TO_BASE64
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Codifica uma string em Base64.
  Assinatura     : SNK_TO_BASE64 (TEXT IN VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_TO_BASE64', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_TO_BASE64 (TEXT IN VARCHAR2) 
RETURN VARCHAR2 
AS
  P_BASE64 VARCHAR2(4000);
  BEGIN 
    P_BASE64 := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(TEXT)));
    RETURN P_BASE64;
  END;
