# Catálogo de Packages

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de packages:** 1  
**Banco:** Oracle PL/SQL  

---

## Objetivo

Os packages Oracle são utilizados como repositório de variáveis de sessão compartilhadas entre triggers e procedures que precisam trocar estado dentro de uma mesma transação, contornando a limitação de tabelas mutantes (`ORA-04091`) sem recorrer a tabelas auxiliares.

---

## Catálogo

### `PKG_SPARK_MOEDA`

**Arquivo:** `PKG_SPARK_MOEDA.sql`  
**Tipo:** Package (especificação apenas — sem body)

**Descrição:** Package de estado de sessão para a trigger compound `TRG_UPD_TGFCAB_MOEDA_SPARK2`. Expõe variáveis globais de sessão que permitem à fase `AFTER STATEMENT` do compound trigger comunicar valores do cabeçalho da nota aos triggers de itens (`TRG_INC_UPD_TGFITE_SPARK2`), evitando SELECT em `TGFCAB` enquanto ela está mutante.

**Variáveis:**

| Variável | Tipo | Descrição |
|---|---|---|
| `V_NUNOTA` | `NUMBER` | Número único da nota em processamento |
| `V_VLRMOEDA` | `NUMBER` | Taxa de câmbio (`VLRMOEDA`) do cabeçalho |
| `V_CODTIPOPER` | `NUMBER` | Tipo de operação (`CODTIPOPER`) do cabeçalho |

**Ciclo de vida:**
- Populadas na fase `AFTER STATEMENT` de `TRG_UPD_TGFCAB_MOEDA_SPARK2`
- Lidas por `TRG_INC_UPD_TGFITE_SPARK2` durante o UPDATE em `TGFITE`
- Limpas (`NULL` / `DELETE`) ao final do loop da fase `AFTER STATEMENT`

**Dependências:**

| Objeto | Relação |
|---|---|
| `TRG_UPD_TGFCAB_MOEDA_SPARK2` | Popula e limpa as variáveis |
| `TRG_INC_UPD_TGFITE_SPARK2` | Consome as variáveis durante o UPDATE de itens |

---

## Observações

- O package não possui body — todas as variáveis são públicas e acessíveis diretamente via `PKG_SPARK_MOEDA.V_XXXX`.
- As variáveis são de sessão: cada conexão Oracle possui sua própria cópia; não há risco de interferência entre sessões concorrentes.
- Ao adicionar novas triggers compound que precisem compartilhar estado, estender este package em vez de criar novos packages de escopo similar.
