# Catálogo de Functions

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de functions:** 3  
**Banco:** Oracle PL/SQL  

---

## Catálogo

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
