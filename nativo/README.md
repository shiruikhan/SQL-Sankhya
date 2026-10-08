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
| [`triggers/`](triggers/README.md) | 2 | **não registrada** | `triggers/README.md` | `TRG_INC_TGFITE` (customização Spark ainda não delimitada) e `TRG_INC_TGFVAR` (100% nativa) |
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
- Referências cruzadas usam os caminhos atuais: `nativo/functions/`, `nativo/triggers/README.md` etc. Os nomes antigos (`trigger_nativa/`, `libs_sankhya/`, `*/nativas_sankhya/`) não existem mais.

## Como recapturar após um upgrade do Sankhya

1. Rodar no VSCode (via VPN) a query com `DBMS_METADATA.GET_DDL('<TIPO>', '<NOME>', 'SPARKPRD')` para os objetos da pasta — o inventário e as queries prontas estão em `scripts/CAPTURA_*.SQL` (pasta local). Exportar o resultado como JSON.
2. Separar o JSON em um arquivo por objeto com um script Python (não ler o JSON inteiro direto; é grande demais). Manter o cabeçalho padrão e atualizar a linha `Capturado do banco em …`.
3. `git diff nativo/` — **o diff é o resultado**: lista exatamente o que o fabricante mudou. Para cada trigger/function alterada, conferir o impacto nos objetos da Spark que a usam (`grep -rn "NOME" triggers/ procedures/ functions/ package/`).
4. `python nativo/GERA_MANIFESTO.py`, ajustar os `README.md` das subpastas e commitar com a versão do ERP na mensagem.
5. Antes de qualquer `CREATE OR REPLACE` numa trigger nativa, conferir `STATUS` em `USER_TRIGGERS` — o Oracle sempre recria como `ENABLED` (ver `triggers/README.md` §15 da raiz).

## Cobertura — o que ainda não foi capturado

| Tipo | Situação |
|---|---|
| Triggers nativas | Só 2. Faltam as das tabelas que a Spark mais customiza (`TGFCAB`, `TGFITE`, `TGFFIN`, `TPR*`) — são as que interagem com os objetos da Spark (ORA-04091, ORA-00001 do `PK_TGFCOM`) |
| Procedures nativas (`STP_*`) | Não capturadas |
| Views nativas (`VGF*`) | Não capturadas |
| Types / sequences | Não capturados |
| Dicionário de dados (`TDDCAM`, `TDDOPC`, parâmetros de `TSIPAR`) | Em análise |
| Tabelas | Só as 53 mais referenciadas; as demais estão fora |

## Pendências conhecidas

- `TRG_INC_TGFITE`: delimitar o que é customização da Spark (ver `triggers/README.md`).
- `SOMA_DIA_UTIL` e `GET_LOCAL_ORIGEM`: origem incerta (hoje catalogadas como nativas) — confirmar.
- Registrar a **versão do Sankhya** vigente nas capturas (hoje não consta em nenhum arquivo).
- Data de captura das 2 triggers.
