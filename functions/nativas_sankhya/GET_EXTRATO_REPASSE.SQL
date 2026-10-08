/*==============================================================================
  Nome do Script : GET_EXTRATO_REPASSE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna (colecao T_EXTRATO_REP_TABLE) o extrato de repasse
                  de um titulo com saldo acumulado.
  Assinatura     : GET_EXTRATO_REPASSE (P_NUFIN NUMBER) RETURN
                  T_EXTRATO_REP_TABLE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_EXTRATO_REPASSE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_EXTRATO_REPASSE (P_NUFIN NUMBER)
   RETURN T_EXTRATO_REP_TABLE
AS
   v_ret         T_EXTRATO_REP_TABLE;
   P_SALDO       FLOAT;
   P_DTLCODIGO   NUMBER;
   P_DTLVALOR    FLOAT;

   CURSOR DTLS
   IS
        SELECT DTLCODIGO,
               CASE
                  WHEN DTLRECEBEDE = 'L' THEN DTLVALOR * (-1)
                  WHEN DTLREPASSAPARA = 'L' THEN DTLVALOR
                  ELSE 0
               END
                  DTLVALOR
          FROM TIMDTL
         WHERE     DTLPARCELA = P_NUFIN
               AND DTLHISTORICO <>
                      NVL ( (SELECT INTEIRO
                               FROM TSIPAR
                              WHERE CHAVE = 'TIMHISDTLREPBEN' AND CODUSU = 0),
                           152)
               AND (DTLRECEBEDE = 'L' OR DTLREPASSAPARA = 'L')
               AND DTLVALOR <> 0
      ORDER BY DTLREPASSAPARA DESC, DTLVALOR DESC, DTLCODIGO;

BEGIN
   v_ret := T_EXTRATO_REP_TABLE ();
   P_SALDO := 0;

   OPEN DTLS;

   LOOP
      FETCH DTLS
         INTO P_DTLCODIGO, P_DTLVALOR;

      EXIT WHEN DTLS%NOTFOUND;
      v_ret.EXTEND;
      P_SALDO := P_SALDO + P_DTLVALOR;
      v_ret (v_ret.COUNT) :=
         T_EXTRATO_REP (v_ret.COUNT,
                        P_NUFIN,
                        P_DTLCODIGO,
                        P_DTLVALOR,
                        P_SALDO);
   END LOOP;

   CLOSE DTLS;

   RETURN v_ret;
END;
