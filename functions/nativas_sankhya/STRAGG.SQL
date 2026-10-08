/*==============================================================================
  Nome do Script : STRAGG
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Funcao agregada de concatenacao de strings (usa o tipo
                  STRING_AGG_TYPE).
  Assinatura     : STRAGG (input VARCHAR2 ) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STRAGG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STRAGG (input VARCHAR2 ) RETURN VARCHAR2 PARALLEL_ENABLE AGGREGATE USING string_agg_type;
