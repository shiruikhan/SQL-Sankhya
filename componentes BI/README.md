# Catálogo de Componentes BI

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de componentes:** 70+  
**Ambiente:** Sankhya BI (SQL analítico Oracle)  

---

## Visão Geral

Os componentes BI são queries SQL analíticas configuradas diretamente no Sankhya para alimentar dashboards, cards e relatórios gerenciais. Cada pasta corresponde a um painel ou tema de análise; cada arquivo `.sql` é um componente (gráfico, tabela, card ou coluna) dentro daquele painel.

**Convenção de nomes de arquivo:**
- `P1.SQL`, `P2.SQL`, `P3.SQL` = partes/painéis de um dashboard multi-componente
- `CARD.SQL` = card numérico de destaque
- `BARRAS.sql`, `Colunas.sql`, `Bolota.sql` = tipo de gráfico do componente

---

## Catálogo por Tema

### 1. Produção

#### `DASHBOARD_FICHAS_PRODUCAO.SQL`
Dashboard de fichas de produção em aberto ou em andamento. Exibe número da ficha, plano, produto, lote, saldo a produzir, status, datas previstas e linha de produção. Filtros: status `Aberto` ou `Em Produção`; vinculado a planos gerados.

#### `CRONOGRAMA GERAL DE PRODUCAO/P1.SQL`
Cronograma consolidado de produção: visão de plano mestre (MPS) por produto acabado, meta, saldo a produzir e necessidade de matéria-prima. Consome a function `OBTEM_TOTAIS_MRP`.

#### `PAINEL ACOMPANHAMENTO DE PRODUÇÃO/`
- `p2.sql` — Componente 2 do painel: detalhes de andamento por processo/etapa
- `p3.sql` — Componente 3: indicadores de conclusão e pendências

#### `AUDITORIA DE PRODUCAO-EXPEDICAO/`
- `P1.SQL` — Pendências de produção
- `P2.SQL` — Status de expedição vinculado à produção
- `P3.SQL` — Conferência e divergências
- `TITULOP1.HTML`, `TITULOP2.HTML`, `TITULOP3.HTML` — Títulos HTML customizados para cada componente

#### `CARD - PRODUÇÃO DIÁRIA/CARD.SQL`
Card numérico: quantidade produzida no dia atual.

#### `CARD - PRODUCAO DIARIA POR COLABORADOR.sql`
Produção do dia agrupada por colaborador (flat query, uso em card ou tabela).

#### `CARD - PRODUÇÃO DIÁRIA.sql`
Variante do card de produção diária (versão anterior ao subdiretório).

#### `ESTOQUE PRODUÇÃO EM PROCESSO/`
- `p1.sql` — Saldo em processo (WIP) por produto
- `p2.sql` — Detalhe de itens em processo por etapa

#### `PLANEJAMENTO DE ESTOQUE DE PRODUCAO.SQL`
Planejamento de necessidade de estoque por produto acabado, considerando ordens abertas e meta de produção.

#### `[SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR/`
- `P1.SQL`, `P2.SQL`, `P3.SQL` — Painel detalhado de produção diária por colaborador: quantidade apontada, eficiência e horas registradas

#### `Produção diária por colaborador.sql`
Versão flat (sem subpastas) da query de produção por colaborador.

---

### 2. Vendas / Faturamento

#### `DASHBOARD DE VENDAS/DASHBOARD DE VENDAS.sql`
Painel completo de vendas: parceiro, UF, vendedor, produto, data de negociação, quantidade, valor unitário, valor com desconto e tipo de operação. Base para análises de carteira e performance comercial.

#### `FATURAMENTO POR PERIODO/P1.SQL`
Faturamento consolidado por período com filtros de data parametrizáveis.

#### `FATURAMENTO POR PERÍODO - GESTÃO.sql`
Versão de faturamento para visão gerencial (consolidado por grupo/família de produtos).

#### `FATURAMENTO POR PERÍODO - Devoluções.sql`
Faturamento separando devoluções para análise de resultado líquido.

#### `Faturamento por período Gestão/`
- `p1.sql` — Faturamento gerencial parte 1
- `p2.sql` — Faturamento gerencial parte 2 (complemento por linha de produto)

#### `RESUMO DE RESULTADO DE VENDAS.sql`
Resumo: receita bruta, devoluções, descontos e resultado líquido de vendas por período.

#### `PAINEL COMERCIAL.SQL`
Painel comercial completo: pedidos abertos, faturados e em atraso por vendedor e região.

#### `CARD - VENDAS MENSAL/CARD.SQL`
Card numérico: total de vendas no mês corrente.

#### `resultado de faturamento.sql`
Query de resultado de faturamento (versão simplificada/legacy).

---

### 3. Análise de Produtos / Clientes

#### `Curva ABC.sql`
Curva ABC de produtos por faturamento: classifica produtos em A, B, C conforme participação no volume de vendas no período.

#### `EVOLUÇÃO DE VENDAS POR PRODUTO.SQL`
Evolução mensal de vendas de um produto específico (quantidade e valor).

#### `Evolução de Vendas de Produto.sql`
Variante da evolução de vendas (filtro diferente ou formato alternativo).

#### `Evolução Mensal de Vendas por Parceiro.sql`
Evolução mensal de compras do cliente por período — útil para análise de relacionamento comercial.

#### `EVOLUÇÃO MENSAL DE COMPRAS POR PARCEIRO.sql`
Evolução mensal do volume de compras por fornecedor — análise de supply chain.

#### `EVOLUÇÃO DE BONIFICACAO POR CLIENTE.SQL`
Evolução de bonificações concedidas por cliente ao longo do tempo.

#### `EVOLUÇÃO DE BRINDES POR CLIENTE.SQL`
Evolução de brindes entregues por cliente por período.

---

### 4. Estoque

#### `ESTIMATIVA DE ESTOQUE/`
- `P1.SQL` — Saldo atual de estoque por produto
- `P2.SQL` — Projeção de consumo por demanda histórica
- `P3.SQL` — Estimativa de ruptura por produto

#### `ESTIMATIVA DE ESTOQUE GERENCIAL/`
- `P1.SQL` — Visão gerencial consolidada de estoque
- `P2.SQL` — Detalhamento por empresa e local
- `P3.SQL` — Alertas de estoque crítico

#### `ESTOQUE SEM MOVIMENTO.SQL`
Lista produtos com estoque positivo sem movimentação de saída no período parametrizado.

#### `RELATÓRIO CÓPIA DE ESTOQUE.SQL`
Snapshot de estoque em um determinado momento (cópia analítica).

#### `CONFERÊNCIA COMPOSIÇÃO PA-PI/`
- `p1.sql` — Composição de produto acabado (PA) versus produto intermediário (PI)
- `p2.sql` — Divergências entre composição teórica e real

---

### 5. Compras

#### `RELAÇÃO DE COMPRAS-PEDIDOS E PREVISÃO DE ENTREGA.SQL`
Pedidos de compra em aberto com previsão de entrega por fornecedor.

#### `RELAÇÃO DE COMPRAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`
Compras agrupadas por produto, com data de previsão de recebimento.

#### `ADIANTAMENTO FORNECEDOR/`
- `p1.sql` — Adiantamentos a fornecedores em aberto
- `p2.sql` — Histórico de adiantamentos liquidados

#### `RELAÇÃO DE ITENS ENTRADAS.sql`
Relação de itens recebidos (entradas) por período, fornecedor e produto.

---

### 6. Vendas — Pedidos e Previsão

#### `RELAÇÃO DE VENDAS-PEDIDOS E PREVISÃO DE ENTREGA.sql`
Pedidos de venda em aberto com previsão de entrega por cliente e vendedor.

#### `RELAÇÃO DE VENDAS-PRODUTO POR PREVISÃO DE ENTREGA.sql`
Pedidos agrupados por produto com datas de previsão.

#### `RELAÇÃO DE ITENS SAIDAS.SQL`
Relação de itens expedidos (saídas) por período, cliente e produto.

---

### 7. Assistência Técnica

#### `Informativo de Gestão da Assistência/`
- `Componentes do período.sql` — Peças/componentes utilizados na assistência no período
- `Gráfico.sql` — Gráfico de evolução de atendimentos
- `Operadores.sql` — Atendimentos por operador/técnico
- `Produtos do período.sql` — Produtos mais atendidos no período

#### `INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA/`
- `painelcomponentes.sql` — Painel de componentes usados em assistência externa
- `painelprodutos.sql` — Painel de produtos atendidos externamente

#### `INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)/`
- `BARRAS.sql` — Gráfico de barras: distribuição de atendimentos
- `Bolota.sql` — Gráfico bolha/scatter: volume vs. custo
- `Colunas.sql` — Gráfico de colunas: atendimentos por mês
- `GEOGUESSER.sql` — Distribuição geográfica de assistências (por UF/cidade)
- `PARCEIRO - BOLOTA.sql` — Gráfico bolha por parceiro
- `Período.sql` — Filtro/componente de seleção de período
- `ProdAcabado/barras.sql` — Barras de produto acabado na assistência
- `ProdAcabado/donut.sql` — Gráfico donut de produto acabado

---

### 8. Auditoria / Rastreabilidade

#### `AUDITORIA DE MOVIMENTACOES/`
- `P1.SQL` — Log geral de movimentações (cabeçalho)
- `P2.SQL` — Detalhamento por item movimentado
- `P3.SQL` — Divergências identificadas
- `P4.SQL` — Resumo de auditoria

#### `AUDITOR E-COMMERCE GODEEP.sql`
Auditoria de produtos no e-commerce GoDeep: rastreia alterações de código de produto via `TECLOG`.  
**Parâmetros:** `:P_CODPROD` (produto), `:P_PERIODO.INI` e `:P_PERIODO.FIN` (período).

#### `TRANSFERENCIA ENTRE EMPRESAS.SQL`
Auditoria de transferências realizadas entre empresas.

---

### 9. Financeiro / Fiscal

#### `Valida Natureza.sql`
Verifica naturezas financeiras inconsistentes ou sem parametrização.

#### `TRG_NUMCHEQUE_TGFECQ_SPARK.SQL`
*(Arquivo mal categorizado — contém trigger, não query BI)*. Trigger de validação de número de cheque em `TGFECQ`.

#### `TEST_JSON_NUFIN_TGFECQ.SQL`
Query de teste/diagnóstico para validar estrutura JSON em `TGFECQ`.

---

### 10. Auxiliares / Cálculo

#### `Cálculo de Proporcionalidade Matriz.sql`
Query de apoio ao cálculo de proporcionalidade de componentes em matrizes de produção.

---

## Observações Gerais

- Componentes com parâmetros dinâmicos usam a sintaxe `:NOME_PARAMETRO` do Sankhya BI.
- Componentes multi-parte (`P1`, `P2`, `P3`) são configurados como abas ou seções do mesmo dashboard no Sankhya — a ordem numérica define a sequência de exibição.
- Arquivos HTML (`TITULOP*.HTML`) são títulos customizados injetados no componente BI via Sankhya.
- O arquivo `TRG_NUMCHEQUE_TGFECQ_SPARK.SQL` está erroneamente nesta pasta — pertence a `triggers/` ou `procedures/`.
