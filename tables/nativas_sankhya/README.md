# Catálogo de Tabelas Nativas do Sankhya (referência)

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de tabelas:** 53  
**Banco:** Oracle  
**Origem:** Nativas do ERP Sankhya (schema SPARKPRD) — mantidas aqui apenas como referência/documentação, não são customizações da Spark.

---

> Estas tabelas **não são mantidas pela Spark** — são nativas do ERP Sankhya, listadas em [`tables/TABELAS_FALTANTES.md`](../TABELAS_FALTANTES.md) por serem muito referenciadas no repositório (>= 5 ocorrências) sem termos o DDL local. Capturadas via `DBMS_METADATA.GET_DDL` em 18/09/2026. Atualizações do Sankhya podem alterar a estrutura — revisar após cada upgrade do ERP (mesmo cuidado do `trigger_nativa/README.md` e de `functions/nativas_sankhya/README.md`).

## Catálogo

| Tabela | PK | Descrição |
|---|---|---|
| [`TCBINT`](TCBINT.SQL) | `CODEMP, REFERENCIA, NUMLOTE, NUMLANC, TIPLANC, SEQUENCIA, ORIGEM, NUNICO, SEQNOTA` | Lançamento de integração contábil, gerado a partir de eventos do ERP (estoque, custo, financeiro, fiscal). |
| [`TFPFUN`](TFPFUN.SQL) | `CODEMP, CODFUNC` | Funcionários (cadastro de RH/folha de pagamento). |
| [`TGFBAR`](TGFBAR.SQL) | `CODBARRA` | Código de barras alternativo do produto. |
| [`TGFCAB`](TGFCAB.SQL) | `NUNOTA` | Cabeçalho de nota (pedido, venda, compra, ordem de produção etc.) — tabela central do módulo comercial/fiscal. |
| [`TGFCHQ`](TGFCHQ.SQL) | `NUCHQ` | Cadastro de cheques recebidos/emitidos. |
| [`TGFCOI2`](TGFCOI2.SQL) | `NUCONF, SEQCONF` | Item conferido numa conferência de expedição/recebimento. |
| [`TGFCON2`](TGFCON2.SQL) | `NUCONF` | Conferência de expedição/recebimento (cabeçalho). |
| [`TGFCTE`](TGFCTE.SQL) | `DTCONTAGEM, CODEMP, CODLOCAL, CODPROD, CONTROLE, CODVOL, CODPARC, TIPO, SEQUENCIA` | Conhecimento de Transporte Eletrônico (CT-e). |
| [`TGFCUS`](TGFCUS.SQL) | `CODPROD, CODEMP, DTATUAL, CODLOCAL, CONTROLE, NUNOTA, SEQUENCIA` | Histórico de custo do produto por empresa/local/data. |
| [`TGFDIN`](TGFDIN.SQL) | `NUNOTA, SEQUENCIA, CODIMP, CODINC` | Dados dinâmicos de impostos por item de nota (ICMS, IPI, PIS, COFINS etc.) por incidência. |
| [`TGFDTP`](TGFDTP.SQL) | `NUNOTA, SEQUENCIA, SEQPREV` | Previsão de data de um evento da nota (entrega, produção etc.). |
| [`TGFECQ`](TGFECQ.SQL) | `NUCHQ, NUEVENTO` | Eventos/movimentação de um cheque (complementa TGFCHQ). |
| [`TGFEST`](TGFEST.SQL) | `CODEMP, CODPROD, CODLOCAL, CONTROLE, CODPARC, TIPO` | Saldo de estoque por produto/local/controle (série/lote). |
| [`TGFFIN`](TGFFIN.SQL) | `NUFIN` | Título financeiro (contas a pagar/receber). |
| [`TGFGRU`](TGFGRU.SQL) | `CODGRUPOPROD` | Grupo de produto. |
| [`TGFITE`](TGFITE.SQL) | `NUNOTA, SEQUENCIA` | Itens de nota (produto, quantidade, valores e impostos por item). |
| [`TGFIXN`](TGFIXN.SQL) | `NUARQUIVO` | Controle de importação de arquivo XML de nota (NF-e/CT-e recebidos de terceiros). |
| [`TGFLOC`](TGFLOC.SQL) | `CODLOCAL` | Local de estoque (armazém/depósito). |
| [`TGFNAT`](TGFNAT.SQL) | `CODNAT` | Natureza financeira (classificação de receita/despesa). |
| [`TGFNCT`](TGFNCT.SQL) | `NUNOTA, SEQUENCIA` | Nota de crédito/documento de transporte vinculado à nota. |
| [`TGFNUM`](TGFNUM.SQL) | `ARQUIVO, CODEMP, SERIE, CODMODDOC` | Controle de numeração sequencial por tipo de documento, empresa e série. |
| [`TGFPAR`](TGFPAR.SQL) | `CODPARC` | Parceiros (clientes, fornecedores, transportadoras etc.). |
| [`TGFPRO`](TGFPRO.SQL) | `CODPROD` | Cadastro de produtos. |
| [`TGFSER`](TGFSER.SQL) | `NUNOTA, SEQUENCIA, SERIE` | Números de série/lote de produto vinculados a itens de nota. |
| [`TGFTOP`](TGFTOP.SQL) | `CODTIPOPER, DHALTER` | Tipo de Operação (TOP) — regras fiscais/contábeis por natureza de movimento. |
| [`TGFTPV`](TGFTPV.SQL) | `CODTIPVENDA, DHALTER` | Tabela de preço por vendedor/tipo de venda. |
| [`TGFVAR`](TGFVAR.SQL) | `NUNOTA, SEQUENCIA, NUNOTAORIG, SEQUENCIAORIG` | Vínculo entre notas (devolução, complementar, ligação pedido -> nota). |
| [`TGFVEN`](TGFVEN.SQL) | `CODVEND` | Vendedores. |
| [`TGFVOA`](TGFVOA.SQL) | `CODPROD, CODVOL, CONTROLE` | Volume/embalagem alternativa do produto. |
| [`TMDFMG`](TMDFMG.SQL) | `CODFILA` | Fila/controle de geração de MDF-e (Manifesto de Documentos Fiscais). |
| [`TPRAPA`](TPRAPA.SQL) | `NUAPO, SEQAPA` | Apontamento de assistência/produção por atividade (nível item). |
| [`TPRAPO`](TPRAPO.SQL) | `NUAPO` | Apontamento de produção (registro de execução de uma atividade). |
| [`TPRATV`](TPRATV.SQL) | `IDEFX` | Cadastro de atividade/etapa de produção (roteiro-mestre). |
| [`TPRCONF`](TPRCONF.SQL) | `NUCONF` | Conferência de produção (cabeçalho). |
| [`TPREFX`](TPREFX.SQL) | `IDEFX` | Estrutura/ficha técnica — roteiro de etapas de fabricação de um produto. |
| [`TPRIATV`](TPRIATV.SQL) | `IDIATV` | Item de atividade/etapa de um processo de produção (roteiro). |
| [`TPRIMPS`](TPRIMPS.SQL) | `NUMPS, SEQIMPS` | Item do Plano Mestre de Produção (produto/quantidade planejada). |
| [`TPRIPA`](TPRIPA.SQL) | `IDIPROC, CODPRODPA, CONTROLEPA` | Item de apontamento de produção (produto acabado apontado). |
| [`TPRIPROC`](TPRIPROC.SQL) | `IDIPROC` | Processo de produção (ordem de fabricação / OP). |
| [`TPRLMP`](TPRLMP.SQL) | `IDEFX, SEQMP` | Lista de materiais/produção por etapa (estrutura de consumo). |
| [`TPRLPA`](TPRLPA.SQL) | `IDPROC, CODPRODPA, CONTROLEPA` | Lista de produção — produto acabado planejado de um processo. |
| [`TPRLPI`](TPRLPI.SQL) | `IDPROC, CODPRODPA, CONTROLEPA, CODPRODPI, CONTROLEPI` | Lista de produção — item de matéria-prima (insumo) de um processo. |
| [`TPRMPS`](TPRMPS.SQL) | `NUMPS` | Plano Mestre de Produção (MPS). |
| [`TPROEST`](TPROEST.SQL) | `IDEFX, SEQOPER` | Estoque em processo de produção por etapa. |
| [`TPRPRC`](TPRPRC.SQL) | `IDPROC` | Processo de produção (cabeçalho, complementa TPRIPROC). |
| [`TPRSERPA`](TPRSERPA.SQL) | `IDIPROC, CODPRODPA, SERIEPA` | Número de série do produto acabado de um processo de produção (nativa — não confundir com a customizada AD_TPRSERPA). |
| [`TSIBAI`](TSIBAI.SQL) | `CODBAI` | Cadastro de bairro. |
| [`TSICID`](TSICID.SQL) | `CODCID` | Cadastro de cidades. |
| [`TSICTA`](TSICTA.SQL) | `CODCTABCOINT` | Conta contábil-financeira (integração contábil). |
| [`TSIEND`](TSIEND.SQL) | `CODEND` | Cadastro de endereço (logradouro). |
| [`TSIPAR`](TSIPAR.SQL) | `CHAVE, CODUSU` | Parâmetros de sistema (chave/valor) configuráveis do ERP. |
| [`TSIUFS`](TSIUFS.SQL) | `CODUF` | Cadastro de Unidades da Federação (UF). |
| [`TSIUSU`](TSIUSU.SQL) | `CODUSU` | Usuários do sistema. |

## Como recapturar / atualizar

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', 'NOME_DA_TABELA', 'SPARKPRD') FROM dual;
```

Lista e ordem de prioridade definidas em [`scripts/CAPTURA_DDL_TABELAS_FALTANTES.SQL`](../../scripts/CAPTURA_DDL_TABELAS_FALTANTES.SQL) (Bloco 2).
