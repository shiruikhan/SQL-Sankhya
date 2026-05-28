# Catálogo de Triggers

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de triggers:** 82  
**Banco:** Oracle PL/SQL  

---

## Convenção de nomenclatura

| Prefixo | Significado |
|---|---|
| `TRG_` | Trigger padrão atual |
| `SPK_` | Trigger com nomenclatura legada (anterior ao padrão `TRG_`) |
| `_SPARK` | Sufixo identificando customização da Spark Eletrônica |

Nomenclatura de tabelas-alvo mais comuns: `TGFCAB` (cabeçalho de nota), `TGFITE` (itens), `TGFPAR` (parceiros), `TGFFIN` (financeiro), `TPRAPA` (apontamento produção).

---

## Catálogo por Domínio

### 1. Produção / PCP

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPD_TPRMPS_SPARK.SQL` | `TRG_INC_UPD_TPRMPS_SPARK` | `TPRMPS` | INSERT, UPDATE | Controla integridade e atualizações no Plano Mestre de Produção |
| `TRG_INC_UPD_TPRPRC_SPARK.SQL` | `TRG_INC_UPD_TPRPRC_SPARK` | `TPRPRC` | INSERT, UPDATE | Valida e sincroniza processo produtivo |
| `TRG_INC_UPD_TPRIPROC_SPARK.SQL` | `TRG_INC_UPD_TPRIPROC_SPARK` | `TPRIPROC` | INSERT, UPDATE | Controla itens de processo de produção |
| `TRG_INC_UPD_TPRCONF_SPARK.SQL` | `TRG_INC_UPD_TPRCONF_SPARK` | `TPRCONF` | INSERT, UPDATE | Valida configurações de produção |
| `TRG_INC_UPD_TPRIMRP_SPARK.SQL` | `TRG_INC_UPD_TPRIMRP_SPARK` | `TPRIMRP` | INSERT, UPDATE | Controla itens do MRP |
| `TRG_INC_UPD_TPRROPE_PROD_SPARK.SQL` | `TRG_INC_UPD_TPRROPE_PROD_SPARK` | `TPRROPE` | INSERT, UPDATE | Gerencia roteiros de produção |
| `TRG_INC_UPD_DLT_TPRAPA_SPARK.SQL` | `TRG_INC_UPD_DLT_TPRAPA_SPARK` | `TPRAPA` | INSERT, UPDATE, DELETE | Valida apontamentos de produção; controla inclusão, alteração e exclusão |
| `TRG_INC_UPD_DLT_TPRIPA_SPARK.SQL` | `TRG_INC_UPD_DLT_TPRIPA_SPARK` | `TPRIPA` | INSERT, UPDATE, DELETE | Controla itens de apontamento de produção |
| `TRG_VAL_AD_CODFUNC_TPRAPA.SQL` | `TRG_VAL_AD_CODFUNC_TPRAPA` | `TPRAPA` | INSERT, UPDATE | Valida se o código de colaborador (`AD_CODFUNC`) é válido no apontamento |
| `TRG_VAL_SETOR_CODFUNC_TPRAPA.SQL` | `TRG_VAL_SETOR_CODFUNC_TPRAPA` | `TPRAPA` | INSERT, UPDATE | Valida se o colaborador pertence ao setor da etapa do apontamento (usa `AD_MAP_SETOR_FUNC`) |
| `TRG_INC_UPD_TGFCAB_PROD_SPARK.SQL` | `TRG_INC_UPD_TGFCAB_PROD_SPARK` | `TGFCAB` | INSERT, UPDATE | Controla cabeçalho de ordens de produção |
| `TRG_DEL_TPRSERPA_SPARK3.SQL` | `TRG_DEL_TPRSERPA_SPARK3` | `TPRSERPA` | DELETE | Remove séries de produção vinculadas ao processo excluído |
| `TRG_INC_TPRSERPA_SPARK2.SQL` | `TRG_INC_TPRSERPA_SPARK2` | `TPRSERPA` | INSERT | Valida séries na inclusão de processos de produção |
| `TRG_INC_TPRCOI_SPARK.SQL` | `TRG_INC_TPRCOI_SPARK` | `TPRCOI` | INSERT | Controla componentes de ordens internas de produção |
| `TRG_INC_TPRCOI_SPARK2.SQL` | `TRG_INC_TPRCOI_SPARK2` | `TPRCOI` | INSERT | Complementa validação de componentes de O.I. |
| `TRG_INC_TPRLPA_SPARK.SQL` | `TRG_INC_TPRLPA_SPARK` | `TPRLPA` | INSERT | Valida inclusão de lote padrão de produção |
| `TRG_APOQLD_INS_SPARK.SQL` | `TRG_APOQLD_INS_SPARK` | `TPRAPOQLD` | INSERT | Controla quantidade de lote no apontamento |

---

### 2. Nota Fiscal / Movimentação (TGFCAB / TGFITE)

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_CMP_TGFCAB_NFE_SPARK.SQL` | `TRG_CMP_TGFCAB_NFE_SPARK` | `TGFCAB` | UPDATE (COMPOUND) | Copia dados da NF-e de entrada (valores ICMS, IPI, série, chave) para itens |
| `TRG_INC_TGFCAB_DC_SPARK.SQL` | `TRG_INC_TGFCAB_DC_SPARK` | `TGFCAB` | INSERT | Inicializa campos customizados do cabeçalho na inclusão de nota |
| `TRG_UPD_TGFCAB_DTFAT_SPARK.SQL` | `TRG_UPD_TGFCAB_DTFAT_SPARK` | `TGFCAB` | UPDATE | Preenche data de faturamento ao confirmar nota |
| `TRG_UPD_TGFCAB_IMF_SPARK.SQL` | `TRG_UPD_TGFCAB_IMF_SPARK` | `TGFCAB` | UPDATE | Atualiza indicador de movimentação financeira |
| `TRG_UPD_TGFCAB_TRANSP_SPARK.SQL` | `TRG_UPD_TGFCAB_TRANSP_SPARK` | `TGFCAB` | UPDATE | Sincroniza dados de transportadora na nota |
| `TRG_INC_UPD_TGFCAB_PREVENT.SQL` | `TRG_INC_UPD_TGFCAB_PREVENT` | `TGFCAB` | INSERT, UPDATE | Controla previsão de entrega em pedidos de venda |
| `TRG_DEL_TGFCAB_CLEAN_SPARK.SQL` | `TRG_DEL_TGFCAB_CLEAN_SPARK` | `TGFCAB` | DELETE | Limpa registros dependentes ao excluir cabeçalho (AD_TGSLCB, AD_TGSCTF) |
| `TRG_CMP_TRANFS_SPARK.SQL` | `TRG_CMP_TRANFS_SPARK` | `TGFCAB` | UPDATE (COMPOUND) | Gerencia transferências entre empresas no cabeçalho |
| `TRG_TGFITE_SPARK1.SQL` | `TRG_TGFITE_SPARK1` | `TGFITE` | INSERT, UPDATE | Validações gerais em itens de nota (trigger de uso múltiplo) |
| `TRG_INC_UPD_TGFITE_SPARK.SQL` | `TRG_INC_UPD_TGFITE_SPARK` | `TGFITE` | INSERT, UPDATE | Complementa validações de itens (segunda camada) |
| `TRG_INC_UPD_TGFITE_SPARK2.SQL` | `TRG_INC_UPD_TGFITE_SPARK2` | `TGFITE` | INSERT, UPDATE | Terceira camada de validações de item |
| `TRG_UPT_TGFITE.SQL` | `TRG_UPT_TGFITE` | `TGFITE` | UPDATE | Atualiza campos específicos em alterações de item |
| `SPK_UPD_INS_TGFITE_CONSUMOPRD.SQL` | `SPK_UPD_INS_TGFITE_CONSUMOPRD` | `TGFITE` | INSERT, UPDATE | Controla consumo de matéria-prima em produção nos itens |
| `TRG_ATUALIZA_STATUS_NUNOTA.sql` | `TRG_ATUALIZA_STATUS_NUNOTA` | `[customizada]` | UPDATE | Atualiza status de nota quando `NUNOTA` é preenchido |
| `TRG_CMP_TGFVAR_NUNOTASIT.SQL` | `TRG_CMP_TGFVAR_NUNOTASIT` | `TGFVAR` | UPDATE (COMPOUND) | Sincroniza `NUNOTA` em variáveis de nota |
| `TRG_INC_TGFVAR_SPARK.SQL` | `TRG_INC_TGFVAR_SPARK` | `TGFVAR` | INSERT | Copia dados de embalagem (`AD_EMBPED`) da nota original para a nota de variação quando a nota de origem já possui registro de embarque |
| `TRG_INC_UPD_TGFVAR_SPARK.SQL` | `TRG_INC_UPD_TGFVAR_SPARK` | `TGFVAR` | INSERT, UPDATE | Controla variáveis customizadas de nota |
| `TRG_UPD_TGFCAB_MOEDA_SPARK2.sql` | `TRG_UPD_TGFCAB_MOEDA_SPARK2` | `TGFCAB` | UPDATE (COMPOUND) | Recalcula `VLRUNITMOE`/`VLRTOTMOE` dos itens quando `VLRMOEDA` é alterado no cabeçalho (TOPs 1008/1009). Usa compound trigger para evitar ORA-04091; comunica valores via `PKG_SPARK_MOEDA` |
| `TRG_TGFNCT_SPARK.SQL` | `TRG_TGFNCT_SPARK` | `TGFNCT` | INSERT, UPDATE | Controla naturezas de nota |

---

### 3. Compras / Solicitação de Compra

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_NOTIFICA_SOLIC_COMPRA.sql` | `TRG_NOTIFICA_SOLIC_COMPRA` | `AD_TGSSCP` | INSERT | Dispara notificação ao aprovador quando uma nova solicitação de compra é criada |
| `TRG_STATUS_PADRAO_SC.sql` | `TRG_STATUS_PADRAO_SC` | `AD_TGSSCP` | INSERT | Define status padrão `EA` (Em Aprovação) ao incluir nova solicitação |
| `TRG_BLOQUEIA_EDICAO_STATUS_CR.sql` | `TRG_BLOQUEIA_EDICAO_STATUS_CR` | `AD_TGSSCP` | UPDATE | Impede qualquer alteração quando status = `CR` (Compra Realizada) |
| `TRG_BLOQUEIA_DELETE_SC.sql` | `TRG_BLOQUEIA_DELETE_SC` | `AD_TGSSCP` | DELETE | Bloqueia exclusão de solicitações em estados que não permitem remoção |
| `TRG_VALIDA_PRAZO_SC.sql` | `TRG_VALIDA_PRAZO_SC` | `AD_TGSSCP` | INSERT, UPDATE | Valida prazo informado na solicitação conforme regras de negócio |
| `TRG_INC_UPD_AD_TGSCMP_SPARK.SQL` | `TRG_INC_UPD_AD_TGSCMP_SPARK` | `AD_TGSCMP` | INSERT, UPDATE | Controla campos de comparativo de preço no processo de compra |

---

### 4. Logística / Frete / Embarque

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_COTAFRETE_SPARK.SQL` | `TRG_COTAFRETE_SPARK` | `TGFCAB` | INSERT, UPDATE | Dispara cotação de frete ao salvar cabeçalho de nota de saída |
| `TRG_COTAFRETE_EMB_SPARK.SQL` | `TRG_COTAFRETE_EMB_SPARK` | `[embarque]` | INSERT, UPDATE | Dispara cotação de frete ao confirmar embarque (agrupa por caixas) |
| `TRG_FRETE_CIF_MTKPL_SPARK.sql` | `TRG_FRETE_CIF_MTKPL_SPARK` | `TGFCAB` | INSERT, UPDATE | Força `CIF_FOB = 'C'` e `TIPFRETE = 'N'` em notas da empresa 2 com tipo de venda 78, TOP 1005 e vendedor 5 (vendas marketplace) |
| `TRG_AD_EMBPED_SPARK.SQL` | `TRG_AD_EMBPED_SPARK` | `AD_EMBPED` | INSERT, UPDATE | Controla associação de pedidos ao embarque |
| `TRG_TGSCAB_TRANSP_SPARK.SQL` | `TRG_TGSCAB_TRANSP_SPARK` | `TGSCAB` | INSERT, UPDATE | Valida e preenche transportadora no separador |
| `TRG_INC_UPD_INFCOLETA.SQL` | `TRG_INC_UPD_INFCOLETA` | `[coleta]` | INSERT, UPDATE | Atualiza informações de coleta logística |

---

### 5. Assistência Técnica / Ordem de Serviço

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_UPD_OSINTERNA.SQL` | `TRG_UPD_OSINTERNA` | `[O.S.]` | UPDATE | Envia e-mail ao criador da O.S. quando há mudança de status |
| `TRG_UPD_OSINTERNA_DHFIM.SQL` | `TRG_UPD_OSINTERNA_DHFIM` | `[O.S.]` | UPDATE | Grava data e hora de finalização (`DHFIM`) quando status muda para finalizado |
| `TRG_INS_OSSTATUS_SPARK.SQL` | `TRG_INS_OSSTATUS_SPARK` | `[O.S.]` | INSERT | Define status inicial da Ordem de Serviço |
| `SPK_TRG_OSINTERNA.SQL` | `SPK_TRG_OSINTERNA` | `[O.S.]` | INSERT, UPDATE | Controles adicionais na O.S. Interna (versão legada) |
| `SPK_TGFASS_INC.SQL` | `SPK_TGFASS_INC` | `TGFASS` | INSERT | Automação na inclusão de registros de assistência |
| `SPK_TGFASS_INCUPD.SQL` | `SPK_TGFASS_INCUPD` | `TGFASS` | INSERT, UPDATE | Validações adicionais na assistência (inclusão e alteração) |

---

### 6. Séries / Conferência

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_TGFSER_SPARK.SQL` | `TRG_INC_TGFSER_SPARK` | `TGFSER` | INSERT | Valida inclusão de série de produto na nota |
| `TRG_DLT_TGFSER_SPARK.SQL` | `TRG_DLT_TGFSER_SPARK` | `TGFSER` | DELETE | Controla exclusão de série — impede remoção em estados confirmados |
| `TRG_TGFCON2_SPARK.SQL` | `TRG_TGFCON2_SPARK` | `TGFCON2` | INSERT, UPDATE | Controla registros de conferência de documentos |
| `TRG_TGFCOI2_SPARK.SQL` | `TRG_TGFCOI2_SPARK` | `TGFCOI2` | INSERT, UPDATE | Controla itens de conferência (COI) |

---

### 7. Financeiro

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_REFORCA_NAT_FIN.sql` | `TRG_REFORCA_NAT_FIN` | `TGFFIN` | INSERT, UPDATE | Reforça natureza financeira e centro de custo baseado no cabeçalho da nota |
| `SPK_TGFFIN_LOG.SQL` | `SPK_TGFFIN_LOG` | `TGFFIN` | INSERT, UPDATE, DELETE | Log de alterações nos lançamentos financeiros |
| `TRG_INCDEVCH_SPARK.SQL` | `TRG_INCDEVCH_SPARK` | `[cheque/dev]` | INSERT | Controla inclusão de devolução/cheque |
| `TRG_INC_AD_TGFFTA_SPARK.SQL` | `TRG_INC_AD_TGFFTA_SPARK` | `AD_TGFFTA` | INSERT | Controla lançamento de adiantamento financeiro |

---

### 8. Parceiros / Cadastros

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_UPD_TGFPAR_UF_SPARK.SQL` | `TRG_UPD_TGFPAR_UF_SPARK` | `TGFPAR` | UPDATE | Atualiza UF do parceiro baseada na cidade cadastrada |
| `TRG_INC_TSICID_SPARK.SQL` | `TRG_INC_TSICID_SPARK` | `TSICID` | INSERT | Valida município fiscal obrigatório (`CODMUNFIS`) e normaliza `NOMECID` para o valor canônico já cadastrado (case-insensitive), forçando a AK para que o Sankhya reutilize o registro existente em vez de criar duplicata |
| `TRG_INC_TGFPAR_SPARK.SQL` | `TRG_INC_TGFPAR_SPARK` | `TGFPAR` | INSERT | Em Pessoa Física sem vendedor associado (`TIPPESSOA = 'F'`, `CODVEND = 0`), força `APLICLEITRANSP = 'S'` e `IPIINCICMS = 'S'` e replica o e-mail principal em `EMAILNFE` |
| `TRG_INC_UPD_CMF_SPARK.SQL` | `TRG_INC_UPD_CMF_SPARK` | `[CMF]` | INSERT, UPDATE | Atualiza nome de cidade (executa somente em INSERT ou quando `NOMECID` é alterado) |
| `SPK_INS_UPD_TGFCAB_AVISOPARC.SQL` | `SPK_INS_UPD_TGFCAB_AVISOPARC` | `TGFCAB` | INSERT, UPDATE | Exibe aviso de restrições do parceiro ao movimentar nota |
| `TRG_UPD_TGSLOGLIB_SPARK.SQL` | `TRG_UPD_TGSLOGLIB_SPARK` | `TGSLOGLIB` | UPDATE | Atualiza log de liberações do parceiro |

---

### 9. Notificações / Avisos / E-mail

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_AVISOCONF_SPARK.sql` | `TRG_AVISOCONF_SPARK` | `TGFCAB` | UPDATE | Envia aviso quando pedido de venda tem conferência finalizada |
| `TRG_UPD_AVISOSPARK.SQL` | `TRG_UPD_AVISOSPARK` | `[avisos]` | UPDATE | Atualiza status de aviso após ação do destinatário |
| `TRG_INC_TGFIXN_EMAIL_SPARK.SQL` | `TRG_INC_TGFIXN_EMAIL_SPARK` | `TGFIXN` | INSERT | Dispara envio de e-mail na inclusão de XML de CT-e/NF-e importado |
| `SPK_INS_UPD_CODLOCALDEST.SQL` | `TRG_INS_UPD_CODLOCALDEST` | `TGFITE` | INSERT, UPDATE | Controla código de local de destino em itens com notificação associada |

---

### 10. Produto / Estoque

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPT_TGFPRO_SPARK.SQL` | `TRG_INC_UPT_TGFPRO_SPARK` | `TGFPRO` | INSERT, UPDATE | Valida e sincroniza campos do cadastro de produto |
| `TRG_INC_UPD_AD_TPRSERPA_SPARK.SQL` | `TRG_INC_UPD_AD_TPRSERPA_SPARK` | `AD_TPRSERPA` | INSERT, UPDATE | Controla séries de PA no processo produtivo |
| `TRG_INC_ATUALIZAATRIB_SPARK.sql` | `TRG_INC_ATUALIZAATRIB_SPARK` | `[atributos]` | INSERT | Atualiza atributos customizados na inclusão |
| `SPK_TRG_INS_TGFCUS.SQL` | `SPK_TRG_INS_TGFCUS` | `TGFCUS` | INSERT | Controla inserção de custos de produto |
| `SPK_TRG_TGFCUS.SQL` | `SPK_TRG_TGFCUS` | `TGFCUS` | INSERT, UPDATE | Valida atualizações de custo |

---

### 11. Integrações / E-commerce

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPD_INTEGRA.sql` | `TRG_INC_UPD_INTEGRA` | `[integração]` | INSERT, UPDATE | Sincroniza dados para integração com sistemas externos |
| `SPK_INS_UPD_TWFIVAR_CODIGONOVO.SQL` | `SPK_INS_UPD_TWFIVAR_CODIGONOVO` | `TWFIVAR` | INSERT, UPDATE | Mantém código novo em variáveis de integração WFI |

---

### 12. Validação / Controle de Regras

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_VAL_CSTIPI_SPARK.SQL` | `TRG_VAL_CSTIPI_SPARK` | `TGFITE` | INSERT, UPDATE | Valida CST/IPI — bloqueia se campo for 0 ou nulo em operações que exigem |
| `TRG_SPKCAE_INC_SPARK.SQL` | `TRG_SPKCAE_INC_SPARK` | `AD_SPKCAE` | INSERT | Preenche campos automáticos na inclusão de cadastro especial |
| `SPK_TGFCAB_TSIBLOCK.SQL` | *(INATIVADA)* | `TGFCAB` | — | Bloqueava pedidos com data de previsão de entrega retroativa — desativada a pedido |

---

### 13. Trigger Nativa (pasta `trigger_nativa/`)

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC.TGFITE.sql` | `TRG_INC_TGFITE` | `TGFITE` | BEFORE INSERT | Trigger nativa do Sankhya com lógicas de validação de agrupamento mínimo, lote, CFOP e estoque adicionadas pela Spark |

---

## Observações Gerais

- Todas as triggers usam `RAISE_APPLICATION_ERROR` com códigos no intervalo `-20001` a `-20999` para erros de negócio identificáveis.
- Triggers com sufixo `2` ou `3` são versões evolutivas que coexistem por compatibilidade com a plataforma Sankhya.
- Triggers marcadas como **INATIVADAS** nos comentários do código não são executadas, mas são preservadas para referência histórica.
- Erros críticos são registrados na tabela `AD_LOG_ERROS` (quando configurado na trigger).
