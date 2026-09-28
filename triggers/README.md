# Catálogo de Triggers

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de triggers:** 88  
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
| `TRG_TPRCOI_REPLICA_PA.sql` | `TRG_TPRCOI_REPLICA_PA` | `TPRCOI` | INSERT, UPDATE | Replica `CODBARRA`/`CODPROD` para `CONTROLEPA`/`CODPRODPA` na própria linha (padrão *PA* das tabelas de produção). Trigger puramente atribuidora; `TRG_INC_TPRCOI_SPARK`/`SPARK2` usam `FOLLOWS` para rodar depois dela |

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
| `TRG_UPD_DIFALPB_SPARK.sql` | `TRG_UPD_DIFALPB_SPARK` | `TGFCAB` | AFTER UPDATE OF `STATUSNFE` | Após aprovação da NF-e (`STATUSNFE` → `'A'`), recalcula base (`BASEDIFAL`) e valor (`VLRDIFALDEST`) do DIFAL destino em `TGFDIN`, para destinatários da UF configurada (`V_CODUF_PB = 17`, PB) classificados como consumo (`TGFPAR.CLASSIFICMS = 'C'`). Alíquotas fixas (interna 20%, DIFAL 13%). Loga em `AD_LOG_ERROS` e relança o erro (bloqueia a aprovação) |

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
| `TRG_COTAFRETE_SPARK.SQL` | `TRG_COTAFRETE_SPARK` | `TGFCAB` | INSERT, UPDATE | Dispara cotação de frete ao salvar cabeçalho de nota de saída; se `CODPARCREDESPACHO` estiver preenchido, cota até a transportadora de redespacho em vez do parceiro de destino |
| `TRG_COTAFRETE_EMB_SPARK.SQL` | `TRG_COTAFRETE_EMB_SPARK` | `AD_TGSCTF` | INSERT, UPDATE | Grava dimensões e peso por caixa (`PESOITEM`) em `AD_TGSLCB`, agrupando por embalagem; rateia `PESOTOT` proporcionalmente entre os grupos |
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
| `TRG_TGFASS_VLRCONSERTO_SPARK.SQL` | `TRG_TGFASS_VLRCONSERTO_SPARK` | `AD_TGFASS` | INSERT, UPDATE | Preenche `VLRCONSERTO` via `SNK_PRECO(14, T_CODPROD)` e `VLRSERVTECNICO` via `SNK_PRECO(15, T_CODPROD)`, cada um quando o respectivo campo está nulo/zerado. `FOLLOWS SPK_TGFASS_INC` para garantir `T_CODPROD` já preenchido |

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
| `TRG_UPD_TGSLOGLIB_SPARK.SQL` | *(INATIVADA)* | `TSILIB` | UPDATE | Atualizava log de liberações do parceiro — estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026 (ver §15) |

---

### 9. Notificações / Avisos / E-mail

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_AVISOCONF_SPARK.sql` | `TRG_AVISOCONF_SPARK` | `TGFCAB` | UPDATE | Envia aviso quando pedido de venda tem conferência finalizada |
| `TRG_UPD_AVISOSPARK.SQL` | `TRG_UPD_AVISOSPARK` | `[avisos]` | UPDATE | Atualiza status de aviso após ação do destinatário |
| `TRG_INC_TGFIXN_EMAIL_SPARK.SQL` | *(INATIVADA)* | `TGFIXN` | INSERT | Disparava envio de e-mail na inclusão de XML de CT-e/NF-e importado — estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026 (ver §15) |
| `SPK_INS_UPD_CODLOCALDEST.SQL` | `TRG_INS_UPD_CODLOCALDEST` | `TGFITE` | INSERT, UPDATE | Controla código de local de destino em itens com notificação associada |
| `TRG_NOTIF_PARCERIA_SPARK.sql` | `TRG_NOTIF_PARCERIA_SPARK` | `AD_TGSTPP` | AFTER INSERT, UPDATE | Notificações por e-mail do fluxo de triagem de parceria (influenciadores/patrocínio): nova solicitação → SAC; 1º parecer do SAC → Comercial; 1ª decisão comercial → SAC. Traduz campos multi-escolha via `TDDCAM`/`TDDOPC`; grava na fila via `STP_GRAVA_FILA_BI2`; loga em `AD_LOG_ERROS` |

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
| `TRG_VAL_CSTIPI_SPARK.SQL` | *(INATIVADA)* | `TGFITE` | INSERT, UPDATE | Validava CST/IPI — bloqueava se campo fosse 0 ou nulo em operações que exigem. Estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026, bloqueando um UPDATE de rotina (`QTDENTREGUE`/`QTDFIXADA`) disparado pela nativa `TRG_INC_TGFVAR` sobre um item legado sem CST IPI preenchido (ver §15) |
| `TRG_SPKCAE_INC_SPARK.SQL` | `TRG_SPKCAE_INC_SPARK` | `AD_SPKCAE` | INSERT | Preenche campos automáticos na inclusão de cadastro especial |
| `SPK_TGFCAB_TSIBLOCK.SQL` | *(INATIVADA)* | `TGFCAB` | — | Bloqueava pedidos com data de previsão de entrega retroativa — desativada a pedido |

---

### 13. Conferência de Importação de XML (`AD_TGSIXN`)

Apontamento de conferência de notas importadas, criado direto na tela de
`AD_TGSIXN` (ver `tables/AD_TGSIXN.SQL` e `procedures/README.md` §14).

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_AD_TGSIXN_SPARK.SQL` | `TRG_INC_AD_TGSIXN_SPARK` | `AD_TGSIXN` | BEFORE INSERT | Preenche a identidade do apontamento: `CODUSUINC`, `DTINI`, `CODEMP = 1`, e busca `NUMNOTA`/`DHEMISS` em `TGFIXN` pelo `NUARQUIVO`; inicializa `DURACAO_DIAS_UTEIS` |
| `TRG_INC_UPD_AD_TGSIXN_SPARK.SQL` | `TRG_INC_UPD_AD_TGSIXN_SPARK` | `AD_TGSIXN` | BEFORE INSERT, UPDATE | Mantém `STATUS` coerente com `DTFIM`: `1` (aberto) enquanto `DTFIM` nula, `2` (finalizado) quando preenchida — sempre recalculado, sobrepõe valor manual |
| `TRG_UPD_AD_TGSIXN_SPARK.SQL` | `TRG_UPD_AD_TGSIXN_SPARK` | `AD_TGSIXN` | BEFORE UPDATE | Torna imutáveis os campos de identidade (`NUCONF`, `CODUSUINC`, `NUARQUIVO`, `DTINI`, `CODEMP`, `NUMNOTA`, `DHEMISS`); `CODFUNC` (conferente) só pode ser setado uma vez; `OBSERVACAO` livre |

---

### 14. Trigger Nativa (pasta `trigger_nativa/`)

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC.TGFITE.sql` | `TRG_INC_TGFITE` | `TGFITE` | BEFORE INSERT | Trigger nativa do Sankhya com lógicas de validação de agrupamento mínimo, lote, CFOP e estoque adicionadas pela Spark |
| `TRG_INC_TGFVAR.sql` | `TRG_INC_TGFVAR` | `TGFVAR` | BEFORE INSERT | Trigger nativa do Sankhya (não customizada pela Spark) que processa a inclusão de "nota de variação" (atendimento/entrega parcial): valida a existência da nota de origem, atualiza `QTDENTREGUE`/`QTDFIXADA` em `TGFITE` para o item de origem e replica compromissos em `TGMTRA`. Documentada aqui após investigação de incidente (ver §15) — não fazia parte do catálogo até Set/2026 |

---

### 15. Incidente de Produção — Set/2026 (refatoração de performance)

Durante uma rodada de otimização de performance em 20 triggers (10 sobre TGFCAB/TGFITE/TPRAPA/TPRCOI/TSILIB/TGFIXN, ver histórico de commits de Set/2026), dois problemas de produção foram causados pelas próprias alterações — nenhum por erro de lógica de negócio, ambos por armadilhas específicas do Oracle que não são visíveis lendo só o texto SQL versionado aqui:

1. **`CREATE OR REPLACE TRIGGER` sempre recria a trigger em estado `ENABLED`, independente do estado anterior.** Três triggers (`TRG_VAL_CSTIPI_SPARK`, `TRG_INC_TGFIXN_EMAIL_SPARK`, `TRG_UPD_TGSLOGLIB_SPARK`) estavam **desativadas em produção** por decisão de negócio, mas o repositório não registra status de habilitação (isso é uma propriedade de runtime do banco, não do arquivo `.sql`). Ao rodar `CREATE OR REPLACE` nelas durante a refatoração — mesmo para mudanças triviais de performance — elas voltaram a disparar, causando bloqueio inesperado em produção. **Lição:** antes de tocar em qualquer trigger de produção, confirmar `STATUS` em `USER_TRIGGERS` (ou pedir confirmação de quem mantém o ambiente); se estava `DISABLED`, ou não mexer, ou reaplicar o `DISABLE` logo após o `CREATE OR REPLACE`. As três foram marcadas `*(INATIVADA)*` no catálogo acima e comentadas por completo no arquivo `.sql` (mesmo padrão de `SPK_TGFCAB_TSIBLOCK.SQL`).

2. **`PRAGMA AUTONOMOUS_TRANSACTION` sem `COMMIT`/`ROLLBACK` visível não é necessariamente código morto.** Em `TRG_INC_TPRCOI_SPARK.SQL`, a pragma existia para permitir que o `SELECT` da trigger leia `TPRCONF` mesmo quando ela é disparada em cascata de dentro de `TRG_INC_UPD_TPRCONF_SPARK` (que faz DML em `TPRCOI` a partir de um gatilho sobre a própria `TPRCONF`) — sem a autonomous transaction, `TPRCONF` fica "mutante" para essa leitura (`ORA-04091`). Remover a pragma por não achar `COMMIT`/`ROLLBACK` no corpo quebrou esse caso. **Lição:** antes de remover uma `PRAGMA AUTONOMOUS_TRANSACTION` aparentemente sem uso, verificar se alguma tabela lida pela trigger pode estar em cascata de outra trigger/procedure que modifica essa mesma tabela na mesma transação — esse é o uso mais comum da pragma além de isolar `COMMIT`/`ROLLBACK`.

---

## Observações Gerais

- Todas as triggers usam `RAISE_APPLICATION_ERROR` com códigos no intervalo `-20001` a `-20999` para erros de negócio identificáveis.
- Triggers com sufixo `2` ou `3` são versões evolutivas que coexistem por compatibilidade com a plataforma Sankhya.
- Triggers marcadas como **INATIVADAS** nos comentários do código não são executadas, mas são preservadas para referência histórica.
- Erros críticos são registrados na tabela `AD_LOG_ERROS` (quando configurado na trigger).
- Antes de rodar `CREATE OR REPLACE` em qualquer trigger de produção, confirmar se ela está `ENABLED`/`DISABLED` no banco — o `.sql` local não guarda esse estado, e o `REPLACE` sempre recria como `ENABLED` (ver §15).
- Uma `PRAGMA AUTONOMOUS_TRANSACTION` sem `COMMIT`/`ROLLBACK` aparente pode existir só para evitar `ORA-04091` (tabela mutante) em leituras cross-trigger — não remover sem checar o grafo de disparo entre triggers das tabelas envolvidas (ver §15).
