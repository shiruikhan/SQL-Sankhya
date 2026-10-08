/*==============================================================================
  Nome do Script : TGFFIN_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Estado do financeiro: tabela de NUMDUPL, titulos de
                  recompra, indicador de baixa parcial e flag
                  V_VALIDA_FINANCEIRO.
  Uso            : Triggers de TGFFIN.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGFFIN_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGFFIN_PKG AS
  TYPE T_NUMDUPL    IS TABLE OF TGFFIN.NUMDUPL%TYPE INDEX BY BINARY_INTEGER;
  V_CONTADOR           BINARY_INTEGER := 0;
  V_NUMDUPL            T_NUMDUPL;
  V_NUFINRECOMP  	   TGFFIN.NUFIN%TYPE := 0;
  V_NUFINRECOMPANT     TGFFIN.NUFIN%TYPE := 0;
  V_BAIXAPARCIAL       CHAR(1) := 'N';
  V_VALIDA_FINANCEIRO  BOOLEAN := TRUE;
END;
