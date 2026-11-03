# Catálogo de Componentes BI

**Empresa:** Spark Eletrônica
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior
**Total de componentes:** 184 (171 ativos, 13 inativos) — snapshot de produção de 03/11/2026
**Ambiente:** Sankhya BI (SQL analítico Oracle)

---

## Visão Geral

Cada pasta numerada corresponde a um componente BI de produção, no mesmo padrão de `reports/`: **`<NUGDG> - <TÍTULO>`**, em que `NUGDG` é o código do componente na tabela `TSIGDG` (tela *Construtor de Componentes de BI*) e o título é o de produção (`/` trocado por `-`).

O conteúdo de cada pasta veio do campo `TSIGDG.CONFIG` em produção:

- `componente.xml` — o XML completo do componente (parâmetros, níveis, layout e SQLs). É a fonte da verdade; dá para reimportar no Sankhya.
- `grid<n>.sql`, `chart<n>.sql`, `simple-value<n>.sql`, `geochart<n>.sql`… — um arquivo por SQL embutido no XML, numerado por tipo de elemento na ordem em que aparece (todos os níveis).
- Outros arquivos (`README.md`, `00_*`, `01_*`, `*.HTML`) são material de apoio que já existia no repositório para aquele componente.

Componentes HTML5 (`TEMHTML5 = 'S'`) guardam o pacote no BLOB `TSIGDG.HTML5`, que **não** foi capturado; nesses casos a pasta tem só o XML.

### Como atualizar

1. Rodar os blocos de `scripts/CAPTURA_COMPONENTES_BI.SQL` no VSCode e exportar como JSON.
2. `python -I scripts/bi_compara_producao.py <componentes.json> <pasta_saida>` — remonta o XML (confere o tamanho), separa os SQLs e gera `comparacao.csv` (repo × produção) e `producao.csv`.
3. Copiar `<pasta_saida>/producao/*` por cima destas pastas e revisar o `git diff`.

> Antes de editar um SQL aqui, confira se a pasta está igual à produção: alteração feita direto no Sankhya só aparece no repositório na próxima captura.

---

## Catálogo

Inativo = `TSIGDG.ATIVO = 'N'`. As notas em itálico vêm do catálogo anterior e citam os nomes de arquivo antigos.

| Nº | Pasta | Ativo | SQLs / apoio | Notas |
|---|---|---|---|---|
| 15 | `15 - AUDITORIA BASE DE DADOS` | **N** | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql`, `grid4.sql`, `grid5.sql`, `grid6.sql`, `grid7.sql`, `grid8.sql`, `grid9.sql`, `grid10.sql`, `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql`, `simple-value4.sql`, `simple-value5.sql`, `simple-value6.sql`, `simple-value7.sql`, `simple-value8.sql`, `simple-value9.sql`, `simple-value10.sql`, `simple-value11.sql`, `simple-value12.sql`, `simple-value13.sql`, `simple-value14.sql`, `simple-value15.sql`, `simple-value16.sql`, `simple-value17.sql`, `simple-value18.sql`, `simple-value19.sql`, `simple-value20.sql`, `simple-value21.sql`, `simple-value22.sql`, `simple-value23.sql`, `simple-value24.sql`, `simple-value25.sql`, `simple-value26.sql`, `simple-value27.sql`, `simple-value28.sql`, `simple-value29.sql`, `simple-value30.sql`, `simple-value31.sql`, `simple-value32.sql`, `simple-value33.sql`, `simple-value34.sql`, `simple-value35.sql`, `simple-value36.sql`, `simple-value37.sql`, `simple-value38.sql`, `simple-value39.sql`, `simple-value40.sql`, `simple-value41.sql`, `simple-value42.sql`, `simple-value43.sql`, `simple-value44.sql` |  |
| 16 | `16 - CAD. BÁSICOS - TOPS` | **N** | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `chart6.sql`, `chart7.sql`, `chart8.sql`, `chart9.sql`, `chart10.sql`, `chart11.sql`, `chart12.sql` |  |
| 17 | `17 - PRODUTOS - PARCEIROS` | **N** | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `chart6.sql`, `chart7.sql`, `chart8.sql`, `chart9.sql`, `chart10.sql`, `chart11.sql`, `chart12.sql`, `grid1.sql`, `grid2.sql` |  |
| 18 | `18 - EMPRESA - MOVIMENTAÇÕES` | **N** | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `chart6.sql`, `chart7.sql`, `chart8.sql`, `chart9.sql`, `chart10.sql`, `chart11.sql` |  |
| 24 | `24 - CONFERENCIA IMPOSTOS ANALITICO (EFD CONTRIB.)` | S | `grid1.sql` |  |
| 26 | `26 - APURAÇÃO DIFAL` | S | `grid1.sql` | *(antigo `APURAÇÃO DIFAL`)* • `P1.SQL` — Notas com DIFAL (remetente ou destinatário, via `:P_TIPOIMPOSTO`) e FCP no período de faturamento, comparando com os títulos de imposto (`TGFFIN.CODTIPTIT = 35`) e colorindo a linha conforme a UF tenha ou não IE cadastrada (`TSIIUF`). Parâmetros: `:PERIODO`, `:TIPMOV`, `:EMPRESA`, `:UF`, `:CIDADE`, `:NOTA`, `:P_TIPOIMPOSTO`. • `COMPONENTE.XML` — Gadget do componente (parâmetros e layout). |
| 28 | `28 - ESTIMATIVA DE ESTOQUE` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `ESTIMATIVA DE ESTOQUE`)* • `P1.SQL` — Saldo estimado por produto: estoque + planejado em produção + pedidos de estoque − pedidos de venda em aberto (`:P_DATA`, `:P_CODGRUPO`, `:P_DESCRPROD`) • `P2.SQL` — Pedidos de venda em aberto do produto selecionado (`:A_CODPROD`, `:P_DATA`) • `P3.SQL` — Processos/lotes de produção em aberto do produto selecionado, com saldo a produzir (`:A_CODPROD`) |
| 29 | `29 - CONSULTA NOTAS COM RETENÇÃO (REINF)` | S | `grid1.sql` |  |
| 30 | `30 - CONFERÊNCIA COMPOSIÇÃO PA-PI` | S | `grid1.sql`, `grid2.sql` | *(antigo `CONFERÊNCIA COMPOSIÇÃO PA-PI`)* • `p1.sql` — Conferência da estrutura de produtos: processos, etapas e materiais (`TPRPRC`, `TPRATV`, `TPREFX`, `TPRLMP`). Parâmetros: `:P_CODPRC`, `:P_CODPRODPA`, `:P_CODPRODMP`, `:P_DESCRMP`, `:P_PA`. • `p2.sql` — Materiais da etapa selecionada, com quantidade de mistura e requisição (`:A_CODPRC`, `:A_IDEFX`) |
| 31 | `31 - CONFERENCIA VOLUMES` | S | `grid1.sql`, `grid2.sql` |  |
| 32 | `32 - PRODUTOS REPETIDOS` | S | `grid1.sql` |  |
| 33 | `33 - PRODUTOS INVENTÁRIO SEM CADASTRO` | S | `grid1.sql`, `grid2.sql` |  |
| 34 | `34 - IMPORTAÇÕES ANDES` | S | `grid1.sql`, `grid2.sql` |  |
| 35 | `35 - POSIÇÃO DO ESTOQUE` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 36 | `36 - INDICADOR PEDIDOS DE REQUISIÇÃO` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `grid1.sql` |  |
| 37 | `37 - CONFERENCIA IMPOSTOS ANALITICO` | S | `grid1.sql` |  |
| 38 | `38 - CONFERENCIA IMPOSTOS SINTETICO - CFOP-CST` | S | `grid1.sql` |  |
| 39 | `39 - CONFERENCIA IMPOSTOS SINTETICO - NOTA` | S | `grid1.sql` |  |
| 40 | `40 - PAINEL - ACOMPANHAMENTO PRODUÇÃO` | S | `chart1.sql`, `grid1.sql` | *(antigo `PAINEL ACOMPANHAMENTO DE PRODUÇÃO`)* • `p2.sql` — Detalhe dos processos de produção com apontamentos e percentual produzido por lote • `p3.sql` — Detalhe de processos/atividades com apontamentos de produção e perdas • Parâmetros comuns: `:P_DTAPONT.INI/FIN`, `:P_STATUSPROC`, `:P_IDIPROC`, `:P_DETALHAR` (P = processo, A = atividade), `:P_FINAL`, `:A_VALUE`. Não há `p1.sql` versionado. |
| 41 | `41 - PRODUTOS P- SÉRIE -SALDO` | S | `grid1.sql` |  |
| 42 | `42 - PAINEL - GESTÃO SUPRIMENTOS MRP-PRODUÇÃO` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 43 | `43 - CARD - INSERÇÃO` | **N** | `chart1.sql` |  |
| 44 | `44 - CARD - SOLDA` | **N** | `chart1.sql` |  |
| 45 | `45 - CARD - TESTE` | **N** | `chart1.sql` |  |
| 46 | `46 - CONFERÊNCIA DIFAL` | S | `grid1.sql` |  |
| 47 | `47 - APURAÇÃO ST-DIFAL-FCP DIFAL` | S | `grid1.sql`, `grid2.sql` |  |
| 48 | `48 - CARD - DISSIPADOR` | **N** | `chart1.sql` |  |
| 49 | `49 - CARD - TAMPA-GABINETE` | **N** | `chart1.sql` |  |
| 50 | `50 - CARD - MONTAGEM FINAL` | **N** | `chart1.sql` | *(antigo `CARD - PRODUÇÃO DIÁRIA/CARD.SQL`)* Card: produção do dia atual por setor (soma de `QTDAPONTADA` em `TPRAPA`, 7 setores fixos). |
| 51 | `51 - CARD - EXPEDIÇÃO` | **N** | `chart1.sql` |  |
| 52 | `52 - FLUXO DE CAIXA` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `grid1.sql`, `grid2.sql`, `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql`, `simple-value4.sql`, `simple-value5.sql`, `simple-value6.sql`, `simple-value7.sql` |  |
| 53 | `53 - FLUXO DE CAIXA POR NATUREZA I` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `grid1.sql`, `grid2.sql` |  |
| 54 | `54 - FLUXO DE CAIXA POR NATUREZA II` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `grid1.sql`, `grid2.sql` |  |
| 55 | `55 - CARD - PRODUÇÃO DIÁRIA` | S | `grid1.sql` |  |
| 56 | `56 - SN VINCULADO` | S | `grid1.sql`, `grid2.sql` |  |
| 57 | `57 - ESTOQUE PRODUÇÃO EM PROCESSO` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `ESTOQUE PRODUÇÃO EM PROCESSO`)* • `p1.sql` — Estoque em processo por produto acabado com saldo e custo por matéria-prima pendente de conclusão (`:P_CODPRC`, `:P_CODPRODPA`) • `p2.sql` — Saldo pendente por lote/processo do PA selecionado (`:A_CODPRODPA`, `:P_CODPRC`) |
| 58 | `58 - RELATÓRIO CÓPIA DE ESTOQUE` | S | `grid1.sql` | *(antigo `RELATÓRIO CÓPIA DE ESTOQUE.SQL`)* Contagem de estoque (`TGFCTE`) com produto, local, custos (sem ICMS, com ICMS, gerencial) e última movimentação. Parâmetros: `:DATE`, `:P_CODLOCAL` e outros opcionais. |
| 59 | `59 - FATURAMENTO POR PERÍODO` | S | `chart1.sql`, `chart2.sql`, `grid1.sql`, `grid2.sql` | *(antigo `FATURAMENTO POR PERIODO/P1.SQL`)* Faturamento por período com Curva ABC de vendas por produto. Parâmetros: `:P_PER.INI/FIN`, `:P_GRUPO`, `:P_CODVEND`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODEMP`. |
| 61 | `61 - FATURAMENTO POR PERÍODO - GESTÃO` | S | `chart1.sql`, `chart2.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `FATURAMENTO POR PERÍODO - Devoluções.sql`)* Devoluções agrupadas por produto/agrupador, com participação percentual em quantidade e valor. Variante do `Faturamento por período Gestão/p2.sql` (versões diferentes).<br>*(antigo `Faturamento por período Gestão`)* • `p1.sql` — Faturamento por agrupador de produto e vendedor, com percentuais de participação • `p2.sql` — Devoluções por agrupador de produto e vendedor, com percentuais de participação |
| 62 | `62 - CONSULTA SN` | S | `grid1.sql`, `grid2.sql` |  |
| 64 | `64 - AQUISIÇÕES DE SERVIÇOS - IMPOSTOS RETIDOS` | S | `grid1.sql` |  |
| 65 | `65 - RELAÇÃO DE ITENS ENTRADAS` | S | `grid1.sql` |  |
| 66 | `66 - RELAÇÃO DE ITENS SAÍDAS` | S | `grid1.sql` |  |
| 67 | `67 - COMISSÃO POR VENDEDOR DETALHADA` | S | `grid1.sql`, `grid2.sql` |  |
| 68 | `68 - AUDITORIA FRETES` | S | `grid1.sql` |  |
| 71 | `71 - CURVA ABC` | S | `grid1.sql`, `simple-value1.sql` | *(antigo `Curva ABC.sql`)* Curva ABC de produtos ou de parceiros (`:@ANALISE`), com opções de incluir desconto, reposição, ST, IPI e notas não confirmadas (`:DESC`, `:REP`, `:ST`, `:IPI`, `:STATUSNOTA`). |
| 73 | `73 - CONFERENCIA IMPOSTOS ANALITICO (EFD CONTRIB.) - NOVO` | S | `grid1.sql` |  |
| 74 | `74 - CONFERENCIA EFD FISCAL - CFOP-CST-ALIQ` | S | `grid1.sql`, `grid2.sql` |  |
| 76 | `76 - PEDIDOS EM ABERTO - COMPRAS` | S | `grid1.sql` |  |
| 77 | `77 - JUROS E MULTA POR PERÍODO` | S | `grid1.sql` |  |
| 78 | `78 - RENDIMENTOS PIS-COFINS` | S | `grid1.sql` |  |
| 79 | `79 - CARD - CONTADOR DE OS` | S | `chart1.sql` |  |
| 80 | `80 - EM ELABORAÇÃO PA` | S | `grid1.sql`, `grid2.sql` | *(antigo `Estoque em Elaboração.sql`)* Localiza o saldo de PA ainda não apontado (estoque em elaboração) por processo (`IDIPROC`) e lote. Parâmetros: `:P_PERIODO.INI/FIN` (sobre `TPRIPROC.DHINST`), `:P_CODPRC`, `:P_CODPRODPA`. |
| 81 | `81 - CONFERENCIA DE DEPRECIAÇÃO SPED` | S | `grid1.sql` |  |
| 82 | `82 - CUSTO - DATA DE CORTE` | S | `grid1.sql` |  |
| 83 | `83 - DESCONTO POR FINANCEIRO` | S | `grid1.sql` |  |
| 85 | `85 - PAINEL DE CHEGADA DE COMPRAS` | S | `grid1.sql`, `grid2.sql` |  |
| 86 | `86 - PAINEL DE PREVENTIVAS` | S | `grid1.sql`, `grid2.sql` |  |
| 87 | `87 - CARD - PREVENTIVAS` | S | `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql`, `simple-value4.sql`, `simple-value5.sql` |  |
| 89 | `89 - ACOMPANHAMENTO DE REMESSAS` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 90 | `90 - LANÇAMENTOS POR TOP E DATA` | S | `grid1.sql`, `grid2.sql` |  |
| 91 | `91 - DIVERGÊNCIAS DO LIVRO FISCAL ICMS-IPI` | S | `grid1.sql`, `grid2.sql`, `grid3.sql`, `grid4.sql`, `grid5.sql`, `grid6.sql`, `grid7.sql`, `grid8.sql`, `grid9.sql`, `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql`, `simple-value4.sql` |  |
| 92 | `92 - RESULTADO DE FATURAMENTO` | S | `grid1.sql` | *(antigo `resultado de faturamento.sql`)* Resultado de faturamento por nota de venda (CFOP, parceiro, UF, `AD_RESULTADO`, total com impostos de `TGFDIN`). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`. |
| 93 | `93 - CONFERENCIA DE ESTOQUE DE TERCEIRO` | S | `grid1.sql`, `grid2.sql` | *(antigo `CONFERENCIA DE ESTOQUE DE TERCEIRO`)* • `p1.sql` — Saldo de estoque de terceiros por parceiro e produto até a data, pela flag `ITE.ATUALESTTERC` (P/T somam, R/D subtraem). Parâmetros: `:P_DATAFIN`, `:P_CODEMP`, `:P_CODLOCAL`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODPPROD`. • `p2.sql` — Detalhe nota a nota do parceiro + produto selecionados (`:A_CODPARC`, `:A_CODPROD`), com saldo acumulado. |
| 94 | `94 - ESTOQUE SEM MOVIMENTO` | S | `grid1.sql` | *(antigo `ESTOQUE SEM MOVIMENTO.SQL`)* Produtos em estoque sem movimento há 3, 2 ou 1 ano, com indicação por cor. Parâmetros: `:P_DTCORTE`, `:P_CODLOCAL`, `:P_USOPROD`, `:P_VALIDEST`. |
| 95 | `95 - PRD - ACOMPANHAMENTO DE OPS` | S | — |  |
| 97 | `97 - SN PARA TRANSFERÊNCIA` | S | `grid1.sql` |  |
| 98 | `98 - ESTIMATIVA DE ESTOQUE BKP` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 99 | `99 - RELAÇÃO FINANCEIRA POR NATUREZA` | S | `grid1.sql`, `grid2.sql` |  |
| 100 | `100 - RESUMO FINANCEIRO POR NATUREZA` | S | `grid1.sql` |  |
| 101 | `101 - BUSCADOR DE CLIENTES` | S | `grid1.sql`, `grid2.sql` |  |
| 102 | `102 - APONTAMENTO DE SÉRIES POR PRODUÇÃO` | S | `grid1.sql` |  |
| 103 | `103 - LANÇAMENTOS SEM CONFIRMAÇÃO` | S | `grid1.sql` |  |
| 104 | `104 - VALIDA TGFESE` | S | `grid1.sql`, `grid2.sql` |  |
| 105 | `105 - VALIDA TGFESE - CONSUMO` | **N** | `grid1.sql` |  |
| 106 | `106 - PRODUÇÃO POR PERÍODO` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 107 | `107 - VENDAS POR PERÍODO` | S | `grid1.sql` |  |
| 109 | `109 - NOTAS DE TELECOMUNICAÇÃO E COMUNICAÇÃO` | S | `grid1.sql` |  |
| 110 | `110 - TRANSFERÊNCIA ENTRE EMPRESAS` | S | `grid1.sql` | *(antigo `TRANSFERENCIA ENTRE EMPRESAS.SQL`)* Quantidades a transferir entre empresas: produtos com saldo de contagem (`TGFCTE`) negativo em uma filial e positivo em outra. Parâmetro: `:DATE`. |
| 112 | `112 - VERIFICAR ENTRADAS AVULSAS` | S | `grid1.sql` |  |
| 113 | `113 - VALIDA CONFERÊNCIA EXPEDIÇÃO` | S | `grid1.sql` |  |
| 114 | `114 - EXPORTADOR DE SÉRIES DO ESTOQUE` | S | `grid1.sql` | *(antigo `EXPORTADOR DE SÉRIES DO ESTOQUE.SQL`)* Séries em estoque (`TGFSER`, saldo ≥ 1) por empresa, local, produto e série. Parâmetros: `:P_CODEMP`, `:P_CODLOCALORIG`, `:P_CODPROD`, `:P_SERIE`. |
| 115 | `115 - APURAÇÕES - RETENÇÕES POR PERÍODO` | S | `grid1.sql` |  |
| 116 | `116 - PAINEL ALMOXARIFADO` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 117 | `117 - EVOLUÇÃO MENSAL DE VENDAS POR PARCEIRO` | S | `grid1.sql` | *(antigo `EVOLUÇÃO MENSAL DE VENDAS POR PARCEIRO`)* • `p1.sql` — Valor vendido por parceiro, mês a mês, com total, representante e UF. Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODVEND` (multilist), `:P_CODPARCMATRIZ`. • `componente.xaml` — Gadget do componente (parâmetros e grade). |
| 118 | `118 - ESTIMATIVA DE ESTOQUE GERENCIAL` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `ESTIMATIVA DE ESTOQUE GERENCIAL`)* • `P1.SQL`, `P2.SQL`, `P3.SQL` — Mesmo painel de `ESTIMATIVA DE ESTOQUE/`, em **versão diferente/anterior** (subconsultas inline em vez de CTEs; P1 traz bloco `SALDOMETA` comentado). Mesmos parâmetros. |
| 119 | `119 - SERIES ANDES` | S | `grid1.sql` |  |
| 120 | `120 - PAINEL FINANCEIRO` | S | `grid1.sql`, `grid2.sql` |  |
| 121 | `121 - PAINEL COMERCIAL` | S | `grid1.sql` | *(antigo `PAINEL COMERCIAL.SQL`)* Pedidos de venda em aberto com estoque atual, simulação de entrega e disponibilidade. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_ENTREGA.INI/FIN`, `:P_CODPARC`, `:P_CODEMP`, `:P_SIMULACRO`. |
| 122 | `122 - RELAÇÃO DE SÉRIES POR PARCEIRO` | S | `grid1.sql` |  |
| 123 | `123 - EXTRATO BANCÁRIO CONCILIADO` | S | `grid1.sql` |  |
| 125 | `125 - DASHBOARD DE VENDAS` | S | `grid1.sql` | *(antigo `DASHBOARD DE VENDAS/DASHBOARD DE VENDAS.sql`)* Detalhe de vendas: parceiro, UF, vendedor, produto, data de negociação, quantidade, valor unitário, valor com desconto e tipo de operação. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODVEND`, `:P_CODGRUPOPROD`, `:P_UF`, `:P_CODPARC`. |
| 126 | `126 - EVOLUÇÃO DE BRINDES POR CLIENTE` | S | `grid1.sql` | *(antigo `EVOLUÇÃO DE BRINDES POR CLIENTE.SQL`)* Evolução mensal de brindes por cliente (TOP 1311). Mesma query da bonificação, mudando só as TOPs. --- |
| 127 | `127 - EVOLUÇÃO DE BONIFICACAO POR CLIENTE` | S | `grid1.sql` | *(antigo `EVOLUÇÃO DE BONIFICACAO POR CLIENTE.SQL`)* Evolução mensal de bonificações por cliente (TOPs 1121, 1117, 1191). Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODVEND`. |
| 128 | `128 - RELAÇÃO DE ITENS ENTRADAS` | S | `grid1.sql` | *(antigo `RELAÇÃO DE ITENS ENTRADAS.sql`)* Itens de entrada (compra/devolução) com valores unitários, impostos, custos e fornecedor. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODNAT`, `:P_CODGRUPOPROD`. --- |
| 129 | `129 - RELAÇÃO DE PRODUTOS E UNIDADES` | S | `grid1.sql` |  |
| 130 | `130 - LANÇAMENTOS POR UNIDADES` | S | `grid1.sql` |  |
| 131 | `131 - APURAÇÃO - RETENÇÃO POR PERÍODO` | S | `grid1.sql` |  |
| 132 | `132 - COMPOSIÇÃO DE VENDAS (DT. CORTE) PROVISÓRIO` | **N** | `grid1.sql` |  |
| 134 | `134 - COMPOSIÇÃO DE VENDAS (DT. DE CORTE)` | S | `grid1.sql` |  |
| 136 | `136 - INFORMATIVOS DE ESTOQUE` | S | `grid1.sql` |  |
| 137 | `137 - LIVRO GERENCIAL` | S | `grid1.sql` |  |
| 138 | `138 - INFORMATIVO DE PRODUÇÃO` | S | `grid1.sql`, `grid2.sql` |  |
| 139 | `139 - AVALIAÇÃO DE CONSUMO` | S | `grid1.sql` |  |
| 140 | `140 - PAINEL ASSISTENCIA` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 141 | `141 - LANÇAMENTOS DE NOTAS DE COMUNICAÇÃO-TELECOMUNICAÇÃO` | S | `grid1.sql` |  |
| 142 | `142 - ESTOQUE POR LOCAL - EMPRESA` | S | `grid1.sql` |  |
| 143 | `143 - RELAÇÃO DE ENTRADAS POR NATUREZAS` | S | `grid1.sql` |  |
| 145 | `145 - APO. QUALI. POR COLABORADOR E ERRO` | S | `grid1.sql` |  |
| 146 | `146 - APO. QUALI. POR OPEFAB E ERRO` | S | `grid1.sql` |  |
| 147 | `147 - APO. QUALI. POR OPETESTE E ERRO` | S | `grid1.sql` |  |
| 148 | `148 - APO. QUALI. POR REVFAB E ERRO` | S | `grid1.sql` |  |
| 149 | `149 - GRAFICO-QUALIDADE POR OPERADOR` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `grid1.sql` | *(antigo `GRAFICO-QUALIDADE POR OPERADOR`)* Não conformidades do apontamento de qualidade (`AD_APOQLD`). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_SETOR` (multilist). • `g1.sql` — Total de defeitos por revisor • `g2.sql` — Total de defeitos por operador • `g3.sql` — Defeitos por tipo do funcionário selecionado (`:A_IDFUNC`) • `p1.sql` — Detalhamento dos apontamentos do funcionário selecionado (`:A_IDFUNC`) • `componente.xml` — Gadget do dashboard (parâmetros e layout com as quatro consultas embutidas)<br>*(antigo `01 - Gráfico Qualidade por Operador`)* • `p2.sql` — Total de defeitos por operador (`TFPFUN`, sem filtro de setor) • `p3.sql` — Defeitos por tipo × setor (`AD_CADFUNC.SETOR IN :P_SETOR`) • Versão diferente/anterior do painel acima: `p2.sql` equivale ao `g2.sql` sem o filtro `:P_SETOR` e sem a deduplicação de `TFPFUN`. Qual está em uso: a confirmar. --- |
| 152 | `152 - EVOLUÇÃO MENSAL DE COMPRAS POR PARCEIRO` | S | `grid1.sql` |  |
| 153 | `153 - RELAÇÃO DE COMPRAS-PRODUTO POR PREVISÃO DE ENTREGA` | S | `grid1.sql` | *(antigo `EVOLUÇÃO MENSAL DE COMPRAS POR PARCEIRO.sql`)* Evolução mensal de compras por fornecedor/produto. Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODGRUPOPROD`.<br>*(antigo `RELAÇÃO DE COMPRAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`)* Itens de compra por produto e fornecedor com quantidades por mês de previsão de entrega. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODGRUPOPROD`.<br>*(antigo `RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`)* Itens de venda por produto e cliente com quantidades por mês de previsão de entrega. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODGRUPOPROD`. |
| 154 | `154 - FINANCEIRO E PROVISAO DE DESPESAS` | S | `grid1.sql` | *(antigo `CONTAS A PAGAR E PROVISAO DE DESPESAS.sql`)* Títulos em aberto (`DHBAIXA` nula) por vencimento, separando provisões e reais, com natureza e centro de resultado (exceto `CODTIPTIT = 34`). Parâmetros: `:P_PERIODO.INI/FIN` (sobre `DTVENC`), `:P_CODEMP`, `:P_RECDESP`. |
| 155 | `155 - EVOLUÇÃO DE CONSUMO DE PRODUTOS` | S | `grid1.sql` |  |
| 157 | `157 - EVOLUÇÃO DE MOVIMENTAÇÃO DE PRODUTOS` | S | `grid1.sql` |  |
| 158 | `158 - CONCESSÃO DE DESCONTOS` | S | `grid1.sql` |  |
| 159 | `159 - RESUMO DE VENDAS POR VENDEDOR` | S | `chart1.sql`, `grid1.sql` |  |
| 160 | `160 - UTILIZAÇÃO DE TELAS I` | S | `chart1.sql`, `chart2.sql`, `simple-value1.sql` |  |
| 161 | `161 - UTILIZAÇÃO DE TELAS II` | S | `chart1.sql`, `chart2.sql` |  |
| 162 | `162 - EVOLUÇÃO DE VENDAS DO PRODUTO` | S | `chart1.sql`, `chart2.sql`, `grid1.sql` | *(antigo `Evolução de Vendas de Produto.sql`)* Gráfico de colunas: evolução mensal de vendas de um produto, com opções de desconto/impostos (`:DESC`, `:REP`, `:ST`, `:IPI`, `:STATUSNOTA`, `:TOP`). |
| 163 | `163 - PRINCIPAIS COMPRADORES` | S | `grid1.sql` |  |
| 164 | `164 - VENDAS POR ESTADO` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `grid1.sql`, `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql` |  |
| 165 | `165 - CONTROLE DE MOVIMENTAÇÕES DE TERCEIROS` | S | `grid1.sql`, `grid2.sql` | *(antigo `CONTROLE DE MOVIMENTAÇÃO DE TERCEIROS`)* • `P1.SQL` — Saldo por produto em poder de terceiros no período, por TOP (retorno 1202/1212/1213, remessa 1108/2208/1123). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODPARC`, `:P_CODPROD`. • `P2.SQL` — Detalhe nota a nota do produto selecionado (`:A_CODPROD`), com saldo acumulado. |
| 166 | `166 - RESUMO DE RESULTADO DE VENDAS` | S | `grid1.sql` | *(antigo `RESUMO DE RESULTADO DE VENDAS.sql`)* Resumo de faturamento e resultado (`AD_RESULTADO`) por nota fiscal de venda. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`, `:P_CODPARC`, `:P_CODVEND`. |
| 169 | `169 - CONFERÊNCIA DE DEVOLUÇÕES` | S | `grid1.sql` |  |
| 170 | `170 - CÁLCULO PROPORCIONALIDADE MATRIZ` | S | `grid1.sql`, `simple-value1.sql`, `simple-value2.sql` |  |
| 172 | `172 - AUDITORIA DE PRODUÇÃO-EXPEDIÇÃO` | S | `grid1.sql`, `grid2.sql`, `grid3.sql`, `TITULOP1.HTML`, `TITULOP2.HTML`, `TITULOP3.HTML` | *(antigo `AUDITORIA DE PRODUCAO-EXPEDICAO`)* • `P1.SQL` — Produção apontada em montagem final por produto e apontador (`:P_DTBASE`) • `P2.SQL` — Expedição/conferência apontada por produto e apontador (`:P_DTBASE`) • `P3.SQL` — Comparação produção apontada × expedição, identificando divergências (`:P_DTBASE`) • `LISTA_EXPEDIDOS_HOJE.SQL` — Produtos que entraram na expedição/conferência no dia (data fixa em `SYSDATE`, sem parâmetro), com quantidade e conferente • `TITULOP1.HTML`, `TITULOP2.HTML`, `TITULOP3.HTML` — Títulos HTML customizados para cada componente |
| 173 | `173 - DASH - ICMS IMPOSTOS ANALITICO` | S | `grid1.sql` |  |
| 174 | `174 - DASH - CONFERÊNCIA DE SALDO DE FORNECEDORES` | S | `grid1.sql`, `grid2.sql`, `grid3.sql`, `grid4.sql` |  |
| 175 | `175 - DASH - ICMS ESTORNAR SPARK FILIAL` | S | `grid1.sql` |  |
| 176 | `176 - INDICADOR DE ATENDIMENTO` | S | `grid1.sql`, `grid2.sql` |  |
| 177 | `177 - DASH - APONTAMENTO DE PRODUCAO` | S | `grid1.sql` |  |
| 179 | `179 - PAINEL - FICHA DE PARCEIRO` | S | `grid1.sql` |  |
| 180 | `180 - DASH - RELAÇÃO DE GUIAS` | S | `grid1.sql` |  |
| 181 | `181 - DASH - APURAÇÃO DO FRETE DE VENDA` | S | `grid1.sql` |  |
| 182 | `182 - AUDITOR E-COMMERCE GODEEP` | S | `grid1.sql` | *(antigo `AUDITOR E-COMMERCE GODEEP.sql`)* Auditoria de produtos no e-commerce GoDeep: rastreia alterações de código de produto via `TECLOG`. **Parâmetros:** `:P_CODPROD` (produto), `:P_PERIODO.INI` e `:P_PERIODO.FIN` (período). |
| 183 | `183 - DASH - QUANTIDADE DE BOLETOS` | S | `grid1.sql`, `grid2.sql`, `p1.html`, `simple-value1.sql` | *(antigo `DASH - QUANTIDADE DE BOLETOS`)* • `p1.sql`, `p2.sql` — Posição de cobrança: quantidade e valor de boletos a vencer, vencidos e em cartório, apurados na data de referência `DTREF` (última data útil anterior — ver memória `francesinha-data-referencia-d1`). `p1.sql` totaliza em uma linha (alimenta o título); `p2.sql` abre por conta bancária e status. • `p1.html` — Título HTML customizado do componente. |
| 184 | `184 - DASH - INCLUSÃO DE BOLETOS` | S | `grid1.sql` |  |
| 185 | `185 - VALIDA NATUREZA` | S | `grid1.sql` | *(antigo `Valida Natureza.sql`)* Query de validação: notas cuja natureza no cabeçalho (`TGFCAB`) diverge da natureza no financeiro (`TGFFIN`). Parâmetros: `:P_PERIODO.INI/FIN`. --- |
| 186 | `186 - INFORMATIVO DE GESTÃO ASSISTÊNCIA` | S | `chart1.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `Informativo de Gestão da Assistência`)* Parâmetros comuns: `:P_ANO`, `:P_DTFAB.INI/FIN`, `:P_CODPROD`, `:P_CODGRUPOPROD`. • `Gráfico.sql` — Série mensal de O.S. por tipo de defeito • `Componentes do período.sql` — Componentes utilizados na assistência, por código e grupo (`:A_MES`, `:A_DEFEITO`) • `Operadores.sql` — O.S. por técnico/operador (`:A_MES`, `:A_DEFEITO`) • `Produtos do período.sql` — O.S. por produto (`:A_MES`, `:A_DEFEITO`) |
| 187 | `187 - INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `chart6.sql`, `chart7.sql`, `geochart1.sql` | *(antigo `INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)`)* Parâmetros comuns: `:P_PERIODO.INI/FIN`, `:P_DTFAB.INI/FIN`. • `BARRAS.sql` — O.S. por produto do cliente selecionado (`:A_CODPARC`) • `Bolota.sql` — Movimentações por peça utilizada (`:P_CODGRUPOMAPROD`, `:P_CODGRUPOPROD`) • `Colunas.sql` — Movimentações por grupo de produto (`:P_CODGRUPOMAPROD`, `:P_CODGRUPOPROD`) • `GEOGUESSER.sql` — Mapa de calor de O.S. por UF • `PARCEIRO - BOLOTA.sql` — O.S. por parceiro em bolhas (`:A_UFS`) • `Período.sql` — Movimentos de assistência por mês do período (`:A_CODGRUPOPROD`) • `ProdAcabado/barras.sql` — Assistências por produto acabado • `ProdAcabado/donut.sql` — Tipos de defeito do agrupador selecionado (`:A_AGRUPADOR`, `:P_CODGRUPOPROD`) --- |
| 188 | `188 - INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA` | S | `grid1.sql`, `grid2.sql` | *(antigo `INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA`)* • `painelcomponentes.sql` — Componentes movimentados em assistência externa (`AD_SPKCAE`/`AD_SPKICAE`) • `painelprodutos.sql` — O.S. de assistência externa por produto (`AD_SPKCAE`) • Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODPARC`. |
| 189 | `189 - EVOLUÇÃO DE VENDAS POR PRODUTO` | S | `grid1.sql` | *(antigo `EVOLUÇÃO DE VENDAS POR PRODUTO.SQL`)* Evolução mensal de vendas por produto ou por agrupador (`:P_AGRUPADO`), com valores, quantidades e percentuais de participação. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_PA`. |
| 190 | `190 - AUDITORIA DE MOVIMENTAÇÕES` | S | `chart1.sql`, `chart2.sql`, `grid1.sql`, `grid2.sql` | *(antigo `AUDITORIA DE MOVIMENTACOES`)* Parâmetros comuns: `:P_MES`, `:P_ANO`, `:P_CODTIPOPER`. • `P1.SQL` — Gráfico de movimentações por dia (soma de quantidade ou contagem de notas, via `:P_DETALHE`) • `P2.SQL` — Gráfico de movimentações por usuário (`:P_DETALHE`) • `P3.SQL` — Detalhe das movimentações do dia selecionado (`:A_DIA`) • `P4.SQL` — Detalhe das movimentações do usuário selecionado (`:A_CODUSU`) |
| 191 | `191 - MOVIMENTACOES SEM CONFIRMAR` | S | `grid1.sql` |  |
| 192 | `192 - RELAÇÃO DE COMPRAS-PEDIDOS E PREVISÃO DE ENTREGA` | S | `grid1.sql` | *(antigo `RELAÇÃO DE COMPRAS-PEDIDOS E PREVISÃO DE ENTREGA.SQL`)* Pedidos de compra por fornecedor com valores agrupados por mês de previsão de entrega. Parâmetro: `:P_ANO`.<br>*(antigo `RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA.sql`)* Pedidos de venda por cliente com valores agrupados por mês de previsão de entrega. Parâmetro: `:P_ANO`. |
| 193 | `193 - RELAÇÃO DE ITENS SAIDAS` | S | `grid1.sql` | *(antigo `RELAÇÃO DE ITENS SAIDAS.SQL`)* Itens de saída (venda/devolução) com valores unitários, impostos, custos e cliente. Mesmos parâmetros de `RELAÇÃO DE ITENS ENTRADAS.sql`. --- |
| 194 | `194 - RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA` | S | `grid1.sql` |  |
| 195 | `195 - RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA` | S | `grid1.sql` |  |
| 196 | `196 - [OT] - MONITOR DE NOTAS FISCAIS DA REFORMA` | S | `chart1.sql`, `grid1.sql` |  |
| 197 | `197 - PAINEL DE GESTÃO` | S | `chart1.sql`, `chart2.sql`, `chart3.sql`, `chart4.sql`, `chart5.sql`, `chart6.sql`, `chart7.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql`, `grid4.sql`, `grid5.sql`, `grid6.sql`, `grid7.sql`, `grid8.sql`, `grid9.sql`, `grid10.sql`, `grid11.sql`, `grid12.sql`, `grid13.sql`, `grid14.sql`, `grid15.sql`, `grid16.sql`, `grid17.sql`, `grid18.sql`, `grid19.sql`, `grid20.sql`, `grid21.sql`, `grid22.sql`, `grid23.sql`, `grid24.sql`, `grid25.sql`, `grid26.sql`, `grid27.sql`, `simple-value1.sql`, `simple-value2.sql`, `simple-value3.sql`, `simple-value4.sql`, `simple-value5.sql`, `simple-value6.sql`, `simple-value7.sql`, `simple-value8.sql`, `simple-value9.sql`, `simple-value10.sql` |  |
| 198 | `198 - PAINEL PATRIMONIAL` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 200 | `200 - CLIENTES VENCIDOS` | S | `grid1.sql`, `grid2.sql` |  |
| 201 | `201 - DRE CONTABIL` | S | `chart1.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql`, `grid4.sql`, `grid5.sql` |  |
| 202 | `202 - BALANÇO PATRIMONIAL` | S | `chart1.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 203 | `203 - DASH - GESTÃO RECEBIMENTO EM CHEQUE` | S | `grid1.sql`, `simple-value1.sql` |  |
| 204 | `204 - ADIANTAMENTO FORNECEDOR` | S | `grid1.sql`, `grid2.sql` | *(antigo `ADIANTAMENTO FORNECEDOR`)* • `p1.sql` — Adiantamentos e empréstimos de fornecedores com natureza, datas e usuário (`:P_CODPARC`) • `p2.sql` — Detalhe da compensação selecionada (`:A_NUCOMPENS`) |
| 205 | `205 - PAINEL - FICHA DE PARCEIRO CHEQUE` | S | `chart1.sql`, `grid1.sql` |  |
| 206 | `206 - CARD - VENDAS MENSAL` | S | `grid1.sql` | *(antigo `CARD - VENDAS MENSAL/CARD.SQL`)* Card: quantidade vendida no mês corrente por grupo de meta (`AD_TGSSGM`/`AD_TGSISGM`), descontadas as devoluções, comparada com a meta (`VLRMET`) e colorida conforme o saldo. |
| 207 | `207 - ANÁLISE DE METAS DE VENDAS` | S | `chart1.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql` |  |
| 208 | `208 - PLANEJAMENTO DE ESTOQUE DE PRODUCAO` | S | `grid1.sql` | *(antigo `PLANEJAMENTO DE ESTOQUE DE PRODUCAO.SQL`)* Planejamento de estoque por agrupador de produto (`AD_AGRUPADOR`): estoque (local 109), estoque mínimo/máximo, planejado em produção (processos `A`/`P2`), pedidos de estoque e de venda em aberto, saldo MRP (`OBTEM_TOTAIS_MRP`) e histórico/pico de vendas. Parâmetros: `:P_DATA`, `:P_DATAPRD`. |
| 209 | `209 - PRODUÇÃO DIÁRIA POR COLABORADOR` | S | `00_MAPEAMENTO_COLABORADOR.sql`, `01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO.sql`, `chart1.sql`, `grid1.sql`, `grid2.sql`, `grid3.sql`, `README.md` | *(antigo `CARD - PRODUÇÃO DIÁRIA.sql`)* Card de produção diária por setor — **versão diferente** do `CARD.SQL` acima (não é cópia): filtra `APO.SITUACAO = 'C'`, cobre 12 setores (inclui insersora, revisora, display, kit IBM) e junta `TPRIPROC`/`TPRPRC`. Qual das duas está publicada no Sankhya: a confirmar.<br>*(antigo `PRODUCAO DIARIA POR COLABORADOR`)* Dashboard "[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR" — **versão atual** (revisada em Set/2026). Parâmetros comuns: `:P_PERIODO.INI/FIN` (sobre `APO.DHAPO`), `:P_STATUSPROC`, `:P_IDIPROD`, `:P_FINAL`, `:P_CODPRC`. • `p1.sql` — Processos/atividades com apontamento no período: quantidade apontada, perdas e saldo a produzir • `p2.sql` — Total produzido por colaborador × setor; expõe `CODFUNC` para drill-down • `g1.sql` — Mesmo resumo do `p2.sql` em forma de gráfico • `p3.sql` — Apontamentos do colaborador selecionado no P2 (`:A_CODFUNC`), um por linha • `01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO.sql` — *não é componente BI* (script de diagnóstico; ver seção própria)<br>*(antigo `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR`)* • `P1.SQL`, `P2.SQL`, `P3.SQL` — **Versão anterior** do dashboard acima. `P1.SQL` difere de `PRODUCAO DIARIA POR COLABORADOR/p1.sql` só no cabeçalho; `P2.SQL`/`P3.SQL` são produção por colaborador agrupada por setor (sem o drill-down por `CODFUNC` da versão atual).<br>*(antigo `Produção diária por colaborador.sql`)* Resumo de produção por colaborador e setor no período (`:P_PERIODO.INI/FIN`). Versão avulsa, próxima do `P2.SQL` de `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/`, mas não idêntica. |
| 210 | `210 - CRONOGRAMA GERAL DE PRODUCAO` | S | `grid1.sql` | *(antigo `CRONOGRAMA GERAL DE PRODUCAO/P1.SQL`)* Cronograma de produção por ficha (lote) e plano: produto, modelo, linha, placa, setor (etapa) e datas de apontamento, com quantidade apontada por setor. Parâmetros: `:P_NROLOTE`, `:P_NUMPS`, `:P_DTPREVENT.INI/FIN`, `:P_DESCRICAO` (setores). Tabelas: `TPRIPROC`, `TPRIPA`, `TPREFX`, `TPRIATV`, `TPRAPO`, `TPRAPA`, `TGFPRO`. |
| 211 | `211 - CARD - PRODUCAO DIARIA POR COLABORADOR` | S | `grid1.sql` | *(antigo `CARD - PRODUCAO DIARIA POR COLABORADOR.sql`)* Card: produção do dia por colaborador, agrupada por setor. Sem parâmetros. Tabelas: `TPRAPA`, `TPRAPO`, `TPRIATV`, `TPREFX`, `TFPFUN`, `TPRIPROC`, `TPRPRC`. |
| 212 | `212 - CONFERÊNCIA DIFAL- ST` | S | `grid1.sql` |  |
| 213 | `213 - DASHBOARD FICHAS DE PRODUCAO` | S | `grid1.sql` | *(antigo `DASHBOARD_FICHAS_PRODUCAO.SQL`)* Dashboard de fichas de produção em aberto ou em andamento. Exibe número da ficha, plano, produto, lote, saldo a produzir, status, datas previstas e linha de produção. Filtro fixo: `TPRIPROC.STATUSPROC IN ('A', 'P2')` (Aberto / Em Produção). Sem parâmetros. |
| 214 | `214 - VALIDA CONCILIAÇÃO BANCARIA` | S | `grid1.sql` |  |
| 215 | `215 - TABELA DE CARACTERÍSTICAS DE PRODUTO` | S | `grid1.sql` | *(antigo `Tabela de características de produto`)* • `p1.sql` — Tabela de características de produto: lista produtos ativos e não obsoletos com descrição completa, referência, NCM, peso líquido, medidas do produto (espessura × largura × altura em campos customizados `AD_`) e medidas da caixa (campos nativos). Aceita filtro multilist por grupo via `:P_CODGRUPOPROD`; quando o grupo informado for sintético (`ANALITICO = 'N'`), inclui automaticamente os filhos diretos. Tabelas: `TGFPRO`, `TGFGRU`. • `filtro.sql` — Componente de filtro multilist que popula o parâmetro `:P_CODGRUPOPROD` com grupos de produto cujo código inicia com `'3'`. Retorna `VALUE` (código) e `LABEL` (descrição). • `p1.xml` — Gadget de configuração do componente BI (prompt-parameter `P_CODGRUPOPROD` com entidade `GrupoProduto@CODGRUPOPROD`). --- |
| 216 | `216 - PRODUÇÃO DIARIA POR SETOR` | S | `00_MAPEAMENTO_TABELAS.sql`, `grid1.sql`, `grid2.sql`, `README.md` | *(antigo `PRODUCAO DIARIA POR SETOR`)* • `p1.sql` — Matriz dia útil × setor com a soma de `QTDAPONTADA` dos apontamentos concluídos (`:P_PERIODO.INI/FIN`) • `p2.sql` — Detalhamento por setor e colaborador (`:P_PERIODO`, `:P_SETOR`, `:A_DATA`) • `README.md` e `00_MAPEAMENTO_TABELAS.sql` desta pasta **não são versionados** (`.gitignore`). |
| 217 | `217 - PRODUCAO DIARIA POR COLABORADOR-TEMPO` | S | `grid1.sql`, `grid2.sql` |  |
| 218 | `218 - EVOLUÇÃO DE VENDAS POR PRODUTO - ANUAL` | S | `grid1.sql` |  |
| 219 | `219 - CARD - OS POR TECNICO MENSAL` | S | `grid1.sql` |  |
| 220 | `220 - CARD - OS POR PRODUTO MENSAL` | S | `grid1.sql` | *(antigo `CARD - OS POR PRODUTO MENSAL/CARD.SQL`)* Card: O.S. recebidas no mês corrente (`DTRECEB`) por grupo de produto (`AD_TGSSGM`/`AD_TGSISGM`), separando em aberto, finalizadas e total. |
| 221 | `221 - [SPARK] - APONTAMENTOS DE CONFERÊNCIA` | S | `grid1.sql` |  |
| 222 | `222 - [SPARK] - INDICADORES DE ATENDIMENTO DE REQUISIÇÃO` | S | `grid1.sql` | *(antigo `[SPARK] - INDICADORES DE ATENDIMENTO DE REQUISIÇÃO.sql`)* Atendimento do almoxarifado: requisições/transferências (`TIPMOV` Q e T) do período comparadas ao pedido de requisição de origem (`TGFVAR`), com percentual atendido e atraso em relação a `DTPREVENT`. Parâmetros: `:P_PERIODO.INI/FIN`. --- |
| 223 | `223 - [SPARK] - RELAÇÃO DE VENDAS POR PARCEIRO` | S | `grid1.sql` | *(antigo `[SPARK] - Relação de Vendas por Parceiro.sql`)* Números de série vendidos a um parceiro: produto, série, nota e data (`TGFSER`). Parâmetros: `:P_CODPARC`, `:P_PERIODO.INI/FIN`. --- |
| 224 | `224 - [SPARK] - INDICADOR DE ATENDIMENTO INTERNO` | S | `grid1.sql` | *(antigo `[SPARK] - INDICADOR DE ATENDIMENTO INTERNO.SQL`)* Atendimento das solicitações internas (`TIPMOV = 'J'`, exceto TOP 402 do plano de produção): data da solicitação, data de atendimento total, tempo em dias úteis e corridos, setor solicitante e códigos solicitados, via vínculo `TGFVAR`. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_ATENDIMENTO` (S/N/P). |
| 225 | `225 - [SPARK] - VENDAS POR VENDEDOR` | S | `grid1.sql`, `grid2.sql`, `grid3.sql` | *(antigo `RESUMO DE VENDAS POR VENDEDOR`)* Painel em três níveis, período `:P_PERIODO.INI/FIN` sobre `DTNEG`. • `P1.SQL` — Notas, produtos e total faturado por gerente (`TGFVEN.CODGER`); clique aciona o P2 (`:A_CODGER`) • `P2.SQL` — Mesmo resumo por vendedor (`:P_VENDEDOR`, `:P_GERENTE` ou drill de P1); clique aciona o P3 (`:A_CODVEND`) • `P3.SQL` — Notas do vendedor selecionado, uma por linha |
| 227 | `227 - EVOLUÇÃO MENSAL DE VENDAS POR PARCEIRO V2` | S | `grid1.sql` |  |
| 228 | `228 - [SPARK] - DISTRIBUIÇÃO DE VENDAS POR GRUPO DE PRODUTO` | S | `geochart1.sql`, `grid1.sql`, `grid2.sql` | *(antigo `[SPARK] - Distribuição de vendas por Grupo de Produto`)* Distribuição das vendas de um grupo de produto (pai ou direto, via `:P_CODGRUPOPROD`) no período `:P_PERIODO` (DTNEG), filtrado por vendedor/gerente via `:P_CODVEND` (multilist; gerente traz a equipe por `TGFVEN.CODGER`). Mesmo critério de venda de `RESUMO DE VENDAS POR VENDEDOR`; quantidades e valores são líquidos de devolução (critério de devolução de `Faturamento por período Gestão/p2.sql`). • `P1.SQL` — Parceiros (por vendedor) que compraram o grupo: quantidade de produtos, quantidade de notas e valor (só itens do grupo). Clique na linha aciona o P2 (`:A_CODPARC` e `:A_CODVEND`). • `P2.SQL` — Produtos do grupo comprados pelo parceiro/vendedor selecionado (`:A_CODPARC`, `:A_CODVEND`), com o vendedor em cada linha. • `P3.SQL` — Mapa de calor do Brasil por UF do parceiro, em quantidade (mesmo formato `QTD/CODUF/UF` do `GEOGUESSER`). |
| 230 | `230 - CARD - CÓDIGO DIÁRIO MERCADO LIVRE` | S | — |  |

---

## Comparação com o repositório anterior (03/11/2026)

Dos 126 SQLs que estavam no repositório, **83 eram idênticos** à produção, **29 estavam diferentes** e **14 não tinham correspondente**. Na reorganização valeu a versão de produção; as versões antigas continuam no histórico do git (commit anterior a esta reorganização).

### Arquivos que estavam diferentes da produção

| Arquivo antigo | Nº | Similaridade |
|---|---|---|
| `01 - Gráfico Qualidade por Operador/p2.sql` | 149 | 91% |
| `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/P2.SQL` | 209 | 98% |
| `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/P3.SQL` | 209 | 98% |
| `ADIANTAMENTO FORNECEDOR/p2.sql` | 204 | 98% |
| `AUDITORIA DE MOVIMENTACOES/P4.SQL` | 190 | 99% |
| `AUDITORIA DE PRODUCAO-EXPEDICAO/LISTA_EXPEDIDOS_HOJE.SQL` | 172 | 73% |
| `AUDITORIA DE PRODUCAO-EXPEDICAO/P1.SQL` | 172 | 98% |
| `AUDITORIA DE PRODUCAO-EXPEDICAO/P2.SQL` | 172 | 98% |
| `CARD - PRODUCAO DIARIA POR COLABORADOR.sql` | 211 | 100% |
| `CARD - PRODUÇÃO DIÁRIA/CARD.SQL` | 50 | 76% |
| `CARD - PRODUÇÃO DIÁRIA.sql` | 209 | 72% |
| `Curva ABC.sql` | 71 | 99% |
| `DASHBOARD DE VENDAS/DASHBOARD DE VENDAS.sql` | 125 | 98% |
| `Estoque em Elaboração.sql` | 80 | 67% |
| `EVOLUÇÃO DE BONIFICACAO POR CLIENTE.SQL` | 127 | 99% |
| `EVOLUÇÃO DE BRINDES POR CLIENTE.SQL` | 126 | 99% |
| `Evolução de Vendas de Produto.sql` | 162 | 92% |
| `EVOLUÇÃO DE VENDAS POR PRODUTO.SQL` | 189 | 100% |
| `FATURAMENTO POR PERIODO/P1.SQL` | 59 | 97% |
| `FATURAMENTO POR PERÍODO - Devoluções.sql` | 61 | 91% |
| `GRAFICO-QUALIDADE POR OPERADOR/g3.sql` | 149 | 95% |
| `GRAFICO-QUALIDADE POR OPERADOR/p1.sql` | 149 | 97% |
| `INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA/painelprodutos.sql` | 188 | 96% |
| `Produção diária por colaborador.sql` | 209 | 74% |
| `RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA.sql` | 192 | 100% |
| `RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA.sql` | 153 | 100% |
| `resultado de faturamento.sql` | 92 | 98% |
| `RESUMO DE RESULTADO DE VENDAS.sql` | 166 | 98% |
| `Tabela de características de produto/p1.xml` | 215 | 67% |

### Trocas de conteúdo encontradas

- `RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA.sql` continha o SQL de **compras** (nº 192), não o de vendas (nº 194).
- `RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA.sql` continha o SQL de **compras** (nº 153), não o de vendas (nº 195).
- `EVOLUÇÃO MENSAL DE COMPRAS POR PARCEIRO.sql` continha o SQL de *Relação de compras/produto por previsão de entrega* (nº 153), não o do nº 152.
- `ESTIMATIVA DE ESTOQUE GERENCIAL/P2.SQL` é idêntico ao `grid2` do nº 98 (*ESTIMATIVA DE ESTOQUE BKP*) e do nº 118.

### `_fora_de_producao/`

Arquivos sem correspondente em produção (versões antigas, rascunhos ou testes), mantidos com o caminho original:

- `01 - Gráfico Qualidade por Operador/p3.sql`
- `CARD - APONTAMENTOS DE CONFERENCIA - DETALHE.SQL`
- `CARD - OS POR TECNICO MENSAL/CARD.SQL`
- `Cálculo de Proporcionalidade Matriz.sql`
- `EVOLUÇÃO DE VENDAS POR PRODUTO - ANUAL.sql`
- `FATURAMENTO POR PERÍODO - GESTÃO.sql`
- `TEST_JSON_NUFIN_TGFECQ.SQL`
- `Tabela de características de produto/filtro.sql`

`TRG_NUMCHEQUE_TGFECQ_SPARK.SQL` (trigger, não é BI) foi movido para `triggers/`.

---

## Observações Gerais

- Parâmetros dinâmicos usam a sintaxe `:NOME_PARAMETRO` do Sankhya BI (`:P_*` = parâmetro de tela, `:A_*` = argumento recebido de outro componente via clique/drill-down).
- O SQL de componente BI é encapsulado em subconsulta pelo Sankhya: não terminar com `;` (gera ORA-00933).
- `HTML5 - Sankhya/` (fora do versionamento) guarda os modelos de componente HTML5 do fabricante.
- `209 - …/README.md`, `00_MAPEAMENTO_COLABORADOR.sql`, `216 - …/README.md` e `00_MAPEAMENTO_TABELAS.sql` ficam fora do versionamento (`.gitignore` — volumetria e nomes de colaboradores).
