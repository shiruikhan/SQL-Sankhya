/*==============================================================================
  Nome do Script : OBTEM_PROX_PK_EC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Gera e retorna o proximo codigo de uma tabela via
                  STP_KEYGEN_TGFNUM.
  Assinatura     : OBTEM_PROX_PK_EC (P_ARQUIVO VARCHAR, P_CODEMP INT, P_TABELA
                  VARCHAR, P_CAMPO VARCHAR, P_DSYNC INT) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEM_PROX_PK_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEM_PROX_PK_EC (P_ARQUIVO VARCHAR, P_CODEMP INT, P_TABELA VARCHAR, P_CAMPO VARCHAR, P_DSYNC INT)
 RETURN NUMBER AS P_ULTCOD NUMBER;
BEGIN
    STP_KEYGEN_TGFNUM(P_ARQUIVO, P_CODEMP, P_TABELA, P_CAMPO, P_DSYNC, P_ULTCOD);
    RETURN P_ULTCOD;
END;
