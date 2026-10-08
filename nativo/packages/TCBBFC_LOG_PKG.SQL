/*==============================================================================
  Nome do Script : TCBBFC_LOG_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Variaveis do fechamento contabil: rotina contabil em
                  execucao e indicador V_UTILIZA_FECHACTB.
  Uso            : Lida por STP_GET_UTILIZAFECHACTB.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TCBBFC_LOG_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TCBBFC_LOG_PKG as
  V_ROTINACTB CHAR(1);
  V_UTILIZA_FECHACTB          BOOLEAN := FALSE;
END;
