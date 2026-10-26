# Catálogo de Componentes BI

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de componentes:** 32 pastas (+ subpasta `ProdAcabado/`) / 115 arquivos `.sql` (38 soltos na raiz, 77 em pastas), dos quais 3 não são componentes BI (ver [Arquivos que não são componentes BI](#arquivos-que-não-são-componentes-bi)); além de 4 títulos `.html` e 4 gadgets `.xml`/`.xaml`  
**Ambiente:** Sankhya BI (SQL analítico Oracle)  

> As pastas `PRODUCAO DIARIA POR SETOR/` e `PRODUCAO DIARIA POR COLABORADOR/`
> têm o `README.md` e os arquivos de mapeamento (`00_MAPEAMENTO_TABELAS.sql`,
> `00_MAPEAMENTO_COLABORADOR.sql`) **fora do versionamento** (`.gitignore` —
> volumetria e nomes de colaboradores). Os componentes de query dessas pastas
> (`p1.sql`, `p2.sql`, `p3.sql`, `g1.sql`) e o script de investigação
> `01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO.sql` estão no repositório.

---

## Visão Geral

Os componentes BI são queries SQL analíticas configuradas diretamente no Sankhya para alimentar dashboards, cards e relatórios gerenciais. Cada pasta corresponde a um painel ou tema de análise; cada arquivo `.sql` é um componente (gráfico, tabela, card ou coluna) dentro daquele painel. Arquivos `.sql` soltos na raiz são componentes de painel único.

**Convenção de nomes de arquivo:**
- `P1.SQL`, `P2.SQL`, `P3.SQL` = partes/painéis de um dashboard multi-componente
- `g1.sql`, `g2.sql`, `g3.sql` = componentes de gráfico de um dashboard multi-componente
- `CARD.SQL` = card numérico de destaque
- `BARRAS.sql`, `Colunas.sql`, `Bolota.sql` = tipo de gráfico do componente
- `componente.xml` / `COMPONENTE.XML` / `componente.xaml` / `p1.xml` = gadget exportado do BI (parâmetros e layout)

---

## Catálogo por Tema

### 1. Produção

#### `DASHBOARD_FICHAS_PRODUCAO.SQL`
Dashboard de fichas de produção em aberto ou em andamento. Exibe número da ficha, plano, produto, lote, saldo a produzir, status, datas previstas e linha de produção. Filtro fixo: `TPRIPROC.STATUSPROC IN ('A', 'P2')` (Aberto / Em Produção). Sem parâmetros.

#### `CRONOGRAMA GERAL DE PRODUCAO/P1.SQL`
Cronograma de produção por ficha (lote) e plano: produto, modelo, linha, placa, setor (etapa) e datas de apontamento, com quantidade apontada por setor. Parâmetros: `:P_NROLOTE`, `:P_NUMPS`, `:P_DTPREVENT.INI/FIN`, `:P_DESCRICAO` (setores). Tabelas: `TPRIPROC`, `TPRIPA`, `TPREFX`, `TPRIATV`, `TPRAPO`, `TPRAPA`, `TGFPRO`.

#### `PAINEL ACOMPANHAMENTO DE PRODUÇÃO/`
- `p2.sql` — Detalhe dos processos de produção com apontamentos e percentual produzido por lote
- `p3.sql` — Detalhe de processos/atividades com apontamentos de produção e perdas
- Parâmetros comuns: `:P_DTAPONT.INI/FIN`, `:P_STATUSPROC`, `:P_IDIPROC`, `:P_DETALHAR` (P = processo, A = atividade), `:P_FINAL`, `:A_VALUE`. Não há `p1.sql` versionado.

#### `AUDITORIA DE PRODUCAO-EXPEDICAO/`
- `P1.SQL` — Produção apontada em montagem final por produto e apontador (`:P_DTBASE`)
- `P2.SQL` — Expedição/conferência apontada por produto e apontador (`:P_DTBASE`)
- `P3.SQL` — Comparação produção apontada × expedição, identificando divergências (`:P_DTBASE`)
- `LISTA_EXPEDIDOS_HOJE.SQL` — Produtos que entraram na expedição/conferência no dia (data fixa em `SYSDATE`, sem parâmetro), com quantidade e conferente
- `TITULOP1.HTML`, `TITULOP2.HTML`, `TITULOP3.HTML` — Títulos HTML customizados para cada componente

#### `CARD - PRODUÇÃO DIÁRIA/CARD.SQL`
Card: produção do dia atual por setor (soma de `QTDAPONTADA` em `TPRAPA`, 7 setores fixos).

#### `CARD - PRODUÇÃO DIÁRIA.sql`
Card de produção diária por setor — **versão diferente** do `CARD.SQL` acima (não é cópia): filtra `APO.SITUACAO = 'C'`, cobre 12 setores (inclui insersora, revisora, display, kit IBM) e junta `TPRIPROC`/`TPRPRC`. Qual das duas está publicada no Sankhya: a confirmar.

#### `CARD - PRODUCAO DIARIA POR COLABORADOR.sql`
Card: produção do dia por colaborador, agrupada por setor. Sem parâmetros. Tabelas: `TPRAPA`, `TPRAPO`, `TPRIATV`, `TPREFX`, `TFPFUN`, `TPRIPROC`, `TPRPRC`.

#### `ESTOQUE PRODUÇÃO EM PROCESSO/`
- `p1.sql` — Estoque em processo por produto acabado com saldo e custo por matéria-prima pendente de conclusão (`:P_CODPRC`, `:P_CODPRODPA`)
- `p2.sql` — Saldo pendente por lote/processo do PA selecionado (`:A_CODPRODPA`, `:P_CODPRC`)

#### `Estoque em Elaboração.sql`
Localiza o saldo de PA ainda não apontado (estoque em elaboração) por processo (`IDIPROC`) e lote. Parâmetros: `:P_PERIODO.INI/FIN` (sobre `TPRIPROC.DHINST`), `:P_CODPRC`, `:P_CODPRODPA`.

#### `PLANEJAMENTO DE ESTOQUE DE PRODUCAO.SQL`
Planejamento de estoque por agrupador de produto (`AD_AGRUPADOR`): estoque (local 109), estoque mínimo/máximo, planejado em produção (processos `A`/`P2`), pedidos de estoque e de venda em aberto, saldo MRP (`OBTEM_TOTAIS_MRP`) e histórico/pico de vendas. Parâmetros: `:P_DATA`, `:P_DATAPRD`.

#### `PRODUCAO DIARIA POR COLABORADOR/`
Dashboard "[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR" — **versão atual** (revisada em Set/2026). Parâmetros comuns: `:P_PERIODO.INI/FIN` (sobre `APO.DHAPO`), `:P_STATUSPROC`, `:P_IDIPROD`, `:P_FINAL`, `:P_CODPRC`.
- `p1.sql` — Processos/atividades com apontamento no período: quantidade apontada, perdas e saldo a produzir
- `p2.sql` — Total produzido por colaborador × setor; expõe `CODFUNC` para drill-down
- `g1.sql` — Mesmo resumo do `p2.sql` em forma de gráfico
- `p3.sql` — Apontamentos do colaborador selecionado no P2 (`:A_CODFUNC`), um por linha
- `01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO.sql` — *não é componente BI* (script de diagnóstico; ver seção própria)

#### `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/`
- `P1.SQL`, `P2.SQL`, `P3.SQL` — **Versão anterior** do dashboard acima. `P1.SQL` difere de `PRODUCAO DIARIA POR COLABORADOR/p1.sql` só no cabeçalho; `P2.SQL`/`P3.SQL` são produção por colaborador agrupada por setor (sem o drill-down por `CODFUNC` da versão atual).

#### `Produção diária por colaborador.sql`
Resumo de produção por colaborador e setor no período (`:P_PERIODO.INI/FIN`). Versão avulsa, próxima do `P2.SQL` de `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/`, mas não idêntica.

#### `PRODUCAO DIARIA POR SETOR/`
- `p1.sql` — Matriz dia útil × setor com a soma de `QTDAPONTADA` dos apontamentos concluídos (`:P_PERIODO.INI/FIN`)
- `p2.sql` — Detalhamento por setor e colaborador (`:P_PERIODO`, `:P_SETOR`, `:A_DATA`)
- `README.md` e `00_MAPEAMENTO_TABELAS.sql` desta pasta **não são versionados** (`.gitignore`).

#### `GRAFICO-QUALIDADE POR OPERADOR/`
Não conformidades do apontamento de qualidade (`AD_APOQLD`). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_SETOR` (multilist).
- `g1.sql` — Total de defeitos por revisor
- `g2.sql` — Total de defeitos por operador
- `g3.sql` — Defeitos por tipo do funcionário selecionado (`:A_IDFUNC`)
- `p1.sql` — Detalhamento dos apontamentos do funcionário selecionado (`:A_IDFUNC`)
- `componente.xml` — Gadget do dashboard (parâmetros e layout com as quatro consultas embutidas)

#### `01 - Gráfico Qualidade por Operador/`
- `p2.sql` — Total de defeitos por operador (`TFPFUN`, sem filtro de setor)
- `p3.sql` — Defeitos por tipo × setor (`AD_CADFUNC.SETOR IN :P_SETOR`)
- Versão diferente/anterior do painel acima: `p2.sql` equivale ao `g2.sql` sem o filtro `:P_SETOR` e sem a deduplicação de `TFPFUN`. Qual está em uso: a confirmar.

---

### 2. Vendas / Faturamento

#### `DASHBOARD DE VENDAS/DASHBOARD DE VENDAS.sql`
Detalhe de vendas: parceiro, UF, vendedor, produto, data de negociação, quantidade, valor unitário, valor com desconto e tipo de operação. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODVEND`, `:P_CODGRUPOPROD`, `:P_UF`, `:P_CODPARC`.

#### `FATURAMENTO POR PERIODO/P1.SQL`
Faturamento por período com Curva ABC de vendas por produto. Parâmetros: `:P_PER.INI/FIN`, `:P_GRUPO`, `:P_CODVEND`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODEMP`.

#### `FATURAMENTO POR PERÍODO - GESTÃO.sql`
Faturamento por agrupador de produto e vendedor, com participação percentual em quantidade e valor. Mesma lógica do `Faturamento por período Gestão/p1.sql`, reescrita com CTEs (versão diferente). Parâmetros: `:P_PER.INI/FIN`, `:P_GRUPO`, `:P_CODEMP`, `:P_CODVEND`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODPARCMATRIZ`, `:P_CODUF`.

#### `FATURAMENTO POR PERÍODO - Devoluções.sql`
Devoluções agrupadas por produto/agrupador, com participação percentual em quantidade e valor. Variante do `Faturamento por período Gestão/p2.sql` (versões diferentes).

#### `Faturamento por período Gestão/`
- `p1.sql` — Faturamento por agrupador de produto e vendedor, com percentuais de participação
- `p2.sql` — Devoluções por agrupador de produto e vendedor, com percentuais de participação

#### `RESUMO DE RESULTADO DE VENDAS.sql`
Resumo de faturamento e resultado (`AD_RESULTADO`) por nota fiscal de venda. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`, `:P_CODPARC`, `:P_CODVEND`.

#### `resultado de faturamento.sql`
Resultado de faturamento por nota de venda (CFOP, parceiro, UF, `AD_RESULTADO`, total com impostos de `TGFDIN`). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`.

#### `RESUMO DE VENDAS POR VENDEDOR/`
Painel em três níveis, período `:P_PERIODO.INI/FIN` sobre `DTNEG`.
- `P1.SQL` — Notas, produtos e total faturado por gerente (`TGFVEN.CODGER`); clique aciona o P2 (`:A_CODGER`)
- `P2.SQL` — Mesmo resumo por vendedor (`:P_VENDEDOR`, `:P_GERENTE` ou drill de P1); clique aciona o P3 (`:A_CODVEND`)
- `P3.SQL` — Notas do vendedor selecionado, uma por linha

#### `PAINEL COMERCIAL.SQL`
Pedidos de venda em aberto com estoque atual, simulação de entrega e disponibilidade. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_ENTREGA.INI/FIN`, `:P_CODPARC`, `:P_CODEMP`, `:P_SIMULACRO`.

#### `CARD - VENDAS MENSAL/CARD.SQL`
Card: quantidade vendida no mês corrente por grupo de meta (`AD_TGSSGM`/`AD_TGSISGM`), descontadas as devoluções, comparada com a meta (`VLRMET`) e colorida conforme o saldo.

#### `[SPARK] - Distribuição de vendas por Grupo de Produto/`
Distribuição das vendas de um grupo de produto (pai ou direto, via `:P_CODGRUPOPROD`) no período `:P_PERIODO` (DTNEG), filtrado por vendedor/gerente via `:P_CODVEND` (multilist; gerente traz a equipe por `TGFVEN.CODGER`). Mesmo critério de venda de `RESUMO DE VENDAS POR VENDEDOR`; quantidades e valores são líquidos de devolução (critério de devolução de `Faturamento por período Gestão/p2.sql`).
- `P1.SQL` — Parceiros (por vendedor) que compraram o grupo: quantidade de produtos, quantidade de notas e valor (só itens do grupo). Clique na linha aciona o P2 (`:A_CODPARC` e `:A_CODVEND`).
- `P2.SQL` — Produtos do grupo comprados pelo parceiro/vendedor selecionado (`:A_CODPARC`, `:A_CODVEND`), com o vendedor em cada linha.
- `P3.SQL` — Mapa de calor do Brasil por UF do parceiro, em quantidade (mesmo formato `QTD/CODUF/UF` do `GEOGUESSER`).

#### `[SPARK] - Relação de Vendas por Parceiro.sql`
Números de série vendidos a um parceiro: produto, série, nota e data (`TGFSER`). Parâmetros: `:P_CODPARC`, `:P_PERIODO.INI/FIN`.

---

### 3. Análise de Produtos / Clientes

#### `Curva ABC.sql`
Curva ABC de produtos ou de parceiros (`:@ANALISE`), com opções de incluir desconto, reposição, ST, IPI e notas não confirmadas (`:DESC`, `:REP`, `:ST`, `:IPI`, `:STATUSNOTA`).

#### `EVOLUÇÃO DE VENDAS POR PRODUTO.SQL`
Evolução mensal de vendas por produto ou por agrupador (`:P_AGRUPADO`), com valores, quantidades e percentuais de participação. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_PA`.

#### `EVOLUÇÃO DE VENDAS POR PRODUTO - ANUAL.sql`
Variante com eixos invertidos: linhas = mês + linha de produto (`AD_LINHA`), colunas = anos. Sem parâmetros (período fixo 2022–2026 resolvido na query).

#### `Evolução de Vendas de Produto.sql`
Gráfico de colunas: evolução mensal de vendas de um produto, com opções de desconto/impostos (`:DESC`, `:REP`, `:ST`, `:IPI`, `:STATUSNOTA`, `:TOP`).

#### `EVOLUÇÃO MENSAL DE VENDAS POR PARCEIRO/`
- `p1.sql` — Valor vendido por parceiro, mês a mês, com total, representante e UF. Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODVEND` (multilist), `:P_CODPARCMATRIZ`.
- `componente.xaml` — Gadget do componente (parâmetros e grade).

#### `EVOLUÇÃO MENSAL DE COMPRAS POR PARCEIRO.sql`
Evolução mensal de compras por fornecedor/produto. Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODGRUPOPROD`.

#### `EVOLUÇÃO DE BONIFICACAO POR CLIENTE.SQL`
Evolução mensal de bonificações por cliente (TOPs 1121, 1117, 1191). Parâmetros: `:P_ANO`, `:P_CODPARC`, `:P_CODVEND`.

#### `EVOLUÇÃO DE BRINDES POR CLIENTE.SQL`
Evolução mensal de brindes por cliente (TOP 1311). Mesma query da bonificação, mudando só as TOPs.

---

### 4. Estoque

#### `ESTIMATIVA DE ESTOQUE/`
- `P1.SQL` — Saldo estimado por produto: estoque + planejado em produção + pedidos de estoque − pedidos de venda em aberto (`:P_DATA`, `:P_CODGRUPO`, `:P_DESCRPROD`)
- `P2.SQL` — Pedidos de venda em aberto do produto selecionado (`:A_CODPROD`, `:P_DATA`)
- `P3.SQL` — Processos/lotes de produção em aberto do produto selecionado, com saldo a produzir (`:A_CODPROD`)

#### `ESTIMATIVA DE ESTOQUE GERENCIAL/`
- `P1.SQL`, `P2.SQL`, `P3.SQL` — Mesmo painel de `ESTIMATIVA DE ESTOQUE/`, em **versão diferente/anterior** (subconsultas inline em vez de CTEs; P1 traz bloco `SALDOMETA` comentado). Mesmos parâmetros.

#### `ESTOQUE SEM MOVIMENTO.SQL`
Produtos em estoque sem movimento há 3, 2 ou 1 ano, com indicação por cor. Parâmetros: `:P_DTCORTE`, `:P_CODLOCAL`, `:P_USOPROD`, `:P_VALIDEST`.

#### `RELATÓRIO CÓPIA DE ESTOQUE.SQL`
Contagem de estoque (`TGFCTE`) com produto, local, custos (sem ICMS, com ICMS, gerencial) e última movimentação. Parâmetros: `:DATE`, `:P_CODLOCAL` e outros opcionais.

#### `TRANSFERENCIA ENTRE EMPRESAS.SQL`
Quantidades a transferir entre empresas: produtos com saldo de contagem (`TGFCTE`) negativo em uma filial e positivo em outra. Parâmetro: `:DATE`.

#### `EXPORTADOR DE SÉRIES DO ESTOQUE.SQL`
Séries em estoque (`TGFSER`, saldo ≥ 1) por empresa, local, produto e série. Parâmetros: `:P_CODEMP`, `:P_CODLOCALORIG`, `:P_CODPROD`, `:P_SERIE`.

#### `CONFERENCIA DE ESTOQUE DE TERCEIRO/`
- `p1.sql` — Saldo de estoque de terceiros por parceiro e produto até a data, pela flag `ITE.ATUALESTTERC` (P/T somam, R/D subtraem). Parâmetros: `:P_DATAFIN`, `:P_CODEMP`, `:P_CODLOCAL`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODPPROD`.
- `p2.sql` — Detalhe nota a nota do parceiro + produto selecionados (`:A_CODPARC`, `:A_CODPROD`), com saldo acumulado.

#### `CONTROLE DE MOVIMENTAÇÃO DE TERCEIROS/`
- `P1.SQL` — Saldo por produto em poder de terceiros no período, por TOP (retorno 1202/1212/1213, remessa 1108/2208/1123). Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODPARC`, `:P_CODPROD`.
- `P2.SQL` — Detalhe nota a nota do produto selecionado (`:A_CODPROD`), com saldo acumulado.

#### `CONFERÊNCIA COMPOSIÇÃO PA-PI/`
- `p1.sql` — Conferência da estrutura de produtos: processos, etapas e materiais (`TPRPRC`, `TPRATV`, `TPREFX`, `TPRLMP`). Parâmetros: `:P_CODPRC`, `:P_CODPRODPA`, `:P_CODPRODMP`, `:P_DESCRMP`, `:P_PA`.
- `p2.sql` — Materiais da etapa selecionada, com quantidade de mistura e requisição (`:A_CODPRC`, `:A_IDEFX`)

#### `[SPARK] - INDICADOR DE ATENDIMENTO INTERNO.SQL`
Atendimento das solicitações internas (`TIPMOV = 'J'`, exceto TOP 402 do plano de produção): data da solicitação, data de atendimento total, tempo em dias úteis e corridos, setor solicitante e códigos solicitados, via vínculo `TGFVAR`. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_ATENDIMENTO` (S/N/P).

#### `[SPARK] - INDICADORES DE ATENDIMENTO DE REQUISIÇÃO.sql`
Atendimento do almoxarifado: requisições/transferências (`TIPMOV` Q e T) do período comparadas ao pedido de requisição de origem (`TGFVAR`), com percentual atendido e atraso em relação a `DTPREVENT`. Parâmetros: `:P_PERIODO.INI/FIN`.

---

### 5. Compras

#### `RELAÇÃO DE COMPRAS-PEDIDOS E PREVISÃO DE ENTREGA.SQL`
Pedidos de compra por fornecedor com valores agrupados por mês de previsão de entrega. Parâmetro: `:P_ANO`.

#### `RELAÇÃO DE COMPRAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`
Itens de compra por produto e fornecedor com quantidades por mês de previsão de entrega. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODGRUPOPROD`.

#### `ADIANTAMENTO FORNECEDOR/`
- `p1.sql` — Adiantamentos e empréstimos de fornecedores com natureza, datas e usuário (`:P_CODPARC`)
- `p2.sql` — Detalhe da compensação selecionada (`:A_NUCOMPENS`)

#### `RELAÇÃO DE ITENS ENTRADAS.sql`
Itens de entrada (compra/devolução) com valores unitários, impostos, custos e fornecedor. Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODEMP`, `:P_CODPARC`, `:P_CODPROD`, `:P_CODNAT`, `:P_CODGRUPOPROD`.

---

### 6. Vendas — Pedidos e Previsão

#### `RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA.sql`
Pedidos de venda por cliente com valores agrupados por mês de previsão de entrega. Parâmetro: `:P_ANO`.

#### `RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`
Itens de venda por produto e cliente com quantidades por mês de previsão de entrega. Parâmetros: `:P_ANO`, `:P_CODPROD`, `:P_CODPARC`, `:P_CODGRUPOPROD`.

#### `RELAÇÃO DE ITENS SAIDAS.SQL`
Itens de saída (venda/devolução) com valores unitários, impostos, custos e cliente. Mesmos parâmetros de `RELAÇÃO DE ITENS ENTRADAS.sql`.

---

### 7. Assistência Técnica

#### `Informativo de Gestão da Assistência/`
Parâmetros comuns: `:P_ANO`, `:P_DTFAB.INI/FIN`, `:P_CODPROD`, `:P_CODGRUPOPROD`.
- `Gráfico.sql` — Série mensal de O.S. por tipo de defeito
- `Componentes do período.sql` — Componentes utilizados na assistência, por código e grupo (`:A_MES`, `:A_DEFEITO`)
- `Operadores.sql` — O.S. por técnico/operador (`:A_MES`, `:A_DEFEITO`)
- `Produtos do período.sql` — O.S. por produto (`:A_MES`, `:A_DEFEITO`)

#### `INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA/`
- `painelcomponentes.sql` — Componentes movimentados em assistência externa (`AD_SPKCAE`/`AD_SPKICAE`)
- `painelprodutos.sql` — O.S. de assistência externa por produto (`AD_SPKCAE`)
- Parâmetros: `:P_PERIODO.INI/FIN`, `:P_CODPARC`.

#### `CARD - OS POR PRODUTO MENSAL/CARD.SQL`
Card: O.S. recebidas no mês corrente (`DTRECEB`) por grupo de produto (`AD_TGSSGM`/`AD_TGSISGM`), separando em aberto, finalizadas e total.

#### `CARD - OS POR TECNICO MENSAL/CARD.SQL`
Card: O.S. recebidas no mês corrente por técnico (`AD_CADFUNC`), separando em aberto, finalizadas e total.

#### `INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)/`
Parâmetros comuns: `:P_PERIODO.INI/FIN`, `:P_DTFAB.INI/FIN`.
- `BARRAS.sql` — O.S. por produto do cliente selecionado (`:A_CODPARC`)
- `Bolota.sql` — Movimentações por peça utilizada (`:P_CODGRUPOMAPROD`, `:P_CODGRUPOPROD`)
- `Colunas.sql` — Movimentações por grupo de produto (`:P_CODGRUPOMAPROD`, `:P_CODGRUPOPROD`)
- `GEOGUESSER.sql` — Mapa de calor de O.S. por UF
- `PARCEIRO - BOLOTA.sql` — O.S. por parceiro em bolhas (`:A_UFS`)
- `Período.sql` — Movimentos de assistência por mês do período (`:A_CODGRUPOPROD`)
- `ProdAcabado/barras.sql` — Assistências por produto acabado
- `ProdAcabado/donut.sql` — Tipos de defeito do agrupador selecionado (`:A_AGRUPADOR`, `:P_CODGRUPOPROD`)

---

### 8. Auditoria / Rastreabilidade

#### `AUDITORIA DE MOVIMENTACOES/`
Parâmetros comuns: `:P_MES`, `:P_ANO`, `:P_CODTIPOPER`.
- `P1.SQL` — Gráfico de movimentações por dia (soma de quantidade ou contagem de notas, via `:P_DETALHE`)
- `P2.SQL` — Gráfico de movimentações por usuário (`:P_DETALHE`)
- `P3.SQL` — Detalhe das movimentações do dia selecionado (`:A_DIA`)
- `P4.SQL` — Detalhe das movimentações do usuário selecionado (`:A_CODUSU`)

#### `AUDITOR E-COMMERCE GODEEP.sql`
Auditoria de produtos no e-commerce GoDeep: rastreia alterações de código de produto via `TECLOG`.  
**Parâmetros:** `:P_CODPROD` (produto), `:P_PERIODO.INI` e `:P_PERIODO.FIN` (período).

#### `CARD - APONTAMENTOS DE CONFERENCIA - DETALHE.SQL`
Apontamentos de conferência de arquivos ainda em andamento (`AD_TGSIXN.STATUS = 1`), com nota conferida, conferente e duração em dias úteis. Sem parâmetros. Tabelas: `AD_TGSIXN`, `TGFIXN`, `TFPFUN`.

---

### 9. Financeiro / Fiscal

#### `APURAÇÃO DIFAL/`
- `P1.SQL` — Notas com DIFAL (remetente ou destinatário, via `:P_TIPOIMPOSTO`) e FCP no período de faturamento, comparando com os títulos de imposto (`TGFFIN.CODTIPTIT = 35`) e colorindo a linha conforme a UF tenha ou não IE cadastrada (`TSIIUF`). Parâmetros: `:PERIODO`, `:TIPMOV`, `:EMPRESA`, `:UF`, `:CIDADE`, `:NOTA`, `:P_TIPOIMPOSTO`.
- `COMPONENTE.XML` — Gadget do componente (parâmetros e layout).

#### `CONTAS A PAGAR E PROVISAO DE DESPESAS.sql`
Títulos em aberto (`DHBAIXA` nula) por vencimento, separando provisões e reais, com natureza e centro de resultado (exceto `CODTIPTIT = 34`). Parâmetros: `:P_PERIODO.INI/FIN` (sobre `DTVENC`), `:P_CODEMP`, `:P_RECDESP`.

#### `DASH - QUANTIDADE DE BOLETOS/`
- `p1.sql`, `p2.sql` — Posição de cobrança: quantidade e valor de boletos a vencer, vencidos e em cartório, apurados na data de referência `DTREF` (última data útil anterior — ver memória `francesinha-data-referencia-d1`). `p1.sql` totaliza em uma linha (alimenta o título); `p2.sql` abre por conta bancária e status.
- `p1.html` — Título HTML customizado do componente.

#### `Cálculo de Proporcionalidade Matriz.sql`
Base de ICMS e valor das notas por CFOP no período, para cálculo de proporcionalidade da matriz. Parâmetros: `:P_PERIODO.INI/FIN`, `:STATUSNOTA`.

#### `Valida Natureza.sql`
Query de validação: notas cuja natureza no cabeçalho (`TGFCAB`) diverge da natureza no financeiro (`TGFFIN`). Parâmetros: `:P_PERIODO.INI/FIN`.

---

### 10. Cadastro de Produtos

#### `Tabela de características de produto/`
- `p1.sql` — Tabela de características de produto: lista produtos ativos e não obsoletos com descrição completa, referência, NCM, peso líquido, medidas do produto (espessura × largura × altura em campos customizados `AD_`) e medidas da caixa (campos nativos). Aceita filtro multilist por grupo via `:P_CODGRUPOPROD`; quando o grupo informado for sintético (`ANALITICO = 'N'`), inclui automaticamente os filhos diretos. Tabelas: `TGFPRO`, `TGFGRU`.
- `filtro.sql` — Componente de filtro multilist que popula o parâmetro `:P_CODGRUPOPROD` com grupos de produto cujo código inicia com `'3'`. Retorna `VALUE` (código) e `LABEL` (descrição).
- `p1.xml` — Gadget de configuração do componente BI (prompt-parameter `P_CODGRUPOPROD` com entidade `GrupoProduto@CODGRUPOPROD`).

---

## Arquivos que não são componentes BI

Estão nesta pasta, mas não são queries de dashboard. Mantidos no lugar (não movidos):

| Arquivo | O que é |
|---|---|
| `TRG_NUMCHEQUE_TGFECQ_SPARK.SQL` | Trigger em `TGFECQ` que propaga o número do cheque para a movimentação bancária (`TGFMBC`). Pertence a `triggers/`. |
| `TEST_JSON_NUFIN_TGFECQ.SQL` | Query de teste/diagnóstico da extração do JSON do campo `DETALHE` de `TGFECQ` (apoio à trigger acima). |
| `PRODUCAO DIARIA POR COLABORADOR/01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO.sql` | Script de investigação: por que o saldo a produzir do `p1.sql` não bate com o `PLANEJADO_ESTOQUE` de `PLANEJAMENTO DE ESTOQUE DE PRODUCAO.SQL`. |

## Versões paralelas (possíveis duplicatas)

Pares com o mesmo propósito e conteúdo diferente. Qual está publicada no Sankhya: a confirmar.

| Arquivos | Situação |
|---|---|
| `CARD - PRODUÇÃO DIÁRIA.sql` × `CARD - PRODUÇÃO DIÁRIA/CARD.SQL` | Versões diferentes (lista de setores, filtro `SITUACAO = 'C'`, joins) |
| `PRODUCAO DIARIA POR COLABORADOR/` × `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/` | Mesma P1 (só cabeçalho difere); P2/P3 diferentes; a primeira é a versão atual (Set/2026) com G1 e drill por `CODFUNC` |
| `Produção diária por colaborador.sql` × `CARD - PRODUCAO DIARIA POR COLABORADOR.sql` × `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/P2.SQL` | Variantes da produção por colaborador/setor; nenhuma é cópia exata |
| `GRAFICO-QUALIDADE POR OPERADOR/` × `01 - Gráfico Qualidade por Operador/` | `p2.sql` ≈ `g2.sql` sem filtro `:P_SETOR` e sem deduplicação de `TFPFUN` |
| `ESTIMATIVA DE ESTOQUE/` × `ESTIMATIVA DE ESTOQUE GERENCIAL/` | Mesmo painel; a versão "GERENCIAL" usa subconsultas inline |
| `FATURAMENTO POR PERÍODO - GESTÃO.sql` × `Faturamento por período Gestão/p1.sql` | Mesma lógica; o avulso foi reescrito com CTEs |
| `FATURAMENTO POR PERÍODO - Devoluções.sql` × `Faturamento por período Gestão/p2.sql` | Variantes da análise de devoluções |

---

## Observações Gerais

- Componentes com parâmetros dinâmicos usam a sintaxe `:NOME_PARAMETRO` do Sankhya BI (`:P_*` = parâmetro de tela, `:A_*` = argumento recebido de outro componente via clique/drill-down).
- Componentes multi-parte (`P1`, `P2`, `P3`) são configurados como abas ou seções do mesmo dashboard no Sankhya — a ordem numérica define a sequência de exibição.
- Arquivos HTML (`TITULOP*.HTML`, `p1.html`) são títulos customizados injetados no componente BI via Sankhya.
- Arquivos `.xml`/`.xaml` são exportações do gadget (parâmetros e layout); podem conter cópia das queries embutidas.
