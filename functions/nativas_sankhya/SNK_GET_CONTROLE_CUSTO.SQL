/*==============================================================================
  Nome do Script : SNK_GET_CONTROLE_CUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna CAMPO ou PARAMETRO conforme o parametro de sistema
                  CUSTOPORCONTROLE (custo por controle de serie/lote).
  Assinatura     : SNK_GET_CONTROLE_CUSTO ( CAMPO VARCHAR, PARAMETRO VARCHAR )
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CONTROLE_CUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CONTROLE_CUSTO ( CAMPO VARCHAR, PARAMETRO VARCHAR )
   RETURN VARCHAR AS
   P_RESULT   VARCHAR( 200 );
BEGIN
   IF VARIAVEIS_PKG.V_CUSTOPORCONTROLE = 'N' THEN
      P_RESULT    := CAMPO;
   ELSE
      P_RESULT    := PARAMETRO;
   END IF;

   RETURN P_RESULT;
END;

 
 
