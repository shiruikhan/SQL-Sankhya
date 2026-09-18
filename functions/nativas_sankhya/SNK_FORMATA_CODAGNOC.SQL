/*==============================================================================
  Nome do Script : SNK_FORMATA_CODAGNOC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata um codigo numerico no padrao AGNOC (ex.: 0000000 -> 00.00.00).
  Assinatura     : SNK_FORMATA_CODAGNOC (P_CODIGO IN VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_FORMATA_CODAGNOC', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_FORMATA_CODAGNOC (P_CODIGO IN VARCHAR2) 
RETURN VARCHAR2
IS
BEGIN
	RETURN REGEXP_REPLACE(LPAD(REGEXP_REPLACE(P_CODIGO, '([^0-9]*)', ''), 7, '0'), '([0-9]{2})([0-9]{2})', '\1.\2.');
END;
