/*==============================================================================
  Nome do Script : GET_LOCAL_CUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Devolve o local da chave de custo: o proprio campo se custo
                  nao e por local, senao o parametro informado.
  Assinatura     : GET_LOCAL_CUSTO ( CAMPO INTEGER, PARAMETRO INTEGER ) RETURN
                  INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_LOCAL_CUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_LOCAL_CUSTO ( CAMPO INTEGER, PARAMETRO INTEGER )
   RETURN INTEGER AS
   P_RESULT   INTEGER;
BEGIN
   IF Variaveis_Pkg.V_CustoPorLocal = 'N' THEN
      P_RESULT    := CAMPO;
   ELSE
      P_RESULT    := PARAMETRO;
   END IF;

   RETURN P_RESULT;
END;
