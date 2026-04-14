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

> Para ver o histórico de quando cada arquivo foi movido para cá, use: `git log --follow -- inativos/<arquivo>`
