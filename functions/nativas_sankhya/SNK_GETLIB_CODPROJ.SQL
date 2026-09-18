/*==============================================================================
  Nome do Script : SNK_GETLIB_CODPROJ
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub de liberacao de fluxo (TSILIB) — sempre retorna 0.
  Assinatura     : SNK_GETLIB_CODPROJ (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE)
                   RETURN TSILIB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETLIB_CODPROJ', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETLIB_CODPROJ (P_TABELA TSILIB.TABELA%TYPE, P_NUCHAVE TSILIB.NUCHAVE%TYPE, P_SEQUENCIA TSILIB.SEQUENCIA%TYPE, P_EVENTO TSILIB.EVENTO%TYPE) 
RETURN TSILIB.CODPROJ%TYPE
IS
BEGIN
  RETURN 0;
END;
