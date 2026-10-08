# Catálogo de Procedures Nativas do Sankhya

**Empresa:** Spark Eletrônica
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior
**Total de procedures:** 6
**Banco:** Oracle PL/SQL
**Origem:** Nativas do ERP Sankhya (schema SPARKPRD) — referência/documentação, não são customizações da Spark.

---

> Capturadas em 08/10/2026 via `DBMS_METADATA.GET_DDL`, apenas as procedures **citadas** por triggers nativas capturadas ou por objetos da Spark (as ~200 procedures de 12/2021 não foram capturadas — ver `nativo/README.md`, "Cobertura"). Nenhuma está wrapped. Atualizações do Sankhya podem alterar estas procedures — revisar após cada upgrade do ERP.

## Catálogo

| Procedure | Descrição |
|---|---|
| [`STP_ATUALIZA_TGFEST`](STP_ATUALIZA_TGFEST.SQL) | Atualiza o saldo de TGFEST (ESTOQUE ou RESERVADO) de um produto/local/controle, criando a linha se não existir; valida estoque insuficiente (Stp_Valida_Estoque312) conforme VALEST do grupo. Chamada por TRG_INC_TGFITE. |
| [`STP_GRAVATABLOG`](STP_GRAVATABLOG.SQL) | Grava em TSILGT o log de alteração de um campo (tabela, chave, ação, valor novo/antigo) com usuário do sistema, usuário de banco, máquina, IP e programa da sessão. |
| [`STP_OBTEM_PRECO2`](STP_OBTEM_PRECO2.SQL) | Wrapper de SNK_GET_PRECO(NUTAB, CODPROD, DTVIGOR) que devolve o preço vigente em P_PRECO (OUT). Usada por SNK_PRECO. |
| [`STP_POPULA_MSG`](STP_POPULA_MSG.SQL) | Levanta ORA-20101 com a mensagem padrão "registro não cadastrado, inativo ou não analítico" para a tabela informada, usando a descrição da instância em TDDINS. |
| [`STP_VALIDA_ENQUADRAMENTO_IPI`](STP_VALIDA_ENQUADRAMENTO_IPI.SQL) | Valida a compatibilidade entre CST do IPI e código de enquadramento legal (CST 02/52 → 301–399; 04/54 → 001–099; 05/55 → 101–199). Versão 1: exige enquadramento válido mesmo quando vazio. |
| [`STP_VALIDA_ENQUADRAMENTO_IPI_2`](STP_VALIDA_ENQUADRAMENTO_IPI_2.SQL) | Mesma validação de CST x enquadramento do IPI, mas só quando o enquadramento está preenchido (CODENQIPI <> 0). Versão chamada por TRG_INC_TGFITE. |

## Observações

- `STP_VALIDA_ENQUADRAMENTO_IPI` (v1) e `STP_VALIDA_ENQUADRAMENTO_IPI_2` diferem só no tratamento de enquadramento vazio; a `TRG_INC_TGFITE` chama a `_2`.
- `STP_OBTEM_PRECO2` é só um wrapper de `SNK_GET_PRECO`; existe também `STP_OBTEM_PRECO3` (criada em 03/2026, não capturada).
