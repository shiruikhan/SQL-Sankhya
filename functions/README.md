# Catálogo de Functions

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de functions:** 10  
**Banco:** Oracle PL/SQL  

---

## Catálogo

### `FC_GETPRECO_TRASF_SP`

**Arquivo:** `FC_GETPRECO_TRASF_SP.SQL`  
**Tipo de retorno:** `FLOAT`

**Assinatura:**
```sql
FC_GETPRECO_TRASF_SP(P_CODPROD IN INT) RETURN FLOAT
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_CODPROD` | `INT` | Código do produto a consultar |

**Retorno:** Custo mais recente do produto na tabela de custos customizada (`AD_TGSCUS` / `AD_TGSCIT`) com data de referência `≤ SYSDATE`. Retorna `0` se não houver registro.

**Tabelas consultadas:** `AD_TGSCUS` (cabeçalho da tabela de custo), `AD_TGSCIT` (itens da tabela de custo)  
**Uso:** Procedure de transferência entre empresas para obter o preço de custo do produto no momento da geração da nota.

---

### `FN_XMLTYPE_SAFE`

**Arquivo:** `FN_XMLTYPE_SAFE.SQL`  
**Tipo de retorno:** `XMLTYPE`  
**Criação:** Abril/2026 | **Última revisão:** Abril/2026

**Assinatura:**
```sql
FN_XMLTYPE_SAFE(P_XML IN VARCHAR2) RETURN XMLTYPE
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_XML` | `VARCHAR2` | String contendo o conteúdo XML a converter |

**Retorno:**
- `XMLTYPE` — objeto XML parseado com sucesso
- `NULL` — quando o conteúdo não é XML válido (suprime `ORA-31011`)

**Uso:** Substituição de `XMLTYPE(X.DOCSREF)` no `PASSING` do `XMLTABLE` na view `VW_CTE_AUTORIZADOS`. Evita que XMLs malformados ou nulos em `TGFIXN.DOCSREF` derrubem queries que dependem de parsing de XML.

---

### `FC_TEMMETA_SPARK`

**Arquivo:** `FC_TEMMETA_SPARK.SQL`  
**Tipo de retorno:** `VARCHAR2`  
**Criação:** 16/12/2021 | **Última revisão:** 23/04/2025

**Assinatura:**
```sql
FC_TEMMETA_SPARK(P_CODPROD IN NUMBER) RETURN VARCHAR2
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_CODPROD` | `NUMBER` | Código do produto a verificar |

**Retorno:**
- `'S'` — produto possui meta cadastrada com `CODMETA = 3`
- `'N'` — produto não possui meta

**Tabela consultada:** `TGMMET`  
**Uso:** Verificação de pré-condição nas procedures de PCP/MRP antes de calcular o plano de produção.

---

### `OBTEMCUSTO_SPARK`

**Arquivo:** `OBTEMCUSTO_SPARK.SQL`  
**Tipo de retorno:** `FLOAT`  
**Criação:** 10/03/2022 | **Última revisão:** 23/04/2025

**Assinatura:**
```sql
OBTEMCUSTO_SPARK(
    P_CODPROD      IN NUMBER,
    P_POREMP       IN CHAR,
    P_CODEMP       IN NUMBER,
    P_PORLOCAL     IN CHAR,
    P_CODLOCAL     IN NUMBER,
    P_PORCONTROLE  IN CHAR,
    P_CONTROLE     IN VARCHAR2,
    P_DATA         IN DATE,
    P_TIPO         IN NUMBER
) RETURN FLOAT
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_CODPROD` | `NUMBER` | Código do produto |
| `P_POREMP` | `CHAR` | Filtrar por empresa? `'S'` / `'N'` |
| `P_CODEMP` | `NUMBER` | Código da empresa (usado se `P_POREMP = 'S'`) |
| `P_PORLOCAL` | `CHAR` | Filtrar por local? `'S'` / `'N'` |
| `P_CODLOCAL` | `NUMBER` | Código do local de estoque (usado se `P_PORLOCAL = 'S'`) |
| `P_PORCONTROLE` | `CHAR` | Filtrar por controle (série/lote)? `'S'` / `'N'` |
| `P_CONTROLE` | `VARCHAR2` | Identificador do controle |
| `P_DATA` | `DATE` | Data de referência da movimentação |
| `P_TIPO` | `NUMBER` | Tipo de custo desejado (ver tabela abaixo) |

**Tipos de custo (P_TIPO):**

| Valor | Tipo de custo |
|---|---|
| `0` | Custo de reposição |
| `1` | Custo médio |
| `2` | Custo variável |
| `3` | Custo sem ICMS |
| `4` | Custo médio com ICMS |
| `5` | Entrada sem ICMS |

**Uso:** Utilizada em procedures de transferência, análise de margem e relatórios de custo de produto.

---

### `OBTEM_TOTAIS_MRP`

**Arquivo:** `OBTEM_TOTAIS_MRP.sql`  
**Tipo de retorno:** `FLOAT`

**Assinatura:**
```sql
OBTEM_TOTAIS_MRP(
    P_NUMPS     NUMBER,
    P_CODPRODPA NUMBER,
    P_CODPRODMP NUMBER,
    P_TIPO      VARCHAR2
) RETURN FLOAT
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_NUMPS` | `NUMBER` | Número do plano mestre (MPS) |
| `P_CODPRODPA` | `NUMBER` | Código do produto acabado (PA) |
| `P_CODPRODMP` | `NUMBER` | Código da matéria-prima (MP) |
| `P_TIPO` | `VARCHAR2` | Tipo de total a retornar (ver tabela abaixo) |

**Tipos de total (P_TIPO):**

| Valor | Significado |
|---|---|
| `'M'` | Meta do PA |
| `'P'` | Produção do PA |
| `'S'` | Saldo a produzir do PA (negativo = produção acima da meta) |
| `'N'` | Necessidade de MP no MRP filtrado |
| `'NA'` | Necessidade total de MP |
| `'C'` | Necessidade de compra de MP no MRP filtrado |
| `'E'` | Estoque disponível de MP |
| `'O'` | Ordem/Pedido de compra aberto de MP |

**Uso:** Utilizada nas queries analíticas de BI e no componente `CRONOGRAMA GERAL DE PRODUCAO` para construir visão consolidada do plano de produção por produto.

> **Observação:** Saldo negativo em `P_TIPO = 'S'` indica que o PA já foi produzido acima da meta; neste caso o valor não deve influenciar no cálculo de MP a comprar.

---

### `FC_GET_FATURAS`

**Arquivo:** `FC_GET_FATURAS.SQL`  
**Tipo de retorno:** `VARCHAR2`  
**Captura:** 08/10/2026 (via `DBMS_METADATA.GET_DDL`, cópia fiel da produção)

**Assinatura:**
```sql
FC_GET_FATURAS (P_NUNOTA IN TGFCAB.NUNOTA%TYPE) RETURN VARCHAR2
```

**Retorno:** Texto com as parcelas dos títulos da nota (`TGFFIN`: `Parc=… Venc=… Valor=…`, separadas por ` | `), excluindo os tipos de título 34, 35, 36 e 15 e empresas ≥ 500.

**Tabela consultada:** `TGFFIN`

> **Origem não confirmada:** sem sufixo `_SPARK`, mas criada em 02/2022, alterada em 09/2025 e com regras de negócio da Spark; tratada como customização.

---

### `FC_RATEIOFRETE_SAPARK`

**Arquivo:** `FC_RATEIOFRETE_SAPARK.SQL`  
**Tipo de retorno:** `NUMBER`  
**Captura:** 08/10/2026 (via `DBMS_METADATA.GET_DDL`, cópia fiel da produção)

**Assinatura:**
```sql
FC_RATEIOFRETE_SAPARK ( P_NUNOTA IN NUMBER ) RETURN NUMBER
```

**Retorno:** Percentual (0 a 1, 6 casas) do valor das notas vinculadas (`TGFNCT` → `TGFCAB` pela chave NF-e) que é base de DIFAL: soma das notas das TOPs 201, 221, 224, 231 e 209 sobre o total. `0` se o total for zero.

**Tabelas consultadas:** `TGFNCT`, `TGFCAB`  
**Autoria:** Lucas Gabriel (ONTIME TECH), 04/08/2025 — apoio ao cálculo do DIFAL.

> **Atenção:** o sufixo `SAPARK` parece erro de digitação de `SPARK`; renomear exigiria ajustar quem a chama.

---

### `FN_GET_ULTIMO_CUSTO_SPARK1`

**Arquivo:** `FN_GET_ULTIMO_CUSTO_SPARK1.SQL`  
**Tipo de retorno:** `NUMBER`  
**Captura:** 08/10/2026 (via `DBMS_METADATA.GET_DDL`, cópia fiel da produção)

**Assinatura:**
```sql
FN_GET_ULTIMO_CUSTO_SPARK1 ( P_CODPROD IN NUMBER, P_TIPO IN NUMBER, P_DATA IN DATE ) RETURN NUMBER
```

**Parâmetros:** `P_CODPROD` (produto), `P_TIPO` (componente do custo), `P_DATA` (data de referência).

| `P_TIPO` | Retorno |
|---|---|
| `0` | Custo MP fiscal |
| `1` | Custo MP real |
| `2` | Mão de obra |
| `3` | Valor ICMS |
| `4` | Valor IPI |
| `5` | Frete fixo |

**Retorno:** Componente do último custo realizado da planilha de custos (`AD_TGSCIT` / `AD_TGSCUS`) com `DTREF <= P_DATA` e `CUSTOREL > 0`; `0` se não houver registro.

**Tabelas consultadas:** `AD_TGSCIT`, `AD_TGSCUS`  
**Autoria:** Lucas Gabriel (ONTIME TECH), 30/10/2025  
**Uso:** Relatório `33 - ORÇAMENTO DE VENDA LUCAS` (`ORCAMENTO V04.jrxml`).

---

### `GET_ESTOQUE_KIT_PA_OVERSYSTEM`

**Arquivo:** `GET_ESTOQUE_KIT_PA_OVERSYSTEM.SQL`  
**Tipo de retorno:** `TYPE_TABLE_KIT`  
**Captura:** 08/10/2026 (via `DBMS_METADATA.GET_DDL`, cópia fiel da produção)

**Assinatura:**
```sql
GET_ESTOQUE_KIT_PA_OVERSYSTEM ( P_CODPROD IN INT,P_CODLOCAL IN INT ) RETURN TYPE_TABLE_KIT
```

**Retorno:** Pipelined (`TYPE_TABLE_KIT`): estoque disponível (`ESTOQUE - RESERVADO`, mínimo 0) do PA ou, quando é kit (variação 30000 em `TGFICP`), de cada matéria-prima componente. `P_CODLOCAL = 0` soma todos os locais.

**Tabelas consultadas:** `TGFEST`, `TGFICP`

> **Origem não confirmada:** o sufixo `OVERSYSTEM` sugere consultoria externa; criada em 02/2022. Nenhum objeto do repositório a referencia.

---

### `SNK_PRECO` (nativa Sankhya)

**Arquivo:** `SNK_PRECO.SQL`  
**Tipo de retorno:** `FLOAT`  
**Captura:** 17/09/2026 (via `DBA_SOURCE`)

**Assinatura:**
```sql
SNK_PRECO(P_CODTAB IN INTEGER, P_CODPROD IN INTEGER) RETURN FLOAT
```

**Parâmetros:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `P_CODTAB` | `INTEGER` | Código da tabela de preços (ex.: `14` = tabela padrão de serviços, `15` = tabela usada para `VLRSERVTECNICO` em `AD_TGFASS`) |
| `P_CODPROD` | `INTEGER` | Código do produto a precificar |

**Retorno:** Preço do produto vigente na tabela informada, resolvendo primeiro a `NUTAB` com `DTVIGOR` mais recente `<= SYSDATE` em `TGFTAB` e delegando o cálculo para `STP_OBTEM_PRECO2`. Se não houver tabela vigente, `V_NUTAB = 0` é passado adiante.

**Tabela consultada:** `TGFTAB`  
**Dependência:** `STP_OBTEM_PRECO2` (procedure nativa Sankhya)  
**Uso:**
- `TRG_SPKCAE_VLRCONSERTO_SPARK` e `scripts/AD_SPKCAE_BACKFILL_VLRCONSERTO.SQL` — calcula `VLRCONSERTO` a partir do preço de serviço do produto (`CODTAB = 14`).
- `TRG_TGFASS_VLRCONSERTO_SPARK` e `scripts/AD_TGFASS_BACKFILL_VLRCONSERTO_VLRSERVTECNICO.SQL` — calculam `VLRCONSERTO` (`CODTAB = 14`) e `VLRSERVTECNICO` (`CODTAB = 15`) a partir do preço do produto.

> **Atenção:** function **nativa** do ERP, não uma customização Spark — armazenada aqui só como referência. Atualizações do Sankhya podem sobrescrevê-la; revisar após cada upgrade (mesmo cuidado de `trigger_nativa/README.md`).
