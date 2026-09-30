# Catálogo de Relatórios Jasper

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de relatórios:** 37 pastas  
**Tecnologia:** JasperReports — arquivos `.jrxml` (XML de definição de relatório)  

---

## Visão Geral

Os relatórios são templates JasperReports configurados e compilados pelo Sankhya. Cada pasta numerada corresponde a um relatório ou grupo de relatórios de um domínio funcional. O Sankhya carrega os arquivos `.jrxml` via upload em *Administração → Relatórios*, onde são associados a telas e tipos de operação.

---

## Catálogo

| Nº | Pasta | Arquivo(s) | Domínio | Descrição |
|---|---|---|---|---|
| 1 | `1 - Pedido de Compra` | `pedidodecompra2.jrxml`, `romaneio.jrxml` | Compras | Pedido de compra impresso e romaneio de recebimento |
| 2 | `2 - Assistência` | `EtiquetaOSSerie.jrxml`, `EtiquetaSerie.jrxml`, `OS_Assistencia.jrxml` | Assistência Técnica | OS de assistência e etiquetas de série para produto em assistência |
| 3 | `3 - Comercial` | `EspelhoFINAN.jrxml`, `RelatorioPedidoDeVenda.jrxml` | Vendas | Espelho de lançamentos financeiros e pedido de venda |
| 4 | `4 - Administrativo` | `conferencia.jrxml`, `conferencia_2.jrxml` | Administrativo | Conferência de documentos (duas versões) |
| 5 | `5 - Etiquetas de Produto` | `etiquetaprodutonovo`, `etiquetaprodutonovo.jrxml` | Estoque | Etiqueta padrão de produto (versão vigente e arquivo base) |
| 6 | `6 - Lista de Materiais Almoxarifado` | *(ver pasta)* | Estoque | Lista de materiais para o almoxarifado |
| 7 | `7 - Romaneio de Entregas` | *(ver pasta)* | Logística | Romaneio de entregas para expedição |
| 8 | `8 - Expedição` | *(ver pasta)* | Logística | Relatório de controle de expedição |
| 9 | `9 - NFe Simplificada` | *(ver pasta)* | Fiscal | DANFE simplificado para operações internas |
| 10 | `10 - Apontamento de Fabricação` | *(ver pasta)* | Produção | Folha de apontamento de fabricação por ordem |
| 11 | `11 - Requisições` | *(ver pasta)* | Estoque | Requisição de materiais ao almoxarifado |
| 12 | `12 - Etiqueta de Volumes` | *(ver pasta)* | Logística | Etiqueta de volumes de caixas na expedição |
| 13 | `13 - Nota` | *(ver pasta)* | Fiscal | Nota fiscal impressa (formato padrão) |
| 14 | `14 - Etiqueta Compras Avulsa` | *(ver pasta)* | Compras | Etiqueta avulsa para itens recebidos de compra |
| 15 | `15 - INVOICE e PACKING LIST` | *(ver pasta)* | Exportação | Invoice e Packing List para exportação |
| 16 | `16 - Ordem de Produção` | *(ver pasta)* | Produção | Ordem de produção impressa para o chão de fábrica |
| 17 | `17 - Etiqueta Sequencial` | *(ver pasta)* | Logística | Etiqueta com numeração sequencial para rastreabilidade |
| 18 | `18 - Conferência da Expedição` | *(ver pasta)* | Logística | Lista de conferência na saída da expedição |
| 19 | `19 - Lista Almoxarifado` | *(ver pasta)* | Estoque | Lista de itens disponíveis no almoxarifado |
| 20 | `20 - MODELO NOTA-PEDIDO - DESCRIÇÃO DA TOP` | *(ver pasta)* | Fiscal | Modelo de nota/pedido com descrição do tipo de operação |
| 21 | `21 - Pedido de Venda - Spark` | *(ver pasta)* | Vendas | Pedido de venda no layout padrão Spark |
| 22 | `22 - Espelho de Nota` | *(ver pasta)* | Fiscal | Espelho completo da nota fiscal |
| 23 | `23 - Inadimplência por Vendedor` | *(ver pasta)* | Financeiro | Relatório de títulos vencidos por vendedor |
| 24 | `24 - Ordem de Compra` | *(ver pasta)* | Compras | Ordem de compra para envio ao fornecedor |
| 25 | `25 - O.S. Interna` | *(ver pasta)* | Assistência | Ordem de serviço interna impressa |
| 26 | `26 - Etiqueta de Compra - MKTP` | `ETQ_Compra_MKTP.jrxml` | Compras | Etiqueta de itens recebidos de compra para marketplace |
| 27 | `27 - Ficha de Anomalia de Processo` | `FichaAnomalia.jrxml` | Produção / Qualidade | Ficha de registro de anomalia de processo produtivo |
| 28 | `28 - Etiqueta Compra Avulsa` | `EtiquetaComprasAvulsa.jrxml` | Compras | Etiqueta avulsa de compra (revisão da nº 14) |
| 29 | `29 - Tabela Spark Produtos` | `TabSparkProdutos.jrxml` | Vendas / Catálogo | Tabela de produtos Spark para divulgação |
| 30 | `30 - Etiqueta de Qualidade` | `Etiqueta APOQLD.jrxml`, `Etiqueta APOQLD AVULSA.jrxml` | Produção / Qualidade | Etiqueta de aprovação de qualidade (por apontamento e avulsa) |
| 31 | `31 - Etiqueta de Série Avulsa Manual` | `ETIQUETAS DANIELA.jrxml` | Logística | Etiqueta de série avulsa gerada manualmente |
| 32 | `32 - ETIQUETA AVULSA MANUAL` | `ETIQUETA AVULSA ALTERADA.jrxml`, `ETIQUETA AVULSA ORIGINAL.jrxml` | Logística | Etiqueta avulsa manual (versão alterada vigente + original) |
| 33 | `33 - ORÇAMENTO DE VENDA LUCAS` | `ORCAMENTO V04.jrxml` | Vendas | Orçamento de venda em layout customizado (paisagem) |
| 34 | `34 - Fechamento Assistência` | `FechamentoAssistencia.jrxml` | Assistência / Financeiro | Lista as O.S. de um título gerado por `STP_INCFINASSIST_SPARK` (parâmetro `PK_NUFIN`), com dados do parceiro e total |
| 35 | `35 - Fechamento Assistência Interna` | `FechamentoAssistenciaInterna.jrxml` | Assistência Técnica | Pré-fechamento impresso ANTES da emissão da nota de serviço: resume as O.S. concluídas de `AD_TGFASS` por assistência responsável (`CODPARCASS`), com uma linha por STATUS + DEFEITO (qtd. de O.S. e soma de `VLRCONSERTO`), total por assistência e total geral. Não depende de `AD_TGFASS.NUNOTA` e não lista O.S./SN individuais. Parâmetros opcionais `P_CODPARCASS`, `P_DTINI`/`P_DTFIN` (sobre `DTCONCLUSAO`) e `P_STATUS`; STATUS/DEFEITO traduzidos via `TDDCAM`/`TDDOPC`; cabeçalho da empresa 1 |
| 36 | `36 - Fechamento Assistência Interna Técnico` | `FechAssistIntTecnico.jrxml` | Assistência Técnica / Folha | Relação de pagamentos ao técnico: tabela única com todos os técnicos das O.S. de `AD_TGFASS` com o `MESFOLHA` informado em `P_MESFOLHA` (ou o do lançamento selecionado, `PK_NUMOS`) e, opcionalmente, `P_STATUS`, por técnico (`TECNICO` → `AD_CADFUNC.NOME`), `STATUS` (texto da opção) e `MESFOLHA`, com nº de O.S. e soma de `VLRSERVTECNICO`; total geral; cabeçalho da empresa 1 |
| 37 | `37 - Separação Transferência Assistência` | `SepTransfAssistExterna.jrxml` | Assistência Externa / Estoque | Lista de separação física das transferências (TOP 708) geradas por `STP_MOVMATASSIST_SPARK`: itens lidos da própria nota (`CODPROD`, `DESCRPROD`, `CODVOL`, `QTD`), unificados por parceiro (uma seção/página por parceiro, quantidades somadas), com local de origem e destino. Parâmetros opcionais `P_CODPARC`, `P_DTINI`/`P_DTFIN` (sobre a data da nota; padrão hoje); não usa `PK_`; cabeçalho da empresa 1 |

---

## Como Fazer Deploy

1. Acessar *Administração → Relatórios* no Sankhya
2. Localizar o relatório pelo nome ou criar novo
3. Fazer upload do arquivo `.jrxml` correspondente
4. Associar ao tipo de operação (TOP) e à tela desejada
5. Definir permissões de acesso por grupo de usuário

---

## Observações

- Arquivos sem extensão (ex: `etiquetaprodutonovo`) são versões base ou intermediárias — usar sempre o `.jrxml` para deploy.
- Relatórios com múltiplos `.jrxml` em uma mesma pasta geralmente representam versões (`_2`, `novo`, etc.) — identificar a versão vigente consultando o histórico Git (`git log --follow`).
- Os relatórios `15 - INVOICE e PACKING LIST` são usados em operações de exportação — atentar para campos específicos de fiscal internacional.
- Parâmetros dinâmicos dos relatórios (filtros de data, empresa, etc.) são definidos no Sankhya no cadastro do relatório, não no `.jrxml`.
