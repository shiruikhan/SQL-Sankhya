# Catálogo de Procedures Nativas do Sankhya

**Empresa:** Spark Eletrônica
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior
**Total de procedures:** 21
**Banco:** Oracle PL/SQL
**Origem:** Nativas do ERP Sankhya (schema SPARKPRD) — referência/documentação; a Spark só customizou o que está marcado.

---

> Capturadas em 08/10/2026 via `DBMS_METADATA.GET_DDL`, apenas as procedures **chamadas** por triggers nativas capturadas ou por objetos da Spark (fechamento de dependência — lotes 1 e 2). As ~200 procedures de 12/2021 restantes não foram capturadas (ver `nativo/README.md`, "Cobertura"). Nenhuma está wrapped. Atualizações do Sankhya podem alterar estas procedures — revisar após cada upgrade do ERP.

## Catálogo

| Procedure | Descrição |
|---|---|
| [`GET_IMPOSTOS_RASTSTULTENTRADA`](GET_IMPOSTOS_RASTSTULTENTRADA.SQL) | Apura os impostos consumidos (ICMS, base e valor de ST, base/valor/percentual de FCP-ST de entrada anterior) proporcionalmente à quantidade de saída, para o rastreamento de estoque de um item de nota; usa TGFITE/TGFVAR/TGFDIN e o parâmetro UTILBASEREDRAST. |
| [`GET_IMPOSTOS_RAT_EST`](GET_IMPOSTOS_RAT_EST.SQL) | Versão mais completa (criada em 04/2026) da apuração de impostos rateados no rastreamento de estoque: considera notas de imposto de rastreamento digitadas, valores anteriores digitados no item e notas de complemento; devolve ICMS, base/valor de ST e FCP-ST (mesma assinatura de GET_IMPOSTOS_RASTSTULTENTRADA). |
| [`SNK_ORIGEM_DESTINO_ENTREGA`](SNK_ORIGEM_DESTINO_ENTREGA.SQL) | Resolve cidade e UF de origem, destino e entrega da nota a partir de empresa, parceiros, remetente e contato de entrega, conforme o tipo de movimento; usa STP_END_ICMS. |
| [`SNK_VAL_UTIL_PRODUTO_GENERICO`](SNK_VAL_UTIL_PRODUTO_GENERICO.SQL) | Bloqueia (ORA-20101) a movimentação de produto genérico (TGFGXE) em TOP que atualiza livros fiscais; chamada por TRG_INC_UPD_TGFITE_TGFGXE e TRG_INC_UPD_TGFCAB_TGFGXE. Usa PRAGMA AUTONOMOUS_TRANSACTION. |
| [`STP_ATUALIZA_TGFEST`](STP_ATUALIZA_TGFEST.SQL) | Atualiza o saldo de TGFEST (ESTOQUE ou RESERVADO) de um produto/local/controle, criando a linha se não existir; valida estoque insuficiente (Stp_Valida_Estoque312) conforme VALEST do grupo. Chamada por TRG_INC_TGFITE. |
| [`STP_GRAVATABLOG`](STP_GRAVATABLOG.SQL) | Grava em TSILGT o log de alteração de um campo (tabela, chave, ação, valor novo/antigo) com usuário do sistema, usuário de banco, máquina, IP e programa da sessão. |
| [`STP_LOGTSIALT`](STP_LOGTSIALT.SQL) | Grava em TSIALT o novo conteúdo de um campo alterado (tabela, chave, campo, data/hora): atualiza o registro se já existe a mesma combinação, senão insere. É a mais chamada pelas triggers nativas (24 chamadas). |
| [`STP_MSG_CERTIFIC_CODINST`](STP_MSG_CERTIFIC_CODINST.SQL) | Devolve a descrição de uma instância (centro de resultado, natureza, projeto, TOP, local, conta bancária …) a partir do nome da instância e da chave, para compor mensagens do módulo de certificação. |
| [`STP_MSG_CERTIFIC_TIPO`](STP_MSG_CERTIFIC_TIPO.SQL) | Devolve o rótulo textual (usuário, empresa, vendedor, funcionário ou 'Regras Gerais') de um tipo/chave, para mensagens do módulo de certificação. |
| [`STP_OBTEM_DATAS_ARMAZEM`](STP_OBTEM_DATAS_ARMAZEM.SQL) | Calcula as datas de referência de entrada e de cobrança de armazenagem (por quinzena, conforme a isenção do contrato em TCSPSC) para o módulo de armazém/contratos. |
| [`STP_OBTEM_PRECO2`](STP_OBTEM_PRECO2.SQL) | Wrapper de SNK_GET_PRECO(NUTAB, CODPROD, DTVIGOR) que devolve o preço vigente em P_PRECO (OUT). Usada por SNK_PRECO. |
| [`STP_POPULA_MSG`](STP_POPULA_MSG.SQL) | Levanta ORA-20101 com a mensagem padrão "registro não cadastrado, inativo ou não analítico" para a tabela informada, usando a descrição da instância em TDDINS. |
| [`STP_PRODALTERNATIVO`](STP_PRODALTERNATIVO.SQL) | Mantém e propaga a cadeia de produtos alternativos/substitutos de TGFPRO (CODPRODSUBST), usando a tabela temporária TEMP_PRODALT. |
| [`STP_RASTREAMENTO_EST_ITENS`](STP_RASTREAMENTO_EST_ITENS.SQL) | Rotina de rastreamento de estoque por item de nota (criada em 05/2026): liga itens de saída às entradas de origem consumindo/devolvendo o saldo de TGFITS (P_TIPO: F = fazer NEW, D = desfazer OLD). |
| [`STP_TIM_INSERT_TIMDTL`](STP_TIM_INSERT_TIMDTL.SQL) | Insere um lançamento de detalhe (TIMDTL) de uma parcela (NUFIN) no módulo TIM (locação), com recebedor/repassa-para conforme o sinal do valor; chamada pelas triggers de TGFFIN. |
| [`STP_TIM_INSERT_TIMLDT`](STP_TIM_INSERT_TIMLDT.SQL) | Insere um lançamento (TIMLDT) de uma parcela (NUFIN) no módulo TIM (locação), com recebedor/repassa-para conforme o sinal do valor; chamada pelas triggers de TGFFIN. |
| [`STP_TROCA_NUMTRANSF`](STP_TROCA_NUMTRANSF.SQL) | Troca o NUMTRANSF de TGMTRA (antigo para novo) para a nota e suas variações (SNK_GET_VAR), no compromisso de maior CODMETA; usada por TRG_INC_TGFVAR. |
| [`STP_VALIDA_ENQUADRAMENTO_IPI`](STP_VALIDA_ENQUADRAMENTO_IPI.SQL) | Valida a compatibilidade entre CST do IPI e código de enquadramento legal (CST 02/52 → 301–399; 04/54 → 001–099; 05/55 → 101–199). Versão 1: exige enquadramento válido mesmo quando vazio. |
| [`STP_VALIDA_ENQUADRAMENTO_IPI_2`](STP_VALIDA_ENQUADRAMENTO_IPI_2.SQL) | Mesma validação de CST x enquadramento do IPI, mas só quando o enquadramento está preenchido (CODENQIPI <> 0). Versão chamada por TRG_INC_TGFITE. |
| [`STP_VALIDA_ESTOQUE40`](STP_VALIDA_ESTOQUE40.SQL) **(customização Spark)** | Valida o estoque disponível de um produto conforme o VALEST do grupo (I/N/E/G/S/L), considerando reserva, WMS e controle/lote; devolve P_QUANTEST e P_VALEST. CONTÉM CUSTOMIZAÇÃO DA SPARK (ver Observações). |
| [`STP_VALIDA_VEICULO`](STP_VALIDA_VEICULO.SQL) | Valida que o veículo (TGFVEI) existe e está ativo; senão levanta ORA-20101 com ERROS_PKG.ERRO_VEICULO_NAOATIVO. |

## Observações

- `STP_VALIDA_ENQUADRAMENTO_IPI` (v1) e `STP_VALIDA_ENQUADRAMENTO_IPI_2` diferem só no tratamento de enquadramento vazio; a `TRG_INC_TGFITE` chama a `_2`.
- `STP_OBTEM_PRECO2` é só um wrapper de `SNK_GET_PRECO`; existe também `STP_OBTEM_PRECO3` (criada em 03/2026, não capturada).
- `STP_VALIDA_ESTOQUE40`: único caso desta pasta com customização da Spark — ver `nativo/README.md`, "Customizações da Spark em objetos nativos".
- Ainda não capturada: `STP_END_ICMS` (chamada por `SNK_ORIGEM_DESTINO_ENTREGA`).
