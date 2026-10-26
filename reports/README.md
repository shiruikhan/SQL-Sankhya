# Catálogo de Relatórios Jasper

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de relatórios:** 39 pastas  
**Tecnologia:** JasperReports — arquivos `.jrxml` (XML de definição de relatório)  

---

## Visão Geral

Os relatórios são templates JasperReports configurados e compilados pelo Sankhya. Cada pasta numerada corresponde a um relatório ou grupo de relatórios de um domínio funcional. O Sankhya carrega os arquivos `.jrxml` via upload em *Administração → Relatórios*, onde são associados a telas e tipos de operação.

---

## Catálogo

| Nº | Pasta | Arquivo(s) | Domínio | Descrição |
|---|---|---|---|---|
| 1 | `1 - Pedido de Compra` | `pedidodecompra2.jrxml`, `romaneio.jrxml` | Compras | Pedido de compra impresso e romaneio de recebimento |
| 2 | `2 - Assistência` | `OS_Assistencia.jrxml`, `EtiquetaOSSerie.jrxml`, `EtiquetaSerie.jrxml`, `etiquetaprodutonovo.jrxml`, `etiquetaprodutonovo` | Assistência Técnica | OS de assistência (`AD_TGFASS`, faixa `NUMOSINI`–`NUMOSFIN`) e etiquetas de série/SKU para produto em assistência. `etiquetaprodutonovo` (sem extensão) é outra versão da etiqueta, baseada no apontamento de produção (`PK_IDIPROC`, `TPRIPROC`/`AD_TPRSERPA`) |
| 3 | `3 - Comercial` | `EspelhoFINAN.jrxml`, `RelatorioPedidoDeVenda.jrxml`, `conferencia.jrxml`, `conferencia_2.jrxml` | Vendas | Espelho de duplicatas (`TGFFIN`), pedido de venda e conferência/embalagens do pedido (`AD_EMBPED`) — layouts também presentes nas pastas 8, 18, 21 e 22 |
| 4 | `4 - Administrativo` | `Nota sem confirmar.jrxml`, `Nota sem confirmar REMESSAS.jrxml` | Administrativo | Notas/pedidos/requisições sem confirmação e notas de remessa sem retorno (TOPs 1108/1202), com dias sem confirmação |
| 5 | `5 - Etiquetas de Produto` | `etiquetanova0-50.jrxml` … `etiquetanova950-1000.jrxml` (21 arquivos, inclui `etiquetanova1-50.jrxml`), `EtiquetaSerie250-300.jrxml` … `EtiquetaSerie950-1000.jrxml` (15 arquivos), `EtiquetaSequencialPA.jrxml`, `Etiqueta APOQLD.jrxml`, `Etiqueta APOQLD AVULSA.jrxml` | Estoque | Etiquetas de produto/série divididas em faixas de 50 por arquivo, mais cópias das etiquetas sequencial de PA (nº 17) e de qualidade (nº 30) |
| 6 | `6 - Lista de Materiais Almoxarifado` | `Separacao_Lista_Materiais.jrxml` | Estoque | Lista de materiais para o almoxarifado (separação por setor/plano) |
| 7 | `7 - Romaneio de Entregas` | `RomaneioEntrega.jrxml` | Logística | Romaneio de entregas para expedição |
| 8 | `8 - Expedição` | `expedicao novo.jrxml`, `expedicao_ite.jrxml`, `conferencia.jrxml`, `conferencia_2.jrxml` | Logística | Relatório de controle de expedição (com sub-relatório de itens) e conferência |
| 9 | `9 - NFe Simplificada` | `danfe_simplificado.jrxml` | Fiscal | DANFE simplificado (formato etiqueta) |
| 10 | `10 - Apontamento de Fabricação` | `ped_req.jrxml`, `ped_req V.2.jrxml` | Produção | Folha de apontamento de fabricação por ordem (duas versões) |
| 11 | `11 - Requisições` | `ped_req.jrxml` | Estoque | Requisição de materiais ao almoxarifado |
| 12 | `12 - Etiqueta de Volumes` | `ETIQUETA_EMB.jrxml`, `ETIQUETA_EMB_SUB.jrxml`, `ETIQUETA_EMB_SUB.old.jrxml` | Logística | Etiqueta de volumes de caixas na expedição (principal + sub-relatório; `.old` = versão anterior do sub-relatório) |
| 13 | `13 - Nota` | `danfe_retrato_itens_4.0.jrxml` | Fiscal | Nota fiscal impressa (DANFE retrato — bloco de itens) |
| 14 | `14 - Etiqueta Compras Avulsa` | `EtiquetaComprasAvulsa.jrxml`, `EtiquetaComprasAvulsa.bkp.jrxml` | Compras | Etiqueta avulsa para itens recebidos de compra (`.bkp` = cópia de segurança) |
| 15 | `15 - INVOICE e PACKING LIST` | `INVOICE.jrxml`, `expedicao.jrxml`, `expedicao_EMBALAGENS.jrxml` | Exportação | Commercial Invoice e Packing List (com sub-relatório de embalagens) para exportação |
| 16 | `16 - Ordem de Produção` | `OrdemProducao.jrxml`, `OrdemProducao_Itens.jrxml`, `BKP/OrdemProducao.jrxml`, `BKP/OrdemProducao_Itens.jrxml` | Produção | Ordem de produção impressa para o chão de fábrica (principal + itens; `BKP/` = versão anterior) |
| 17 | `17 - Etiqueta Sequencial` | `EtiquetaSequencialPA.jrxml` | Logística | Etiqueta com numeração sequencial para rastreabilidade |
| 18 | `18 - Conferência da Expedição` | `conferencia.jrxml`, `conferencia_2.jrxml` | Logística | Lista de conferência na saída da expedição |
| 19 | `19 - Lista Almoxarifado` | `Separacao_Lista_Materiais.jrxml` | Estoque | Lista de separação de materiais do almoxarifado |
| 20 | `20 - MODELO NOTA-PEDIDO - DESCRIÇÃO DA TOP` | `PEDIDO.jrxml`, `ITENS.jrxml`, `FINAN.jrxml`, `RODAPE.jrxml` | Fiscal | Modelo de nota/pedido com descrição do tipo de operação (principal + sub-relatórios de itens, financeiro e rodapé) |
| 21 | `21 - Pedido de Venda - Spark` | `RelatorioPedidoDeVenda.jrxml` | Vendas | Pedido de venda no layout padrão Spark |
| 22 | `22 - Espelho de Nota` | `Espelho.jrxml`, `EspelhoFINAN.jrxml`, `BKP/Espelho.jrxml`, `BKP/EspelhoFINAN.jrxml`, `script.sql` | Fiscal | Espelho completo da nota fiscal (principal + duplicatas; `BKP/` = versão anterior; `script.sql` = query de apoio) |
| 23 | `23 - Inadimplência por Vendedor` | `Inadimplencia_Geral_vend.jrxml`, `script.sql` | Financeiro | Relatório de títulos vencidos por vendedor (`script.sql` = query de apoio) |
| 24 | `24 - Ordem de Compra` | `pedidodecompra2.jrxml` | Compras | Ordem de compra para envio ao fornecedor |
| 25 | `25 - O.S. Interna` | `OS_Interna.jrxml`, `OS_Interna.jasper` | Assistência | Ordem de serviço interna (PCM / TI) impressa (`.jasper` = versão compilada) |
| 26 | `26 - Etiqueta de Compra - MKTP` | `ETQ_Compra_MKTP.jrxml` | Compras | Etiqueta de itens recebidos de compra para marketplace |
| 27 | `27 - Ficha de Anomalia de Processo` | `FichaAnomalia.jrxml` | Produção / Qualidade | Ficha de registro de anomalia de processo produtivo |
| 28 | `28 - Etiqueta Compra Avulsa` | `EtiquetaComprasAvulsa.jrxml` | Compras | Etiqueta avulsa de compra (revisão da nº 14) |
| 29 | `29 - Tabela Spark Produtos` | `TabSparkProdutos.jrxml` | Vendas / Catálogo | Tabela de produtos Spark para divulgação |
| 30 | `30 - Etiqueta de Qualidade` | `Etiqueta APOQLD.jrxml`, `Etiqueta APOQLD AVULSA.jrxml` | Produção / Qualidade | Etiqueta de aprovação de qualidade (por apontamento e avulsa) |
| 31 | `31 - Etiqueta de Série Avulsa Manual` | `ETIQUETAS DANIELA.jrxml` | Logística | Etiqueta de série avulsa gerada manualmente |
| 32 | `32 - ETIQUETA AVULSA MANUAL` | `ETIQUETA AVULSA ALTERADA.jrxml`, `ETIQUETA AVULSA ORIGINAL.jrxml` | Logística | Etiqueta avulsa manual (versão alterada vigente + original) |
| 33 | `33 - ORÇAMENTO DE VENDA LUCAS` | `ORCAMENTO V04.jrxml` | Vendas | Orçamento de venda em layout customizado (paisagem) |
| 34 | `34 - Fechamento Assistência` | `FechamentoAssistencia.jrxml` | Assistência / Financeiro | Fechamento da assistência técnica externa: lista as O.S. de `AD_SPKCAE` concluídas por parceiro e/ou período de conclusão (parâmetros `P_CODPARC`, `P_DTINI`, `P_DTFIN`), uma seção por parceiro com total |
| 35 | `35 - Fechamento Assistência Interna` | `FechamentoAssistenciaInterna.jrxml` | Assistência Técnica | Pré-fechamento impresso ANTES da emissão da nota de serviço: resume as O.S. concluídas de `AD_TGFASS` por assistência responsável (`CODPARCASS`), com uma linha por STATUS + DEFEITO (qtd. de O.S. e soma de `VLRCONSERTO`), total por assistência e total geral. Não depende de `AD_TGFASS.NUNOTA` e não lista O.S./SN individuais. Parâmetros opcionais `P_CODPARCASS`, `P_DTINI`/`P_DTFIN` (sobre `DTCONCLUSAO`) e `P_STATUS`; STATUS/DEFEITO traduzidos via `TDDCAM`/`TDDOPC`; cabeçalho da empresa 1 |
| 36 | `36 - Fechamento Assistência Interna Técnico` | `FechAssistIntTecnico.jrxml` | Assistência Técnica / Folha | Relação de pagamentos ao técnico: tabela única com todos os técnicos das O.S. de `AD_TGFASS` com o `MESFOLHA` informado em `P_MESFOLHA` (ou o do lançamento selecionado, `PK_NUMOS`) e, opcionalmente, `P_STATUS`, por técnico (`TECNICO` → `AD_CADFUNC.NOME`), `STATUS` (texto da opção) e `MESFOLHA`, com nº de O.S. e soma de `VLRSERVTECNICO`; total geral; cabeçalho da empresa 1 |
| 37 | `37 - Separação Transferência Assistência` | `SepTransfAssistExterna.jrxml` | Assistência Externa / Estoque | Lista de separação física das transferências (TOP 708) geradas por `STP_MOVMATASSIST_SPARK`: itens lidos da própria nota (`CODPROD`, `DESCRPROD`, `CODVOL`, `QTD`), unificados por parceiro (uma seção/página por parceiro, quantidades somadas), com local de origem e destino. Parâmetros opcionais `P_CODPARC`, `P_DTINI`/`P_DTFIN` (sobre a data da nota; padrão hoje); não usa `PK_`; cabeçalho da empresa 1 |
| 38 | `38 - Etiquetas Transferência Assistência` | `EtqTransfAssistExterna.jrxml` | Assistência Externa / Estoque | Etiquetas (2 colunas, 142 x 36 pt) dos produtos das transferências TOP 708 da assistência externa (`AD_SPKCAE.NUNOTATRF`): uma etiqueta por parceiro + produto + unidade com código, descrição e quantidade somada. Mesma busca e filtros do nº 37 (`P_CODPARC`, `P_DTINI`/`P_DTFIN` sobre `DTCONCLUSAO`); não usa `PK_` |
| 39 | `39 - O.S. Assistência` | `OS_Assistencia.jrxml`, `OS_Assistencia_Componentes.jrxml` | Assistência Técnica | Nova versão da O.S. de assistência (nº 2): mesma faixa `NUMOSINI`–`NUMOSFIN` sobre `AD_TGFASS`, com nomes dos funcionários (técnico, solda, teste, inserção via `AD_CADFUNC`), DEFEITO traduzido via `TDDCAM`/`TDDOPC` e sub-relatório de componentes (`AD_TGFIASS`: produto, quantidade e unidade por `NUMOS`) |

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
- Subpastas `BKP/` e arquivos `.bkp.jrxml` / `.old.jrxml` são cópias de versões anteriores; `.jasper` é o binário compilado; `script.sql` é a query de apoio do relatório — nenhum deles é o arquivo de deploy.
- Relatórios com múltiplos `.jrxml` em uma mesma pasta geralmente representam versões (`_2`, `novo`, etc.) — identificar a versão vigente consultando o histórico Git (`git log --follow`).
- Os relatórios `15 - INVOICE e PACKING LIST` são usados em operações de exportação — atentar para campos específicos de fiscal internacional.
- Parâmetros dos relatórios (filtros de data, parceiro, etc.) são declarados no `.jrxml` (`<parameter>`) e configurados/expostos no cadastro do relatório no Sankhya.
