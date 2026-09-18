/*==============================================================================
  Nome do Script : CAPTURA_DDL_TABELAS_FALTANTES
  Tipo           : Script Utilitário (execução única/manual)
  Descrição      : Extrai o DDL completo (CREATE TABLE, constraints, índices e
                    cláusulas de storage) de todas as tabelas listadas em
                    tables/TABELAS_FALTANTES.md via DBMS_METADATA.GET_DDL, para
                    gerar os arquivos de referência tables/*.SQL que ainda não
                    existem no repositório — mesmo padrão de captura usado em
                    scripts/CAPTURA_DDL_AD_TGFASS.SQL e em
                    functions/nativas_sankhya/ (SNK_%).
  Tabelas        : 83 tabelas -- somente leitura (dicionário de dados):
                    30 customizadas AD_* (Bloco 1) + 53 nativas do Sankhya
                    com >= 5 referências no repositório (Bloco 2)
  Dependencias   : DBMS_METADATA (pacote nativo Oracle)
  Uso            : Rodar cada bloco (SELECT) num client SQL conectado via VPN
                    (ex.: extensão SQL do VSCode) e exportar o resultado
                    completo como JSON (aumentar o limite de linhas do client
                    antes de rodar — são 30 e 53 linhas respectivamente).
                    Depois, entregar o(s) arquivo(s) .json exportado(s) para
                    processamento (split automático em tables/*.SQL +
                    atualização do catálogo).

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 18/09/2026

  Observações    : - Ajuste o schema ('SPARKPRD') caso a base de destino use
                     outro owner.
                   - Os dois blocos podem ser exportados juntos (um único
                     JSON) ou separados (recomendado: Bloco 1 primeiro, são
                     as tabelas nossas e sem nenhuma documentação alternativa).
                   - Se algum nome da lista não existir mais na base atual
                     (renomeada/removida), a linha correspondente
                     simplesmente não aparece no resultado — não é erro.
                   - Lista extraída de tables/TABELAS_FALTANTES.md; se esse
                     arquivo for atualizado, sincronizar as listas abaixo.
==============================================================================*/

-- ============================================================================
-- BLOCO 1 — Tabelas customizadas AD_* (prioridade alta — são nossas)
-- ============================================================================
SELECT table_name,
       DBMS_METADATA.GET_DDL('TABLE', table_name, 'SPARKPRD') AS ddl_text
  FROM all_tables
 WHERE owner = 'SPARKPRD'
   AND table_name IN (
        'AD_EMBPED', 'AD_APOQLD', 'AD_CADFUNC', 'AD_TGSCIT', 'AD_TGSCAB',
        'AD_TPRCOI', 'AD_TGFMET', 'AD_TGFIASS', 'AD_TPRSERAPO', 'AD_TPRSERPA',
        'AD_TGSSCP', 'AD_TGSCUS', 'AD_OSINTERNA', 'AD_MKTPMELI', 'AD_TGSITE',
        'AD_FRETE', 'AD_TGFNCO', 'AD_TGFPIM', 'AD_MKTPMELIATRIB',
        'AD_DBFECHCOMFIN', 'AD_TGSIOSI', 'AD_TGSPAR', 'AD_TGSSER',
        'AD_SPKICAE', 'AD_CADMKTATRIB', 'AD_PRVCTR', 'AD_TGSCUSBLOCOH',
        'AD_TSIBLOCK', 'AD_TGSMDF', 'AD_TGSISCP'
   )
 ORDER BY table_name;

-- ============================================================================
-- BLOCO 2 — Tabelas nativas do Sankhya (>= 5 referências no repositório)
-- ============================================================================
SELECT table_name,
       DBMS_METADATA.GET_DDL('TABLE', table_name, 'SPARKPRD') AS ddl_text
  FROM all_tables
 WHERE owner = 'SPARKPRD'
   AND table_name IN (
        'TGFCAB', 'TGFITE', 'TGFPRO', 'TPRIATV', 'TGFPAR', 'TPRAPO',
        'TGFSER', 'TGFGRU', 'TPRIPROC', 'TPRAPA', 'TPREFX', 'TGFFIN',
        'TGFVEN', 'TPRPRC', 'TGFTOP', 'TPRIPA', 'TGFEST', 'TSICID',
        'TMDFMG', 'TGFECQ', 'TFPFUN', 'TSIUSU', 'TPRLMP', 'TPRLPI',
        'TGFNUM', 'TPRLPA', 'TPRMPS', 'TPRATV', 'TGFTPV', 'TGFNCT',
        'TGFIXN', 'TSIUFS', 'TGFCUS', 'TGFVAR', 'TPRIMPS', 'TGFBAR',
        'TGFNAT', 'TGFDIN', 'TGFCHQ', 'TSIPAR', 'TGFCTE', 'TPROEST',
        'TGFCOI2', 'TGFLOC', 'TGFVOA', 'TSICTA', 'TGFDTP', 'TCBINT',
        'TPRCONF', 'TPRSERPA', 'TGFCON2', 'TSIEND', 'TSIBAI'
   )
 ORDER BY table_name;
