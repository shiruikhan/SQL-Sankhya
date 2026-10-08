/*==============================================================================
  Nome do Script : TGFCAB_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Tabelas PL/SQL (associative arrays) com dados do cabecalho
                  da nota (NUNOTA, TOP, vendedor, parceiro, tipo de movimento,
                  totais) e flag V_FATURANDO, para contornar tabela mutante
                  (ORA-04091) em triggers de TGFCAB.
  Uso            : Triggers de TGFCAB / TGFFIN do Sankhya.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGFCAB_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGFCAB_PKG AS
  TYPE T_NUNOTA       IS TABLE OF TGFCAB.NUNOTA%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_CODTIPOPER   IS TABLE OF TGFCAB.CODTIPOPER%TYPE   INDEX BY BINARY_INTEGER;
  TYPE T_DHTIPOPER    IS TABLE OF TGFCAB.DHTIPOPER%TYPE    INDEX BY BINARY_INTEGER;
  TYPE T_CODVEND      IS TABLE OF TGFCAB.CODVEND%TYPE      INDEX BY BINARY_INTEGER;
  TYPE T_CODPARC      IS TABLE OF TGFCAB.CODPARC%TYPE      INDEX BY BINARY_INTEGER;
  TYPE T_TIPMOV       IS TABLE OF TGFCAB.TIPMOV%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_TOTDESDOB    IS TABLE OF TGFCAB.VLRNOTA%TYPE      INDEX BY BINARY_INTEGER;
  V_CONTADOR     BINARY_INTEGER := 0;
  V_NUNOTA       T_NUNOTA;
  V_CODTIPOPER   T_CODTIPOPER;
  V_DHTIPOPER    T_DHTIPOPER;
  V_CODVEND      T_CODVEND;
  V_CODPARC      T_CODPARC;    
  V_TIPMOV       T_TIPMOV;
  V_TOTDESDOB    T_TOTDESDOB;
  V_VLRNOTA      T_TOTDESDOB;
  V_FATURANDO    CHAR(1);
END;
