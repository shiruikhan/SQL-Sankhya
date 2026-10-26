# Integração Contábil — Audicon

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Sistema externo:** Audicon (sistema de contabilidade)  

---

## Objetivo

Esta pasta contém procedures de geração de contas contábeis para integração com o sistema Audicon. As procedures criam no plano de contas (`TCBPLA`) uma conta analítica por parceiro — cliente ou fornecedor — que movimentou o financeiro e ainda não tem conta própria, e gravam o vínculo no cadastro do parceiro.

> **Autoria:** rotinas criadas pela própria Audicon em 23/01/2026 (comentário no código-fonte). Não seguem o padrão de cabeçalho/log de erros da Spark.

---

## Catálogo

### `STP_CRIA_CTACTBCLI_AUDICON`

**Arquivo:** `STP_CRIA_CTACTBCLI_AUDICON.sql`  
**Tipo:** Stored Procedure (sem parâmetros)  

**Descrição:** Percorre os parceiros com títulos **a receber** (`TGFFIN.RECDESP = 1`) desde 01/01/2024, cuja TOP tenha contabilização com conta `PARC1` (`TGFCTB`), e que ainda não tenham conta contábil (`TGFPAR.CODCTACTB IS NULL` e nenhuma `TCBPLA` com o código gerado). Para cada um:

- insere a conta em `TCBPLA` — código `LPAD(CODPARC, 5, 1000)`, máscara `1.1.03.01.001.<CODPARC>`, grau 6, conta-pai 169, grupo `01`, descrição = razão social (40 caracteres, `&` → `E`);
- atualiza `TGFPAR.CODCTACTB2` com o código criado;
- insere o vínculo com a conta referencial em `TCBCTR` (`1.01.02.02.01`, ou `1.01.02.02.02` para parceiro estrangeiro).

Títulos de TOPs com `TIPMOV = 'I'` só entram se a natureza não tiver `AD_TIPOCTBZ = 'S'`.

**Tabelas lidas:** `TGFFIN`, `TGFPAR`, `TGFTOP`, `TGFCTB`, `TGFNAT`, `TCBPLA`  
**Tabelas gravadas:** `TCBPLA`, `TCBCTR`, `TGFPAR` (`CODCTACTB2`)

---

### `STP_CRIA_CTACTBFOR_AUDICON`

**Arquivo:** `STP_CRIA_CTACTBFOR_AUDICON.sql`  
**Tipo:** Stored Procedure (sem parâmetros)  

**Descrição:** Mesma lógica de `STP_CRIA_CTACTBCLI_AUDICON`, aplicada a fornecedores. Diferenças:

| Item | Cliente (`CLI`) | Fornecedor (`FOR`) |
|---|---|---|
| Títulos considerados | `RECDESP = 1` | `RECDESP = -1` |
| Conta de contabilização da TOP | `PARC1` | `PARC2` |
| Filtro de parceiro sem conta | `TGFPAR.CODCTACTB IS NULL` | `TGFPAR.CODCTACTB2 IS NULL` |
| Código da conta | `LPAD(CODPARC, 5, 1000)` | `LPAD(CODPARC, 5, 2000)` |
| Máscara | `1.1.03.01.001.<CODPARC>` | `2.1.01.01.001.<CODPARC>` |
| Conta-pai / grupo | 169 / `01` | 194 / `02` |
| Conta referencial (nacional / estrangeiro) | `1.01.02.02.01` / `1.01.02.02.02` | `2.01.01.03.01` / `2.01.01.03.02` |

**Tabelas lidas:** `TGFFIN`, `TGFPAR`, `TGFTOP`, `TGFCTB`, `TGFNAT`, `TCBPLA`  
**Tabelas gravadas:** `TCBPLA`, `TCBCTR`, `TGFPAR` (`CODCTACTB2`)

---

## Observações

- Execução manual (ou agendada) no ERP, após o cadastro/movimentação de novos parceiros. O resultado deve ser validado no módulo de contabilidade do Sankhya antes de exportar para o Audicon.
- **Duplicidade:** a própria consulta evita recriar a conta (`NOT EXISTS` em `TCBPLA` pelo código gerado), então reexecutar é seguro.
- **Atenção — divergência no código:** as duas procedures gravam em `TGFPAR.CODCTACTB2`, mas a de clientes filtra por `TGFPAR.CODCTACTB IS NULL`. Confirmar com a Audicon se a versão de clientes deveria gravar em `CODCTACTB`.
- Há `COMMIT` após cada `INSERT`/`UPDATE` dentro do laço, e não há tratamento de exceção — uma falha no meio deixa os parceiros anteriores já processados.
