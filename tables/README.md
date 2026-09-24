# Dicionário de Dados — Tabelas Customizadas

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de tabelas:** 38  
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
(data de lançamento — adicionada em Set/2026), `VLRCONSERTO` e
`VLRSERVTECNICO` (valores de conserto e de serviço técnico — adicionadas em
Set/2026, ambas preenchidas automaticamente por
`TRG_TGFASS_VLRCONSERTO_SPARK` via `SNK_PRECO`, com `CODTAB` 14 e 15
respectivamente). Colunas `FOTO` e `COMPROVANTE` são BLOB (SecureFile). FKs
para `TGFPAR` (cliente e parceiro assistência) e `AD_CADFUNC` (`TECNICO` — FK
recriada em Set/2026, coluna foi dropada/readicionada e por isso hoje aparece
ao final do DDL).

> **Nota:** `VLRSERVTECNICO` ainda não consta no DDL local (`AD_TGFASS.SQL`)
> — recapturar via o workflow de captura de DDL quando possível.

### `AD_TGSAPI`

**Arquivo:** `AD_TGSAPI.SQL` | **PK:** `API`

Registro de credenciais e endpoints de APIs externas consumidas pelas classes
Java (`CotaFreteMultiTransp`, antes `CotaFrete`/`CotaFreteRodonaves`). Colunas
base: `ENDPOINT`, `USUARIO`, `PASSWORD`, `AMBIENTE`. Colunas adicionadas para a
integração Rodonaves: `ENDPOINTAUTH` (URL do `/token` OAuth2), `ENDPOINTCIDADE`
(busca-cidade por CEP), `AUTH_TYPE` (usar `'DEV'` — ver
[[integracao-rodonaves-status]]; `'PRD'` é inválido) e `ENDPOINTPRAZO` (URL do
endpoint de cálculo de prazo de entrega, que recebe nome de cidade + UF de
origem/destino e devolve `DeliveryTime` em dias).

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

### `AD_APOQLD`

**Arquivo:** `AD_APOQLD.SQL` | **PK:** `NUAPO` | **FK:** `CODPROD` → `TGFPRO`

Checklist de defeitos de qualidade por apontamento de produção (`NUAPO`), com
contadores por tipo de ocorrência (`QUEIMADO`, `CURTO`, `SOLDAFRIA`,
`CHICOTE`, `DISPLAY`, `LED`, `CONSUMO`, `CORRENTE`, `PROGRAMACAO`,
`ADESIVOTROC/TORT`, `GABARRANHADO/MASSADO`, `TAMPATROCA/AMASS`, etc.) e os
operadores/revisores envolvidos (`FUNCOPERADOR`, `FUNCOPERADOR2`,
`FUNCREVISOR`, `FUNCREVISOR2`). Base do componente BI `01 - Gráfico Qualidade
por Operador`.

### `AD_CADFUNC`

**Arquivo:** `AD_CADFUNC.SQL` | **PK:** `IDFUNC`

Cadastro auxiliar simplificado de funcionários (`NOME`, `SETOR`, `ATIVO`,
`REVISOR`) — não é o `TFPFUN` nativo, é usado pelos componentes BI de
produção/qualidade para exibir nome/setor sem depender da folha de pagamento.

### `AD_DBFECHCOMFIN`

**Arquivo:** `AD_DBFECHCOMFIN.SQL` | **PK composta:** `(NUFECH, SEQUENCIA)` | **FKs:** `NUFECH` → `AD_DBFECHCOM`, `CODPARC` → `TGFPAR`

Itens financeiros (`TIPO`, `VALOR`, `NUFIN`) vinculados a um fechamento de
comissão (`AD_DBFECHCOM` — ainda sem DDL capturado). Usada por
`STP_EXCLUIRFINCOM_SPARK`.

### `AD_EMBPED`

**Arquivo:** `AD_EMBPED.SQL` | **PK composta:** `(NUNOTA, SEQ)` | **FKs:** `CODPROD`, `CODPRODEMB` → `TGFPRO`

Itens de embalagem gerados na expedição de uma nota: vincula o produto físico
(`CODPROD`) à embalagem usada (`CODPRODEMB`, `IDCAIXA`), com peso bruto
(`PESOBRUTO`) e cubagem (`M3`). Usada por `STP_GERARVOLUMES_SPARK`,
`STP_INCEMB_SPARK` e `TRG_AD_EMBPED_SPARK`.

### `AD_FRETE`

**Arquivo:** `AD_FRETE.SQL` | **PK:** nenhuma constraint definida (`NUNOTA` + `VLRFRETE`, ambos `NOT NULL`)

Valor de frete rateado (`VLRFRETE`) por nota (`NUNOTA`). Usada por
`TRG_UPD_TGFCAB_TRANSP_SPARK`.

### `AD_OSINTERNA`

**Arquivo:** `AD_OSINTERNA.SQL` | **PK:** `NUMOS` | **FKs:** `CODCENCUS` → `TSICUS`, `CODPARC` → `TGFPAR`, `CODUSUCRI` → `TSIUSU`

Cabeçalho de Ordem de Serviço **interna** (manutenção de equipamentos/
patrimônio da empresa — diferente da assistência técnica ao cliente em
`AD_TGFASS`). Guarda problema apontado (`PROBAPONTADO`, CLOB), setor,
status, prioridade, datas (criação/alteração/programada/deadline/fim),
custo, tipo e natureza de manutenção, executante/manutentor, patrimônio
(`CODPAT`) e fotos (`IMAGEM`, `ANTES`, `DEPOIS`, BLOB). Usada por
`STP_INCMOVOSINT_SPARK` e `STP_OSINTERNA_INC_SPARK`.

### `AD_PRVCTR`

**Arquivo:** `AD_PRVCTR.SQL` | **PK:** `NUPREV` | **FK:** `CODBEM` → `AD_ADCADBENS` (ainda sem DDL capturado)

Programação de manutenção preventiva de um bem do imobilizado/patrimônio
(`CODBEM`): data prevista, tipo/natureza de manutenção, operador e custo.
Usada por `STP_INCLUIRLANCTO_SPARK`.

### `AD_SPKICAE`

**Arquivo:** `AD_SPKICAE.SQL` | **PK composta:** `(NUMOS, IDCOMP)` | **FKs:** `NUMOS` → `AD_SPKCAE`, `CODPROD` → `TGFPRO`

Componentes/peças consumidos numa O.S. de conserto (`AD_SPKCAE`):
quantidade movimentada (`QTDMOV`), unidade (`CODVOL`) e a nota de
movimentação de estoque gerada (`NUNOTAMOV`).

### `AD_TGFIASS`

**Arquivo:** `AD_TGFIASS.SQL` | **PK composta:** `(NUMOS, IDCOMP)` | **FKs:** `NUMOS` → `AD_TGFASS`, `CODPROD` → `TGFPRO`

Mesma estrutura de `AD_SPKICAE`, mas para a O.S. de assistência técnica
(`AD_TGFASS`): componentes/peças consumidos no conserto.

### `AD_TGFMET`

**Arquivo:** `AD_TGFMET.SQL` | **PK composta:** `(CODMETA, DTREF, CODEMP, CODPROD)` | **FKs:** `CODUSU` → `TSIUSU`, `CODPROD` → `TGFPRO`, `CODEMP` → `TSIEMP`

Meta de vendas/produção por produto, empresa e período — complementa a
`TGMMET` nativa com `QTDPREV` (quantidade prevista) e `QTDREDMET` (redução de
meta). Usada por `STP_ALTERAMETA_SPARK` e `STP_PCPMETA_SPARK`.

### `AD_TGFNCO`

**Arquivo:** `AD_TGFNCO.SQL` | **PK:** `NUNCO` | **FKs:** `CODUSU`/`TRANSP` → `TSIUSU`/`TGFPAR`, `CODCENCUS` → `TGFLOC`, `NCOAPO` → `AD_CADNCO` (ainda sem DDL capturado)

Registro de **Não Conformidade** (NC): produto/nota/parceiro envolvidos,
causa (`CAUSA`), técnico responsável, ação imediata e corretiva
(`ACAOIMED`/`ACAOCORRET`, com responsáveis e datas), validação
(`DTVALID`/`RESPVALID`), eficácia (`EFICACIA`) e até 4 fotos (BLOB). Usada
por `STP_INCNCONFORM_SPARK`.

### `AD_TGFPIM`

**Arquivo:** `AD_TGFPIM.SQL` | **PK:** `IDIMP`

Parâmetro de ICMS por ano/mês (`ANO`, `MES`, `ICMS`) usado no rateio de
proporção por `STP_CALCULAPROPORCAO_SPARK`.

### `AD_TGSCAB`

**Arquivo:** `AD_TGSCAB.SQL` | **PK:** `NUPED` | **FKs:** `ID` → `AD_TGSPAR`, `CODPARCTRANSP` → `TGFPAR`

Cabeçalho de pedido vindo de integração externa (site/marketplace): parceiro
(`AD_TGSPAR`), data, forma de pagamento, frete, transportadora e a
`NUNOTA` gerada no Sankhya após a integração. Usada por
`STP_INTEGRAPEDIDO_AGENDADA` e `STP_INTEGRAPEDIDO_SITESPARK`.

### `AD_TGSCIT`

**Arquivo:** `AD_TGSCIT.SQL` | **PK composta:** `(CODREG, SEQUENCIA)` | **FKs:** `CODREG` → `AD_TGSCUS`, `CODPROD` → `TGFPRO`

Itens de um registro de custo importado externamente (cabeçalho em
`AD_TGSCUS`): custo, custo relativo, ICMS, IPI, moeda, custo fiscal e custo
de frete por produto. Usada por `FC_GETPRECO_TRASF_SP` e pelas triggers de
custo (`SPK_TRG_TGFCUS`, `SPK_TRG_INS_TGFCUS`).

### `AD_TGSCUS`

**Arquivo:** `AD_TGSCUS.SQL` | **PK:** `CODREG` | **FK:** `CODUSU` → `TSIUSU`

Cabeçalho do registro de custo importado externamente (data de referência,
data de importação, usuário) — pai de `AD_TGSCIT`.

### `AD_TGSCUSBLOCOH`

**Arquivo:** `AD_TGSCUSBLOCOH.SQL` | **PK:** `ID`

Tabela de staging/conferência de custo por produto (carga externa "Bloco
H"): descrição, unidade, valor de custo e data de referência. Usada por
`STP_VERCORCUSTO_SPARK`.

### `AD_TGSIOSI`

**Arquivo:** `AD_TGSIOSI.SQL` | **PK composta:** `(NUMOS, ID)` | **FKs:** `NUMOS` → `AD_OSINTERNA`, `CODPROD` → `TGFPRO`, `NUNOTA` → `TGFCAB`, `CODVOL` → `TGFVOL`

Itens de material/peça consumidos numa Ordem de Serviço interna
(`AD_OSINTERNA`): produto, quantidade, unidade e a nota de movimentação
gerada. Usada por `STP_INCMOVOSINT_SPARK`.

### `AD_TGSISCP`

**Arquivo:** `AD_TGSISCP.SQL` | **PK composta:** `(NUSOL, SEQUENCIA)` | **FKs:** `NUSOL` → `AD_TGSSCP`, `CODVOL` → `TGFVOL`, `CODPROD` → `TGFPRO`

Itens de uma Solicitação de Compra interna (`AD_TGSSCP`): produto (cadastrado
ou só descrito em `PRODUTO`/`MARCA`), quantidade em estoque, estoque mínimo e
observação adicional. Usada por `STP_NOTIFICASOLICCOMPRA_SPARK` e
`TRG_NOTIFICA_SOLIC_COMPRA`.

### `AD_TGSITE`

**Arquivo:** `AD_TGSITE.SQL` | **PK composta:** `(NUPED, IDITEM)` | **FKs:** `NUPED` → `AD_TGSCAB`, `CODPROD` → `TGFPRO`

Itens do pedido de integração externa (`AD_TGSCAB`): quantidade, valor
unitário/liquido, desconto e total.

### `AD_TGSMDF`

**Arquivo:** `AD_TGSMDF.SQL` | **PK:** `ID`

Tabela de apoio de município/UF para o MDF-e (Manifesto de Documentos
Fiscais). Usada por `TRG_INC_UPD_CMF_SPARK`.

### `AD_TGSPAR`

**Arquivo:** `AD_TGSPAR.SQL` | **PK:** `ID` | **FKs:** `CODPARC` → `TGFPAR`, `CODCID` → `TSICID`, `CODEND` → `TSIEND`, `CODBAI` → `TSIBAI`, `CODUF` → `TSIUFS`

Cadastro de parceiro vindo de integração externa (site/marketplace) —
razão social, contato, endereço completo e documento — antes/depois de
vinculado ao `TGFPAR` nativo (`CODPARC`). Usada por
`STP_INTEGRAPEDIDO_AGENDADA` e `STP_INTEGRAPEDIDO_SITESPARK`.

### `AD_TGSSCP`

**Arquivo:** `AD_TGSSCP.SQL` | **PK:** `NUSOL` | **FKs:** `CODCENCUS` → `TSICUS`, `APROVADOR` → `TSIUSU`, `NUNOTA` → `TGFCAB`

Cabeçalho de Solicitação de Compra interna, com workflow de aprovação:
solicitante, centro de custo, justificativa (CLOB), prazo, status,
aprovador e observação da aprovação (CLOB). Usada por
`STP_APROVA_SOLIC_COMPRA` e `STP_NOTIFICASOLICCOMPRA_SPARK`.

### `AD_TGSSER`

**Arquivo:** `AD_TGSSER.SQL` | **PK composta:** `(NUPED, IDITEM, IDSERIE)` | **FKs:** `(NUPED, IDITEM)` → `AD_TGSITE`, `CODPROD` → `TGFPRO`

Números de série vinculados a um item de pedido de integração externa
(`AD_TGSITE`).

### `AD_TPRCOI`

**Arquivo:** `AD_TPRCOI.SQL` | **PK composta:** `(NUCONF, CODBARRA, CODPROD)` | **FK:** `CODUSU` → `TSIUSU`

Itens conferidos por código de barras numa conferência de produção
(`NUCONF`). Usada por `STP_CORRIGENOTAPROD_SPARK` e pelas triggers de
conferência de item (`TRG_INC_TPRCOI_SPARK`, `TRG_INC_UPD_TGFITE_SPARK`).

### `AD_TPRSERAPO`

**Arquivo:** `AD_TPRSERAPO.SQL` | **PK composta:** `(NUAPO, SEQAPA, SEQ)` | **FK:** `CODUSUINC` → `TSIUSU`

Números de série vinculados a um apontamento de produção (`NUAPO`/`SEQAPA`).
Usada pelas triggers `TRG_INC_UPD_DLT_TPRAPA_SPARK` /
`TRG_INC_UPD_DLT_TPRIPA_SPARK`.

### `AD_TPRSERPA`

**Arquivo:** `AD_TPRSERPA.SQL` | **PK composta:** `(IDIPROC, SERIEPA)` | **FK:** `CODPRODPA` → `TGFPRO`

Vincula um número de série ao produto acabado (`CODPRODPA`) de um processo
de produção (`IDIPROC`). Usada por `STP_LIBERASERIE_SPARK`.

### `AD_TSIBLOCK`

**Arquivo:** `AD_TSIBLOCK.SQL` | **PK:** `IDBLOCK`

Registro de bloqueio de sistema por tipo (`TIPBLOCK`) e data (`DTBLOCK`).
Usada por `SPK_TGFCAB_TSIBLOCK`.

> **Não capturadas nesta rodada:** `AD_CADMKTATRIB` e `AD_MKTPMELIATRIB`
> (atributos de marketplace) e `AD_MKTPMELI` não retornaram na consulta
> `DBMS_METADATA.GET_DDL` — provavelmente foram renomeadas, removidas ou o
> nome em `TABELAS_FALTANTES.md` está desatualizado. Confirmar o nome atual
> no banco antes de tentar capturar novamente.
