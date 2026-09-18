/*==============================================================================
  Nome do Script : SNK_GET_TAMANHO_BLOB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o tamanho em bytes de um BLOB.
  Assinatura     : SNK_GET_TAMANHO_BLOB (P_BLOB BLOB)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_TAMANHO_BLOB', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_TAMANHO_BLOB (P_BLOB BLOB)
RETURN NUMBER IS
  RESULT NUMBER(10);
BEGIN
 RESULT := NVL(DBMS_LOB.GETLENGTH(P_BLOB), 0);
 RETURN RESULT;
END;

 
 
