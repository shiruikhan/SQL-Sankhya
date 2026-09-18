# Dicionário de Dados — Tabelas Customizadas

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de tabelas:** 10  
**Prefixo padrão:** `AD_` (customização Spark sobre o Sankhya)  

> As duas primeiras tabelas abaixo têm dicionário de campos completo. As demais
> (bloco **Demais tabelas**) estão catalogadas com finalidade, PK e dependências —
> o DDL detalhado está no respectivo arquivo `.SQL`.

---

## `AD_LOG_ERROS`

**Arquivo:** `AD_LOG_ERROS.SQL`  
**Descrição:** Log centralizado de erros capturados por triggers de banco de dados. Registra contexto completo da ocorrência para diagnóstico e auditoria.

**Script DDL:**
```sql
CREATE TABLE AD_LOG_ERROS (
  IDLOG           NUMBER          NOT NULL,
  DHLOG           DATE            DEFAULT SYSDATE NOT NULL,
  TRIGGER_NAME    VARCHAR2(100),
  OPERACAO        VARCHAR2(10),
  NUNOTA          NUMBER,
  NUMNOTA         NUMBER,
  CFOPXML         VARCHAR2(4000),
  CHAVEACESSO     VARCHAR2(100),
  XNOMEEMIT       VARCHAR2(200),
  ERROR_CODE      NUMBER,
  ERROR_MESSAGE   VARCHAR2(4000),
  ERROR_BACKTRACE VARCHAR2(4000),
  CALL_STACK      VARCHAR2(4000)
);
ALTER TABLE AD_LOG_ERROS ADD CONSTRAINT AD_LOG_ERROS_PK PRIMARY KEY (IDLOG);
```

**Dicionário de Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `IDLOG` | `NUMBER` | Sim (PK) | Identificador único do registro de log |
| `DHLOG` | `DATE` | Sim | Data e hora do erro (padrão: `SYSDATE`) |
| `TRIGGER_NAME` | `VARCHAR2(100)` | Não | Nome da trigger que gerou o erro |
| `OPERACAO` | `VARCHAR2(10)` | Não | Operação DML que originou o erro (`INSERT`, `UPDATE`, `DELETE`) |
| `NUNOTA` | `NUMBER` | Não | Número único da nota envolvida |
| `NUMNOTA` | `NUMBER` | Não | Número da nota fiscal impressa |
| `CFOPXML` | `VARCHAR2(4000)` | Não | CFOP extraído do XML (contexto fiscal) |
| `CHAVEACESSO` | `VARCHAR2(100)` | Não | Chave de acesso da NF-e ou CT-e envolvida |
| `XNOMEEMIT` | `VARCHAR2(200)` | Não | Nome do emitente do documento |
| `ERROR_CODE` | `NUMBER` | Não | Código Oracle do erro (`SQLCODE`) |
| `ERROR_MESSAGE` | `VARCHAR2(4000)` | Não | Mensagem do erro (`SQLERRM`) |
| `ERROR_BACKTRACE` | `VARCHAR2(4000)` | Não | Backtrace completo do erro (`DBMS_UTILITY.FORMAT_ERROR_BACKTRACE`) |
| `CALL_STACK` | `VARCHAR2(4000)` | Não | Pilha de chamadas (`DBMS_UTILITY.FORMAT_CALL_STACK`) |

**Observações:**
- O campo `IDLOG` não possui sequence automática definida neste script — recomenda-se criar uma sequence `SEQ_AD_LOG_ERROS` e trigger de auto-incremento, ou usar `SYS_GUID()` como alternativa.
- Consumida por triggers que capturam erros em processamentos de NF-e/CT-e.

---

## `AD_MAP_SETOR_FUNC`

**Arquivo:** `AD_MAP_SETOR_FUNC.SQL`  
**Autor:** Silvio Vieira | **Data de criação:** 31/03/2026  
**Descrição:** Tabela de mapeamento entre o departamento do colaborador (`TFPDEP.DESCDEP`) e a etapa de produção (`TPREFX.DESCRICAO`). Necessária porque os nomes não são padronizados entre as duas origens. Utilizada pela trigger `TRG_VAL_SETOR_CODFUNC_TPRAPA` para validar se o colaborador pertence ao setor correto do apontamento.

**Script DDL:**
```sql
CREATE TABLE AD_MAP_SETOR_FUNC (
    DESCDEP    VARCHAR2(100) NOT NULL,
    DESCIDEFX  VARCHAR2(100) NOT NULL,
    CONSTRAINT AD_MAP_SETOR_FUNC_PK PRIMARY KEY (DESCDEP, DESCIDEFX)
);
```

**Dicionário de Campos:**

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `DESCDEP` | `VARCHAR2(100)` | Sim (PK) | Descrição do departamento do colaborador (`TFPDEP.DESCDEP`) |
| `DESCIDEFX` | `VARCHAR2(100)` | Sim (PK) | Descrição da etapa de produção (`TPREFX.DESCRICAO`) |

**Chave primária composta:** `(DESCDEP, DESCIDEFX)` — um departamento pode mapear para múltiplas etapas e vice-versa.

**Mapeamentos iniciais registrados:**

| DESCDEP | DESCIDEFX |
|---|---|
| `INSERCAO` | `INSERÇÃO` |
| `INSERSORA` | `APONTAMENTO INSERSORA` |
| `INSERSORA` | `APONTAMENTO REVISORA` |
| `SOLDA` | `SOLDA` |
| `TESTE` | `TESTE` |
| `DISSIPADOR` | `DISSIPADOR` |
| `MONTAGEM FINAL` | `MONTAGEM FINAL` |
| `MONTAGEM DISPLAY` | `DISPLAY` |

**Observações:**
- Manutenção dos registros via `INSERT/DELETE` direto na tabela — não há tela nativa no ERP para isso.
- Novos setores de produção ou departamentos criados no ERP devem ser incluídos nesta tabela para que a validação de apontamentos continue funcionando.
- A trigger dependente (`TRG_VAL_SETOR_CODFUNC_TPRAPA`) rejeita apontamentos de colaboradores de departamentos não mapeados.

---

## Demais tabelas

### `AD_CORRNOTAPROD`

**Arquivo:** `AD_CORRNOTAPROD.SQL` | **PK:** `NUCORR` | **Criação:** 09/07/2026

Auditoria das verificações/correções de notas de produção feitas por
`STP_CORRIGENOTAPROD_SPARK`. Cada linha registra uma divergência detectada (ou
corrigida) ao comparar as conferências finalizadas (`TPRCONF` / `AD_TPRCOI`) com
o lançamento da nota de produção (`TGFCAB` / `TGFITE` / `TGFSER`, TOP 800) da
mesma OP. Conciliação por conferência (`NUCONF`). Valores de `TIPOCORR`:
`NOTA_CRIADA`, `QTD_AJUSTADA`, `SERIE_INCLUIDA`, `DIVERG_NEGATIVA` (legado).
Índices por `IDIPROC` e `NUCONF`. O arquivo traz um bloco `ALTER` comentado para
bases anteriores a Jul/2026 (quando `NUCONF` foi adicionada).

### `AD_TGFASS`

**Arquivo:** `AD_TGFASS.SQL` | **PK:** `NUMOS`

Cabeçalho da O.S. de assistência técnica da Spark (complementa `TGFCAB`/CAC).
Guarda datas (recebimento, conclusão, envio), status, observações adm/técnico,
valor de produto, número da série de entrada, notas de entrada/saída, endereço de
entrega, dados de rastreamento (`TIPOENTREGA`, `RASTREIO`), o checklist técnico de
inspeção da placa (campos `S/N`: `DISJUNTOR`, `COOLER`, `DISPLAY`, `SOLDA`,
`INDUTOR`, `TRANSFORMADOR`, etc.), os funcionários responsáveis
(`FUNCSOLDA`, `FUNCSOLDA2`, `FUNCTESTE`, `FUNCINSERCAO`, `TECNICO`), `DTLANC`
(data de lançamento — adicionada em Set/2026) e `VLRCONSERTO` (valor do
conserto — adicionada em Set/2026, preenchida automaticamente por
`TRG_TGFASS_VLRCONSERTO_SPARK` via `SNK_PRECO`). Colunas `FOTO` e
`COMPROVANTE` são BLOB (SecureFile). FKs para `TGFPAR` (cliente e parceiro
assistência) e `AD_CADFUNC` (`TECNICO` — FK recriada em Set/2026, coluna foi
dropada/readicionada e por isso hoje aparece ao final do DDL).

### `AD_TGSAPI`

**Arquivo:** `AD_TGSAPI.SQL` | **PK:** `API`

Registro de credenciais e endpoints de APIs externas consumidas pelas classes
Java (`CotaFrete`, `CotaFreteRodonaves`). Colunas base: `ENDPOINT`, `USUARIO`,
`PASSWORD`, `AMBIENTE`. Colunas adicionadas para a integração Rodonaves:
`ENDPOINTAUTH` (URL do `/token` OAuth2), `ENDPOINTCIDADE` (busca-cidade por CEP) e
`AUTH_TYPE` (usar `'DEV'` — ver [[integracao-rodonaves-status]]; `'PRD'` é inválido).

### `AD_TGSCTF`

**Arquivo:** `AD_TGSCTF.SQL` | **PK:** `NUCTF` | **FK:** `NUNOTA` → `TGFCAB`

Cabeçalho da cotação de frete (uma linha por embarque a cotar). Guarda documentos
de origem/destino/consignatário, modal, tipo de frete, CEPs, volume/peso/valor
totais e o resultado da cotação (`VLRFRETE`, `VLRFRETEPED`). `APIDEST` indica a
transportadora/API usada. Alimentada e lida pelas classes de cotação de frete.

### `AD_TGSISGM`

**Arquivo:** `AD_TGSISGM.sql` | **PK composta:** `(CODSGRU, ANO, MES, IDGRU)`

Itens da meta por subgrupo: associa cada meta de subgrupo (`AD_TGSSGM`) aos grupos
de produto (`CODGRUPOPROD`) que a compõem, por período (`ANO`/`MES`). `TIPO`
classifica a linha. FK composta para `AD_TGSSGM`.

### `AD_TGSIXN`

**Arquivo:** `AD_TGSIXN.SQL` | **PK:** `NUCONF` | **FKs:** `CODUSUINC` → `TSIUSU`, `NUARQUIVO` → `TGFIXN`, `(CODEMP, CODFUNC)` → `TFPFUN`

Apontamento de conferência de arquivo/nota importada. Como `TGFIXN` não aceita
botão de ação, o usuário cria o apontamento nesta tela informando só o
`NUARQUIVO`. Colunas: `DTINI`/`DTFIM`, `STATUS` (`1` = aberto, `2` = finalizado),
`OBSERVACAO` (CLOB), `CODFUNC` (conferente, setável uma única vez), `NUMNOTA` e
`DHEMISS` (copiados de `TGFIXN` no INSERT), `DURACAO_DIAS_UTEIS`. Restrição
`UQ_AD_TGSIXN_NUARQUIVO` garante apontamento único por arquivo mesmo sob
concorrência. Objetos que operam sobre ela: `STP_APONTACONFERENCIA_SPARK`
(inativa), `TRG_INC_AD_TGSIXN_SPARK`, `TRG_INC_UPD_AD_TGSIXN_SPARK`,
`TRG_UPD_AD_TGSIXN_SPARK`, `STP_ATUALIZADTFIM_TGSIXN_SPARK` (job agendado).

### `AD_TGSLCB`

**Arquivo:** `AD_TGSLCB.SQL` | **PK composta:** `(NUCTF, IDEMB)` | **FK:** `NUCTF` → `AD_TGSCTF`

Itens (pacotes/volumes) da cotação de frete: dimensões (`COMPRIMENTO`, `ALTURA`,
`LARGURA`), `VOLTOT` e `PESOITEM` (adicionada para a Rodonaves —
`Packs[].Weight`). Uma linha por embalagem do embarque.

### `AD_TGSSGM`

**Arquivo:** `AD_TGSSGM.SQL` | **PK composta:** `(CODSGRU, ANO, MES)`

Meta de venda por subgrupo e período: `VLRMET` (valor da meta) e `APELIDO`
(rótulo do subgrupo). Cabeçalho de `AD_TGSISGM`; base dos componentes BI de
acompanhamento de meta por subgrupo.
