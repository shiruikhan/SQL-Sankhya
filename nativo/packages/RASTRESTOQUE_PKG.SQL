/*==============================================================================
  Nome do Script : RASTRESTOQUE_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Estado do rastreamento de estoque (liberacao de execucao,
                  rastreio via sistema, movimento de rastreio em execucao).
  Uso            : Triggers de rastreamento (TGFRASTEMP / rastro por ultima
                  entrada).
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'RASTRESTOQUE_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE RASTRESTOQUE_PKG AS
  V_LIB_EXEC BOOLEAN := FALSE;
  V_RASTREA_VIA_SIS BOOLEAN := FALSE;
  V_MOVNEGRAST_EXEC NUMBER(5) := -1;
END;
