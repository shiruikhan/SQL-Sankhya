/*==============================================================================
  Nome do Script : CAPTURA_DDL_TABELAS_FALTANTES_V2
  Tipo           : Script Utilitário (execução única/manual)
  Descrição      : Extrai o DDL completo (CREATE TABLE, constraints, índices e
                    cláusulas de storage) das tabelas listadas na Seção 3 de
                    tables/TABELAS_FALTANTES.md — lacunas encontradas numa
                    segunda varredura pelas cláusulas REFERENCES (FK) dos 90
                    DDLs já capturados por CAPTURA_DDL_TABELAS_FALTANTES.SQL,
                    cruzadas com uso direto confirmado no código da Spark.
  Tabelas        : 11 tabelas -- somente leitura (dicionário de dados):
                    3 customizadas AD_* (Bloco 1, prioridade alta) + 8 nativas
                    do Sankhya (Bloco 2)
  Dependencias   : DBMS_METADATA (pacote nativo Oracle)
  Uso            : Rodar cada bloco (SELECT) num client SQL conectado via VPN
                    (ex.: extensão SQL do VSCode) e exportar o resultado
                    completo como JSON. Depois, entregar o(s) arquivo(s)
                    .json exportado(s) para processamento (split automático
                    em tables/*.SQL ou tables/nativas_sankhya/*.SQL +
                    atualização dos catálogos).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 18/09/2026

  Observações    : - Ajuste o schema ('SPARKPRD') caso a base de destino use
                     outro owner.
                   - Bloco 1 (AD_*) tem prioridade — são tabelas nossas sem
                     nenhuma documentação alternativa (dependências de FK das
                     tabelas capturadas em CAPTURA_DDL_TABELAS_FALTANTES.SQL
                     Bloco 1).
                   - Bloco 2 são nativas com FK relevante (>= 1 outra tabela
                     apontando para elas) E uso direto confirmado no código
                     via grep estático — não é a lista completa de alvos de
                     FK (são 133; a maioria é infraestrutura genérica do ERP
                     sem relevância prática, ver tables/TABELAS_FALTANTES.md
                     Seção 3 para o racional do corte).
                   - Metodologia reaproveitável: sempre que capturar novas
                     tabelas, vale rodar uma nova varredura de REFERENCES
                     sobre os DDLs recém-capturados para achar a próxima
                     camada de dependências (grafo de FK).
==============================================================================*/

-- ============================================================================
-- BLOCO 1 — Tabelas customizadas AD_* (prioridade alta — dependências de FK
--           das tabelas da Seção 1, sem nenhuma documentação alternativa)
-- ============================================================================
SELECT table_name,
       DBMS_METADATA.GET_DDL('TABLE', table_name, 'SPARKPRD') AS ddl_text
  FROM all_tables
 WHERE owner = 'SPARKPRD'
   AND table_name IN (
        'AD_DBFECHCOM', 'AD_ADCADBENS', 'AD_CADNCO'
   )
 ORDER BY table_name;

-- ============================================================================
-- BLOCO 2 — Tabelas nativas com FK relevante + uso direto confirmado no código
-- ============================================================================
SELECT table_name,
       DBMS_METADATA.GET_DDL('TABLE', table_name, 'SPARKPRD') AS ddl_text
  FROM all_tables
 WHERE owner = 'SPARKPRD'
   AND table_name IN (
        'TCBPLA', 'TSICUS', 'TGFEMP', 'TGFVOL', 'TSIEMP', 'TGFMBC',
        'TGFTAB', 'TGFTIT'
   )
 ORDER BY table_name;
