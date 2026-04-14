# Dicionário de Dados — Tabelas Customizadas

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de tabelas:** 2  
**Prefixo padrão:** `AD_` (customização Spark sobre o Sankhya)  

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
