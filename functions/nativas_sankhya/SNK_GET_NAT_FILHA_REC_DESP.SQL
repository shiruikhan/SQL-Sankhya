/*==============================================================================
  Nome do Script : SNK_GET_NAT_FILHA_REC_DESP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Determina se uma natureza financeira tem naturezas-filha de receita e
                  despesa mescladas (TIPNAT), navegando pela mascara de natureza.
  Assinatura     : SNK_GET_NAT_FILHA_REC_DESP (P_CODNAT NUMBER, P_ANALITICA CHAR, P_GRAU NUMBER)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_NAT_FILHA_REC_DESP', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_NAT_FILHA_REC_DESP (P_CODNAT NUMBER, P_ANALITICA CHAR, P_GRAU  NUMBER)
RETURN VARCHAR2
AS
   P_RETURN        VARCHAR2(100) := 'N';
   P_MASC          VARCHAR2(100);
   P_INDEX         NUMBER(10) := 1;
   P_CODNAT_FILTRO VARCHAR2(100);
   P_INDEX_FIM_PAI NUMBER(10) := 0;
   P_COUNT         NUMBER(10) := 0;
BEGIN
   IF P_CODNAT <= 0 THEN
       P_RETURN := 'N';
   ELSIF P_ANALITICA = 'S' THEN
       P_RETURN := 'S';
   ELSE
       SELECT REPLACE(SUBSTR(MASC, 1, INSTR(MASC, ';') - 1), '\', '') as MASC INTO P_MASC FROM (SELECT GET_TSIPAR_TEXTO('MASCNATUREZA') AS MASC FROM DUAL) TAB;
       
       WHILE P_INDEX <= P_GRAU LOOP
           P_INDEX_FIM_PAI := P_INDEX_FIM_PAI + LENGTH(REPLACE(REGEXP_SUBSTR(P_MASC, '([0-9]+)\.?', P_INDEX), '.', ''));
           P_INDEX := P_INDEX + 1;
       END LOOP;
       P_CODNAT_FILTRO := SUBSTR(P_CODNAT, 1, P_INDEX_FIM_PAI)||'%';
       SELECT COUNT(DISTINCT TIPNAT) INTO P_COUNT
       FROM TGFNAT
       WHERE CODNAT LIKE P_CODNAT_FILTRO
         AND ANALITICA = 'S'
         AND TIPNAT IS NOT NULL;
       IF P_COUNT > 1 THEN
           P_RETURN := 'S';
       ELSE 
          IF P_COUNT = 1 THEN
              SELECT TIPNAT INTO P_RETURN
               FROM TGFNAT
               WHERE CODNAT LIKE P_CODNAT_FILTRO
                 AND ANALITICA = 'S'
                 AND TIPNAT IS NOT NULL
               GROUP BY TIPNAT;
          END IF;
       END IF;
   END IF;
   RETURN P_RETURN;
END;
