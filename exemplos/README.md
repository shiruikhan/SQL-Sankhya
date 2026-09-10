# Exemplos de Referência

**Empresa:** Spark Eletrônica
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior

---

## Objetivo

Esta pasta guarda **amostras reais de dados** e scripts de extração usados como
referência de estrutura ao desenvolver e revisar customizações. Nada aqui é
objeto implantado no ERP — são artefatos de apoio à documentação.

> Os arquivos `TGFCAB.sql`, `TGFITE.sql` e `TGFSER.sql` contêm `INSERT`s
> exportados de um lançamento de produção real (`NUNOTA` 803681, TOP 800,
> anterior a 01/07/2026). Servem para inspecionar o preenchimento campo a campo
> de um cabeçalho + itens + séries consistentes entre si. **Não executar em
> produção.**

---

## Catálogo

| Arquivo | Tipo | Descrição |
|---|---|---|
| `EXEMPLO_LANCAMENTO_CAB_ITE_SER.sql` | Script de consulta | Localiza um `NUNOTA` de exemplo (mais recente antes de 01/07/2026, com item e série vinculados) e extrai o conteúdo completo de `TGFCAB`, `TGFITE` e `TGFSER` desse lançamento. Execução manual em SQL Developer/Toad; substituir `:P_NUNOTA` pelo valor retornado no passo 1 |
| `TGFCAB.sql` | Dump de dados | `INSERT` do cabeçalho da nota de exemplo (`NUNOTA` 803681) — todas as colunas de `TGFCAB` |
| `TGFITE.sql` | Dump de dados | `INSERT`s dos itens da nota de exemplo — todas as colunas de `TGFITE` |
| `TGFSER.sql` | Dump de dados | `INSERT`s das séries (`TGFSER`) vinculadas ao item da nota de exemplo |

---

## Observações

- Os dumps usam `SET DEFINE OFF` — necessário para não interpretar `&` como
  variável de substituição ao reexecutar em outra base de teste.
- As datas nos `INSERT`s estão no formato `DD/MM/RR` via `TO_DATE`.
- Se um novo exemplo for necessário (ex.: nota com desconto, com moeda
  estrangeira, com devolução), rodar `EXEMPLO_LANCAMENTO_CAB_ITE_SER.sql`
  ajustando os filtros e anexar o novo dump aqui.
