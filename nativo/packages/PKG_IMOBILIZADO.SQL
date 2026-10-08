/*==============================================================================
  Nome do Script : PKG_IMOBILIZADO
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Flag V_DESMEMBRANDO_BEM que indica desmembramento de bem do
                  imobilizado em andamento.
  Uso            : Triggers do patrimonio (TCIBEM).
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'PKG_IMOBILIZADO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE PKG_IMOBILIZADO 
AS
 V_DESMEMBRANDO_BEM BOOLEAN:= FALSE;
END;
