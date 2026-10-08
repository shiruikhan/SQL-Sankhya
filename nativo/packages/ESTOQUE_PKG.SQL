/*==============================================================================
  Nome do Script : ESTOQUE_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Flag V_TRANSF (S/N) que indica movimento de transferencia de
                  estoque em andamento na sessao.
  Uso            : Triggers de estoque.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'ESTOQUE_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE ESTOQUE_PKG AS
  V_TRANSF  VARCHAR2(1) := 'N';
END;
