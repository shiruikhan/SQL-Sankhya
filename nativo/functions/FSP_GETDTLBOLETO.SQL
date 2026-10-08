/*==============================================================================
  Nome do Script : FSP_GETDTLBOLETO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o detalhamento (historico, complemento e valor) dos
                  lancamentos de um titulo para o boleto.
  Assinatura     : FSP_GETDTLBOLETO (P_NUFIN IN NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FSP_GETDTLBOLETO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FSP_GETDTLBOLETO (P_NUFIN IN NUMBER)
   RETURN VARCHAR2
IS
   RSP     VARCHAR2 (4000);
   PARTE   VARCHAR2 (1000);
   CURSOR RSLCD
   IS
        SELECT    HCBHISTORICO
               || ' - '
               || DTLCOMPLEMENTO
               || ' - R$ '
               || TRIM (
                     TO_CHAR (
                        (CASE
                            WHEN DTLRECEBEDE = 'I'
                            THEN
                               NVL (DTLVALOR, 0)
                            WHEN DTLREPASSAPARA = 'I'
                            THEN
                               NVL (DTLVALOR, 0) * (-1)
                            ELSE
                               0
                         END),
                        '999g999g990d00'))
                  DESCRDTL
          FROM TIMDTL DTL
               INNER JOIN TIMHCB HCB ON (DTL.DTLHISTORICO = HCB.HCBCODIGO)
         WHERE     (DTLRECEBEDE = 'I' OR DTLREPASSAPARA = 'I')
               AND DTLPARCELA = P_NUFIN
      ORDER BY DTLCODIGO;

BEGIN
   RSP := ' DETALHAMENTO DO BOLETO:';

   FOR PES IN RSLCD
   LOOP
      PARTE := PES.DESCRDTL;
      RSP := RSP ||' | '||TRIM(PARTE);
   END LOOP;
   RETURN RSP;
END;
