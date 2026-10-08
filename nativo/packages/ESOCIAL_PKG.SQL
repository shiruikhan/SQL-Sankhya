/*==============================================================================
  Nome do Script : ESOCIAL_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Estado da geracao de eventos do eSocial: se esta gerando,
                  ambiente (P = producao), referencia, sequencia atual e data
                  de execucao.
  Uso            : Rotinas de geracao do eSocial (folha).
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'ESOCIAL_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE ESOCIAL_PKG AS
  V_GERANDO                 CHAR(1) := 'N';
  V_AMBIENTE                CHAR(1) := 'P';
  V_REFERENCIA              DATE;
  V_SEQUENCIA_ATUAL         NUMBER(10);
  V_DTREF_EXEC              DATE := NULL;
END;
