# Catálogo de Views

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de views:** 15  
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
| `NOTAXML` | XML da NF-e para o cliente (`TGFNFE.XMLENVCLI`, via subconsulta) |

**Tabelas fonte:** `TGFCAB`, `TGFITE` (LEFT JOIN + `GROUP BY` — não filtra itens na prática), `TGFNFE`

**Filtros ativos:**
- Apenas vendas: `TIPMOV = 'V'`
- Vendedor: `CODVEND = 42`
- NF-e autorizada (`STATUSNFE = 'A'`) e com `CHAVENFE` preenchida
- Protocolo de autorização (`DHPROTOC`) nos **últimos 4 dias** (`> TRUNC(SYSDATE) - 4`)

**Uso:** Integração com o site e marketplace da Spark para informar chave NF-e ao cliente externo.

---

### `VGFSALDOMRP`

**Arquivo:** `VGFSALDOMRP.sql`

**Objetivo:** Consolidar, por mês de referência e produto, a quantidade prevista (meta) contra a quantidade a produzir das ordens de produção, retornando o saldo.

**Colunas:** `DTREF` (mês, truncado), `CODPROD`, `QTDPREV` (meta de `AD_TGFMET`, `CODMETA = 3`, líquida de `QTDREDMET`), `QTDPRODUZIR` (das OPs em `TPRIPROC`/`TPRIPA`, status `A`/`F`/`P2`, com o produto alternativo resolvido via `TGFPAL` e mês pela data do MPS ou `DHINST`), `SALDO` (`QTDPREV - QTDPRODUZIR`).

**Tabelas fonte:** `TPRIPROC`, `TPRIPA`, `TGFPAL`, `TPRMPS`, `TPRIMPS`, `AD_TGFMET`

**Uso:** Componentes BI de cronograma/saldo de produção e planejamento de MP.

---

### `AD_VWMELIFATVIX` / `AD_VWMELIFATVIX2`

**Arquivos:** `AD_VWMELIFATVIX.sql`, `AD_VWMELIFATVIX2.sql`

**Objetivo:** Listar NF-e de venda de marketplace (Mercado Livre) autorizadas (`STATUSNFE = 'A'`), com `AD_PEDIDOMKTPLACE` preenchido e faturadas nos últimos 7 dias, que ainda **não** têm etiqueta gerada, para disparar a impressão/integração de etiqueta de expedição.

**Colunas:** `ID` (fixo `0`), `NUMNOTA`, `NUNOTA`, `SERIENOTA`, `DTFATUR`, `STATUSNFE`, `AD_PEDIDOMKTPLACE`, `AD_SHIPID` (de `AD_MELISHIPID`), `CHAVENFE`, `CODVEND`, `CODEMP`, `NOTAXML` (de `TGFNFE.XMLENVCLI`).

**Tabelas fonte:** `TGFCAB`, `TGFNFE`; exclui notas já presentes em `TSIATA` (`TIPO = 'N'`) com descrição contendo `Etiqueta`.

**Diferença entre as duas:** filtro de vendedor — `AD_VWMELIFATVIX` usa `CODVEND = 5`; `AD_VWMELIFATVIX2` usa `CODVEND = 43` (o filtro de empresa está comentado nas duas: `CODEMP = 1` / `CODEMP = 2`). A janela de 7 dias também difere: a primeira compara `DTFATUR >= SYSDATE-7` (com hora); a segunda usa `TO_DATE(DTFATUR) >= TO_DATE(SYSDATE-7)`. Vendedor fixo no código — ajustar conforme o ambiente.

---

### Views descobertas no banco em 08/10/2026

Existiam no banco sem arquivo no repositório (inventário de 08/10/2026, `scripts/inventario_2026-10-08/`). Capturadas **sem alteração do corpo**, com cabeçalho de captura (o cabeçalho do `.SQL` ainda diz `[A DOCUMENTAR]`; as descrições abaixo foram levantadas a partir do corpo da view). Só as duas `VGF_OBS*_SPARK` geram texto de observação de nota; as demais são de cálculo fiscal/financeiro (DIFAL, ST, importação) e de comissão. Não há referência a elas em outros objetos versionados do repositório — o consumo deve estar em configurações do ERP (a confirmar).

| Arquivo | View | Descrição | Criada no banco |
|---|---|---|---|
| `VGF_CALCFINIMP_SPARK.SQL` | `VGF_CALCFINIMP_SPARK` | Por `NUNOTA`, soma `TGFIII.VLRDESPADUA + TGFIII.VLRIMPOSTO + TGFITE.VLRICMS` dos itens com declaração de importação (`TGFIDI`). Coluna de saída: `FINACEIRO` (grafia do banco). | 16/12/2025 |
| `VGF_CALDIFAL_SPARK.SQL` | `VGF_CALDIFAL_SPARK` | Cálculo de DIFAL por item (`NUNOTA`, `SEQUENCIA`, `BASE`, `ICMS`, `DIFAL`, `BASEAJD`, `ALIQUOTA`). Bloco 1: entradas CFOP 2551/2556, 2949 (TOP 224) e 2910 (TOP 316), com base "por dentro" `(BASE-ICMS)/0,82` e alíquota interna 18%. Bloco 2: CT-e CFOP 2352/2932 vinculados (`TGFNCT`) a notas das TOPs 201/221/224/209/316, `DIFAL = BASE × 6%` e base rateada por `FC_RATEIOFRETE_SAPARK`. | 08/11/2024 |
| `VGF_CALIDFAL_SPARK.SQL` | `VGF_CALIDFAL_SPARK` | Variante de `VGF_CALDIFAL_SPARK` com as mesmas colunas e fórmulas; diferenças: não inclui o caso CFOP 2910/TOP 316, não inclui a TOP 316 no bloco de CT-e, não deduplica o bloco de CT-e (`ROW_NUMBER`) e não tem o ramo `BASEICMS =` no cálculo da base. Qual das duas está em uso — a confirmar. | 02/12/2025 |
| `VGFCOM_FECHSPARK.SQL` | `VGFCOM_FECHSPARK` | Base de fechamento de comissão (46 colunas: `CODVEND`, `VLRCOM`, `COMLIQ`, `AD_COMBASE`, `PERCCOM`, `NUFECHAMENTO`, dados de nota/financeiro/parceiro...). `UNION ALL` de 8 blocos sobre `TGFCOM` identificados por `POSICAO_QUERY`: 1 negociação pela nota, 2 negociação pelo financeiro, 3 baixa não renegociada, 4 baixa renegociada, 5 negociação por OS, 6 contrato, 7 baixa não renegociada por OS, 8 baixa renegociada por OS. Aparenta ser cópia customizada da base nativa de comissão (a confirmar). | 14/03/2022 |
| `VGF_DIFSTFEM_SPARK.SQL` | `VGF_DIFSTFEM_SPARK` | `NUNOTA`, `SEQUENCIA`, `BASE`, `ALIQUOTA`, `VALOR` de `TGFIMN` com `CODIMP = 18` (imposto a confirmar — pelo nome, DIFAL ST/FEM). | 12/03/2026 |
| `VGF_DIFST_SPARK.SQL` | `VGF_DIFST_SPARK` | Igual a `VGF_DIFSTFEM_SPARK`, mas com `CODIMP = 17` (imposto a confirmar — pelo nome, DIFAL ST). | 12/03/2026 |
| `VGF_OBSNOTASDEV2_SPARK.SQL` | `VGF_OBSNOTASDEV2_SPARK` | Observação de nota de devolução (TOPs 300, 301, 305, 306, 308, 331, 1200, 1204, 1206, 1234, 1266, 1314): para cada nota de origem (`TGFVAR`) monta "Devolucao Ref. NFe ... Chave ... Emitida em ... Motivo (`AD_MOTIVODEV`) ... Parcial/Total" e agrega com `LISTAGG`. Colunas: `NUNOTA_DEV`, `NUMNOTA_DEV`, `NUNOTAS_VENDA`, `OBSDEV`. | 12/11/2025 |
| `VGF_OBSNOTAS2_SPARK.SQL` | `VGF_OBSNOTAS2_SPARK` | Observação fixa por TOP (`NUNOTA`, `NUMNOTA`, `OBSDEV`): TOP 1215 "Troca em garantia..." (`AD_DTVENCGAR`), TOP 1109 "Remessa ... comodato..." (`AD_NUCONTRCOMOD`) e TOPs 1111/1112 "Ajuste SINIEF 49/2025". | 28/01/2022 |
| `VGFSERIES.SQL` | `VGFSERIES` | Consulta unificada de números de série (Andes + Sankhya) com nota, produto, parceiro, lote, movimento e local. | 17/01/2024 |

> `VGFSERIES` **não é nativa** (parecia ser): une `AD_ANDSER` (seriais Andes) a `TGFSER` — TOP 800 ou vendas (`TIPMOV = 'V'`) do local 109; TOP 1314 no local 201; e entradas da TOP 213 (ou vendas do local 109) como "IMPORTADO ANDES" — e é a view mais referenciada nos componentes BI do repositório (~78 usos). `VGF_OBSNOTAS2_SPARK` tem uma condição fixa `CAB.NUNOTA = 1962` em **dois** ramos do `UNION` (troca em garantia, TOP 1215, e comodato, TOP 1109) — na prática esses ramos só retornam essa nota; aparenta ser resquício de teste; confirmar antes de mexer.

---

## Observações Gerais

- Todas as views usam `CREATE OR REPLACE` — seguras para reexecução. As capturadas do banco (`VGFSALDOMRP` e as nove da seção acima) usam `FORCE EDITIONABLE`; `VGFSALDOMRP` ainda traz o owner `"SPARKPRD".` no nome.
- `VGFNFE` tem o `CODVEND = 42` fixo no código — ajustar conforme necessidade em outros ambientes.
- Alterações nas tabelas fonte podem invalidar as views; revisar após mudanças de schema no Sankhya.
