/*==============================================================================
  Nome do Script : GET_VLRFRETE_TGFFNF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Soma o valor de frete (TGFFNF) de uma nota, excluindo o
                  titulo informado.
  Assinatura     : GET_VLRFRETE_TGFFNF (P_NUFIN NUMBER, P_NUNOTA NUMBER) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_VLRFRETE_TGFFNF', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_VLRFRETE_TGFFNF (P_NUFIN NUMBER, P_NUNOTA NUMBER)
RETURN FLOAT
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_VLRFRETE       FLOAT;
BEGIN

  SELECT NVL(SUM(VLRFRETE), 0) INTO P_VLRFRETE
  FROM TGFFNF FNF 
  WHERE FNF.NUNOTA = P_NUNOTA
    AND FNF.NUFIN <> P_NUFIN;
  COMMIT;
  RETURN P_VLRFRETE;
END;
