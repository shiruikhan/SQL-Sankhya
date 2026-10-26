# SQL Sankhya — Especificação de Sistema

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Versão:** 2.4  
**Data:** Outubro/2026  
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
- Packages Oracle (estado de sessão compartilhado entre triggers e procedures)
- Views de consulta
- Tabelas customizadas (prefixo `AD_`)
- Componentes BI (queries analíticas para dashboards gerenciais)
- Relatórios Jasper (.jrxml)
- Classes Java (listeners e botões de ação de eventos)
- Fórmulas e regras do ERP
- Procedures de integração contábil (Audicon)

**Referência (versionado, mas não é código da Spark):**
- Código e DDL nativos do Sankhya (functions, packages, tabelas, triggers) — em `nativo/`, só para consulta e para `git diff` após cada upgrade do ERP. Ver [`nativo/README.md`](nativo/README.md)

**Fora do escopo (não versionado):**
- JARs do Sankhya SDK — mantidos só localmente em `nativo/libs/` (536 MB, fora do git)
- Scripts de apoio operacional (captura de DDL, diagnósticos, backfills pontuais) — mantidos só localmente em `scripts/`
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
├── package/                Packages Oracle (variáveis de sessão compartilhadas entre objetos)
├── view/                   Views de consulta reutilizáveis
├── tables/                 Scripts DDL de tabelas customizadas (prefixo AD_)
├── componentes BI/         Queries analíticas para dashboards e relatórios gerenciais
├── reports/                Templates de relatórios impressos Jasper (.jrxml)
├── java/                   Classes Java (botões de ação, listeners, utilitários)
├── formulas/               Regras e fórmulas configuradas no ERP
├── audicon/                Procedures de integração contábil (Audicon)
├── exemplos/               Amostras reais de dados (cabeçalho+itens+série) para referência
├── inativos/               Objetos descontinuados (preservados para referência)
│
├── nativo/                 Material nativo do Sankhya — referência, NÃO é código da Spark (índice em nativo/README.md)
│   ├── functions/          DDL das functions nativas (348: SNK_*, ACT_*, TIM_* …) + catálogo
│   ├── packages/           Especificações dos packages nativos (20, só spec) + catálogo
│   ├── tables/             DDL das tabelas nativas mais referenciadas (54) + catálogo
│   ├── procedures/         Procedures nativas citadas por triggers/procedures da Spark (21) + catálogo
│   ├── triggers/           Triggers nativas das tabelas que a Spark customiza (149: TGFCAB, TGFITE, TGFFIN …) + catálogo
│   ├── MANIFESTO.csv       Inventário de tudo o que foi capturado (tipo, nome, data, linhas)
│   └── libs/               JARs do Sankhya SDK — LOCAL, fora do git (classpath do Java)
│
│   ── Pasta local (NÃO versionada — ver `.gitignore`) ──
└── scripts/                Scripts de apoio: captura de DDL, diagnóstico, backfills pontuais
```

> **Material local.** `scripts/` e `nativo/libs/` existem apenas na máquina de quem
> mantém o repositório. Não são enviados ao git: os scripts são ferramentas
> descartáveis de uso operacional e os JARs do SDK pertencem ao fabricante e
> pesam ~536 MB. Ao clonar o repositório essas pastas não existem; para
> recriá-las, ver [§10](#10-material-nativo-e-material-local).
>
> **Material nativo versionado.** O restante de `nativo/` (functions, packages,
> tabelas e triggers do fabricante) *é* versionado, de propósito: serve de
> referência e permite `git diff` após cada upgrade do Sankhya. Não é código da
> Spark — nunca editar à mão; recapturar do banco (ver [`nativo/README.md`](nativo/README.md)).

---

## 4. Tecnologias

| Tecnologia | Uso |
|---|---|
| Oracle PL/SQL | Triggers, procedures, functions, packages, views, DDL |
| SQL Analítico | CTEs, window functions, queries de BI |
| Java (SE 8) | Listeners de eventos, botões de ação, utilitários |
| JasperReports (.jrxml) | Templates de relatórios impressos |
| Sankhya ERP SDK | APIs de integração com o ERP (`SankhyaW`) |

---

## 5. Domínios Cobertos

| Domínio | Objetos principais |
|---|---|
| **Planejamento de Produção (PCP/MRP)** | `STP_PCP_SPARK`, `STP_PCPMETA_SPARK`, `TRG_INC_UPD_TPRIPROC_SPARK`, `OBTEM_TOTAIS_MRP` |
| **Compras e Supply Chain** | `STP_APROVA_SOLIC_COMPRA`, `TRG_NOTIFICA_SOLIC_COMPRA`, `TRG_STATUS_PADRAO_SC` |
| **Vendas e Faturamento** | `TRG_CMP_TGFCAB_NFE_SPARK`, `STP_VALIDARCONF_SPARK`, `STP_VALIDARSERIE_SPARK`, `STP_NFREFDEV_SPARK` |
| **Estoque** | `VGFEST`, `STP_GARANTEESTOQUE_SPARK`, `STP_TRANSFEMP_SPARK`, `OBTEMCUSTO_SPARK` |
| **Financeiro** | `TRG_REFORCA_NAT_FIN`, `TRG_TGFFIN_LOG_SPARK`, `STP_EXCLUIRFINCOM_SPARK`, `STP_ATTCOTACAO_SPARK` |
| **Logística e Expedição** | `STP_GERARVOLUMES_SPARK`, `STP_INCEMB_SPARK`, `TRG_COTAFRETE_SPARK`, `TRG_FRETE_CIF_MTKPL_SPARK`, `CotaFreteMultiTransp.java` (`java/frete/`) |
| **Assistência Técnica** | `STP_INCMOVASSIST_SPARK`, `STP_MOVMATASSIST_SPARK`, `STP_INCNCONFORM_SPARK`, `TRG_UPD_OSINTERNA`, `STP_ENVIAEMAILOS_SPARK` |
| **Produção / Apontamento** | `TRG_VAL_SETOR_CODFUNC_TPRAPA`, `TRG_VAL_AD_CODFUNC_TPRAPA`, `AD_MAP_SETOR_FUNC` |
| **Fiscal / DIFAL / Impostos** | `EVP_GEROBRGDIFAL_SPARK`, `VGF_CALDIFAL_SPARK`, `TRG_UPD_DIFALPB_SPARK`, `STP_GERGUIAICMS_SPARK` |
| **Integração E-commerce / Site** | `STP_INTEGRAPEDIDO_SITESPARK`, `STP_INTEGRAPEDIDO_AGENDADA`, `TRG_INC_UPD_INTEGRA` |
| **CT-e / NF-e** | `EVP_CLASSIFICACTE_SPARK`, `TRG_CMP_TGFCAB_NFE_SPARK`, `VW_CTE_AUTORIZADOS`, `VGFNFE` |
| **Integração Contábil** | `STP_CRIA_CTACTBCLI_AUDICON`, `STP_CRIA_CTACTBFOR_AUDICON` |
| **BI / Gerencial** | 112 queries analíticas em `componentes BI/` |

---

## 6. Convenções de Nomenclatura

| Prefixo | Tipo de objeto | Exemplo |
|---|---|---|
| `STP_` | Stored Procedure (botão de ação ou automação) | `STP_PCP_SPARK` |
| `EVP_` | Procedure de visão externa (evento de tela) | `EVP_CLASSIFICACTE_SPARK` |
| `TRG_` | Trigger de banco de dados | `TRG_COTAFRETE_SPARK` |
| `SPK_` | Trigger legada (nomenclatura anterior) | `SPK_TGFCAB_TSIBLOCK` |
| `FC_` / `FN_` | Function escalar | `FC_TEMMETA_SPARK`, `FN_XMLTYPE_SAFE` |
| `PKG_SPARK_` | Package | `PKG_SPARK_MOEDA` |
| `V` / `VW_` | View de consulta | `VGFEST`, `VW_CTE_AUTORIZADOS` |
| `AD_` | Tabela customizada | `AD_LOG_ERROS`, `AD_MAP_SETOR_FUNC` |
| `_SPARK` | Sufixo padrão em objetos da Spark Eletrônica | — |

---

## 7. Inventário de Objetos

### 7.1 Triggers (pasta `triggers/`)
> 88 triggers (4 com o corpo todo comentado — *INATIVADA*). Ver [`triggers/README.md`](triggers/README.md) para catálogo completo.

Agrupadas por domínio:

| Domínio | Qtd | Exemplos |
|---|---|---|
| Produção / PCP | 17 | `TRG_INC_UPD_TPRIPROC_SPARK`, `TRG_TPRCOI_REPLICA_PA`, `TRG_INC_UPD_TPRCONF_SPARK`, `TRG_INC_UPD_DLT_TPRAPA_SPARK` |
| Nota Fiscal / Movimentação | 14 | `TRG_CMP_TGFCAB_NFE_SPARK`, `TRG_UPD_TGFCAB_MOEDA_SPARK2`, `TRG_INC_TGFVAR_SPARK`, `TRG_UPD_DIFALPB_SPARK` |
| Compras / SC | 6 | `TRG_NOTIFICA_SOLIC_COMPRA`, `TRG_STATUS_PADRAO_SC`, `TRG_ATUALIZA_STATUS_NUNOTA`, `TRG_BLOQUEIA_DELETE_SC` |
| Logística / Frete | 6 | `TRG_COTAFRETE_SPARK`, `TRG_COTAFRETE_EMB_SPARK`, `TRG_FRETE_CIF_MTKPL_SPARK`, `TRG_AD_EMBPED_SPARK` |
| Assistência / O.S. | 8 | `TRG_UPD_OSINTERNA`, `TRG_TGFASS_VLRCONSERTO_SPARK`, `TRG_SPKCAE_INC_SPARK`, `TRG_SPKCAE_VLRCONSERTO_SPARK` |
| Itens de Nota | 6 | `TRG_INC_UPD_TGFITE_SPARK`, `SPK_UPD_INS_TGFITE_CONSUMOPRD`, `TRG_UPT_TGFITE`, `TRG_INS_UPD_CODLOCALDEST` |
| Validação / Controle | 2 | `TRG_VAL_CSTIPI_SPARK` (inativada), `SPK_TGFCAB_TSIBLOCK` (inativada) |
| Financeiro | 4 | `TRG_REFORCA_NAT_FIN`, `TRG_TGFFIN_LOG_SPARK`, `TRG_INCDEVCH_SPARK`, `TRG_INC_AD_TGFFTA_SPARK` |
| Parceiro / Cadastro | 6 | `TRG_UPD_TGFPAR_UF_SPARK`, `TRG_INC_TSICID_SPARK`, `TRG_INC_TGFPAR_SPARK`, `TRG_INC_UPD_CMF_SPARK` |
| Séries / Conferência | 4 | `TRG_INC_TGFSER_SPARK`, `TRG_DLT_TGFSER_SPARK`, `TRG_TGFCON2_SPARK`, `TRG_TGFCOI2_SPARK` |
| Notificações / Avisos | 4 | `TRG_NOTIF_PARCERIA_SPARK`, `TRG_UPD_AVISOSPARK`, `TRG_INC_CORRAPONTAMENTO_SPARK`, `TRG_INC_TGFIXN_EMAIL_SPARK` (inativada) |
| Conferência de XML (`AD_TGSIXN`) | 3 | `TRG_INC_AD_TGSIXN_SPARK`, `TRG_INC_UPD_AD_TGSIXN_SPARK`, `TRG_UPD_AD_TGSIXN_SPARK` |
| Demais | 8 | Produto/custo (`TRG_INC_UPT_TGFPRO_SPARK`, `TRG_TGFCUS_SPARK`), integração (`TRG_INC_UPD_INTEGRA`), inventário de out/2026 (`TRG_UPD_NCMPROD_SPARK`, `TRG_UPD_ORIGPROD_SPARK`) |

---

### 7.2 Procedures (pasta `procedures/`)
> 103 procedures. Ver [`procedures/README.md`](procedures/README.md) para catálogo completo. O prefixo nem sempre indica a assinatura (há `STP_` de evento e `EVP_` de botão de ação) — ver "Tipos de Procedure" no catálogo.

| Domínio | Qtd | Exemplos |
|---|---|---|
| PCP / MRP | 8 | `STP_PCP_SPARK`, `STP_PCPMETA_SPARK`, `STP_TGFMET_SPARK`, `STP_ALTERAMETA_SPARK` |
| Compras / SC | 5 | `STP_APROVA_SOLIC_COMPRA`, `STP_NOTIFICASOLICCOMPRA_SPARK` |
| Estoque / Movimentação | 7 | `STP_TRANSFEMP_SPARK`, `STP_GARANTEESTOQUE_SPARK`, `STP_RESERVA_SPARK`, `STP_VGERENCIAL_SPARK` |
| Logística / Expedição / Frete | 9 | `STP_GERARVOLUMES_SPARK`, `STP_INCEMB_SPARK`, `STP_ATUALIZA_FRETE_COTA`, `STP_LIMPAREMESSA_SPARK` |
| Vendas / NF-e / Conferência | 11 | `STP_VALIDARCONF_SPARK`, `STP_VALIDARSERIE_SPARK`, `STP_NFREFDEV_SPARK`, `STP_CALCULAPROPORCAO_SPARK` |
| Assistência Técnica / O.S. | 7 | `STP_INCMOVASSIST_SPARK`, `STP_MOVMATASSIST_SPARK`, `STP_INCNCONFORM_SPARK`, `STP_OSINTERNA_INC_SPARK` |
| Financeiro | 8 | `STP_EXCLUIRFINCOM_SPARK`, `STP_ATTCOTACAO_SPARK`, `STP_ATUALIZARVLRMOEDA_SPARK`, `EVP_GEROBRGDIFAL_SPARK` |
| Produto / Cadastro | 7 | `STP_ALTDADOSPRO_SPARK`, `STP_MUDANCADECODIGO_SPARK`, `STP_ORIGPROD_SPARK`, `STP_CORCSTIPI_SPARK` |
| Produção — Operacional | 8 | `STP_TPRIATV_SPARK`, `STP_REABRIR_PA_SPARK`, `STP_CORRIGENOTAPROD_SPARK`, `STP_CORRIGEAPONTAMENTO_SPARK`, `STP_AGRUPAIMP_SPARK` |
| Integração E-commerce / Marketplace | 2 | `STP_INTEGRAPEDIDO_SITESPARK`, `STP_INTEGRAPEDIDO_AGENDADA` (pedidos de feiras/eventos) |
| Colaboradores / RH | 1 | `STP_TFPFUN_ALTERADEP` |
| Eventos de tela (EVP) | 3 | `EVP_CLASSIFICACTE_SPARK`, `EVP_TGFIXN_EMAIL_SPARK` |
| Auxiliares / Configuração | 4 | `STP_GRAVA_FILA_BI2`, `STP_INCLUIRLANCTO_SPARK`, `STP_INICIADATA_SPARK` |
| Conferência de XML (`AD_TGSIXN`) | 2 | `STP_APONTACONFERENCIA_SPARK`, `STP_ATUALIZADTFIM_TGSIXN_SPARK` |
| Objetos descobertos em 08/10/2026 (autoria Lucas Gabriel — ONTIME TECH / DM TECH) | 21 | `STP_INCSUSPIPI_SPARK`, `STP_CALCPROPOICMS_SPARK`, `STP_GERGUIAICMS_SPARK`, `EVP_ICMSSIMPLES_SPARK`, `STP_BOLJUROSMULTA_SPARK` … (ver `procedures/README.md` §15) |

---

### 7.3 Functions (pasta `functions/`)

| Objeto | Assinatura | Descrição |
|---|---|---|
| `FC_TEMMETA_SPARK` | `(P_CODPROD NUMBER) → VARCHAR2` | `'S'`/`'N'` conforme o produto tenha meta cadastrada (`TGMMET`, CODMETA = 3) |
| `FC_GETPRECO_TRASF_SP` | `(P_CODPROD INT) → FLOAT` | Maior custo em `AD_TGSCIT` no registro `AD_TGSCUS` de `DTREF` mais recente ≤ hoje; 0 se não houver |
| `FN_XMLTYPE_SAFE` | `(P_XML VARCHAR2) → XMLTYPE` | Converte string para XMLTYPE retornando NULL em caso de XML inválido (evita ORA-31011) |
| `OBTEMCUSTO_SPARK` | `(P_CODPROD, P_POREMP, P_CODEMP, P_PORLOCAL, P_CODLOCAL, P_PORCONTROLE, P_CONTROLE, P_DATA, P_TIPO) → FLOAT` | Custo do produto (`TGFCUS`) vigente em `P_DATA` por tipo (0 a 6: reposição, médio, variável, sem ICMS, entrada com ICMS…); 0 em caso de falha |
| `OBTEM_TOTAIS_MRP` | `(P_NUMPS, P_CODPRODPA, P_CODPRODMP, P_TIPO) → FLOAT RESULT_CACHE` | Totais do MPS/MRP por tipo (`M`, `P`, `S`, `N`, `NA`, `E`, `O`; `C` não implementado) |
| `FC_GET_FATURAS` | `(P_NUNOTA) → VARCHAR2` | Parcelas da nota em texto (`TGFFIN`), excluindo tipos de título 34/35/36/15 e `CODEMP` ≥ 500 |
| `FC_RATEIOFRETE_SAPARK` | `(P_NUNOTA) → NUMBER` | Fração (0 a 1) do valor das NF-e do CT-e que pertence às TOPs base de DIFAL (ONTIME TECH) |
| `FN_GET_ULTIMO_CUSTO_SPARK1` | `(P_CODPROD, P_TIPO, P_DATA) → NUMBER` | Componente (0 a 5) do último custo realizado em `AD_TGSCIT`/`AD_TGSCUS` com `DTREF` ≤ `P_DATA` (ONTIME TECH) |
| `GET_ESTOQUE_KIT_PA_OVERSYSTEM` | `(P_CODPROD, P_CODLOCAL) → TYPE_TABLE_KIT PIPELINED` | Estoque disponível de PA/kit por componente; `P_CODLOCAL = 0` soma todos os locais (origem a confirmar) |

---

### 7.3.1 Packages (pasta `package/`)
> Ver [`package/README.md`](package/README.md).

| Objeto | Descrição |
|---|---|
| `PKG_SPARK_MOEDA` | Package de estado de sessão — expõe variáveis globais (`V_NUNOTA`, `V_VLRMOEDA`, `V_CODTIPOPER`) usadas pela trigger compound `TRG_UPD_TGFCAB_MOEDA_SPARK2` para comunicar valores do cabeçalho aos triggers de itens sem incorrer em ORA-04091 |

---

### 7.4 Views (pasta `view/`)
> Ver [`view/README.md`](view/README.md).

| Objeto | Colunas principais | Descrição |
|---|---|---|
| `VGFEST` | `SKU, ESTO` | Estoque por produto ativo de revenda/venda (`USOPROD` R/V), empresa 1, local 109 |
| `VW_CTE_AUTORIZADOS` (arquivo `VGFIXN.SQL`) | `NRARQUIVO, CHAVEACESSO, CHAVEACESSO_REF, CODTIPOPER_NFE, ...` | CT-e autorizados — uma linha por NF-e referenciada, com a TOP da NF-e (usa `FN_XMLTYPE_SAFE`) |
| `VGFNFE` | `NUNOTA, CODVEND, PEDIDOEXTERNO, AD_WAREHOUSEID, CHAVENFE, NOTAXML` | NF-e de venda autorizadas do vendedor 42 nos últimos 4 dias, com XML (`TGFNFE.XMLENVCLI`) para integração com o site |
| `VGFSALDOMRP` | `DTREF, CODPROD, QTDPREV, QTDPRODUZIR, SALDO` | Saldo mensal por produto: meta (`AD_TGFMET`) contra quantidade a produzir das OPs |
| `VGFSERIES` | `NFSAIDA, CODPROD, SERIE, LOTE, TIPO, MOVIMENTO, LOCAL, TOP` | Seriais unificados (Andes + Sankhya) — não é nativa; mais usada pelos componentes BI |
| 8 views `VGF_*_SPARK` | — | `VGF_CALDIFAL_SPARK`, `VGF_CALIDFAL_SPARK`, `VGF_CALCFINIMP_SPARK`, `VGF_DIFST_SPARK`, `VGF_DIFSTFEM_SPARK`, `VGF_OBSNOTAS2_SPARK`, `VGF_OBSNOTASDEV2_SPARK`, `VGFCOM_FECHSPARK` (ver `view/README.md`) |
| `AD_VWMELIFATVIX` / `AD_VWMELIFATVIX2` | `NUNOTA, AD_SHIPID, CHAVENFE, NOTAXML, ...` | NF-e de marketplace (ML) autorizadas nos últimos 7 dias sem etiqueta gerada (`TSIATA`). As duas diferem no vendedor (`CODVEND` 5 / 43) |

---

### 7.5 Tabelas Customizadas (pasta `tables/`)
> 39 DDLs. Ver [`tables/README.md`](tables/README.md) para todas; abaixo, as principais. Tabelas referenciadas sem DDL local estão em [`tables/TABELAS_FALTANTES.md`](tables/TABELAS_FALTANTES.md).

| Tabela | PK | Descrição |
|---|---|---|
| `AD_LOG_ERROS` | `IDLOG` | Log centralizado de erros gerados por triggers. Registra código de erro, backtrace e contexto da nota |
| `AD_MAP_SETOR_FUNC` | `DESCDEP, DESCIDEFX` | Mapeamento entre departamento do colaborador e etapa de produção (suporte à validação de apontamentos) |
| `AD_CORRNOTAPROD` | `NUCORR` | Auditoria das correções de notas de produção feitas por `STP_CORRIGENOTAPROD_SPARK` |
| `AD_CORRAPONTAMENTO` | `NUCORR` | Auditoria das correções de apontamento (`TPRAPA`) feitas por `STP_CORRIGEAPONTAMENTO_SPARK`, com os valores anteriores |
| `AD_TGFASS` | `NUMOS` | Cabeçalho da O.S. de assistência técnica da Spark (checklist de inspeção da placa, técnicos, `VLRCONSERTO`, `MESFOLHA`) |
| `AD_TGFIASS` | `NUMOS, IDCOMP` | Componentes consumidos numa O.S. de `AD_TGFASS` |
| `AD_SPKCAE` / `AD_SPKICAE` | `NUMOS` / `NUMOS, IDCOMP` | O.S. de conserto da assistência externa e seus componentes; `NUFIN`, `NUNOTATRF` e `NUNOTADESC` marcam o que já foi gerado |
| `AD_APOQLD` | `NUAPO` | Checklist de defeitos de qualidade por apontamento, com operadores e revisores |
| `AD_OSINTERNA` | `NUMOS` | O.S. interna de manutenção de equipamentos e patrimônio |
| `AD_TGSAPI` | `API` | Credenciais e endpoints de APIs externas (cotação de frete — Rodonaves) |
| `AD_TGSCTF` | `NUCTF` | Cabeçalho da cotação de frete (uma linha por embarque) |
| `AD_TGSLCB` | `NUCTF, IDEMB` | Itens/pacotes da cotação de frete (dimensões e peso por embalagem) |
| `AD_TGSIXN` | `NUCONF` | Apontamento de conferência de arquivo/nota importada (`TGFIXN`) |
| `AD_TGSSCP` / `AD_TGSISCP` | `NUSOL` / `NUSOL, SEQUENCIA` | Solicitação de compra interna (cabeçalho com workflow de aprovação, e itens) |
| `AD_TGFMET` | `CODMETA, DTREF, CODEMP, CODPROD` | Meta por produto, empresa e período (base de `VGFSALDOMRP`) |
| `AD_TGSSGM` | `CODSGRU, ANO, MES` | Meta de venda por subgrupo e período |
| `AD_TGSISGM` | `CODSGRU, ANO, MES, IDGRU` | Itens da meta por subgrupo (grupos de produto que a compõem) |

---

### 7.6 Componentes BI (pasta `componentes BI/`)
> 112 queries de componente (115 `.sql`, dos quais 3 não são componentes) em 32 pastas + arquivos soltos. Ver [`componentes BI/README.md`](componentes%20BI/README.md).

| Tema | Dashboard / Componente |
|---|---|
| Produção | Fichas de Produção, Cronograma Geral, Painel de Acompanhamento, Produção Diária por Colaborador / por Setor, Estoque em Processo/Elaboração, Planejamento de Estoque de Produção, Gráfico de Qualidade por Operador |
| Vendas | Dashboard de Vendas, Faturamento por Período (Gestão, Devoluções), Resumo de Resultado, Resumo de Vendas por Vendedor, Painel Comercial, Card de Vendas Mensal, Curva ABC, Evolução de Vendas, Distribuição por Grupo de Produto |
| Estoque | Estimativa de Estoque (e Gerencial), Estoque Sem Movimento, Cópia de Estoque, Transferência entre Empresas, Exportador de Séries, Estoque/Movimentação de Terceiros, Conferência Composição PA-PI, Indicadores de Atendimento de Requisição |
| Compras | Relação de Compras por Previsão, Adiantamento Fornecedor, Itens de Entrada, Evolução Mensal de Compras |
| Assistência | Informativo de Gestão da Assistência (e Detalhes), Assistência Externa, Cards de O.S. por Produto / por Técnico |
| Auditoria | Auditoria de Movimentações, Auditoria Produção-Expedição, Auditor E-commerce, Apontamentos de Conferência |
| Financeiro / Fiscal | Apuração DIFAL, Contas a Pagar e Provisão, Quantidade de Boletos, Proporcionalidade Matriz, Valida Natureza |
| Cadastro | Tabela de Características de Produto (descrição, NCM, medidas, grupo — filtro multilist) |

---

### 7.7 Relatórios Jasper (pasta `reports/`)
> 39 pastas de relatórios. Ver [`reports/README.md`](reports/README.md).

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
| 26 | Etiqueta de Compra — MKTP | Compras |
| 27 | Ficha de Anomalia de Processo | Produção / Qualidade |
| 28 | Etiqueta Compra Avulsa | Compras |
| 29 | Tabela Spark Produtos | Vendas / Catálogo |
| 30 | Etiqueta de Qualidade | Produção / Qualidade |
| 31 | Etiqueta de Série Avulsa Manual | Logística |
| 32 | Etiqueta Avulsa Manual | Logística |
| 33 | Orçamento de Venda Lucas | Vendas |
| 34 | Fechamento Assistência | Assistência / Financeiro |
| 35 | Fechamento Assistência Interna | Assistência |
| 36 | Fechamento Assistência Interna Técnico | Assistência / Folha |
| 37 | Separação Transferência Assistência | Assistência Externa / Estoque |
| 38 | Etiquetas Transferência Assistência | Assistência Externa / Estoque |
| 39 | O.S. Assistência | Assistência |

---

### 7.8 Java (pasta `java/`)
> Ver [`java/README.md`](java/README.md).

| Classe | Tipo | Descrição |
|---|---|---|
| `frete/CotaFreteMultiTransp` | Botão de Ação | Botão único de cotação de frete; escolhe Braspress ou Rodonaves por `AD_TGSCTF.APIDEST`, grava `VLRFRETE`/`AD_ESTENTR` e recalcula impostos |
| `frete/BraspressCotador`, `frete/RodonavesCotador` | Apoio (`CotadorTransportadora`) | Autenticação, payload e parse da API de cada transportadora |
| `frete/CotadorTransportadora`, `CotacaoResultado`, `DadosCotacaoLinha`, `PacoteDimensao`, `FreteUtils` | Apoio | Interface, DTOs e funções auxiliares da cotação |
| `frete/legado/CotaFrete`, `frete/legado/CotaFreteRodonaves` | Botão de Ação (legado) | Cotações antigas Braspress e Rodonaves; substituídas por `CotaFreteMultiTransp` |
| `transferencia/GerarTransferencia` | Botão de Ação | Gera saída e entrada de transferência entre empresas a partir de pedidos (impostos com IBS/CBS, confirmação, lote NF-e) |
| `transferencia/legado/GerarTransferenciaOriginal` | Referência | Versão anterior à refatoração (backup) |
| `transferencia/enuns/Tipo` | Enumeração | `PEDIDO` (P), `SAIDA` (V), `ENTRADA` (C) |
| `transferencia/listeners/DelecaoTransfencia` | Evento Programável | Bloqueia exclusão se a nota vinculada estiver confirmada ou no Livro de ICMS; exclui o par em cascata |
| `transferencia/util/TransferenciaUtils` | Utilitário | Validações, montagem de cabeçalho/itens, séries, impostos, confirmação e lote NF-e |
| `etiquetas/ImprimirEtiquetasv2` | Botão de Ação | Concatena num único PDF os relatórios de etiqueta conforme a quantidade de séries da nota (faixas de 50) |
| `financeiro/RecalFinanceiroEve` | Evento Programável | Refaz o financeiro da nota quando `AD_AGDIMPCTE` vira `S` durante a confirmação |

---

### 7.9 Fórmulas e Regras (pasta `formulas/`)
> Ver [`formulas/README.md`](formulas/README.md).

| Arquivo | Descrição |
|---|---|
| `comissaopadrao` | Fórmula de cálculo de comissão padrão por vendedor e tipo de venda |
| `regra_processa_xml_cte.sql` | Complemento da regra de processamento automático de CT-e importado (`TGFIXN`) |
| `Observação_Venda_Spark.txt` | Fórmula do texto de observação da NF-e de venda (blocos por empresa/TOP, views `VGF_OBS*_SPARK`, FCP) |

---

### 7.10 Integração Contábil (pasta `audicon/`)

| Objeto | Descrição |
|---|---|
| `STP_CRIA_CTACTBCLI_AUDICON` | Cria em `TCBPLA`/`TCBCTR` a conta contábil dos clientes com títulos a receber desde 2024 e grava o vínculo em `TGFPAR` (rotina escrita pela Audicon) |
| `STP_CRIA_CTACTBFOR_AUDICON` | Idem para fornecedores (títulos a pagar) |

---

### 7.11 Exemplos de Referência (pasta `exemplos/`)
> Ver [`exemplos/README.md`](exemplos/README.md).

Amostras reais de dados (`TGFCAB` + `TGFITE` + `TGFSER` de um lançamento de
produção) e o script `EXEMPLO_LANCAMENTO_CAB_ITE_SER.sql` que as extrai. Material
de apoio à documentação — não é objeto implantado no ERP.

---

## 8. Restrições e Requisitos Técnicos

- **Banco de dados:** Oracle Database (dialeto PL/SQL obrigatório)
- **ERP:** Sankhya W, módulos COM, FIN, PCP, WMS, CAC
- **Java SDK:** `SankhyaW-extensions.jar`, `mge-modelcore`, `mgecom-model` (JARs em `nativo/libs/`, pasta local fora do git — ver [§10](#10-material-nativo-e-material-local))
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

---

## 10. Material nativo e material local

`nativo/` guarda o que é do **fabricante** (Sankhya): referência de consulta e base para `git diff` após cada upgrade. Está **versionado**, exceto `nativo/libs/`. `scripts/` e `nativo/libs/` estão no `.gitignore` e **não existem num clone novo**. Índice, convenções e procedimento de recaptura em [`nativo/README.md`](nativo/README.md); inventário completo em [`nativo/MANIFESTO.csv`](nativo/MANIFESTO.csv).

| Pasta | Versionada | Conteúdo | Como recriar |
|---|---|---|---|
| `nativo/functions/` | sim | 348 functions nativas (`SNK_*`, `ACT_*`, `TIM_*`, `FSP_*` …) + `README.md` com catálogo | `DBMS_METADATA.GET_DDL('FUNCTION', …)`; inventário em `scripts/CAPTURA_LISTA_FUNCTIONS_NAO_SNK.SQL` |
| `nativo/packages/` | sim | 20 packages nativos (`VARIAVEIS_PKG`, `TGFITE_PKG`, `ERROS_PKG` …), somente especificação — o banco não tem body — + `README.md` com catálogo | `DBMS_METADATA.GET_DDL('PACKAGE_SPEC', …)`; inventário em `scripts/CAPTURA_LISTA_PACKAGES.SQL` |
| `nativo/tables/` | sim | DDL de 54 tabelas nativas (as 53 mais referenciadas + `TSILGT`) + `README.md` | `scripts/CAPTURA_DDL_TABELAS_FALTANTES*.SQL`; lista em [`tables/TABELAS_FALTANTES.md`](tables/TABELAS_FALTANTES.md) |
| `nativo/procedures/` | sim | 21 procedures nativas citadas pelas triggers nativas e pela Spark (`STP_ATUALIZA_TGFEST`, `STP_POPULA_MSG` …) + `README.md` | `DBMS_METADATA.GET_DDL('PROCEDURE', …)`; lote em `scripts/CAPTURA_DDL_NATIVOS_LOTE1.SQL` |
| `nativo/triggers/` | sim | 149 triggers das tabelas nativas que a Spark customiza (TGFCAB, TGFITE, TGFFIN, TGFPRO …), com estado `ENABLED`/`DISABLED` — `TRG_INC_TGFITE` (a validação de lote obrigatório, antes desligada pela Spark, está ativa no banco desde o upgrade de 21/09/2026) e `TRG_INC_TGFVAR` (100% nativa) entre elas | `DBMS_METADATA.GET_DDL('TRIGGER', …)`; inventário em `scripts/CAPTURA_INVENTARIO_NATIVO.SQL`; contexto do incidente em [`triggers/README.md`](triggers/README.md) §14–15 |
| `nativo/libs/` | **não** (536 MB) | JARs do Sankhya SDK (classpath do Java; `.vscode/settings.json` aponta para cá) | Copiar da instalação do servidor Sankhya |
| `scripts/` | **não** | Capturas de DDL, diagnósticos (`DIAG_*`, `DRYRUN_*`, `VALIDA_*`), `CHECK_STATUS_TRIGGERS_SPARK.SQL`, backfills pontuais | Não recriável — fazer backup próprio se necessário |

**Regra prática:** o que é código da Spark e vai para produção fica nas pastas da raiz (§3). O que é do fabricante fica em `nativo/` (versionado, só leitura). O que é ferramenta de uso único ou binário pesado (`scripts/`, `nativo/libs/`) fica fora do git. Documentação que cita arquivos de `scripts/` e `nativo/libs/` indica explicitamente que o caminho é local.

> Atualizações do Sankhya podem alterar ou remover objetos nativos. Recapturar o DDL após cada upgrade do ERP e commitar o resultado — o `git diff` mostra o que o fabricante mudou.
