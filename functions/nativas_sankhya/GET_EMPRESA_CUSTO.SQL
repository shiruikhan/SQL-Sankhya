/*==============================================================================
  Nome do Script : GET_EMPRESA_CUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Devolve a empresa da chave de custo: o proprio campo se
                  custo nao e por empresa, senao o parametro informado.
  Assinatura     : GET_EMPRESA_CUSTO ( CAMPO INTEGER, PARAMETRO INTEGER )
                  RETURN INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_EMPRESA_CUSTO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_EMPRESA_CUSTO ( CAMPO INTEGER, PARAMETRO INTEGER )
   RETURN INTEGER AS
   P_RESULT   INTEGER;
BEGIN
   IF Variaveis_Pkg.V_CustoPorEmpresa = 'N' THEN
      P_RESULT    := CAMPO;
   ELSE
      P_RESULT    := PARAMETRO;
   END IF;

   RETURN P_RESULT;
END;
