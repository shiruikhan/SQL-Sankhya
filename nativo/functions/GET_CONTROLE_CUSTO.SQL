/*==============================================================================
  Nome do Script : GET_CONTROLE_CUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Devolve o controle da chave de custo: o proprio campo se
                  custo nao e por controle, senao o parametro informado.
  Assinatura     : GET_CONTROLE_CUSTO ( CAMPO VARCHAR, PARAMETRO VARCHAR )
                  RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_CONTROLE_CUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_CONTROLE_CUSTO ( CAMPO VARCHAR, PARAMETRO VARCHAR )
   RETURN VARCHAR AS
   P_RESULT   VARCHAR( 200 );
BEGIN
   IF Variaveis_Pkg.V_CustoPorControle = 'N' THEN
      P_RESULT    := CAMPO;
   ELSE
      P_RESULT    := PARAMETRO;
   END IF;

   RETURN P_RESULT;
END;
