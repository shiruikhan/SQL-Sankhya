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

> Para ver o histórico de quando cada arquivo foi movido para cá, use: `git log --follow -- inativos/<arquivo>`
