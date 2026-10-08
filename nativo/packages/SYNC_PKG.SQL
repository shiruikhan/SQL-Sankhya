/*==============================================================================
  Nome do Script : SYNC_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Flag global DSUPD_GLOBAL (S/N) usada pelo DataSync para
                  sinalizar atualizacao em curso e suprimir validacoes.
  Uso            : FPODEVALIDAR e triggers sincronizadas pelo DataSync.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'SYNC_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE SYNC_PKG AS
  DSUPD_GLOBAL CHAR(1) := 'N';
END;
