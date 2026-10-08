/*==============================================================================
  Nome do Script : TCBLAN_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Variavel V_PROCRET de controle do processamento de
                  lancamentos contabeis (TCBLAN).
  Uso            : Triggers de lancamento contabil.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TCBLAN_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TCBLAN_PKG AS
  V_PROCRET BINARY_INTEGER := 0;
END;
