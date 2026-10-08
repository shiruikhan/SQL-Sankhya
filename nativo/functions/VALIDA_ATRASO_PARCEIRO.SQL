/*==============================================================================
  Nome do Script : VALIDA_ATRASO_PARCEIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Stub: sempre retorna 'S' (ponto de extensao para validar
                  atraso de parceiro).
  Assinatura     : VALIDA_ATRASO_PARCEIRO (cod_parc IN NUMBER) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'VALIDA_ATRASO_PARCEIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION VALIDA_ATRASO_PARCEIRO (cod_parc IN NUMBER) 
            RETURN CHAR IS 
            BEGIN
                 RETURN 'S';                  
            END;
