# Integração Contábil — Audicon

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Sistema externo:** Audicon (sistema de contabilidade)  

---

## Objetivo

Esta pasta contém procedures de geração de contas contábeis para integração com o sistema Audicon. As procedures criam automaticamente as contas contábeis correspondentes a clientes e fornecedores no plano de contas, a partir dos dados do cadastro de parceiros do Sankhya.

---

## Catálogo

### `STP_CRIA_CTACTBCLI_AUDICON`

**Arquivo:** `STP_CRIA_CTACTBCLI_AUDICON.sql`  
**Tipo:** Stored Procedure  

**Descrição:** Cria conta contábil no plano de contas para clientes novos ou não cadastrados, permitindo a integração contábil via Audicon. Consulta o cadastro de parceiros do Sankhya e gera a estrutura de conta necessária no módulo contábil.

**Tabelas envolvidas:** `TGFPAR` (parceiros — clientes), tabelas do módulo contábil Sankhya (`TSICCB` ou equivalente)

**Quando usar:** Executar ao cadastrar novos clientes ou ao realizar a carga inicial de contas contábeis para clientes existentes.

---

### `STP_CRIA_CTACTBFOR_AUDICON`

**Arquivo:** `STP_CRIA_CTACTBFOR_AUDICON.sql`  
**Tipo:** Stored Procedure  

**Descrição:** Mesma lógica de `STP_CRIA_CTACTBCLI_AUDICON`, porém aplicada a fornecedores. Cria a conta contábil no módulo contábil Sankhya para viabilizar a integração com o Audicon.

**Tabelas envolvidas:** `TGFPAR` (parceiros — fornecedores), tabelas do módulo contábil

**Quando usar:** Executar ao cadastrar novos fornecedores ou na carga inicial de contas para fornecedores existentes.

---

## Observações

- As procedures devem ser executadas manualmente via botão de ação ou scheduler no ERP, após o cadastro de novos parceiros.
- O resultado da execução deve ser validado no módulo de contabilidade do Sankhya antes de exportar para o Audicon.
- Em caso de parceiro já com conta criada, verificar se a procedure possui tratamento de duplicidade (chave única).
