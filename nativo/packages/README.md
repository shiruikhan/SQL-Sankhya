# Catálogo de Packages Nativos do Sankhya

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de packages:** 20  
**Banco:** Oracle PL/SQL  
**Origem:** Nativos do ERP Sankhya (schema SPARKPRD) — mantidos aqui apenas como referência/documentação, não são customizações da Spark. Os packages da Spark ficam em [`package/README.md`](../../package/README.md) (pasta versionada).

---

> Os 20 packages abaixo são **somente especificação**: o banco não tem `PACKAGE BODY` para nenhum deles (inventário de `scripts/CAPTURA_LISTA_PACKAGES.SQL`, 08/10/2026), nem código wrapped. Funcionam como **repositório de variáveis de sessão** compartilhadas entre triggers, procedures e functions nativas — o mesmo padrão do `PKG_SPARK_MOEDA` da Spark. O código foi capturado do banco em 08/10/2026 via `DBMS_METADATA.GET_DDL`. Atualizações do Sankhya podem alterar ou remover estes packages — revisar após cada upgrade do ERP (mesmo cuidado do `nativo/triggers/README.md`).

## Catálogo

| Package | Descrição |
|---|---|
| [`EFDICMS_PKG`](EFDICMS_PKG.SQL) | Contexto da apuracao EFD ICMS/IPI (SPED Fiscal): empresa, periodo, UF e nota em processamento. |
| [`ERROS_PKG`](ERROS_PKG.SQL) | Constantes com as mensagens de erro padrao de validacao de cadastro (registro inativo, nao analitico ou inexistente: centro de resultado, conta contabil, grupo, natureza, projeto, parceiro, produto, TOP, vendedor, etc.). |
| [`ESOCIAL_PKG`](ESOCIAL_PKG.SQL) | Estado da geracao de eventos do eSocial: se esta gerando, ambiente (P = producao), referencia, sequencia atual e data de execucao. |
| [`ESTOQUE_PKG`](ESTOQUE_PKG.SQL) | Flag V_TRANSF (S/N) que indica movimento de transferencia de estoque em andamento na sessao. |
| [`PKG_IMOBILIZADO`](PKG_IMOBILIZADO.SQL) | Flag V_DESMEMBRANDO_BEM que indica desmembramento de bem do imobilizado em andamento. |
| [`RASTRESTOQUE_PKG`](RASTRESTOQUE_PKG.SQL) | Estado do rastreamento de estoque (liberacao de execucao, rastreio via sistema, movimento de rastreio em execucao). |
| [`SYNC_PKG`](SYNC_PKG.SQL) | Flag global DSUPD_GLOBAL (S/N) usada pelo DataSync para sinalizar atualizacao em curso e suprimir validacoes. |
| [`TCBBFC_LOG_PKG`](TCBBFC_LOG_PKG.SQL) | Variaveis do fechamento contabil: rotina contabil em execucao e indicador V_UTILIZA_FECHACTB. |
| [`TCBLAN_PKG`](TCBLAN_PKG.SQL) | Variavel V_PROCRET de controle do processamento de lancamentos contabeis (TCBLAN). |
| [`TGFCAB_PKG`](TGFCAB_PKG.SQL) | Tabelas PL/SQL (associative arrays) com dados do cabecalho da nota (NUNOTA, TOP, vendedor, parceiro, tipo de movimento, totais) e flag V_FATURANDO, para contornar tabela mutante (ORA-04091) em triggers de TGFCAB. |
| [`TGFCAB_UPD_PKG`](TGFCAB_UPD_PKG.SQL) | Tabelas PL/SQL com NUNOTA, total de desdobramento e valor da nota coletados no UPDATE de TGFCAB, processados na fase AFTER STATEMENT. |
| [`TGFFIN_PKG`](TGFFIN_PKG.SQL) | Estado do financeiro: tabela de NUMDUPL, titulos de recompra, indicador de baixa parcial e flag V_VALIDA_FINANCEIRO. |
| [`TGFITE_PKG`](TGFITE_PKG.SQL) | Tabelas PL/SQL com dados dos itens (nota, sequencia, pendente, reserva, estoque, produto, local, controle, quantidades) para recalcular estoque/reserva na fase AFTER STATEMENT sem ORA-04091; inclui P_INICIOCONTEST. |
| [`TGFVEI_PKG`](TGFVEI_PKG.SQL) | Variaveis V_CODPROD e V_CODBEM da vinculacao de veiculo (TGFVEI) em processamento. |
| [`TGMTME_PKG`](TGMTME_PKG.SQL) | Variaveis de controle da meta por TOP (TGMTME): flag e valores novos/anteriores (meta, TOP, receita/despesa, usuario, compromisso). |
| [`TGMTRA_PKG`](TGMTRA_PKG.SQL) | Variaveis de controle do rastreio de metas (TGMTRA): flag e chaves de nota, financeiro, empresa, produto, parceiro, regiao e demais dimensoes. |
| [`TSIUSU_LOG_PKG`](TSIUSU_LOG_PKG.SQL) | Usuario logado na sessao (codigo e nome) para auditoria. |
| [`VALIDA_ESTOQUE_PKG`](VALIDA_ESTOQUE_PKG.SQL) | Parametros da validacao de estoque: modo normal e agrupamento por local. |
| [`VALIDA_ESTOQUE_PKG40`](VALIDA_ESTOQUE_PKG40.SQL) | Parametros da validacao de estoque (versao 4.0): validacao por empresa, tipo de reserva (com/sem reserva, ou parametro SOESTOQUE) e agrupamento por local. |
| [`VARIAVEIS_PKG`](VARIAVEIS_PKG.SQL) | Pacote central de variaveis de sessao do Sankhya: parametros de custo (por empresa/local/controle), flags de funcionalidades usadas pelo cliente (V_UTILIZA_*), controle de rastreio, validacoes de estoque, WMS, checkout e o record TYPERECCUSTO. |

## Pontos de atenção

- `VARIAVEIS_PKG` é o mais usado: as functions `STP_GET_*`, `GET_CONTROLE_CUSTO`, `GET_EMPRESA_CUSTO` e `GET_LOCAL_CUSTO` (em [`nativo/functions/`](../functions/README.md)) apenas devolvem o valor de uma variável deste package.
- `TGFCAB_PKG`, `TGFCAB_UPD_PKG`, `TGFITE_PKG` e `TGFFIN_PKG` declaram tabelas PL/SQL para guardar chaves no momento da linha e processá-las depois, evitando `ORA-04091` (tabela mutante) — o mesmo objetivo do `PKG_SPARK_MOEDA` (ver [`package/README.md`](../../package/README.md)). O uso exato (fase em que são lidas/limpas) não foi verificado, pois os fontes das triggers nativas não estão no repositório.
- `ERROS_PKG` contém as mensagens-padrão do Sankhya para cadastros inativos/inexistentes; úteis para reconhecer a origem de uma crítica vinda de trigger nativa.

## Como recapturar / atualizar

```sql
SELECT DBMS_METADATA.GET_DDL('PACKAGE_SPEC', 'NOME_DO_PACKAGE', 'SPARKPRD') FROM dual;
```

O inventário completo (status, datas, linhas, wrapped) está em `scripts/CAPTURA_LISTA_PACKAGES.SQL` (Bloco 1) e o DDL no Bloco 2 do mesmo script.
