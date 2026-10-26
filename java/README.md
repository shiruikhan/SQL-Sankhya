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
| **Evento Programável / Listener** | `EventoProgramavelJava` | Cadastrado como *Evento Programável* (extensão) vinculado à entidade monitorada (ex.: `CabecalhoNota`/`TGFCAB`) |

Os arquivos `.class` compilados devem ser empacotados em `.jar` e deployados no servidor Sankhya. As queries SQL auxiliares (`.sql` em `transferencia/util/`) são carregadas por `TransferenciaUtils` via `NativeSql.loadSql`.

### Estrutura da pasta

As pastas agrupam as classes **por domínio**. A declaração `package` de cada classe **não** foi alterada — o botão de ação/evento no ERP é cadastrado pelo nome completo da classe (ex.: `botaoAcao.CotaFreteMultiTransp`), então mudar o pacote exige recadastrar no Sankhya.

```
java/
├── frete/                      package botaoAcao — cotação de frete multi-transportadora
│   ├── CotaFreteMultiTransp    botão de ação (o que deve estar cadastrado no ERP)
│   ├── *Cotador, CotadorTransportadora, DTOs, FreteUtils
│   └── legado/                 CotaFrete, CotaFreteRodonaves (substituídos, só referência)
├── transferencia/              package br.com.spark.transferencia — transferência entre empresas
│   ├── GerarTransferencia      botão de ação
│   ├── enuns/                  Tipo (package br.com.spark.transferencia.enuns)
│   ├── listeners/              DelecaoTransfencia (package br.com.spark.transferencia.listeners)
│   ├── util/                   TransferenciaUtils (package br.com.spark.transferencia.util) + recursos (.sql, .xml)
│   └── legado/                 GerarTransferenciaOriginal (backup pré-refatoração; package br.com.spark.transferencia)
├── etiquetas/                  package botaoAcao — ImprimirEtiquetasv2
└── financeiro/                 package br.com.dm.valida.cte — RecalFinanceiroEve
```

Como os pacotes não seguem as pastas, as classes de `frete/legado/` continuam em `botaoAcao` e `GerarTransferenciaOriginal` continua em `br.com.spark.transferencia` (não em `...legado`).

Os `.sql` e `.xml` em `transferencia/util/` ficam junto da `TransferenciaUtils` porque são carregados relativos a essa classe (`NativeSql.loadSql(TransferenciaUtils.class, ...)` / `BarramentoRegra.build(TransferenciaUtils.class, ...)`) — no `.jar` precisam estar em `br/com/spark/transferencia/util/`.

Arquivos `.class` não são versionados (`*.class` no `.gitignore`); compile localmente para gerar o `.jar`.

---

## Catálogo de Classes

### `frete/CotaFreteMultiTransp.java`

**Pacote:** `botaoAcao`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação  

**Descrição:** Botão único de cotação de frete, que **substitui** `CotaFrete.java` (Braspress) e `CotaFreteRodonaves.java` (Rodonaves) — ver notas de depreciação abaixo. Para cada linha selecionada, lê o cabeçalho de `AD_TGSCTF` (incluindo `APIDEST`, já preenchida pela trigger `TRG_COTAFRETE_SPARK` a partir de `TGFCAB.CODPARCTRANSP`) e despacha para a estratégia da transportadora correspondente:

| `APIDEST` | Transportadora | Classe |
|---|---|---|
| `B` | Braspress | `BraspressCotador` |
| `R` | Rodonaves | `RodonavesCotador` |

As validações (CNPJ/CPF, CEPs, MODAL, TIPFRETE, valores/peso/volumes), a gravação de `AD_TGSCTF.VLRFRETE`/`TGFCAB.VLRFRETE`/`AD_ESTENTR` e o recálculo de impostos via `ImpostosHelpper` são **únicos para todas as transportadoras** — lógica copiada fielmente do `CotaFrete.java` de produção, agora também aplicada a cotações Rodonaves (que antes nunca tocavam `TGFCAB` nem recalculavam impostos). Cada `Cotador` cuida apenas de autenticação, endpoint, payload e parse de resposta da sua própria API.

**Classes de apoio (mesmo pacote `botaoAcao`):**
- `CotadorTransportadora` — interface da estratégia por transportadora.
- `DadosCotacaoLinha` / `PacoteDimensao` — DTOs de entrada (cabeçalho de `AD_TGSCTF` + pacotes de `AD_TGSLCB`).
- `CotacaoResultado` — DTO de saída (valor do frete, prazo opcional, detalhe opcional para a mensagem de retorno).
- `BraspressCotador` / `RodonavesCotador` — implementações extraídas de `CotaFrete.java`/`CotaFreteRodonaves.java`, sem alteração de comportamento na parte de cotação.
- `FreteUtils` — helpers compartilhados (antes duplicados nos dois botões antigos).

**Tabelas acessadas:** `AD_TGSCTF`, `AD_TGSLCB`, `AD_TGSAPI`, `TGFCAB`, `TGFPAR`, `TSICID`, `TSIUFS`  
**Alteração de schema:** `AD_TGSCTF.APIDEST` já existia e já identifica a transportadora por linha (nenhuma mudança necessária). Foi adicionado `AD_TGSAPI.ENDPOINTPRAZO` (URL do endpoint de prazo de entrega da Rodonaves) — ver `tables/AD_TGSAPI.SQL`.  
**Prazo de entrega (`TGFCAB.AD_ESTENTR`):** a Braspress retorna prazo estimado na própria resposta da cotação. A Rodonaves expõe isso num endpoint separado (`POST .../prazo-entrega`, configurado em `AD_TGSAPI.ENDPOINTPRAZO`), que recebe nome de cidade + UF (não CEP): origem fixa (`SACRAMENTO`/`MG`, matriz da empresa) e destino resolvido do parceiro da nota — `TGFCAB.CODPARCREDESPACHO` quando preenchido, senão `TGFCAB.CODPARC` (`→ TGFPAR.CODCID → TSICID.NOMECID/UF → TSIUFS.UF`). Essa busca é *best-effort*: qualquer falha (config ausente, parceiro sem cidade cadastrada, erro HTTP) não impede a gravação do valor do frete — só deixa o prazo em branco e acrescenta um aviso na mensagem de retorno.  
**Aviso operacional:** após o deploy do `.jar`, é preciso reapontar (ou cadastrar) o botão de ação no Sankhya para a classe `CotaFreteMultiTransp` e decidir se os dois botões antigos ficam ocultos/desativados na tela — isso é feito na UI do ERP, fora deste repositório.

---

### `frete/legado/CotaFrete.java` — ⚠️ Substituído por `CotaFreteMultiTransp.java`

**Pacote:** `botaoAcao`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação (mantido apenas como referência histórica; não é mais o botão a cadastrar)

**Descrição:** Cotação de frete via API REST da **Braspress** para os registros selecionados de `AD_TGSCTF`. Monta o payload JSON (remetente, destinatário, modal, CEPs, peso, volumes e cubagem de `AD_TGSLCB`), chama o endpoint configurado em `AD_TGSAPI`, grava `VLRFRETE` em `AD_TGSCTF` e `TGFCAB` (com prazo em `TGFCAB.AD_ESTENTR`) e recalcula impostos via `ImpostosHelpper`.

**Dependências externas:** `HttpURLConnection`, `Base64` (autenticação HTTP Basic, credenciais em `AD_TGSAPI`)  
**Tabelas acessadas:** `AD_TGSCTF`, `AD_TGSLCB`, `AD_TGSAPI`, `TGFCAB`  
**Retorno:** mensagem de sucesso ou erro por registro ao usuário.

---

### `frete/legado/CotaFreteRodonaves.java` — ⚠️ Substituído por `CotaFreteMultiTransp.java`

**Pacote:** `botaoAcao`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação (mantido apenas como referência histórica; não é mais o botão a cadastrar)

**Descrição:** Cotação de frete via API REST da Rodonaves para os embarques selecionados. Fluxo por registro em `AD_TGSCTF`: (1) autentica via OAuth2 no `ENDPOINTAUTH` de `AD_TGSAPI` e obtém Bearer token; (2) resolve `OriginCityId`/`DestinationCityId` chamando `ENDPOINTCIDADE` com os CEPs (usados só em memória); (3) monta payload JSON com remetente, destinatário, peso, valor e dimensões (`AD_TGSLCB`) e chama `ENDPOINT` (gera-cotação); (4) grava `VLRFRETE` em `AD_TGSCTF`.

**Tabelas acessadas:** `AD_TGSCTF`, `AD_TGSLCB`, `AD_TGSAPI`  
**API externa:** Rodonaves — OAuth2 Bearer token (`AUTH_TYPE = 'DEV'`)  
**Observação:** a atualização de `TGFCAB` e o recálculo de impostos (`ImpostosHelpper`) estavam **desativados** no código (bloco comentado em `processarLinha`) enquanto a integração estava em homologação; esse bloco nunca foi reaproveitado — `CotaFreteMultiTransp` usa a lógica fiscal do `CotaFrete.java` para todas as transportadoras. Ver memória `integracao-rodonaves-status`.

---

### `transferencia/GerarTransferencia.java`

**Pacote:** `br.com.spark.transferencia`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação  

**Descrição:** Gera notas de transferência entre empresas a partir dos pedidos de venda selecionados (`TIPMOV = 'P'`, conferência finalizada e sem transferência prévia), via JAPE/`CACHelper`, em 5 etapas com transação própria cada: (1) notas de saída a partir do modelo `CabecalhoNotaModelo` 278268; (2) cálculo de impostos das saídas, incluindo IBS/CBS; (3) notas de entrada espelhando as saídas (modelo 278275); (4) impostos das entradas; (5) confirmação das saídas, lote NF-e (`ServicosNFeHelper2`) e, se o lote foi gerado, confirmação das entradas. Vincula pedido, saída e entrada em `TGFCAB.AD_NUNOTASAI`/`AD_NUNOTAENT` e retorna links das notas geradas e pendências.

**Parâmetros do botão:** `P_CODEMPORIG`, `P_CODEMPDEST`, `P_CODLOCALORIG`, `P_CODLOCALDEST`  
**Dependências:** `JAPE`, `MGEModelException`, `CACHelper`, `BarramentoRegra`  
**Utilidades:** `TransferenciaUtils` (validações, montagem de cabeçalho/itens, séries, impostos, confirmação e lote)  
**Arquivo original:** `legado/GerarTransferenciaOriginal.java` (backup da versão antes da refatoração)

---

### `transferencia/legado/GerarTransferenciaOriginal.java`

**Pacote:** `br.com.spark.transferencia`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Referência / Backup (`@deprecated` — não usar em produção)  
**Descrição:** Versão original do `GerarTransferencia` antes da refatoração para `TransferenciaUtils` e transações por etapa. Usava a tabela intermediária `AD_GERARTRANSF`, gerava saída e entrada numa única sessão sequencial e não calculava impostos entre as etapas. Mantida para referência histórica e rollback em caso de regressão.

---

### `etiquetas/ImprimirEtiquetasv2.java`

**Pacote:** `botaoAcao`  
**Interface:** `AcaoRotinaJava`  
**Tipo:** Botão de Ação  
**Descrição:** Para cada nota selecionada (`NUNOTA`), conta as séries em `TGFSER` e gera um PDF único concatenando os relatórios de etiqueta cadastrados no Sankhya nº 138, 142, 143, 144, 145 e 146 (parâmetros `NUNOTA` e `PDIR_MODELO`) — o 1º sempre, e os demais conforme a quantidade de séries passa de 50, 100, 150, 200 e 250 (faixas de 50 etiquetas por relatório). Devolve um link "Clique aqui para Visualizar." para o arquivo na sessão. Quais `.jrxml` correspondem a esses números de relatório: a confirmar (provavelmente as faixas de `reports/5 - Etiquetas de Produto/`).

---

### `financeiro/RecalFinanceiroEve.java`

**Pacote:** `br.com.dm.valida.cte`  
**Interface:** `EventoProgramavelJava`  
**Tipo:** Evento Programável (entidade `CabecalhoNota` / `TGFCAB`)  
**Descrição:** No `beforeUpdate` de `TGFCAB`, durante a confirmação (atributo de sessão `AtributosRegras.CONFIRMANDO`), quando `AD_AGDIMPCTE` muda de nulo/`N` para `S`, refaz o financeiro da nota via `CentralFinanceiro.inicializaNota` + `refazerFinanceiro`. Os demais eventos estão vazios.

---

## Enumerações e Utilitários

### `transferencia/enuns/Tipo.java`

**Pacote:** `br.com.spark.transferencia.enuns`  
**Tipo:** Enumeração (`enum`)  
**Descrição:** Tipos de movimento do fluxo de transferência; cada constante carrega o `TIPMOV` correspondente (`getOpcao()`). Usado por `TransferenciaUtils.salvarOrigem` para gravar os vínculos.

| Constante | Significado |
|---|---|
| `PEDIDO` | Pedido de venda de origem (`TIPMOV = 'P'`) |
| `SAIDA` | Nota de saída da transferência (`TIPMOV = 'V'`) |
| `ENTRADA` | Nota de entrada da transferência (`TIPMOV = 'C'`) |

---

### `transferencia/listeners/DelecaoTransfencia.java`

**Pacote:** `br.com.spark.transferencia.listeners`  
**Interface:** `EventoProgramavelJava`  
**Tipo:** Evento Programável / Listener (entidade `CabecalhoNota` / `TGFCAB`)  
**Descrição:** Controla a exclusão das notas vinculadas pela transferência (`AD_NUNOTAENT` / `AD_NUNOTASAI`). `beforeDelete`: bloqueia a exclusão se a entrada correlata estiver confirmada e no Livro de ICMS (`TGFLIV`), ou se a saída correlata estiver confirmada. `afterDelete`: exclui em cascata a nota vinculada via `JapeWrapper.delete()`. O nome tem erro de digitação ("Transfencia"), mantido por compatibilidade com o cadastro no Sankhya.

---

### `transferencia/util/TransferenciaUtils.java`

**Pacote:** `br.com.spark.transferencia.util`  
**Tipo:** Classe utilitária (métodos estáticos)  
**Descrição:** Suporte ao `GerarTransferencia`: validações de pré-condição (`ehPedido`, `ehGerada`, `validaConferencia`), montagem de cabeçalho e itens (`buildCabecalho`, `buildItens`), cópia de séries (`gerarSerie`), recálculo de impostos incluindo IBS/CBS (`recalcularImpostos`), vínculo pedido/saída/entrada (`salvarOrigem`), confirmação (`confirmaNota` e variantes `_v1`/`_v2`), lote NF-e (`gerarLote`, `gerarLote_v3`, `confirmarETransmitir`) e link HTML da nota (`getLinkNota`).

**Queries SQL associadas (carregadas via `NativeSql.loadSql` em `gerarSerie`):**

| Arquivo | Descrição |
|---|---|
| `transferencia/util/queItem.sql` | Itens (`NUNOTA`, `SEQUENCIA`, `CODPROD`) de uma nota em `TGFITE` |
| `transferencia/util/queSerie.sql` | Séries (`TGFSER`) de um item da nota de origem, para copiar para a nota de destino |

---

## Arquivos de Regras XML

| Arquivo | Descrição |
|---|---|
| `transferencia/util/regrasCAC.xml` | Lista de regras (`BarramentoRegra`) do CAC para inclusão/alteração de notas — preço, controle de acesso, estoque, parceiro, impostos, série, financeiro etc. Nenhuma classe versionada carrega este arquivo hoje (a confirmar se é usado) |
| `transferencia/util/regrasConfirmacaoCAC.xml` | Regras aplicadas na confirmação da nota (WMS, frete, séries, limite de crédito, impostos, NF-e/CT-e etc.); carregado por `TransferenciaUtils.confirmaNota_v2` via `BarramentoRegra.build(TransferenciaUtils.class, ...)` |

---

## Dependências

Todas as dependências estão em `../nativo/libs/` (local, não versionado). As principais utilizadas pelas classes:

| JAR | Uso |
|---|---|
| `SankhyaW-extensions.jar` | `AcaoRotinaJava`, `ContextoAcao`, `Registro`, `EventoProgramavelJava` |
| `mge-modelcore-*.jar` | `MGEModelException`, `AuthenticationInfo`, `EntityFacadeFactory` |
| `mgecom-model-*.jar` | `CACHelper`, `BarramentoRegra`, `ImpostosHelpper` |
| `jape.jar` / `jape-*.jar` | `JapeSession`, `JdbcWrapper`, `DynamicVO`, `EntityVO` |

---

## Como Deployar

1. Compilar as classes com o classpath apontando para os JARs em `nativo/libs/`
2. Empacotar em `.jar` (sem dependências — as libs já estão no servidor Sankhya)
3. Fazer upload do `.jar` em *Administração → Extensões* no Sankhya
4. Cadastrar os botões de ação e os eventos programáveis pelo nome completo da classe (pacote + classe)
