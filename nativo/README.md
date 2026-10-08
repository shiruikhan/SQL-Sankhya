# Material Nativo do Sankhya

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Origem:** objetos do ERP Sankhya (schema `SPARKPRD`) capturados do banco via `DBMS_METADATA.GET_DDL`

---

## O que é esta pasta

Cópia **de referência** do que é do fabricante: functions, packages, tabelas e triggers nativos. Serve para entender uma dependência sem precisar de VPN/banco, e para descobrir o que mudou depois de cada upgrade do ERP.

**Regras:**

- **Não é código da Spark.** Nunca editar à mão para "corrigir" algo — o arquivo deve refletir o banco. Customização da Spark vai nas pastas da raiz (`triggers/`, `procedures/`, `functions/`, `package/`, `tables/`).
- **É versionada** (exceto `libs/`). O ponto de ter isso no git é o `git diff` após recapturar depois de um upgrade.
- **`libs/` não é versionada** (364 JARs, ~536 MB; `.gitignore`). Copiar da instalação do servidor Sankhya; o `.vscode/settings.json` aponta para cá.
- O que existe no repositório é só uma amostra do banco — ver "Cobertura" abaixo para o que **falta**.

## Conteúdo

| Pasta | Objetos | Capturado em | Catálogo | Observação |
|---|---|---|---|---|
| [`functions/`](functions/README.md) | 348 (153 `SNK_*` + 195 outras) | 17–18/09/2026 (`SNK_*`) e 08/10/2026 (demais) | `functions/README.md` | Cabeçalho padronizado em cada arquivo, com assinatura e data de captura |
| [`packages/`](packages/README.md) | 20 | 08/10/2026 | `packages/README.md` | **Só especificação** — o banco não tem `PACKAGE BODY`; funcionam como repositório de variáveis de sessão |
| [`tables/`](tables/README.md) | 53 | 18/09/2026 | `tables/README.md` | DDL cru do `GET_DDL`, sem cabeçalho; selecionadas por frequência de uso no repositório |
| [`procedures/`](procedures/README.md) | 6 | 08/10/2026 | `procedures/README.md` | Só as citadas por triggers nativas e pela Spark; as ~200 procedures de 12/2021 não foram capturadas |
| [`triggers/`](triggers/README.md) | 94 (92 do lote 1 + 2 antigas) + 57 pendentes | 08/10/2026 (lote 1); 2 antigas sem data | `triggers/README.md` | Triggers das tabelas que a Spark customiza (`TGFCAB`, `TGFITE`, `TGFFIN`, `TGFPRO` …), com estado `ENABLED`/`DISABLED`. As 57 pendentes vieram truncadas em 4000 caracteres e aguardam `scripts/CAPTURA_DDL_NATIVOS_LOTE1B.SQL` |
| `libs/` | 364 JARs | — | — | Local, fora do git |

O inventário arquivo a arquivo (tipo, objeto, arquivo, data de captura, nº de linhas) está em [`MANIFESTO.csv`](MANIFESTO.csv). Para regenerar depois de adicionar ou recapturar arquivos:

```bash
python nativo/GERA_MANIFESTO.py
```

A data vem da linha `Capturado do banco em dd/mm/aaaa` do cabeçalho de cada arquivo. Tabelas não têm cabeçalho (DDL cru), então usam 18/09/2026 como padrão do script, e as triggers ficam em branco — ao recapturar, registre a data no cabeçalho.

## Convenções

- Um objeto por arquivo, nome do objeto em maiúsculas + extensão `.SQL` (ex.: `TRG_INC_TGFITE.SQL`, não `TRG_INC.TGFITE.sql`).
- Functions e packages começam com um bloco de comentário (`Nome do Script`, `Tipo`, `Descricao`, `Assinatura`, `Observacoes`) e o DDL em seguida. A linha `Capturado do banco em …` é a que alimenta o manifesto.
- Todo catálogo (`README.md` da subpasta) lista objeto, retorno/PK e descrição de uma linha.
- Triggers: o DDL do `GET_DDL` é gravado sem alteração, exceto `/` antes do `ALTER TRIGGER … ENABLE|DISABLE` e `;` final (o `ALTER` preserva o estado de habilitação do banco). Cada arquivo traz um cabeçalho com origem provável (instalação 12/2021, lote de atualização do ERP, pontual ou `AD_*`).
- Referências cruzadas usam os caminhos atuais: `nativo/functions/`, `nativo/triggers/README.md` etc. Os nomes antigos (`trigger_nativa/`, `libs_sankhya/`, `*/nativas_sankhya/`) não existem mais.

## Como recapturar após um upgrade do Sankhya

1. Rodar no VSCode (via VPN) a query com `DBMS_METADATA.GET_DDL('<TIPO>', '<NOME>', 'SPARKPRD')` para os objetos da pasta — o inventário e as queries prontas estão em `scripts/CAPTURA_*.SQL` (pasta local). Exportar o resultado como JSON.
   - **Cuidado com o limite de 4000 caracteres:** o client pode converter o CLOB para `VARCHAR2(4000)` e truncar silenciosamente o DDL (aconteceu com 57 de 151 triggers no lote de 08/10/2026). Confira o tamanho de cada texto recebido; se vier exatamente 4000, recapture em pedaços de 1300 caracteres com `DBMS_LOB.SUBSTR` (modelo em `scripts/CAPTURA_DDL_NATIVOS_LOTE1B.SQL`).
2. Separar o JSON em um arquivo por objeto com um script Python (não ler o JSON inteiro direto; é grande demais). Manter o cabeçalho padrão e atualizar a linha `Capturado do banco em …`.
3. `git diff nativo/` — **o diff é o resultado**: lista exatamente o que o fabricante mudou. Para cada trigger/function alterada, conferir o impacto nos objetos da Spark que a usam (`grep -rn "NOME" triggers/ procedures/ functions/ package/`).
4. `python nativo/GERA_MANIFESTO.py`, ajustar os `README.md` das subpastas e commitar com a versão do ERP na mensagem.
5. Antes de qualquer `CREATE OR REPLACE` numa trigger nativa, conferir `STATUS` em `USER_TRIGGERS` — o Oracle sempre recria como `ENABLED` (ver `triggers/README.md` §15 da raiz).

## Cobertura — o que ainda não foi capturado

| Tipo | Situação |
|---|---|
| Triggers nativas | Capturadas as das tabelas que a Spark customiza (lote 1, 08/10/2026), exceto 57 truncadas pendentes de recaptura. Tabelas cujas triggers já estão todas no repositório da Spark (`TPRCOI`, `TGFCON2`, `TPRSERPA`, `TGFCOI2` …) não geraram captura nativa |
| Procedures nativas (`STP_*`) | Só 6 (as citadas). As ~200 de 12/2021 não foram capturadas; capturar por fechamento de dependência — procedures chamadas pelo código das triggers já capturadas — quando as 57 pendentes chegarem |
| Views nativas (`VGF*`) | Não capturadas (673 no banco; a maioria é do fabricante, ex.: `VRI_*`/`VFP_*`). `VGFSERIES`, que parecia nativa, é da Spark e foi para `view/` |
| Types / sequences | Não capturados |
| Dicionário de dados (`TDDCAM`, `TDDOPC`, parâmetros de `TSIPAR`) | Em análise |
| Tabelas | Só as 53 mais referenciadas; as demais estão fora |

## Pendências conhecidas

- `TRG_INC_TGFITE`: delimitar o que é customização da Spark (ver `triggers/README.md`). A versão do banco foi criada em 12/01/2026 e alterada em 21/09/2026; a cópia local é anterior e foi reformatada — comparar após a recaptura (lote 1B).
- **Recapturar as 57 triggers truncadas** (`scripts/CAPTURA_DDL_NATIVOS_LOTE1B.SQL`).
- **Provável upgrade do ERP em 21/09/2026** (196 objetos alterados no mesmo dia): functions `SNK_*` e tabelas capturadas em 18/09/2026 podem estar defasadas — listar por `LAST_DDL_TIME` e recapturar o que mudou.
- `SOMA_DIA_UTIL` e `GET_LOCAL_ORIGEM`: origem incerta (hoje catalogadas como nativas) — confirmar.
- Registrar a **versão do Sankhya** vigente nas capturas (hoje não consta em nenhum arquivo).
- Data de captura das 2 triggers.
