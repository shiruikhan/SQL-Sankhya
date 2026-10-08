/*==============================================================================
  Nome do Script : GET_CODPROD_REF
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Localiza o codigo do produto por referencia, referencia do
                  fornecedor ou descricao, podendo restringir aos itens da
                  nota de origem.
  Assinatura     : GET_CODPROD_REF (P_NUNOTAORIG NUMBER, P_REFERENCIA VARCHAR2,
                  P_REFFORN VARCHAR2, P_DESCRPROD VARCHAR2, P_TODOS VARCHAR2)
                  RETURN INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_CODPROD_REF', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_CODPROD_REF (P_NUNOTAORIG    NUMBER,
                                            P_REFERENCIA    VARCHAR2,
                                            P_REFFORN       VARCHAR2,
                                            P_DESCRPROD     VARCHAR2,
                                            P_TODOS         VARCHAR2)
   RETURN INTEGER
IS
   P_CODPROD   NUMBER (10);
   p_count     INT;
BEGIN
   P_COUNT := 0;

   IF P_NUNOTAORIG = 0
   THEN
      IF P_REFERENCIA IS NOT NULL
      THEN
         SELECT MIN (CODPROD), COUNT (*)
           INTO P_CODPROD, P_COUNT
           FROM TGFPRO
          WHERE REFERENCIA = P_REFERENCIA
          AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

         IF P_COUNT = 1
         THEN
            RETURN P_CODPROD;
         END IF;
      END IF;

      IF P_REFFORN IS NOT NULL
      THEN
         SELECT MIN (CODPROD), COUNT (*)
           INTO P_CODPROD, P_COUNT
           FROM TGFPRO
          WHERE REFFORN = P_REFFORN
          AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

         IF P_COUNT = 1
         THEN
            RETURN P_CODPROD;
         END IF;
      END IF;

      SELECT MIN (CODPROD), COUNT (*)
        INTO P_CODPROD, P_COUNT
        FROM TGFPRO
       WHERE DESCRPROD LIKE P_DESCRPROD
       AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

      IF P_COUNT = 1
      THEN
         RETURN P_CODPROD;
      END IF;
   ELSE
      IF P_REFERENCIA IS NOT NULL
      THEN
         SELECT MIN (CODPROD), COUNT (*)
           INTO P_CODPROD, P_COUNT
           FROM TGFPRO
          WHERE     REFERENCIA = P_REFERENCIA
                AND CODPROD IN (SELECT DISTINCT CODPROD
                                  FROM TGFITE
                                 WHERE NUNOTA = P_NUNOTAORIG)
                AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

         IF P_COUNT = 1
         THEN
            RETURN P_CODPROD;
         END IF;
      END IF;

      IF P_REFFORN IS NOT NULL
      THEN
         SELECT MIN (CODPROD), COUNT (*)
           INTO P_CODPROD, P_COUNT
           FROM TGFPRO
          WHERE     REFFORN = P_REFFORN
                AND CODPROD IN (SELECT DISTINCT CODPROD
                                  FROM TGFITE
                                 WHERE NUNOTA = P_NUNOTAORIG)
                AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

         IF P_COUNT = 1
         THEN
            RETURN P_CODPROD;
         END IF;
      END IF;

      SELECT MIN (CODPROD), COUNT (*)
        INTO P_CODPROD, P_COUNT
        FROM TGFPRO
       WHERE     DESCRPROD LIKE P_DESCRPROD
             AND CODPROD IN (SELECT DISTINCT CODPROD
                               FROM TGFITE
                              WHERE NUNOTA = P_NUNOTAORIG)
             AND ((P_TODOS = 'S') OR (P_TODOS = 'N' AND ATIVO = 'S'));

      IF P_COUNT = 1
      THEN
         RETURN P_CODPROD;
      END IF;
   END IF;

   RETURN 0;
END;
