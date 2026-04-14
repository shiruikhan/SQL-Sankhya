# Catálogo de Classes Java

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**SDK:** Sankhya Extensions (SankhyaW-extensions.jar / mge-modelcore)  
**Java:** SE 8 (compatível com JVM do Sankhya)  

---

## Visão Geral

As classes Java são utilizadas em dois tipos de extensão do Sankhya:

| Tipo | Interface implementada | Registro no ERP |
|---|---|---|
| **Botão de Ação** | `AcaoRotinaJava` | Cadastrado em *Botões de Ação* do Sankhya, associado a uma tela |
| **Listener de Evento** | Implementação direta | Configurado em *Eventos* no CAC ou via `regrasCAC.xml` |

Os arquivos `.class` compilados devem ser empacotados em `.jar` e deployados no servidor Sankhya. As queries SQL auxiliares (`.sql` em `util/`) são executadas pelo código Java via `JdbcWrapper`.

---

## Catálogo de Classes

### `CotaFrete.java`

**Pacote:** `botaoAcao`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação  

**Descrição:** Consulta uma API externa de cotação de frete via HTTP, a partir dos dados da nota selecionada no Sankhya. Calcula o frete com base no peso, volume e CEP de destino, e atualiza o valor na nota.

**Dependências externas:** `HttpURLConnection`, `Base64` (autenticação HTTP Basic)  
**Tabelas acessadas:** `TGFCAB`, `TGFPAR` (para buscar dados da nota e do destinatário)  
**Retorno:** Atualiza campo de frete na nota — exibe mensagem de sucesso ou erro ao usuário.

---

### `GerarTransferencia.java`

**Pacote:** `br.com.spark.transferencia`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação  

**Descrição:** Gera uma nota de transferência entre empresas diretamente via JAPE (API de persistência do Sankhya). Cria o cabeçalho (`TGFCAB`) e os itens (`TGFITE`) programaticamente, sem passar pelo fluxo de tela padrão.

**Dependências:** `JAPE`, `MGEModelException`, `CACHelper`, `ImpostosHelpper`, `BarramentoRegra`  
**Utilidades:** `TransferenciaUtils` (cálculos e validações auxiliares)  
**Arquivo original:** `GerarTransferenciaOriginal.java` (backup da versão antes da refatoração)

---

### `GerarTransferenciaOriginal.java`

**Tipo:** Referência / Backup  
**Descrição:** Versão original do `GerarTransferencia` antes de refatorações. Mantida para referência histórica e rollback em caso de regressão.

---

### `RecalFinanceiroEve.java`

**Tipo:** Evento  
**Descrição:** Realiza recálculo de lançamentos financeiros vinculados a uma nota. Acionado como evento de confirmação ou pós-confirmação de nota no Sankhya.

---

### `recalcpreco.java`

**Tipo:** Botão de Ação  
**Descrição:** Recalcula o preço unitário dos itens de uma nota com base na tabela de preço vigente. Utilizado para corrigir itens inseridos manualmente com preço incorreto.

---

## Enumerações e Utilitários

### `enuns/Tipo.java`

**Tipo:** Enumeração (`enum`)  
**Descrição:** Define os tipos de operação de transferência entre empresas.

| Constante | Significado |
|---|---|
| *(ver código)* | Tipos de transferência suportados pelo `GerarTransferencia` |

---

### `listeners/DelecaoTransfencia.java`

**Tipo:** Listener  
**Descrição:** Intercepta a exclusão de uma transferência entre empresas. Valida se a exclusão é permitida (ex: nota já confirmada) e executa limpeza de dados dependentes se necessário.

---

### `util/TransferenciaUtils.java`

**Tipo:** Classe utilitária  
**Descrição:** Métodos auxiliares reutilizados pelo processo de transferência entre empresas: cálculos de totais, validações de campos, busca de dados complementares.

**Queries SQL associadas (executadas pelo utilitário):**

| Arquivo | Descrição |
|---|---|
| `util/queItem.sql` | Busca itens da nota de origem para a transferência |
| `util/queSerie.sql` | Busca séries vinculadas aos itens para controle de série na transferência |

---

## Arquivos de Regras XML

| Arquivo | Descrição |
|---|---|
| `regrasCAC.xml` | Configuração de regras de negócio do CAC para eventos Java — define quais eventos disparam quais classes |
| `regrasConfirmacaoCAC.xml` | Regras específicas para eventos de confirmação no CAC |

---

## Dependências

Todas as dependências estão em `../libs_sankhya/`. As principais utilizadas pelas classes:

| JAR | Uso |
|---|---|
| `SankhyaW-extensions.jar` | `AcaoRotinaJava`, `ContextoAcao`, `Registro` |
| `mge-modelcore-*.jar` | `MGEModelException`, `AuthenticationInfo`, `EntityFacadeFactory` |
| `mgecom-model-*.jar` | `CACHelper`, `BarramentoRegra`, `ImpostosHelpper` |
| `jape.jar` / `jape-*.jar` | `JapeSession`, `JdbcWrapper`, `DynamicVO`, `EntityVO` |

---

## Como Deployar

1. Compilar as classes com o classpath apontando para os JARs em `libs_sankhya/`
2. Empacotar em `.jar` (sem dependências — as libs já estão no servidor Sankhya)
3. Fazer upload do `.jar` em *Administração → Extensões* no Sankhya
4. Cadastrar os botões de ação ou vincular os listeners conforme `regrasCAC.xml`
