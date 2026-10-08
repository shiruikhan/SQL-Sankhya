/*==============================================================================
  Nome do Script : VALIDA_ESTOQUE_PKG40
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Parametros da validacao de estoque (versao 4.0): validacao
                  por empresa, tipo de reserva (com/sem reserva, ou parametro
                  SOESTOQUE) e agrupamento por local.
  Uso            : Rotinas de validacao de estoque.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'VALIDA_ESTOQUE_PKG40', 'SPARKPRD') FROM dual;
                  - Acento aparece como ? no DDL exportado (comentario); nao
                    verificado se esta corrompido no banco ou so na exportacao.
==============================================================================*/
CREATE OR REPLACE PACKAGE VALIDA_ESTOQUE_PKG40 AS
  V_TipoEmpresa SMALLINT := 0;   -- ( 0 ) Valida normal; ( 1 ) Forca Validac?o por Empresa
  V_TipoReserva SMALLINT := -1;  -- ( -1 ) Execs Antigos < 4.0 (usa o parametro SOESTOQUE); ( 0 ) Estoque Com Reserva; ( 1 ) Estoque Sem Reserva
  V_AGRUPALOCVALEST VARCHAR2(1) := 'N';
END;
