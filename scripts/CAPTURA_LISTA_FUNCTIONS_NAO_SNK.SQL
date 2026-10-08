/*==============================================================================
  Nome do Script : CAPTURA_LISTA_FUNCTIONS_NAO_SNK
  Tipo           : Script Utilitário (execução única/manual)
  Descrição      : Inventário das functions standalone do schema SPARKPRD que
                    NÃO são SNK_% (essas já estão catalogadas em
                    functions/nativas_sankhya/), para separar o que é nativo do
                    Sankhya do que é customização da Spark antes de capturar o
                    DDL.
  Tabelas        : ALL_OBJECTS, ALL_SOURCE, ALL_PROCEDURES (somente leitura)
  Dependencias   : DBMS_METADATA (apenas no Bloco 2)
  Uso            : 1) Rodar o Bloco 1 num client SQL conectado via VPN
                       (ex.: extensão SQL do VSCode) e exportar o resultado
                       completo como JSON.
                    2) Entregar o .json para triagem (nativa x Spark x
                       descartável) — a classificação sai do nome, datas,
                       tamanho, marca 'SPARK' no fonte e uso no repo.
                    3) Com a lista de nativas definida, rodar o Bloco 2
                       (DDL) apenas para elas e exportar como JSON.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 08/10/2026

  Observações    : - Ajuste o schema ('SPARKPRD') se o owner for outro.
                   - FUNCTIONs dentro de PACKAGEs não aparecem aqui (são
                     membros do package) — tratar à parte, via
                     GET_DDL('PACKAGE_SPEC'|'PACKAGE_BODY').
                   - FUNCTION com código wrapped (criptografado) retorna
                     ilegível no GET_DDL; a coluna WRAPPED sinaliza isso.
==============================================================================*/

-- ============================================================================
-- BLOCO 1 — Inventário das functions standalone que não são SNK_%
-- ============================================================================
SELECT o.object_name,
       o.status,
       TO_CHAR(o.created, 'YYYY-MM-DD')        AS criada_em,
       TO_CHAR(o.last_ddl_time, 'YYYY-MM-DD')  AS alterada_em,
       (SELECT COUNT(*)
          FROM all_source s
         WHERE s.owner = o.owner
           AND s.name  = o.object_name
           AND s.type  = 'FUNCTION')           AS linhas,
       CASE WHEN EXISTS (SELECT 1
                           FROM all_source s
                          WHERE s.owner = o.owner
                            AND s.name  = o.object_name
                            AND s.type  = 'FUNCTION'
                            AND s.line  = 1
                            AND UPPER(s.text) LIKE '%WRAPPED%')
            THEN 'S' ELSE 'N' END              AS wrapped,
       CASE WHEN EXISTS (SELECT 1
                           FROM all_source s
                          WHERE s.owner = o.owner
                            AND s.name  = o.object_name
                            AND s.type  = 'FUNCTION'
                            AND UPPER(s.text) LIKE '%SPARK%')
            THEN 'S' ELSE 'N' END              AS cita_spark
  FROM all_objects o
 WHERE o.owner       = 'SPARKPRD'
   AND o.object_type = 'FUNCTION'
   AND o.object_name NOT LIKE 'SNK\_%' ESCAPE '\'
 ORDER BY o.object_name;

-- ============================================================================
-- BLOCO 2 — DDL de todas as functions não-SNK, exceto as 5 da Spark que já
--           estão versionadas em functions/ (triagem nativa x Spark é feita
--           depois, lendo o código; ~175 foram criadas em 12/2021 = instalação)
-- ============================================================================
SELECT object_name,
       DBMS_METADATA.GET_DDL('FUNCTION', object_name, 'SPARKPRD') AS ddl_text
  FROM all_objects
 WHERE owner       = 'SPARKPRD'
   AND object_type = 'FUNCTION'
   AND object_name NOT LIKE 'SNK\_%' ESCAPE '\'
   AND object_name NOT IN (
        'FC_GETPRECO_TRASF_SP', 'FC_TEMMETA_SPARK', 'FN_XMLTYPE_SAFE',
        'OBTEMCUSTO_SPARK', 'OBTEM_TOTAIS_MRP'
   )
 ORDER BY object_name;
