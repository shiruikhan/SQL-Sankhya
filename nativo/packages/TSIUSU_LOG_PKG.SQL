/*==============================================================================
  Nome do Script : TSIUSU_LOG_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Usuario logado na sessao (codigo e nome) para auditoria.
  Uso            : Lida por STP_GET_CODUSULOGADO e pelas funcoes
                  GET_TSIPAR_USUARIO_*.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TSIUSU_LOG_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TSIUSU_LOG_PKG as
  V_CODUSULOG BINARY_INTEGER := 0;
  V_NOMEUSULOG   TSIUSU.NOMEUSU%TYPE;
END;
