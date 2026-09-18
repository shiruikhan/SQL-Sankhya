/*==============================================================================
  Nome do Script : SNK_GET_EMPRESA_CUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna CAMPO ou PARAMETRO conforme o parametro de sistema
                  CUSTOPOREMPRESA.
  Assinatura     : SNK_GET_EMPRESA_CUSTO (CAMPO INTEGER, PARAMETRO INTEGER)
                   RETURN INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_EMPRESA_CUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_EMPRESA_CUSTO (CAMPO INTEGER, PARAMETRO INTEGER)
   RETURN INTEGER AS
   P_RESULT   INTEGER;
BEGIN
   IF VARIAVEIS_PKG.V_CUSTOPOREMPRESA = 'N' THEN
      P_RESULT    := CAMPO;
   ELSE
      P_RESULT    := PARAMETRO;
   END IF;

   RETURN P_RESULT;
END;

 
 
