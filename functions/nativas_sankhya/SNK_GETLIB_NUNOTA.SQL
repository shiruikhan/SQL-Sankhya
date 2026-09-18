/*==============================================================================
  Nome do Script : SNK_GETLIB_NUNOTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub de liberacao de fluxo (TSILIB) — sempre retorna NULL.
  Assinatura     : SNK_GETLIB_NUNOTA (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE)
                   RETURN TGFCAB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETLIB_NUNOTA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETLIB_NUNOTA (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE) 
RETURN TGFCAB.NUNOTA%TYPE
IS
BEGIN
  RETURN NULL;
END;  
