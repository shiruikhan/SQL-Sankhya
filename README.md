# SQL Sankhya — Especificação de Sistema

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Versão:** 2.0  
**Data:** Abril/2026  
**Plataforma-alvo:** Sankhya ERP (Oracle Database)

---

## 1. Objetivo

Este repositório centraliza todas as customizações, extensões e automações desenvolvidas sobre o ERP Sankhya utilizadas pela Spark Eletrônica. Cobre lógica de negócio implementada via Oracle PL/SQL, eventos Java, relatórios Jasper e queries analíticas de BI.

O objetivo é manter um histórico versionado, auditável e documentado de cada objeto criado ou modificado no banco de dados e na camada de aplicação do ERP, permitindo rastreabilidade, reaproveitamento e suporte às operações da empresa.

---

## 2. Escopo

**Incluído:**
- Triggers de banco de dados (validação, automação, notificação)
- Stored procedures e procedures de visão externa (botões de ação, eventos de tela)
- Funções escalares auxiliares
- Views de consulta
- Tabelas customizadas (prefixo `AD_`)
- Componentes BI (queries analíticas para dashboards gerenciais)
- Relatórios Jasper (.jrxml)
- Classes Java (listeners e botões de ação de eventos)
- Fórmulas e regras do ERP
- Procedures de integração contábil (Audicon)
- Dependências JAR do Sankhya SDK

**Fora do escopo:**
- Configurações do servidor de aplicação
- Parametrizações nativas do ERP (sem código customizado)
- Dados de produção ou registros de clientes
- Credenciais e strings de conexão (mantidas via `.env`, ignorado pelo `.gitignore`)

---

## 3. Estrutura do Repositório

```
SQL Sankhya/
├── triggers/               Triggers de banco de dados (validação, automação, notificação)
├── procedures/             Stored procedures e procedures de visão externa
├── functions/              Funções escalares auxiliares
├── view/                   Views de consulta reutilizáveis
├── tables/                 Scripts DDL de tabelas customizadas (prefixo AD_)
├── componentes BI/         Queries analíticas para dashboards e relatórios gerenciais
├── reports/                Templates de relatórios impressos Jasper (.jrxml)
├── java/                   Classes Java (botões de ação, listeners, utilitários)
├── formulas/               Regras e fórmulas configuradas no ERP
├── audicon/                Procedures de integração contábil (Audicon)
├── trigger_nativa/         Trigger nativa do Sankhya (customizada para a empresa)
├── libs_sankhya/           Dependências JAR do Sankhya SDK
└── inativos/               Objetos descontinuados (preservados para referência)
```

---

## 4. Tecnologias

| Tecnologia | Uso |
|---|---|
| Oracle PL/SQL | Triggers, procedures, functions, views, DDL |
| SQL Analítico | CTEs, window functions, queries de BI |
| Java (SE 8) | Listeners de eventos, botões de ação, utilitários |
| JasperReports (.jrxml) | Templates de relatórios impressos |
| Sankhya ERP SDK | APIs de integração com o ERP (`SankhyaW`) |

---

## 5. Domínios Cobertos

| Domínio | Objetos principais |
|---|---|
| **Planejamento de Produção (PCP/MRP)** | `STP_PCP_SPARK`, `STP_PCPMETA_SPARK`, `TRG_INC_UPD_TPRMPS_SPARK`, `OBTEM_TOTAIS_MRP` |
| **Compras e Supply Chain** | `STP_APROVA_SOLIC_COMPRA`, `TRG_NOTIFICA_SOLIC_COMPRA`, `TRG_STATUS_PADRAO_SC`, `TRG_VALIDA_PRAZO_SC` |
| **Vendas e Faturamento** | `TRG_CMP_TGFCAB_NFE_SPARK`, `STP_VALIDARCONF_SPARK`, `STP_VALIDARSERIE_SPARK`, `STP_NFREFDEV_SPARK` |
| **Estoque** | `VGFEST`, `STP_GARANTEESTOQUE_SPARK`, `STP_TRANSFEMP_SPARK`, `OBTEMCUSTO_SPARK` |
| **Financeiro** | `TRG_REFORCA_NAT_FIN`, `STP_INCLUIRLANCTO_SPARK`, `SPK_TGFFIN_LOG`, `STP_EXCLUIRFINCOM_SPARK` |
| **Logística e Expedição** | `STP_GERARVOLUMES_SPARK`, `STP_INCEMB_SPARK`, `TRG_COTAFRETE_SPARK`, `CotaFrete.java` |
| **Assistência Técnica** | `STP_INCMOVASSIST_SPARK`, `STP_INCNCONFORM_SPARK`, `TRG_UPD_OSINTERNA`, `STP_ENVIAEMAILOS_SPARK` |
| **Produção / Apontamento** | `TRG_VAL_SETOR_CODFUNC_TPRAPA`, `TRG_VAL_AD_CODFUNC_TPRAPA`, `AD_MAP_SETOR_FUNC` |
| **Integração E-commerce / Site** | `STP_INTEGRAPEDIDO_SITESPARK`, `STP_INTEGRAPEDIDO_AGENDADA`, `TRG_INC_UPD_INTEGRA` |
| **CT-e / NF-e** | `EVP_CLASSIFICACTE_SPARK`, `TRG_CMP_TGFCAB_NFE_SPARK`, `VW_CTE_AUTORIZADOS`, `VGFNFE` |
| **Integração Contábil** | `STP_CRIA_CTACTBCLI_AUDICON`, `STP_CRIA_CTACTBFOR_AUDICON` |
| **BI / Gerencial** | 70+ queries analíticas em `componentes BI/` |

---

## 6. Convenções de Nomenclatura

| Prefixo | Tipo de objeto | Exemplo |
|---|---|---|
| `STP_` | Stored Procedure (botão de ação ou automação) | `STP_PCP_SPARK` |
| `EVP_` | Procedure de visão externa (evento de tela) | `EVP_CLASSIFICACTE_SPARK` |
| `TRG_` | Trigger de banco de dados | `TRG_AVISOCONF_SPARK` |
| `SPK_` | Trigger legada (nomenclatura anterior) | `SPK_TGFASS_INC` |
| `FC_` | Function escalar | `FC_TEMMETA_SPARK` |
| `V` / `VW_` | View de consulta | `VGFEST`, `VW_CTE_AUTORIZADOS` |
| `AD_` | Tabela customizada | `AD_LOG_ERROS`, `AD_MAP_SETOR_FUNC` |
| `_SPARK` | Sufixo padrão em objetos da Spark Eletrônica | — |

---

## 7. Inventário de Objetos

### 7.1 Triggers (pasta `triggers/`)
> 75 triggers. Ver [`triggers/README.md`](triggers/README.md) para catálogo completo.

Agrupadas por domínio:

| Domínio | Qtd | Exemplos |
|---|---|---|
| Produção / PCP | 9 | `TRG_INC_UPD_TPRMPS_SPARK`, `TRG_INC_UPD_TPRPRC_SPARK`, `TRG_INC_UPD_TPRIPROC_SPARK` |
| Nota Fiscal / Movimentação | 10 | `TRG_CMP_TGFCAB_NFE_SPARK`, `TRG_INC_TGFCAB_DC_SPARK`, `TRG_UPD_TGFCAB_DTFAT_SPARK` |
| Compras / SC | 5 | `TRG_NOTIFICA_SOLIC_COMPRA`, `TRG_STATUS_PADRAO_SC`, `TRG_BLOQUEIA_EDICAO_STATUS_CR` |
| Logística / Frete | 4 | `TRG_COTAFRETE_SPARK`, `TRG_COTAFRETE_EMB_SPARK`, `TRG_AD_EMBPED_SPARK` |
| Assistência / O.S. | 4 | `TRG_UPD_OSINTERNA`, `TRG_UPD_OSINTERNA_DHFIM`, `TRG_INS_OSSTATUS_SPARK` |
| Itens de Nota | 4 | `TRG_INC_UPD_TGFITE_SPARK`, `TRG_UPD_INS_TGFITE_CONSUMOPRD`, `TRG_UPT_TGFITE` |
| Validação / Controle | 8 | `TRG_VAL_SETOR_CODFUNC_TPRAPA`, `TRG_VAL_CSTIPI_SPARK`, `TRG_BLOQUEIA_DELETE_SC` |
| Financeiro | 3 | `TRG_REFORCA_NAT_FIN`, `SPK_TGFFIN_LOG`, `TRG_INCDEVCH_SPARK` |
| Parceiro / Cadastro | 3 | `TRG_UPD_TGFPAR_UF_SPARK`, `TRG_INC_TSICID_SPARK`, `TRG_INC_UPD_CMF_SPARK` |
| Séries / Conferência | 4 | `TRG_INC_TGFSER_SPARK`, `TRG_DLT_TGFSER_SPARK`, `TRG_TGFCON2_SPARK` |
| Notificações / Avisos | 4 | `TRG_AVISOCONF_SPARK`, `TRG_UPD_AVISOSPARK`, `TRG_INC_TGFIXN_EMAIL_SPARK` |
| Demais | 17 | Transferência, impressão de etiquetas, etc. |

---

### 7.2 Procedures (pasta `procedures/`)
> 68 procedures. Ver [`procedures/README.md`](procedures/README.md) para catálogo completo.

| Domínio | Qtd | Exemplos |
|---|---|---|
| PCP / MRP | 4 | `STP_PCP_SPARK`, `STP_PCPMETA_SPARK`, `STP_TGFMET_SPARK`, `STP_ALTERAMETA_SPARK` |
| Compras / SC | 5 | `STP_APROVA_SOLIC_COMPRA`, `STP_NOTIFICASOLICCOMPRA_SPARK`, `STP_ATTCOTACAO_SPARK` |
| Estoque / Transferência | 5 | `STP_TRANSFEMP_SPARK`, `STP_GARANTEESTOQUE_SPARK`, `STP_RESERVA_SPARK`, `STP_IMPORTTAB_SPARK` |
| Logística / Expedição | 6 | `STP_GERARVOLUMES_SPARK`, `STP_INCEMB_SPARK`, `STP_AJUSTARRATFRETE_SAPARK`, `STP_LIMPAREMESSA_SPARK` |
| Vendas / NF | 8 | `STP_VALIDARCONF_SPARK`, `STP_VALIDARSERIE_SPARK`, `STP_NFREFDEV_SPARK`, `STP_TGFCAB_VINCSERIECONF_SPARK` |
| Assistência / O.S. | 4 | `STP_INCMOVASSIST_SPARK`, `STP_INCNCONFORM_SPARK`, `STP_INCMOVOSINT_SPARK`, `STP_OSINTERNA_INC_SPARK` |
| Financeiro | 4 | `STP_INCLUIRLANCTO_SPARK`, `STP_EXCLUIRFINCOM_SPARK`, `STP_ATUALIZARVLRMOEDA_SPARK`, `STP_REGRA_VALID_FINAN_SPARK` |
| E-commerce / Integração | 3 | `STP_INTEGRAPEDIDO_SITESPARK`, `STP_INTEGRAPEDIDO_AGENDADA`, `STP_ATTESTML_SPARK` |
| Cadastros / Produto | 6 | `STP_ALTDADOSPRO_SPARK`, `STP_MUDANCADECODIGO_SPARK`, `STP_ORIGPROD_SPARK`, `STP_CORCSTIPI_SPARK` |
| Produção | 5 | `STP_TPRCOI_SPARK`, `STP_TPRIATV_SPARK`, `STP_TPRIPROC_CANC_SPARK`, `STP_GERALISTAMPS_SPARK` |
| Eventos de tela (EVP) | 2 | `EVP_CLASSIFICACTE_SPARK`, `EVP_TGFIXN_EMAIL_SPARK` |
| Demais / Auxiliares | 16 | BI, impressão, agendamento, etc. |

---

### 7.3 Functions (pasta `functions/`)

| Objeto | Assinatura | Descrição |
|---|---|---|
| `FC_TEMMETA_SPARK` | `(P_CODPROD NUMBER) → VARCHAR2` | Retorna `'S'` se o produto possui meta cadastrada (CODMETA = 3) |
| `OBTEMCUSTO_SPARK` | `(P_CODPROD, P_POREMP, P_CODEMP, P_PORLOCAL, P_CODLOCAL, P_PORCONTROLE, P_CONTROLE, P_DATA, P_TIPO) → FLOAT` | Retorna o custo do produto por tipo (reposição, médio, variável, sem ICMS, etc.) |
| `OBTEM_TOTAIS_MRP` | `(P_NUMPS, P_CODPRODPA, P_CODPRODMP, P_TIPO) → FLOAT` | Retorna totais do MRP: meta PA, produção PA, saldo a produzir, necessidade MP, estoque disponível |

---

### 7.4 Views (pasta `view/`)
> Ver [`view/README.md`](view/README.md).

| Objeto | Colunas principais | Descrição |
|---|---|---|
| `VGFEST` | `SKU, ESTO` | Estoque consolidado por SKU para produtos ativos com movimento recente (empresa 1, local 109) |
| `VW_CTE_AUTORIZADOS` | `NRARQUIVO, NUMNOTA, NUNOTA, CHAVEACESSO, CODTIPOPER_NFE, ...` | CT-e autorizados com referência à NF-e correspondente |
| `VGFNFE` | `NUNOTA, CODVEND, PEDIDOEXTERNO, CHAVENFE, NOTAXML` | NF-e ativas de vendas com XML do cliente (últimos 4 dias) |

---

### 7.5 Tabelas Customizadas (pasta `tables/`)
> Ver [`tables/README.md`](tables/README.md).

| Tabela | PK | Descrição |
|---|---|---|
| `AD_LOG_ERROS` | `IDLOG` | Log centralizado de erros gerados por triggers. Registra código de erro, backtrace e contexto da nota |
| `AD_MAP_SETOR_FUNC` | `DESCDEP, DESCIDEFX` | Mapeamento entre departamento do colaborador e etapa de produção (suporte à validação de apontamentos) |

---

### 7.6 Componentes BI (pasta `componentes BI/`)
> 70+ queries. Ver [`componentes BI/README.md`](componentes BI/README.md).

| Tema | Dashboard / Componente |
|---|---|
| Produção | Fichas de Produção, Cronograma Geral, Painel de Acompanhamento, Produção Diária por Colaborador |
| Vendas | Dashboard de Vendas, Faturamento por Período, Resumo de Resultado, Curva ABC |
| Estoque | Estimativa de Estoque, Estimativa Gerencial, Estoque em Processo, Estoque Sem Movimento |
| Compras | Relação de Compras por Previsão, Adiantamento Fornecedor, Evolução Mensal de Compras |
| Assistência | Informativo de Gestão da Assistência, Gestão Externa, Detalhes |
| Auditoria | Auditoria de Movimentações, Auditoria Produção-Expedição, Auditor E-commerce |

---

### 7.7 Relatórios Jasper (pasta `reports/`)
> 25 relatórios. Ver [`reports/README.md`](reports/README.md).

| Nº | Relatório | Tipo |
|---|---|---|
| 1 | Pedido de Compra | Compras |
| 2 | Assistência / O.S. | Pós-venda |
| 3 | Comercial | Vendas |
| 4 | Administrativo | Administrativo |
| 5 | Etiquetas de Produto | Estoque |
| 6 | Lista de Materiais — Almoxarifado | Estoque |
| 7 | Romaneio de Entregas | Logística |
| 8 | Expedição | Logística |
| 9 | NFe Simplificada | Fiscal |
| 10 | Apontamento de Fabricação | Produção |
| 11 | Requisições | Estoque |
| 12 | Etiqueta de Volumes | Logística |
| 13 | Nota | Fiscal |
| 14 | Etiqueta Compras Avulsa | Compras |
| 15 | Invoice e Packing List | Exportação |
| 16 | Ordem de Produção | Produção |
| 17 | Etiqueta Sequencial | Logística |
| 18 | Conferência da Expedição | Logística |
| 19 | Lista Almoxarifado | Estoque |
| 20 | Modelo Nota-Pedido (Descrição TOP) | Fiscal |
| 21 | Pedido de Venda — Spark | Vendas |
| 22 | Espelho de Nota | Fiscal |
| 23 | Inadimplência por Vendedor | Financeiro |
| 24 | Ordem de Compra | Compras |
| 25 | O.S. Interna | Assistência |

---

### 7.8 Java (pasta `java/`)
> Ver [`java/README.md`](java/README.md).

| Classe | Tipo | Descrição |
|---|---|---|
| `CotaFrete` | Botão de Ação | Consulta API externa para cotação de frete |
| `GerarTransferencia` | Botão de Ação | Gera nota de transferência entre empresas via JAPE |
| `GerarTransferenciaOriginal` | Referência | Versão original do `GerarTransferencia` (backup) |
| `RecalFinanceiroEve` | Evento | Recálculo de lançamentos financeiros |
| `recalcpreco` | Botão de Ação | Recalcula preço de itens em nota |
| `enuns/Tipo` | Enumeração | Enum auxiliar para tipo de transferência |
| `listeners/DelecaoTransfencia` | Listener | Intercepta exclusão de transferência para validação |
| `util/TransferenciaUtils` | Utilitário | Métodos de suporte ao processo de transferência |

---

### 7.9 Fórmulas e Regras (pasta `formulas/`)
> Ver [`formulas/README.md`](formulas/README.md).

| Arquivo | Descrição |
|---|---|
| `comissaopadrao` | Fórmula de cálculo de comissão padrão por vendedor e tipo de venda |
| `regra_processa_xml_cte.sql` | Regra de processamento automático de CT-e via status de importação XML |

---

### 7.10 Integração Contábil (pasta `audicon/`)

| Objeto | Descrição |
|---|---|
| `STP_CRIA_CTACTBCLI_AUDICON` | Cria conta contábil de clientes para integração com o sistema Audicon |
| `STP_CRIA_CTACTBFOR_AUDICON` | Cria conta contábil de fornecedores para integração com o sistema Audicon |

---

### 7.11 Trigger Nativa (pasta `trigger_nativa/`)

| Objeto | Tabela | Descrição |
|---|---|---|
| `TRG_INC_TGFITE` | `TGFITE` | Trigger `BEFORE INSERT` customizada sobre a tabela de itens de nota. Realiza validações de agrupamento mínimo, lote, estoque e CFOP na inclusão de cada item |

---

## 8. Restrições e Requisitos Técnicos

- **Banco de dados:** Oracle Database (dialeto PL/SQL obrigatório)
- **ERP:** Sankhya W, módulos COM, FIN, PCP, WMS, CAC
- **Java SDK:** `SankhyaW-extensions.jar`, `mge-modelcore`, `mgecom-model` (ver `libs_sankhya/`)
- **Reports:** JasperReports — compilados pelo Sankhya no deploy
- **Cada arquivo** contém exatamente um objeto de banco de dados
- **Objetos inativos** ficam em `inativos/` — não são deployados em produção
- **Credenciais e variáveis de ambiente** gerenciadas via `.env` (não versionado)

---

## 9. Glossário

| Termo | Definição |
|---|---|
| `TGFCAB` | Tabela de cabeçalho de notas/movimentos do Sankhya |
| `TGFITE` | Tabela de itens de nota do Sankhya |
| `TGFPAR` | Tabela de parceiros (clientes/fornecedores) |
| `TGFPRO` | Tabela de produtos |
| `TGFEST` | Tabela de estoque |
| `TGFFIN` | Tabela financeira |
| `TPRLPA` | Lote padrão de produção |
| `TPRMPS` | Plano mestre de produção (MPS) |
| `TPRAPA` | Apontamento de produção |
| `TGFSER` | Controle de séries de produtos |
| `TGFCON2` | Conferência de documentos |
| `AD_TGSSCP` | Solicitações de compra (customizada Spark) |
| `MPS` | Master Production Schedule (Plano Mestre de Produção) |
| `MRP` | Material Requirements Planning |
| `PCP` | Planejamento e Controle da Produção |
| `TOP` | Tipo de Operação (parâmetro central do Sankhya) |
| `TIPMOV` | Tipo de movimento: `V` = Venda, `C` = Compra, `P` = Produção, `D` = Devolução |
| `NUSOL` | Número da solicitação de compra |
| `NUNOTA` | Número único de nota/movimento no Sankhya |
| `FILA / TMDFMG` | Fila de processamento assíncrono do Sankhya |
| `CT-e` | Conhecimento de Transporte Eletrônico |
| `NF-e` | Nota Fiscal Eletrônica |
| `CAC` | Central de Atendimento ao Cliente (módulo Sankhya) |
| `O.S.` | Ordem de Serviço |
| `EVP_` | Procedure de visão externa (evento de tela configurado no Sankhya) |
| `STP_` | Procedure executada via botão de ação no Sankhya |
