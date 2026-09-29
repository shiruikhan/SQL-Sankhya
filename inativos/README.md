# Objetos Inativos

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  

---

## Objetivo

Esta pasta preserva objetos de banco de dados e scripts descontinuados, mantidos **apenas para referência histórica**. Nenhum objeto desta pasta está ativo em produção.

---

## Política de uso

- **Não deployar** nenhum arquivo desta pasta em produção sem revisão prévia.
- Objetos são movidos para cá quando substituídos por versão mais nova ou quando desativados a pedido da operação.
- A pasta é preservada para suportar análise de causa raiz, arqueologia de código e rollback em casos extremos.
- Arquivos aqui podem referenciar tabelas, triggers ou procedures que foram renomeadas ou removidas — não confiar nas referências sem validação.

---

## Identificação de itens

Ao mover um objeto para esta pasta, documentar aqui:

| Arquivo | Tipo | Data de inativação | Motivo |
|---|---|---|---|
| `OSINTERNA_DEFINESTATUS.SQL` | Procedure (botão de ação) | [A DEFINIR] | Botão desativado — definição de status da O.S. interna substituída por outra lógica |
| `STP_VALIDANATUREZA_SPARK.SQL` | Procedure de validação | [A DEFINIR] | Regra de validação de natureza de operação — substituída ou incorporada em outro fluxo |
| `VGF_ESTOQUEMELI_SPARK.sql` | View | [A DEFINIR] | View de estoque para o Mercado Livre — vinculada à tabela `AD_MKTPMELI`; descontinuada com a migração da integração ML |
| `TRG_INC_UPD_TPRMPS_SPARK.sql` | Trigger (`TPRMPS`) | Junho/2026 | Restaurava `TIPOPI = AD_TIPOPI` após a geração do MRP para desfazer o forçamento `UPDATE TPRLPI SET TIPOPI='O'` que existia em `STP_PCPMETA_SPARK`. Com a inativação daquele UPDATE (Jun/2026) não há mais nada a restaurar — o corpo da trigger está todo comentado. Uma trigger **ativa** de mesmo nome existe em `triggers/` (ver `triggers/README.md` §1) |
| `SPK_TRG_OSINTERNA.SQL` | Trigger (`AD_OSINTERNA`) | 28/09/2026 | Controles adicionais na O.S. Interna (versão legada). Descoberta durante o levantamento de baseline de `STATUS` (`triggers/README.md` §16): não existe mais em `ALL_TRIGGERS`, embora a tabela `AD_OSINTERNA` siga ativa com outras 3 triggers. Movida de `triggers/` sem alteração de conteúdo |
| `TRG_INC_ATUALIZAATRIB_SPARK.sql` | Trigger (`AD_MKTPMELIATRIB`) | 28/09/2026 | Populava atributos de produto (BRAND, MODEL, HEIGHT, WIDTH, WEIGHT, SELLER_SKU, GTIN) na inclusão. Mesma família `AD_MKTPMELI*` de `VGF_ESTOQUEMELI_SPARK.sql` (linha acima) — indício de resquício da integração Mercado Livre antiga. Não existe mais em `ALL_TRIGGERS`. Movida de `triggers/` sem alteração de conteúdo |
| `TRG_INC_UPD_TGFCAB_NFE_SPARK.SQL` | Trigger (`TGFCAB`) | 29/09/2026 | Versão anterior (não-compound, com `PRAGMA AUTONOMOUS_TRANSACTION` e `COMMIT`s manuais dentro do laço) da sincronização de dados de NFe entre notas de entrada/saída em transferência. Substituída pela versão compound trigger ativa em `triggers/TRG_CMP_TGFCAB_NFE_SPARK.SQL`. Descontinuada por descontinuidade do projeto proposto |
| `TRG_INC_UPD_TGSIXN_DTFIM_SPARK.SQL` | Trigger (`AD_TGSIXN`) | 29/09/2026 | Preenchia `DTFIM` do apontamento de conferência a partir da nota fiscal vinculada (via `TGFIXN.CHAVEACESSO` → `TGFCAB.CHAVENFE`/`DTMOV`). Descontinuada por descontinuidade do projeto proposto — `STP_ATUALIZADTFIM_TGSIXN_SPARK` passou a calcular `DTFIM` diretamente (ver nota em `triggers/TRG_INC_UPD_AD_TGSIXN_SPARK.SQL`) |
| `TRG_INC_UPD_TPRIMPS_SPARK2.SQL` | Trigger (`TPRIMPS`) | 29/09/2026 | Calculava saldo de meta (`TGMMET.CODMETA = 3`) por produto ao atualizar `TPRIMPS`. Descontinuada por descontinuidade do projeto proposto |
| `TRG_INS_UPD_DLT_TPRIMPS_SPARK.SQL` | Trigger (`TPRIMPS`) | 29/09/2026 | Bloqueava alteração de `TPRIMPS` quando já existia Lista de Materiais gerada (`TGFCAB.AD_NUMPS`) para o plano. Descontinuada por descontinuidade do projeto proposto |
| `TRG_TGFCAB_TRANSF_SPARK.SQL` | Trigger (`TGFCAB`) | 29/09/2026 | Variante não-compound (`BEFORE DELETE FOR EACH ROW` simples) da limpeza de referências de transferência ao deletar nota — mesma finalidade da versão compound ativa em `triggers/TRG_CMP_TRANFS_SPARK.SQL`. Descontinuada por descontinuidade do projeto proposto |
| `TRG_AVISOCONF_SPARK.sql` | Trigger (`TGFCAB`) | 29/09/2026 | Enviava e-mail (via `STP_GRAVA_FILA_BI2`) ao usuário que incluiu o pedido quando a conferência era finalizada (`TGFCON2.STATUS = 'F'`). Desativada por descontinuidade do projeto |

> Para ver o histórico de quando cada arquivo foi movido para cá, use: `git log --follow -- inativos/<arquivo>`
