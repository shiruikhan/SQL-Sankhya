/*==============================================================================
  Nome do Script : TGFVEI_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Variaveis V_CODPROD e V_CODBEM da vinculacao de veiculo
                  (TGFVEI) em processamento.
  Uso            : Triggers de TGFVEI.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGFVEI_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGFVEI_PKG AS
   V_CODPROD          TGFVEI.CODPROD%TYPE;
   V_CODBEM              TGFVEI.CODBEM%TYPE;
END;
