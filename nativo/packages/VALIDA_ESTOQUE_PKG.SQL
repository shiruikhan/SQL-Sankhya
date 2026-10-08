/*==============================================================================
  Nome do Script : VALIDA_ESTOQUE_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Parametros da validacao de estoque: modo normal e
                  agrupamento por local.
  Uso            : Rotinas de validacao de estoque (versao anterior a 4.0).
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'VALIDA_ESTOQUE_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE VALIDA_ESTOQUE_PKG AS
  V_NORMAL BINARY_INTEGER := 0;
  V_AGRUPALOCVALEST VARCHAR2(1) := 'N';
END;
