# Tabelas Referenciadas sem DDL Local

**Empresa:** Spark Eletrônica
**Gerado em:** 18/09/2026 — varredura estática do repositório (grep por `FROM`/`JOIN`/`UPDATE`/`INTO`/`TABLE`)
**Objetivo:** mapear tabelas usadas no código (triggers, procedures, functions, BI, views, reports) que ainda não têm um `.SQL` de referência em `tables/`, para priorizar a captura via `DBMS_METADATA.GET_DDL`.

> Metodologia: contagem de ocorrências de cada nome de tabela como alvo de `FROM/JOIN/UPDATE/INTO/TABLE` em todos os arquivos `.sql/.SQL/.trg/.prc/.fnc/.vw` do repositório, excluindo `tables/` (o que já temos) e `functions/nativas_sankhya/` (código de function, não DDL de tabela). Falsos positivos são possíveis (ex.: alias de CTE que por acaso segue o padrão de nome Sankhya) — validar antes de gastar tempo capturando.

---

## 1. Tabelas customizadas `AD_*` sem DDL (prioridade alta — são nossas)

Diferente das nativas, estas foram criadas pela Spark e não existem em nenhuma documentação do fabricante — se não capturarmos aqui, a estrutura só existe no banco.

| Tabela | Refs | Exemplo de uso |
|---|---:|---|
| `AD_EMBPED` | 43 | `procedures/STP_GERARVOLUMES_SPARK.SQL`, `triggers/TRG_AD_EMBPED_SPARK.SQL` |
| `AD_APOQLD` | 25 | `componentes BI/01 - Gráfico Qualidade por Operador/p2.sql` |
| `AD_CADFUNC` | 25 | `componentes BI/CARD - OS POR TECNICO MENSAL/CARD.SQL` |
| `AD_TGSCIT` | 9 | `functions/FC_GETPRECO_TRASF_SP.SQL`, `triggers/SPK_TRG_TGFCUS.SQL` |
| `AD_TGSCAB` | 7 | `procedures/STP_INTEGRAPEDIDO_AGENDADA.sql` |
| `AD_TPRCOI` | 7 | `procedures/STP_CORRIGENOTAPROD_SPARK.SQL` |
| `AD_TGFMET` | 6 | `procedures/STP_ALTERAMETA_SPARK.SQL` |
| `AD_TGFIASS` | 6 | `componentes BI/INFORMATIVO DE GESTÃO ASSISTÊNCIA (DETALHES)/*.sql` |
| `AD_TPRSERAPO` | 6 | `triggers/TRG_INC_UPD_DLT_TPRAPA_SPARK.SQL` |
| `AD_TPRSERPA` | 6 | `triggers/TRG_INC_UPD_DLT_TPRAPA_SPARK.SQL` |
| `AD_TGSSCP` | 5 | `procedures/STP_APROVA_SOLIC_COMPRA.sql` |
| `AD_TGSCUS` | 4 | `functions/FC_GETPRECO_TRASF_SP.SQL` |
| `AD_OSINTERNA` | 4 | `procedures/STP_INCMOVOSINT_SPARK.SQL` |
| `AD_MKTPMELI` | 4 | `procedures/STP_ATTESTML_SPARK.sql` |
| `AD_TGSITE` | 4 | `procedures/STP_INTEGRAPEDIDO_AGENDADA.sql` |
| `AD_FRETE` | 3 | `triggers/TRG_UPD_TGFCAB_TRANSP_SPARK.SQL` |
| `AD_TGFNCO` | 3 | `procedures/STP_INCNCONFORM_SPARK.SQL` |
| `AD_TGFPIM` | 2 | `procedures/STP_CALCULAPROPORCAO_SPARK.SQL` |
| `AD_MKTPMELIATRIB` | 2 | `procedures/STP_BUSCAATRIBML_SPARK.sql` |
| `AD_DBFECHCOMFIN` | 2 | `procedures/STP_EXCLUIRFINCOM_SPARK.sql` |
| `AD_TGSIOSI` | 2 | `procedures/STP_INCMOVOSINT_SPARK.SQL` |
| `AD_TGSPAR` | 2 | `procedures/STP_INTEGRAPEDIDO_AGENDADA.sql` |
| `AD_TGSSER` | 2 | `procedures/STP_INTEGRAPEDIDO_AGENDADA.sql` |
| `AD_SPKICAE` | 1 | `componentes BI/INFORMATIVO DE GESTÃO DA ASSISTÊNCIA EXTERNA/painelcomponentes.sql` |
| `AD_CADMKTATRIB` | 1 | `procedures/STP_BUSCAATRIBML_SPARK.sql` |
| `AD_PRVCTR` | 1 | `procedures/STP_INCLUIRLANCTO_SPARK.SQL` |
| `AD_TGSCUSBLOCOH` | 1 | `procedures/STP_VERCORCUSTO_SPARK.SQL` |
| `AD_TSIBLOCK` | 1 | `triggers/SPK_TGFCAB_TSIBLOCK.SQL` |
| `AD_TGSMDF` | 1 | `triggers/TRG_INC_UPD_CMF_SPARK.SQL` |
| `AD_TGSISCP` | 1 | `triggers/TRG_NOTIFICA_SOLIC_COMPRA.sql` |

## 2. Tabelas nativas do Sankhya mais referenciadas sem DDL (≥ 5 ocorrências)

Referência/documentação apenas (mesmo cuidado do `SNK_PRECO`: atualização do ERP pode alterar a estrutura).

| Tabela | Refs | Exemplo de uso |
|---|---:|---|
| `TGFCAB` | 208 | Cabeçalho de nota — usada em quase todo BI/procedure/trigger |
| `TGFITE` | 148 | Itens de nota |
| `TGFPRO` | 138 | Cadastro de produtos |
| `TPRIATV` | 65 | Apontamento de atividade de produção |
| `TGFPAR` | 52 | Parceiros (clientes/fornecedores) |
| `TPRAPO` | 52 | Apontamento de produção |
| `TGFSER` | 49 | Séries/lotes de produto |
| `TGFGRU` | 47 | Grupo de produto |
| `TPRIPROC` | 46 | Item de processo de produção |
| `TPRAPA` | 41 | Apontamento (assistência/produção) |
| `TPREFX` | 39 | Estrutura/ficha técnica |
| `TGFFIN` | 38 | Financeiro (títulos) |
| `TGFVEN` | 38 | Vendedores |
| `TPRPRC` | 32 | Processo de produção |
| `TGFTOP` | 30 | Tipo de operação (TOP) |
| `TPRIPA` | 24 | Item de apontamento |
| `TGFEST` | 23 | Estoque |
| `TSICID` | 23 | Cidades |
| `TMDFMG` | 23 | MDF-e / manifesto |
| `TGFECQ` | 21 | Cheques |
| `TFPFUN` | 20 | Funcionários (folha) |
| `TSIUSU` | 19 | Usuários |
| `TPRLMP` | 18 | Lista de materiais/produção |
| `TPRLPI`, `TGFNUM` | 16 | Lista de produção item / numeração |
| `TPRLPA`, `TPRMPS`, `TPRATV` | 15 | Produção (lista/MPS/atividade) |
| `TGFTPV` | 13 | Tabela de preço x vendedor |
| `TGFNCT` | 12 | Nota de crédito/transporte |
| `TGFIXN`, `TSIUFS`, `TGFCUS` | 11 | XML de nota / UFs / custo |
| `TGFVAR`, `TPRIMPS`, `TGFBAR` | 10 | Vínculo de nota (devolução) / MPS / código de barras |
| `TGFNAT`, `TGFDIN`, `TGFCHQ`, `TSIPAR` | 8 | Natureza financeira / dados dinâmicos / cheques / parâmetro sistema |
| `TGFCTE`, `TPROEST`, `TGFCOI2` | 7 | CT-e / estoque produção / conferência item |
| `TGFLOC`, `TGFVOA`, `TSICTA`, `TGFDTP`, `TCBINT`, `TPRCONF`, `TPRSERPA`, `TGFCON2`, `TSIEND`, `TSIBAI` | 6 | Local de estoque / volumes / contas / previsão / integração contábil / conferência / série / conferência / endereço / bairro |

Há também ~45 tabelas nativas com 1–4 ocorrências (lista completa disponível no script de varredura, não incluída aqui para não poluir a priorização).

---

## Próximo passo sugerido

Para capturar o DDL de qualquer item desta lista, usar a mesma consulta usada nas functions `SNK_%`, trocando `FUNCTION` por `TABLE`:

```sql
SELECT DBMS_METADATA.GET_DDL('TABLE', 'NOME_DA_TABELA', 'SPARKPRD') FROM dual;
```

Recomendação: começar pelas 30 `AD_*` (seção 1) — são nossas e não têm nenhuma documentação alternativa.
