/*==============================================================================
  Nome do Script : TGFCAB_UPD_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Tabelas PL/SQL com NUNOTA, total de desdobramento e valor da
                  nota coletados no UPDATE de TGFCAB, processados na fase
                  AFTER STATEMENT.
  Uso            : Triggers de UPDATE em TGFCAB.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGFCAB_UPD_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGFCAB_UPD_PKG as
  TYPE T_NUNOTA       IS TABLE OF TGFCAB.NUNOTA%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_TOTDESDOB      IS TABLE OF TGFCAB.VLRNOTA%TYPE       INDEX BY BINARY_INTEGER;
   
  V_CONTADOR     BINARY_INTEGER := 0;
  V_NUNOTA       T_NUNOTA;
  V_TOTDESDOB    T_TOTDESDOB;
  V_VLRNOTA      T_TOTDESDOB;    
END;
