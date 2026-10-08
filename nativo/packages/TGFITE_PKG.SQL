/*==============================================================================
  Nome do Script : TGFITE_PKG
  Tipo           : Package Nativo Sankhya (referencia -- nao customizado)
  Descricao      : Tabelas PL/SQL com dados dos itens (nota, sequencia,
                  pendente, reserva, estoque, produto, local, controle,
                  quantidades) para recalcular estoque/reserva na fase AFTER
                  STATEMENT sem ORA-04091; inclui P_INICIOCONTEST.
  Uso            : Triggers de TGFITE.
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever este package. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Somente especificacao: o banco nao tem PACKAGE BODY para ele.
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'TGFITE_PKG', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE PACKAGE TGFITE_PKG as
  TYPE T_NUNOTA       IS TABLE OF TGFITE.NUNOTA%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_SEQUENCIA    IS TABLE OF TGFITE.SEQUENCIA%TYPE    INDEX BY BINARY_INTEGER;
  TYPE T_PENDENTE     IS TABLE OF TGFITE.PENDENTE%TYPE     INDEX BY BINARY_INTEGER;
  TYPE T_TIPMOV       IS TABLE OF TGFCAB.TIPMOV%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_RESERVA      IS TABLE OF TGFITE.RESERVA%TYPE      INDEX BY BINARY_INTEGER;
  TYPE T_ATUALESTOQUE IS TABLE OF TGFITE.ATUALESTOQUE%TYPE INDEX BY BINARY_INTEGER;
  TYPE T_CODEMP       IS TABLE OF TGFITE.CODEMP%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_CODPROD      IS TABLE OF TGFITE.CODPROD%TYPE      INDEX BY BINARY_INTEGER;
  TYPE T_CODLOCALORIG IS TABLE OF TGFITE.CODLOCALORIG%TYPE INDEX BY BINARY_INTEGER;
  TYPE T_CONTROLE     IS TABLE OF TGFITE.CONTROLE%TYPE     INDEX BY BINARY_INTEGER;
  TYPE T_QTDNEG       IS TABLE OF TGFITE.QTDNEG%TYPE       INDEX BY BINARY_INTEGER;
  TYPE T_QTDENTREGUE  IS TABLE OF TGFITE.QTDENTREGUE%TYPE  INDEX BY BINARY_INTEGER;

  V_CONTADOR     BINARY_INTEGER := 0;
  V_NUNOTA       T_NUNOTA;
  V_SEQUENCIA    T_SEQUENCIA;
  V_PENDENTE     T_PENDENTE;
  V_TIPMOV       T_TIPMOV;
  V_RESERVA      T_RESERVA;
  V_ATUALESTOQUE T_ATUALESTOQUE;
  V_CODEMP       T_CODEMP;
  V_CODPROD      T_CODPROD;
  V_CODLOCALORIG T_CODLOCALORIG;
  V_CONTROLE     T_CONTROLE;
  V_QTDNEG       T_QTDNEG;
  V_QTDENTREGUE  T_QTDENTREGUE;

  P_INICIOCONTEST  INT  := NULL;
END;
