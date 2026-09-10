# Catálogo de Views

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de views:** 6  
**Banco:** Oracle PL/SQL  

---

## Catálogo

### `VGFEST`

**Arquivo:** `VGFEST.sql`

**Objetivo:** Consolidar estoque disponível por SKU para produtos ativos de revenda/venda.

**Colunas:**

| Coluna | Tipo | Descrição |
|---|---|---|
| `SKU` | `NUMBER` | Código do produto (`CODPROD`) |
| `ESTO` | `NUMBER` | Estoque disponível consolidado (0 se ausente em `TGFEST`) |

**Tabelas fonte:** `TGFPRO`, `TGFEST`

**Filtros ativos:**
- Empresa: `1` | Local de estoque: `109`
- Apenas produtos ativos: `PRO.ATIVO = 'S'`
- Uso de produto: `'R'` (Revenda) ou `'V'` (Venda)

**Uso:** Queries de BI de estimativa de estoque, painel de produção e relatórios de planejamento.

---

### `VW_CTE_AUTORIZADOS`

**Arquivo:** `VGFIXN.SQL` (nome do arquivo baseado na tabela fonte `TGFIXN`; a view criada é `VW_CTE_AUTORIZADOS`)

**Objetivo:** Retornar CT-e autorizados que possuem referência a NF-e, extraindo `CODTIPOPER` da nota referenciada via XML.

**Colunas:**

| Coluna | Descrição |
|---|---|
| `NRARQUIVO` | Número do arquivo XML importado |
| `NUMNOTA` | Número da nota fiscal |
| `NUNOTA` | Número único da nota |
| `CHAVEACESSO` | Chave de acesso do CT-e |
| `DHIMPORT` | Data/hora de importação |
| `DHPROCESS` | Data/hora de processamento |
| `XML` | XML completo do CT-e |
| `TIPO` | Tipo do documento (`'C'` = CT-e) |
| `CODUSUIMP` | Usuário que importou |
| `CODUSUPROC` | Usuário que processou |
| `CODTIPOPER` | Tipo de operação do CT-e |
| `SITUACAOCTE` | Situação do CT-e (`'A'` = Autorizado) |
| `ULTEVEDFE` | Último evento DFe registrado |
| `DOCSREF` | XML de documentos referenciados |
| `CHAVEACESSO_REF` | Chave de acesso da NF-e referenciada (extraída do XML) |
| `CODTIPOPER_NFE` | Tipo de operação da NF-e de referência |
| `NR_SEQUENCIA` | Sequência do documento no XML |
| `CNPJREMET` | CNPJ do remetente |
| `CNPJDEST` | CNPJ do destinatário |
| `CFOPXML` | CFOP extraído do XML |

**Tabelas fonte:** `TGFIXN`, `TGFCAB`

**Filtros ativos:**
- Apenas CT-e: `TIPO = 'C'`
- Apenas autorizados: `SITUACAOCTE = 'A'`
- Apenas registros com `DOCSREF` preenchido (referência a NF-e no XML)

**Uso:** Regra de processamento de CT-e (`formulas/regra_processa_xml_cte.sql`) e evento `EVP_CLASSIFICACTE_SPARK` para classificação automática do CT-e.

---

### `VGFNFE`

**Arquivo:** `VGFNFE.sql`

**Objetivo:** Retornar NF-e ativas de vendas com XML do cliente para integração com sistemas externos (site/marketplace).

**Colunas:**

| Coluna | Descrição |
|---|---|
| `NUNOTA` | Número único da nota |
| `CODVEND` | Código do vendedor |
| `PEDIDOEXTERNO` | Número do pedido no sistema externo |
| `AD_WAREHOUSEID` | Identificador do armazém externo |
| `CHAVENFE` | Chave de acesso da NF-e |
| `NOTAXML` | XML da NF-e para o cliente (`AD_NOTAXML`) |

**Tabelas fonte:** `TGFCAB`

**Filtros ativos:**
- Apenas vendas: `TIPMOV = 'V'`
- Vendedor: `CODVEND = 42`
- NF-e com protocolo de autorização preenchido
- Emissão nos **últimos 4 dias**

**Uso:** Integração com o site e marketplace da Spark para informar chave NF-e ao cliente externo.

---

---

### `VGFSALDOMRP`

**Arquivo:** `VGFSALDOMRP.sql`

**Objetivo:** Consolidar, por mês de referência e produto, a quantidade prevista (meta) contra a quantidade a produzir das ordens de produção, retornando o saldo.

**Colunas:** `DTREF` (mês, truncado), `CODPROD`, `QTDPREV` (meta de `AD_TGFMET`, `CODMETA = 3`, líquida de `QTDREDMET`), `QTDPRODUZIR` (das OPs em `TPRIPROC`/`TPRIPA`, status `A`/`F`/`P2`), `SALDO` (`QTDPREV - QTDPRODUZIR`).

**Tabelas fonte:** `TPRIPROC`, `TPRIPA`, `TGFPAL`, `TPRMPS`, `TPRIMPS`, `AD_TGFMET`

**Uso:** Componentes BI de cronograma/saldo de produção e planejamento de MP.

---

### `AD_VWMELIFATVIX` / `AD_VWMELIFATVIX2`

**Arquivos:** `AD_VWMELIFATVIX.sql`, `AD_VWMELIFATVIX2.sql`

**Objetivo:** Listar NF-e de venda de marketplace (Mercado Livre) autorizadas nos últimos 7 dias que ainda **não** têm etiqueta gerada, para disparar a impressão/integração de etiqueta de expedição.

**Colunas:** `ID` (fixo `0`), `NUMNOTA`, `NUNOTA`, `SERIENOTA`, `DTFATUR`, `STATUSNFE`, `AD_PEDIDOMKTPLACE`, `AD_SHIPID` (de `AD_MELISHIPID`), `CHAVENFE`, `CODVEND`, `CODEMP`, `NOTAXML` (de `TGFNFE.XMLENVCLI`).

**Tabelas fonte:** `TGFCAB`, `TGFNFE`; exclui notas já presentes em `TSIATA` com descrição contendo `Etiqueta`.

**Diferença entre as duas:** filtro de vendedor/empresa — `AD_VWMELIFATVIX` usa `CODVEND = 5`; `AD_VWMELIFATVIX2` usa `CODVEND = 43`. Vendedor/empresa fixos no código — ajustar conforme o ambiente.

---

## Observações Gerais

- Todas as views usam `CREATE OR REPLACE` — seguras para reexecução.
- `VGFNFE` tem o `CODVEND = 42` fixo no código — ajustar conforme necessidade em outros ambientes.
- Alterações nas tabelas fonte podem invalidar as views; revisar após mudanças de schema no Sankhya.
