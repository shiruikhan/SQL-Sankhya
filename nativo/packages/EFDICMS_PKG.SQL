/*==============================================================================
  Nome do Script : EFDICMS_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Contexto da apuracao EFD ICMS/IPI (SPED Fiscal): empresa,
                  periodo, UF e nota em processamento.
  Uso            : Escrita pelas rotinas de geracao do SPED Fiscal; lida por
                  views/triggers fiscais.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'EFDICMS_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE EFDICMS_PKG 
AS
    V_CODEMP    NUMBER(10) := 0;
    V_DTINI        DATE;
    V_DTFIM        DATE;
    V_UF        VARCHAR2(2);
    V_NUNOTA    NUMBER(10) := 0;
END;
