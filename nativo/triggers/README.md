# Triggers Nativas

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  

---

## Contexto

Esta pasta contém triggers nativas do Sankhya. Diferentemente das triggers em `triggers/` (raiz do repositório, código da Spark), estas existem nativamente no ERP — sua estrutura foi extraída direto do banco (via `DBMS_METADATA.GET_DDL`) para referência, revisão de impacto e, quando aplicável, para identificar customizações da Spark. A pasta é versionada para que o `git diff` mostre o que mudou a cada recaptura (ver [`../README.md`](../README.md)).

> **Atenção:** Atualizações do ERP Sankhya podem sobrescrever estas triggers. Revisar após cada atualização de versão.

---

## `TRG_INC_TGFITE`

**Arquivo:** `TRG_INC_TGFITE.SQL`  
**Tabela:** `TGFITE` (itens de nota/movimento)  
**Evento:** `BEFORE INSERT`  
**Escopo:** `FOR EACH ROW`  

**Descrição:** Trigger nativa de inclusão de item de nota, com lógicas de validação e controle de estoque. Executa antes de cada inserção de linha em `TGFITE`.

**Responsabilidades:**

1. **Validação de agrupamento mínimo (`AGRUPMIN`):** Verifica se a quantidade inserida respeita o agrupamento mínimo definido para o produto. Calcula o resto da divisão e ajusta se necessário.

2. **Controle de lote:** Verifica o tamanho de lote padrão (`TPRLPA`) e valida se a quantidade está dentro dos limites.

3. **Validação de estoque:** Consulta o grupo do produto para verificar o tipo de validação de estoque (`VALEST`).

4. **Validação de CFOP:** Verifica se o CFOP configurado na TOP está correto para a operação de entrada ou saída.

5. **Validações de IPI:** Verifica se o produto possui IPI em vendas (`P_TEMIPIVENDA`) e compras (`P_TEMIPICOMPRA`) para aplicação correta.

6. **Controle de reserva:** Verifica se a TOP exige reserva de estoque (`P_RESERVADO_TOP`).

**Variáveis declaradas (principais):**

| Variável | Tipo | Uso |
|---|---|---|
| `P_VALEST` | `TGFGRU.VALEST%TYPE` | Tipo de validação de estoque do grupo |
| `P_AGRUPMIN` | `FLOAT` | Agrupamento mínimo do produto |
| `P_TAMLOTEPAD` | — | Tamanho de lote padrão |
| `P_CFOSAIDA` | `TGFTOP.CODCFO_SAIDA%TYPE` | CFOP de saída configurado na TOP |
| `P_CFOENTRADA` | `TGFTOP.CODCFO_ENTRADA%TYPE` | CFOP de entrada configurado na TOP |
| `P_RESERVADO_TOP` | `CHAR` | Indica se a TOP exige reserva |

### Customização da Spark — pendente de delimitação

O cabeçalho do arquivo diz que a trigger tem "customizações adicionadas pela Spark" (agrupamento mínimo, estoque por TOP, CFOP de transferência, IPI), mas **o arquivo não marca quais linhas são da Spark**: não há comentário `-- SPARK`, e as demais referências a OS no cabeçalho (717072, 748512, 756293, 823336, 902640, 954116) são numeração de chamados da Sankhya. Além disso, `AGRUPMIN`, `VALIDAAGRUPMIN` e a lógica de CFOP de transferência são recursos nativos do ERP — então a lista do cabeçalho pode descrever o que a trigger *faz*, e não o que a Spark *alterou*. O histórico do git não ajuda: o arquivo nunca foi versionado antes.

**Consequência:** hoje não é possível reaplicar a customização depois de um upgrade que sobrescreva a trigger — o único jeito seria reler o arquivo inteiro e adivinhar.

**Para fechar a pendência (precisa de quem conhece a alteração):**

1. Obter a versão original do fabricante da `TRG_INC_TGFITE` — pelo suporte Sankhya, por um ambiente sem customização, ou pelo `DBA_SOURCE`/backup anterior à alteração, se existir.
2. Gerar o diff entre a original e a atual e salvar como `triggers/patches/TRG_INC_TGFITE.patch` (pasta versionada, código da Spark) — é esse patch que se reaplica após cada upgrade.
3. Marcar as linhas alteradas no arquivo com `-- SPARK:` e corrigir o cabeçalho para listar apenas o que foi realmente alterado.
4. Atualizar esta seção e o §14 de `triggers/README.md`.

Até lá, vale a regra do "Como Manter" abaixo: comparar com o banco após cada upgrade e tratar qualquer diferença como suspeita.

---

## `TRG_INC_TGFVAR`

**Arquivo:** `TRG_INC_TGFVAR.SQL`
**Tabela:** `TGFVAR` (variações de nota — atendimento/entrega parcial)
**Evento:** `BEFORE INSERT`
**Escopo:** `FOR EACH ROW`
**Customização Spark:** Nenhuma — trigger 100% nativa, documentada aqui só por referência/impacto.

**Descrição:** Processa a inclusão de uma "nota de variação" (mecanismo nativo do Sankhya para atendimento/entrega/devolução parcial de um item). Dispara com `WHEN ((NEW.SEQUENCIA <> 0) AND (NEW.SEQUENCIAORIG <> 0) AND (NEW.QTDATENDIDA <> 0))`.

**Responsabilidades:**

1. Sai cedo durante sincronização de dados (`STP_GET_ATUALIZANDO`) ou quando `Fpodevalidar('TGFVAR')` indica que a validação não deve rodar.
2. Valida que a nota atual e a nota de origem (`NUNOTAORIG`/`SEQUENCIAORIG`) existem em `TGFITE`/`TGFCAB`.
3. **Atualiza o item de origem em `TGFITE`** (`QTDENTREGUE` e `QTDFIXADA`) proporcionalmente à quantidade atendida (`:NEW.QTDATENDIDA`) — esse é o único ponto em que esta trigger toca `TGFITE`, e é ele quem dispara, em cascata, qualquer trigger de `TGFITE` (ex.: `TRG_VAL_CSTIPI_SPARK`) para o item de origem.
4. Duplica/realoca compromissos financeiros/orçamentários em `TGMTRA` quando a nota de origem tem compromisso vinculado (`TIPO = 'C'`), incluindo troca de `NUMTRANSF` via `SNK_VERIFICA_PK_TGMTRA`/`STP_TROCA_NUMTRANSF` quando necessário.

**Observação de incidente (Set/2026):** o `UPDATE TGFITE` do item 3 acima **não escreve em `CSTIPI`** — ele preserva o valor já existente no item de origem. Se esse item tiver `CSTIPI` nulo/zero, qualquer trigger de validação de `TGFITE` sem cláusula `OF <coluna>` (ex.: `TRG_VAL_CSTIPI_SPARK`, quando ativa) dispara sobre essa atualização de rotina, mesmo sem nenhuma mudança de CST IPI envolvida. Ver `triggers/README.md` §15 para o caso completo.

---

## Como Manter

1. Após cada atualização do Sankhya, comparar cada arquivo desta pasta com a trigger vigente no banco via: `SELECT TEXT FROM DBA_SOURCE WHERE NAME = '<NOME_DA_TRIGGER>' ORDER BY LINE` (ex.: `TRG_INC_TGFITE`, `TRG_INC_TGFVAR`)
2. Identificar se as customizações (quando houver) ainda estão presentes
3. Se a atualização sobrescreveu, reaplicar as customizações e atualizar este arquivo
4. Antes de qualquer `CREATE OR REPLACE` numa trigger nativa, confirmar `STATUS` em `USER_TRIGGERS` — o Oracle sempre recria como `ENABLED`, então uma trigger nativa desativada por algum motivo de negócio pode ser reativada sem querer (ver `triggers/README.md` §15)
5. Commitar a nova versão com a nota da versão do ERP no commit message
