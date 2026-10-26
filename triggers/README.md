# Catálogo de Triggers

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de triggers:** 88 arquivos `.SQL` em `triggers/` — 84 com código ativo + 4 *(INATIVADAS)*, com o corpo inteiramente comentado (`SPK_TGFCAB_TSIBLOCK`, `TRG_VAL_CSTIPI_SPARK`, `TRG_INC_TGFIXN_EMAIL_SPARK`, `TRG_UPD_TGSLOGLIB_SPARK`). Não inclui as nativas do §14 nem os arquivos de `inativos/`  
**Banco:** Oracle PL/SQL  

---

## Convenção de nomenclatura

| Prefixo | Significado |
|---|---|
| `TRG_` | Trigger padrão atual |
| `SPK_` | Trigger com nomenclatura legada (anterior ao padrão `TRG_`) |
| `_SPARK` | Sufixo identificando customização da Spark Eletrônica |

Nomenclatura de tabelas-alvo mais comuns: `TGFCAB` (cabeçalho de nota), `TGFITE` (itens), `TGFPAR` (parceiros), `TGFFIN` (financeiro), `TPRAPA` (apontamento produção).

> Na coluna **Evento**, `BEFORE`/`AFTER` indicam triggers de linha (`FOR EACH ROW`); `COMPOUND` indica compound trigger. Condições `WHEN` relevantes estão citadas na descrição.

---

## Catálogo por Domínio

### 1. Produção / PCP

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPD_TPRPRC_SPARK.SQL` | `TRG_INC_UPD_TPRPRC_SPARK` | `TPRPRC` | BEFORE INSERT, UPDATE | Gerencia o tipo de PI nos processos produtivos (sub-ordem ou estoque), inserindo/atualizando `TPRLPI` |
| `TRG_INC_UPD_TPRIPROC_SPARK.SQL` | `TRG_INC_UPD_TPRIPROC_SPARK` | `TPRIPROC` | BEFORE INSERT, UPDATE | `WHEN (STATUSPROC = 'C' AND NUMPS > 0)`: limpa o número do MPS ao cancelar a ordem de produção, liberando a exclusão do plano |
| `TRG_INC_UPD_TPRCONF_SPARK.SQL` | `TRG_INC_UPD_TPRCONF_SPARK` | `TPRCONF` | BEFORE INSERT, UPDATE, DELETE | Insere códigos de barras consolidados ao finalizar a conferência da ordem de produção (faz DML em `TPRCOI` — ver §15 item 2) |
| `TRG_INC_UPD_TPRIMRP_SPARK.SQL` | `TRG_INC_UPD_TPRIMRP_SPARK` | `TPRIMRP` | BEFORE INSERT, UPDATE | Calcula o saldo de necessidade do MRP com ajustes adicionais para análise de giro |
| `TRG_INC_UPD_TPRROPE_PROD_SPARK.SQL` | `TRG_INC_UPD_TPRROPE_PROD_SPARK` | `TPRROPE` | BEFORE INSERT, UPDATE | Define o local de destino nas operações conforme tipo de item e centro de custo |
| `TRG_INC_UPD_DLT_TPRAPA_SPARK.SQL` | `TRG_INC_UPD_DLT_TPRAPA_SPARK` | `TPRAPA` | BEFORE INSERT, UPDATE, DELETE | Gerencia as séries apontadas por atividade e as registra no apontamento de produção |
| `TRG_INC_UPD_DLT_TPRIPA_SPARK.SQL` | `TRG_INC_UPD_DLT_TPRIPA_SPARK` | `TPRIPA` | BEFORE INSERT, UPDATE, DELETE | Gera série automática ou sequencial conforme o tipo de geração do lote de produção |
| `TRG_VAL_AD_CODFUNC_TPRAPA.SQL` | `TRG_VAL_AD_CODFUNC_TPRAPA` | `TPRAPA` | BEFORE UPDATE | Valida a obrigatoriedade do colaborador (`AD_CODFUNC`) no apontamento, exceto na atividade de expedição/conferência |
| `TRG_VAL_SETOR_CODFUNC_TPRAPA.SQL` | `TRG_VAL_SETOR_CODFUNC_TPRAPA` | `TPRAPA` | BEFORE INSERT, UPDATE | Valida se o colaborador pertence ao setor da etapa do apontamento (usa `AD_MAP_SETOR_FUNC`); etapa sem mapeamento ou colaborador sem departamento (`CODDEP = 0`) não são validados |
| `TRG_INC_UPD_TGFCAB_PROD_SPARK.SQL` | `TRG_INC_UPD_TGFCAB_PROD_SPARK` | `TGFCAB` | BEFORE INSERT, UPDATE | Define local de destino e número do PS conforme a atividade vinculada à ordem de produção |
| `TRG_DEL_TPRSERPA_SPARK3.SQL` | `TRG_DEL_TPRSERPA_SPARK3` | `TPRSERPA` | BEFORE DELETE | Remove de `TGFBAR` o código de barras da série de PA excluída |
| `TRG_INC_TPRSERPA_SPARK2.SQL` | `TRG_INC_TPRSERPA_SPARK2` | `TPRSERPA` | BEFORE INSERT, UPDATE | Insere o código de barras em `TGFBAR` quando o apontamento de PA é liberado para expedição |
| `TRG_INC_TPRCOI_SPARK.SQL` | `TRG_INC_TPRCOI_SPARK` | `TPRCOI` | BEFORE INSERT, UPDATE, DELETE | Impede a mesma série em múltiplos apontamentos de conferência. `FOLLOWS TRG_TPRCOI_REPLICA_PA`; usa `PRAGMA AUTONOMOUS_TRANSACTION` (ver §15 item 2) |
| `TRG_INC_TPRCOI_SPARK2.SQL` | `TRG_INC_TPRCOI_SPARK2` | `TPRCOI` | BEFORE INSERT | Valida a correspondência entre código de barras e lote de produção (14 ou 15 dígitos). `FOLLOWS TRG_TPRCOI_REPLICA_PA` |
| `TRG_INC_TPRLPA_SPARK.SQL` | `TRG_INC_TPRLPA_SPARK` | `TPRLPA` | BEFORE INSERT, UPDATE | Define a máscara padrão de geração automática de série para produtos com controle por série |
| `TRG_APOQLD_INS_SPARK.SQL` | `TRG_APOQLD_INS_SPARK` | `AD_APOQLD` | BEFORE INSERT, UPDATE | Preenche `CODPROD` a partir de `TPRIPROC` (produto PA, códigos iniciados por 2 ou 3, associado ao lote do processo) |
| `TRG_TPRCOI_REPLICA_PA.sql` | `TRG_TPRCOI_REPLICA_PA` | `TPRCOI` | BEFORE INSERT, UPDATE | Replica `CODBARRA`/`CODPROD` para `CONTROLEPA`/`CODPRODPA` na própria linha (padrão *PA* das tabelas de produção). Trigger puramente atribuidora; `TRG_INC_TPRCOI_SPARK`/`SPARK2` usam `FOLLOWS` para rodar depois dela |

> `TRG_INC_UPD_TPRMPS_SPARK` (Plano Mestre de Produção) não está mais nesta pasta — o arquivo foi movido para `inativos/` (ver `inativos/README.md`).

---

### 2. Nota Fiscal / Movimentação (TGFCAB / TGFITE)

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_CMP_TGFCAB_NFE_SPARK.SQL` | `TRG_CMP_TGFCAB_NFE_SPARK` | `TGFCAB` | COMPOUND UPDATE | Quando a nota de venda (`TIPMOV = 'V'`) recebe a `CHAVENFE`, copia `NUMNOTA`/`CHAVENFE`/`VLRNOTA` para a nota de entrada vinculada (`AD_NUNOTASAI`/`AD_NUNOTAENT`) e replica valores e tributação (ICMS, IPI, `CODTRIB`) item a item |
| `TRG_INC_TGFCAB_DC_SPARK.SQL` | `TRG_INC_TGFCAB_DC_SPARK` | `TGFCAB` | BEFORE INSERT | Preenche `DTNEG`, `DTENTSAI` e `HRENTSAI` com a data de produção do processo |
| `TRG_UPD_TGFCAB_DTFAT_SPARK.SQL` | `TRG_UPD_TGFCAB_DTFAT_SPARK` | `TGFCAB` | BEFORE INSERT, UPDATE | Iguala `DTFATUR` a `DTNEG` quando configurado na TOP |
| `TRG_UPD_TGFCAB_IMF_SPARK.SQL` | `TRG_UPD_TGFCAB_IMF_SPARK` | `TGFCAB` | BEFORE UPDATE | Ao confirmar nota de compra (`TIPMOV = 'C'`, `STATUSNOTA` → `'L'`), distribui os impostos por financeiro em `TGFIMF` |
| `TRG_UPD_TGFCAB_TRANSP_SPARK.SQL` | `TRG_UPD_TGFCAB_TRANSP_SPARK` | `TGFCAB` | BEFORE INSERT, UPDATE | Em TOPs com `AD_VERIFIPARCTRANSP = 'S'`: exige/proíbe parceiro transportadora conforme `CIF_FOB`; guarda o frete do pedido em `AD_FRETE` e zera `VLRFRETE` até a confirmação, restaurando-o depois; repassa `AD_VLROUTROS`/`AD_VLROUTROSCOMP` dos itens para `VLROUTROS` |
| `TRG_INC_UPD_TGFCAB_PREVENT.SQL` | `TRG_INC_UPD_TGFCAB_PREVENT` | `TGFCAB` | BEFORE INSERT, UPDATE | Em pedidos de compra (grupo de TOP `'Pedido Compra'`) liberados e ainda sem entregas, popula `TGFDTP` com a previsão de entrega |
| `TRG_DEL_TGFCAB_CLEAN_SPARK.SQL` | `TRG_DEL_TGFCAB_CLEAN_SPARK` | `TGFCAB` | BEFORE DELETE | Limpa registros de frete dependentes ao excluir a nota (`AD_TGSLCB`, `AD_TGSCTF`) |
| `TRG_CMP_TRANFS_SPARK.SQL` | `TRG_CMP_TRANFS_SPARK` | `TGFCAB` | COMPOUND DELETE | Ao excluir uma nota, anula `AD_NUNOTAENT`/`AD_NUNOTASAI` nos documentos de transferência relacionados |
| `TRG_TGFITE_SPARK1.SQL` | `TRG_TGFITE_SPARK1` | `TGFITE` | BEFORE INSERT, UPDATE | Calcula `AD_VLRCHEIO` (via `TGFEXC` quando a TOP tem `AD_ATUALOUTROS = 'S'`) e os valores complementares `AD_VLROUTROS*` do item |
| `TRG_INC_UPD_TGFITE_SPARK.SQL` | `TRG_INC_UPD_TGFITE_SPARK` | `TGFITE` | BEFORE UPDATE | Atualiza o local de origem em transferências e insere séries no faturamento de produção (a partir da conferência mais recente da OP) |
| `TRG_INC_UPD_TGFITE_SPARK2.SQL` | `TRG_INC_UPD_TGFITE_SPARK2` | `TGFITE` | BEFORE INSERT, UPDATE | Calcula valores unitário e total em moeda estrangeira em operações de importação |
| `TRG_UPT_TGFITE.SQL` | `TRG_UPT_TGFITE` | `TGFITE` | BEFORE UPDATE | Validações extensas na alteração de item (nota contabilizada / em livro fiscal, série já lançada, coletor `TGFCCX`, remessa, status, vendedor/empresa ativos, etc.). Mesmo nome e estrutura de trigger nativa do Sankhya; customização da Spark a confirmar |
| `SPK_UPD_INS_TGFITE_CONSUMOPRD.SQL` | `SPK_UPD_INS_TGFITE_CONSUMOPRD` | `TGFITE` | BEFORE INSERT, UPDATE | Define `CODLOCALORIG` conforme o centro de custo (mapeia unidades de produção da TOP 509 para locais de origem específicos) |
| `TRG_INS_UPD_CODLOCALDEST.SQL` | `TRG_INS_UPD_CODLOCALDEST` | `TGFITE` | BEFORE INSERT, UPDATE | Força `CODLOCALORIG = 199` nos itens da TOP 712 com sequência maior que zero |
| `TRG_CMP_TGFVAR_NUNOTASIT.SQL` | `TRG_CMP_TGFVAR_NUNOTASIT` | `TGFVAR` | COMPOUND INSERT, UPDATE, DELETE | Atualiza `NUNOTASIT` em `AD_TGSCTF` e `TGFCAB` (`'F'` ou `'A'`) conforme existam variações vinculadas |
| `TRG_INC_TGFVAR_SPARK.SQL` | `TRG_INC_TGFVAR_SPARK` | `TGFVAR` | BEFORE INSERT | Copia dados de embalagem (`AD_EMBPED`) da nota original para a nota de variação quando a nota de origem já possui registro de embarque |
| `TRG_INC_UPD_TGFVAR_SPARK.SQL` | `TRG_INC_UPD_TGFVAR_SPARK` | `TGFVAR` | BEFORE INSERT, UPDATE | Em variações de compra (`TIPMOV = 'C'`), propaga `AD_VLRCHEIOCOM` do item de origem, recalcula `AD_VLROUTROSCOMP` e totaliza `VLROUTROS` no cabeçalho |
| `TRG_UPD_TGFCAB_MOEDA_SPARK2.sql` | `TRG_UPD_TGFCAB_MOEDA_SPARK2` | `TGFCAB` | COMPOUND UPDATE OF `VLRMOEDA` | Recalcula `VLRUNITMOE`/`VLRTOTMOE` dos itens quando `VLRMOEDA` é alterado no cabeçalho (TOPs 1008/1009). Usa compound trigger para evitar ORA-04091; comunica valores via `PKG_SPARK_MOEDA` |
| `TRG_TGFNCT_SPARK.SQL` | `TRG_TGFNCT_SPARK` | `TGFNCT` | BEFORE INSERT, UPDATE | Altera o CST de frete para 90 conforme o tipo de operação da nota de origem |
| `TRG_UPD_DIFALPB_SPARK.sql` | `TRG_UPD_DIFALPB_SPARK` | `TGFCAB` | BEFORE UPDATE OF `STATUSNFE` | Na aprovação da NF-e (`STATUSNFE` → `'A'`), recalcula base (`BASEDIFAL`) e valor (`VLRDIFALDEST`) do DIFAL destino em `TGFDIN` e totaliza o valor no cabeçalho (`TGFCAB.VLRICMSDIFALDEST`, via `:NEW`), para destinatários da UF configurada (`V_CODUF_PB = 17`, PB) classificados como consumo (`TGFPAR.CLASSIFICMS = 'C'`). Alíquotas fixas (interna 20%, DIFAL 13%). Loga em `AD_LOG_ERROS` e relança o erro (bloqueia a aprovação) |

---

### 3. Compras / Solicitação de Compra

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_NOTIFICA_SOLIC_COMPRA.sql` | `TRG_NOTIFICA_SOLIC_COMPRA` | `AD_TGSSCP` | AFTER INSERT, UPDATE | Envia notificações por e-mail nas mudanças de status da solicitação (nova, aprovada, cancelada, compra realizada) |
| `TRG_STATUS_PADRAO_SC.sql` | `TRG_STATUS_PADRAO_SC` | `AD_TGSSCP` | BEFORE INSERT | Define status padrão `EA` ao incluir nova solicitação |
| `TRG_ATUALIZA_STATUS_NUNOTA.sql` | `TRG_ATUALIZA_STATUS_NUNOTA` | `AD_TGSSCP` | BEFORE UPDATE | `WHEN (NUNOTA` passa de nulo a preenchido`)`: muda o status para `CR` (Compra Realizada) |
| `TRG_BLOQUEIA_EDICAO_STATUS_CR.sql` | `TRG_BLOQUEIA_EDICAO_STATUS_CR` | `AD_TGSSCP` | BEFORE UPDATE | Impede qualquer alteração quando status = `CR` (Compra Realizada) |
| `TRG_BLOQUEIA_DELETE_SC.sql` | `TRG_BLOQUEIA_DELETE_SC` | `AD_TGSSCP` | BEFORE DELETE | Bloqueia a exclusão de solicitações com status `A` (Aprovada), `C` (Cancelada) ou `CR` (Compra Realizada) |
| `TRG_INC_UPD_AD_TGSCMP_SPARK.SQL` | `TRG_INC_UPD_AD_TGSCMP_SPARK` | `AD_TGSCMP` | BEFORE INSERT, UPDATE | Preenche `REFERENCIA`, `MARCA`, `PESOBRUTO`, `ALTURA`, `LARGURA`, `ESPESSURA` e `UNIDADE` a partir de `TGFPRO` (ou limpa os campos). Finalidade da tabela `AD_TGSCMP` a confirmar |

---

### 4. Logística / Frete / Embarque

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_COTAFRETE_SPARK.SQL` | `TRG_COTAFRETE_SPARK` | `TGFCAB` | AFTER INSERT, UPDATE, DELETE | Insere/atualiza/limpa a cotação de frete em `AD_TGSCTF` (transportadoras 1085 → `APIDEST = 'B'` Braspress, 1086 → `'R'` Rodonaves); se `CODPARCREDESPACHO` estiver preenchido, cota até a transportadora de redespacho em vez do parceiro de destino |
| `TRG_COTAFRETE_EMB_SPARK.SQL` | `TRG_COTAFRETE_EMB_SPARK` | `AD_TGSCTF` | AFTER INSERT, UPDATE | Grava dimensões e peso por caixa (`PESOITEM`) em `AD_TGSLCB`, agrupando por embalagem; rateia `PESOTOT` proporcionalmente entre os grupos |
| `TRG_FRETE_CIF_MTKPL_SPARK.sql` | `TRG_FRETE_CIF_MTKPL_SPARK` | `TGFCAB` | BEFORE INSERT, UPDATE | Força `CIF_FOB = 'C'` e `TIPFRETE = 'N'` em notas da empresa 2 com tipo de venda 78, TOP 1005 e vendedor 5, 42, 43 ou 44 (vendas marketplace); loga em `AD_LOG_ERROS` |
| `TRG_AD_EMBPED_SPARK.SQL` | `TRG_AD_EMBPED_SPARK` | `AD_EMBPED` | BEFORE DELETE | Ao excluir uma embalagem, recalcula `QTDVOL` e `PESO` em `TGFCAB` |
| `TRG_TGSCAB_TRANSP_SPARK.SQL` | `TRG_TGSCAB_TRANSP_SPARK` | `AD_TGSCAB` | BEFORE INSERT, UPDATE | Atribui o código de parceiro transportador padrão quando o transportador é informado |
| `TRG_INC_UPD_INFCOLETA.SQL` | `TRG_INC_UPD_INFCOLETA` | `AD_COLETA` | BEFORE INSERT, UPDATE | Registra a data de coleta e atualiza `AD_COLETADO` nas notas vinculadas |

---

### 5. Assistência Técnica / Ordem de Serviço

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_UPD_OSINTERNA.SQL` | `TRG_UPD_OSINTERNA` | `AD_OSINTERNA` | BEFORE UPDATE | Envia e-mail ao criador da O.S. quando há mudança de status |
| `TRG_UPD_OSINTERNA_DHFIM.SQL` | `TRG_UPD_OSINTERNA_DHFIM` | `AD_OSINTERNA` | BEFORE UPDATE | Grava data e hora de finalização (`DHFIM`) quando o status muda para `'F'` |
| `TRG_INS_OSSTATUS_SPARK.SQL` | `TRG_INS_OSSTATUS_SPARK` | `AD_OSINTERNA` | BEFORE INSERT | Define status inicial `'I'` (Em aberto) da O.S. interna |
| `TRG_TGFASS_INC_SPARK.SQL` | `TRG_TGFASS_INC_SPARK` | `AD_TGFASS` | BEFORE INSERT, UPDATE OF `SNENTRADA` | Preenche os campos `T_*` (produto, lote, venda, fabricação) a partir da série `SNENTRADA` na `VGFSERIES`; no UPDATE só dispara quando a série muda |
| `TRG_TGFASS_INCUPD_SPARK.SQL` | `TRG_TGFASS_INCUPD_SPARK` | `AD_TGFASS` | BEFORE INSERT, UPDATE | Preenche os dados de endereço do parceiro (rua, número, CEP, UF, cidade, bairro) |
| `TRG_TGFASS_VLRCONSERTO_SPARK.SQL` | `TRG_TGFASS_VLRCONSERTO_SPARK` | `AD_TGFASS` | BEFORE INSERT, UPDATE | Preenche `VLRCONSERTO` via `SNK_PRECO(14, T_CODPROD)` e `VLRSERVTECNICO` via `SNK_PRECO(15, T_CODPROD)`, cada um quando o respectivo campo está nulo/zerado. `FOLLOWS TRG_TGFASS_INC_SPARK` para garantir `T_CODPROD` já preenchido |
| `TRG_SPKCAE_INC_SPARK.SQL` | `TRG_SPKCAE_INC_SPARK` | `AD_SPKCAE` | BEFORE INSERT | Assistência externa: preenche `T_CODPROD`, `T_DESCRPROD`, `T_RFINTERNA`, `T_DESCRPARVENDA`, `T_DTVENDA`, `T_DTFABRICACAO`, `T_TIPO` e `T_LOTE` a partir da série (`SNENTRADA`) na `VGFSERIES` |
| `TRG_SPKCAE_VLRCONSERTO_SPARK.SQL` | `TRG_SPKCAE_VLRCONSERTO_SPARK` | `AD_SPKCAE` | BEFORE INSERT, UPDATE | `WHEN (STATUS = 'C'`, `VLRCONSERTO` nulo/zero e `T_CODPROD` preenchido`)`: preenche `VLRCONSERTO` via `SNK_PRECO(14, T_CODPROD)`. `FOLLOWS TRG_SPKCAE_INC_SPARK` |

---

### 6. Séries / Conferência

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_TGFSER_SPARK.SQL` | `TRG_INC_TGFSER_SPARK` | `TGFSER` | BEFORE INSERT, UPDATE | Gerencia códigos de barras (`TGFBAR`) em ajustes de estoque/produção e limpa códigos em conferências |
| `TRG_DLT_TGFSER_SPARK.SQL` | `TRG_DLT_TGFSER_SPARK` | `TGFSER` | BEFORE DELETE | Ao excluir série (TOP de produção 800), remove o código de `TGFBAR` ou o reinsere em `TGFEST` conforme o contexto |
| `TRG_TGFCON2_SPARK.SQL` | `TRG_TGFCON2_SPARK` | `TGFCON2` | BEFORE INSERT, UPDATE | `WHEN (STATUS` muda para `'F')`: insere as séries conferidas em `TGFSER` ao finalizar a conferência |
| `TRG_TGFCOI2_SPARK.SQL` | `TRG_TGFCOI2_SPARK` | `TGFCOI2` | BEFORE INSERT, UPDATE | Valida duplicidade de série na conferência, disponibilidade em estoque e vínculo com pedidos em aberto |

---

### 7. Financeiro

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_REFORCA_NAT_FIN.sql` | `TRG_REFORCA_NAT_FIN` | `TGFCAB` | AFTER INSERT, UPDATE | Atualiza natureza e centro de custo em `TGFFIN` com base nos valores da `TGFCAB`, exceto tipos específicos e financeiros rateados |
| `TRG_TGFFIN_LOG_SPARK.SQL` | `TRG_TGFFIN_LOG_SPARK` | `TGFFIN` | BEFORE INSERT, UPDATE, DELETE | Grava log (via `STP_GRAVATABLOG`) dos campos `DTNEG`, `DTENTSAI`, `DTVENC`, `HISTORICO`, `VLRBAIXA`, `VLRDESDOB`, `DHBAIXA` na inclusão e exclusão. Não há ramo de UPDATE: a cláusula `WHEN (NEW.NUFIN IS NULL OR OLD.NUFIN IS NULL)` faz a trigger disparar só em INSERT/DELETE. Antigo `SPK_TGFFIN_LOG` (renomeado em 29/09/2026) |
| `TRG_INCDEVCH_SPARK.SQL` | `TRG_INCDEVCH_SPARK` | `TGFMDC` | BEFORE INSERT, DELETE | Na inclusão de devolução de cheque de vendedor comissionado, gera duas notas de estorno (despesa TOP 1222 e receita TOP 1190) com item e financeiro, confirmando-as via `STP_CONFIRMANOTA2`; na exclusão, apaga as notas geradas (`AD_NUMDEVCH`) |
| `TRG_INC_AD_TGFFTA_SPARK.SQL` | `TRG_INC_AD_TGFFTA_SPARK` | `AD_TGFFTA` | BEFORE INSERT | `WHEN (INDICADOR = 'OTR' AND INDICADORORT IS NULL)`: exige o preenchimento de `INDICADORORT` |

---

### 8. Parceiros / Cadastros

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_UPD_TGFPAR_UF_SPARK.SQL` | `TRG_UPD_TGFPAR_UF_SPARK` | `TGFPAR` | BEFORE UPDATE | Quando `CODCID` muda para uma cidade de outra UF, bloqueia a alteração (`-20001`: "Não é possível alterar UF de Parceiro - Favor criar um novo cadastro") |
| `TRG_INC_TSICID_SPARK.SQL` | `TRG_INC_TSICID_SPARK` | `TSICID` | BEFORE INSERT | Valida município fiscal obrigatório (`CODMUNFIS`) e normaliza `NOMECID` para o valor canônico já cadastrado (case-insensitive), forçando a AK para que o Sankhya reutilize o registro existente em vez de criar duplicata |
| `TRG_INC_TGFPAR_SPARK.SQL` | `TRG_INC_TGFPAR_SPARK` | `TGFPAR` | BEFORE INSERT | Em Pessoa Física sem vendedor associado (`TIPPESSOA = 'F'`, `CODVEND = 0`), força `APLICLEITRANSP = 'S'` e `IPIINCICMS = 'S'` e replica o e-mail principal em `EMAILNFE` |
| `TRG_INC_UPD_CMF_SPARK.SQL` | `TRG_INC_UPD_CMF_SPARK` | `TSICID` | BEFORE INSERT, UPDATE OF `NOMECID` | Preenche `CODMUNFIS` buscando o município em `AD_TGSMDF` (comparação sem acento/caixa) sempre que `NOMECID` é informado/alterado; erros não bloqueiam e vão para `AD_LOG_ERROS` |
| `SPK_INS_UPD_TGFCAB_AVISOPARC.SQL` | `SPK_INS_UPD_TGFCAB_AVISOPARC` | `TGFCAB` | BEFORE INSERT, UPDATE | Copia as observações do parceiro (`TGFPAR`) para `AD_AVISOPARC` do cabeçalho da nota |
| `TRG_UPD_TGSLOGLIB_SPARK.SQL` | *(INATIVADA)* | `TSILIB` | BEFORE UPDATE | Gravava em `TGSLOGLIB` o log de liberação de crédito ao autorizar nota de venda — estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026 (ver §15) |

---

### 9. Notificações / Avisos / E-mail

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_UPD_AVISOSPARK.SQL` | `TRG_UPD_AVISOSPARK` | `TGFCON2` | BEFORE UPDATE | `WHEN (STATUS = 'F' AND QTDVOL = 1)`: emite lembrete (via `DBMS_OUTPUT`) para corrigir a quantidade de volumes ao finalizar a conferência |
| `TRG_INC_TGFIXN_EMAIL_SPARK.SQL` | *(INATIVADA)* | `TGFIXN` | AFTER INSERT, UPDATE | Disparava e-mail para XMLs importados de notas de devolução (CFOPs 5201, 5202, 6201, 6202, 5410, 6410) — estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026 (ver §15) |
| `TRG_NOTIF_PARCERIA_SPARK.sql` | `TRG_NOTIF_PARCERIA_SPARK` | `AD_TGSTPP` | AFTER INSERT, UPDATE | Notificações por e-mail do fluxo de triagem de parceria (influenciadores/patrocínio): nova solicitação → SAC; 1º parecer do SAC → Comercial; 1ª decisão comercial → SAC. Traduz campos multi-escolha via `TDDCAM`/`TDDOPC`; grava na fila via `STP_GRAVA_FILA_BI2`; loga em `AD_LOG_ERROS` |
| `TRG_INC_CORRAPONTAMENTO_SPARK.SQL` | `TRG_INC_CORRAPONTAMENTO_SPARK` | `AD_CORRAPONTAMENTO` | AFTER INSERT | Alerta por e-mail (vieira.silvio@spark.ind.br) a cada nova correção de apontamento de produção (registrada pela `STP_CORRIGEAPONTAMENTO_SPARK`), com todos os campos do registro + `DESCRPROD`; grava na fila via `STP_GRAVA_FILA_BI2`; erro só é logado em `AD_LOG_ERROS` (não relança) |

---

### 10. Produto / Estoque

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPT_TGFPRO_SPARK.SQL` | `TRG_INC_UPT_TGFPRO_SPARK` | `TGFPRO` | BEFORE INSERT, UPDATE | Define o uso de local para produtos da Spark, exceto serviços |
| `TRG_INC_UPD_AD_TPRSERPA_SPARK.SQL` | `TRG_INC_UPD_AD_TPRSERPA_SPARK` | `AD_TPRSERPA` | BEFORE INSERT, UPDATE, DELETE | Insere o código de barras na tabela de estoque para a conferência de produção |
| `TRG_INS_TGFCUS_SPARK.SQL` | `TRG_INS_TGFCUS_SPARK` | `TGFCUS` | BEFORE INSERT, UPDATE | Insere registros em `AD_TGSCIT` ao gravar custo de produto (histórico de custo médio) |
| `TRG_TGFCUS_SPARK.SQL` | `TRG_TGFCUS_SPARK` | `TGFCUS` | BEFORE INSERT, UPDATE | Insere registros em `AD_TGSCIT` e `AD_TGSCUS` ao gravar custo de produto (custo médio e data de referência) |

---

### 11. Integrações / E-commerce

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_UPD_INTEGRA.sql` | `TRG_INC_UPD_INTEGRA` | `AD_TGSPAR` | BEFORE INSERT, UPDATE | Normaliza os dados recebidos, busca parceiro existente e cria automaticamente bairro (`TSIBAI`), endereço (`TSIEND`) e parceiro (`TGFPAR`) quando necessário |
| `TRG_INS_UPD_TWFIVAR_CODIGONOVO.SQL` | `TRG_INS_UPD_TWFIVAR_CODIGONOVO` | `TWFIVAR` | BEFORE INSERT, UPDATE | Quando a variável de workflow é `NOME = 'CODPROD_NEW'` com `NUMINT`, atualiza o código do produto em `TGFPRO_WF` |

---

### 12. Validação / Controle de Regras

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_VAL_CSTIPI_SPARK.SQL` | *(INATIVADA)* | `TGFITE` | BEFORE INSERT, UPDATE | Validava CST/IPI — bloqueava se o campo fosse 0 ou nulo em compras da empresa 1. Estava desativada em produção; reativada acidentalmente por `CREATE OR REPLACE` durante refatoração de performance de Set/2026, bloqueando um UPDATE de rotina (`QTDENTREGUE`/`QTDFIXADA`) disparado pela nativa `TRG_INC_TGFVAR` sobre um item legado sem CST IPI preenchido (ver §15) |
| `SPK_TGFCAB_TSIBLOCK.SQL` | *(INATIVADA)* | `TGFCAB` | BEFORE INSERT, UPDATE | Bloqueava pedidos de venda com data de previsão de entrega anterior à data de bloqueio de `AD_TSIBLOCK` — desativada a pedido (arquivo inteiramente comentado) |

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

### 14. Triggers Nativas (pasta `nativo/triggers/`)

> Os fontes ficam em [`nativo/triggers/`](../nativo/triggers/README.md) (versionados como referência — não são código da Spark). Descrição mantida aqui por causa do incidente do §15.

| Arquivo | Trigger | Tabela | Evento | Descrição |
|---|---|---|---|---|
| `TRG_INC_TGFITE.SQL` | `TRG_INC_TGFITE` | `TGFITE` | BEFORE INSERT | Trigger nativa do Sankhya (validação de agrupamento mínimo, lote, CFOP, IPI e estoque). A única customização da Spark identificada era desligar a validação de lote obrigatório; a versão do banco (alterada em 21/09/2026) voltou a exigi-la — ver `nativo/triggers/README.md` |
| `TRG_INC_TGFVAR.SQL` | `TRG_INC_TGFVAR` | `TGFVAR` | BEFORE INSERT | Trigger nativa do Sankhya (não customizada pela Spark) que processa a inclusão de "nota de variação" (atendimento/entrega parcial): valida a existência da nota de origem, atualiza `QTDENTREGUE`/`QTDFIXADA` em `TGFITE` para o item de origem e replica compromissos em `TGMTRA`. Documentada aqui após investigação de incidente (ver §15) — não fazia parte do catálogo até Set/2026 |

---

### 15. Incidente de Produção — Set/2026 (refatoração de performance)

Durante uma rodada de otimização de performance em 20 triggers (10 sobre TGFCAB/TGFITE/TPRAPA/TPRCOI/TSILIB/TGFIXN, ver histórico de commits de Set/2026), dois problemas de produção foram causados pelas próprias alterações — nenhum por erro de lógica de negócio, ambos por armadilhas específicas do Oracle que não são visíveis lendo só o texto SQL versionado aqui:

1. **`CREATE OR REPLACE TRIGGER` sempre recria a trigger em estado `ENABLED`, independente do estado anterior.** Três triggers (`TRG_VAL_CSTIPI_SPARK`, `TRG_INC_TGFIXN_EMAIL_SPARK`, `TRG_UPD_TGSLOGLIB_SPARK`) estavam **desativadas em produção** por decisão de negócio, mas o repositório não registra status de habilitação (isso é uma propriedade de runtime do banco, não do arquivo `.sql`). Ao rodar `CREATE OR REPLACE` nelas durante a refatoração — mesmo para mudanças triviais de performance — elas voltaram a disparar, causando bloqueio inesperado em produção. **Lição:** antes de tocar em qualquer trigger de produção, confirmar `STATUS` em `USER_TRIGGERS` (ou pedir confirmação de quem mantém o ambiente); se estava `DISABLED`, ou não mexer, ou reaplicar o `DISABLE` logo após o `CREATE OR REPLACE`. As três foram marcadas `*(INATIVADA)*` no catálogo acima e comentadas por completo no arquivo `.sql` (mesmo padrão de `SPK_TGFCAB_TSIBLOCK.SQL`).

2. **`PRAGMA AUTONOMOUS_TRANSACTION` sem `COMMIT`/`ROLLBACK` visível não é necessariamente código morto.** Em `TRG_INC_TPRCOI_SPARK.SQL`, a pragma existia para permitir que o `SELECT` da trigger leia `TPRCONF` mesmo quando ela é disparada em cascata de dentro de `TRG_INC_UPD_TPRCONF_SPARK` (que faz DML em `TPRCOI` a partir de um gatilho sobre a própria `TPRCONF`) — sem a autonomous transaction, `TPRCONF` fica "mutante" para essa leitura (`ORA-04091`). Remover a pragma por não achar `COMMIT`/`ROLLBACK` no corpo quebrou esse caso. **Lição:** antes de remover uma `PRAGMA AUTONOMOUS_TRANSACTION` aparentemente sem uso, verificar se alguma tabela lida pela trigger pode estar em cascata de outra trigger/procedure que modifica essa mesma tabela na mesma transação — esse é o uso mais comum da pragma além de isolar `COMMIT`/`ROLLBACK`.

---

### 16. Levantamento de baseline de STATUS — Set/2026

Como consequência direta da lição do §15 item 1, foi criado `scripts/CHECK_STATUS_TRIGGERS_SPARK.SQL` (pasta local, não versionada): um `SELECT` sobre `ALL_TRIGGERS` cobrindo todas as triggers do repositório, para rodar antes de cada novo lote de otimização. A primeira execução (Set/2026) não encontrou nenhuma `DISABLED` além das 3 já conhecidas, mas revelou um segundo tipo de gap de documentação: **duas triggers cujo `.sql` continuava em `triggers/`, com aparência de código ativo, mas que não existem mais em `ALL_TRIGGERS`** — ou seja, já foram removidas do banco (não apenas desabilitadas), sem que o arquivo fosse movido para `inativos/`:

- `SPK_TRG_OSINTERNA.SQL` — tabela `AD_OSINTERNA` segue ativa (outras 3 triggers da tabela confirmadas `ENABLED`), mas esta trigger específica não existe mais no banco.
- `TRG_INC_ATUALIZAATRIB_SPARK.sql` — tabela `AD_MKTPMELIATRIB`, mesma família `AD_MKTPMELI*` de `VGF_ESTOQUEMELI_SPARK.sql` (já em `inativos/`, descontinuada com a migração da integração Mercado Livre) — indício de que esta trigger é resquício da mesma integração antiga.

Ambas foram movidas para `inativos/` (ver `inativos/README.md`). **Lição:** `STATUS = DISABLED` não é o único jeito de uma trigger estar "morta" sem o repositório saber — ela pode ter sido **dropada** do banco. O baseline de `ALL_TRIGGERS` cobre os dois casos: `DISABLED` (não mexer sem confirmação) e ausência de linha (confirmar se foi removida e mover para `inativos/`).

---

### 17. Triggers `_SPARK` descobertas no inventário de 08/10/2026

Existiam no banco (ambas `ENABLED`) sem arquivo no repositório. Convivem com as triggers nativas das mesmas tabelas — em especial `TGFITE`, que passou pela refatoração de performance de Set/2026 (§15). Capturadas **sem alteração do corpo** (removida só a qualificação `"SPARKPRD".`; acrescentados `/` antes do `ALTER TRIGGER` e `;` final).

| Arquivo | Trigger | Tabela | Evento | Objetivo (do fonte) | Autor (no fonte) |
|---|---|---|---|---|---|
| `TRG_UPD_NCMPROD_SPARK.SQL` | `TRG_UPD_NCMPROD_SPARK` | `TGFPRO` | BEFORE ROW UPDATE | Impedir alteração do NCM para produtos acabados se o usuário não pertencer ao grupo fiscal (CODGRUPO = 5). Caso seja do grupo 5, registrar a alteração em um log. | Lucas Gabriel |
| `TRG_UPD_ORIGPROD_SPARK.SQL` | `TRG_UPD_ORIGPROD_SPARK` | `TGFITE` | BEFORE ROW UPDATE | Atualizar a origem do produto, ao mesmo tempo na nota e no produto, automação devido a não poder utilizar a rotina de atualização de cadastro de produto do portal do XML, devido ao fato de nem sempre o fornecedor utilizar as informações corretas. | Lucas Gabriel - DM TECH |

> **Atenção.** `TRG_UPD_NCMPROD_SPARK` bloqueia (reverte silenciosamente) a alteração do NCM em produto acabado para usuários fora do `CODGRUPO = 5` e grava as alterações do grupo 5 em `LOG_ALTERACAO_NCM` (sequence `SEQ_LOG_ALTERACAO`) — objetos que também não estão versionados. `TRG_UPD_ORIGPROD_SPARK` atualiza `TGFPRO.ORIGPROD` a partir de uma trigger `BEFORE UPDATE` de `TGFITE` (compras com `AD_ORIGPROD` preenchido).

---


## Observações Gerais

- As triggers que bloqueiam operações usam `RAISE_APPLICATION_ERROR` com códigos no intervalo `-20001` a `-20999` para erros de negócio identificáveis (nem todas bloqueiam — várias só preenchem campos).
- Triggers com sufixo `2` ou `3` são versões evolutivas que coexistem por compatibilidade com a plataforma Sankhya.
- Triggers marcadas como **INATIVADAS** têm o corpo inteiramente comentado no `.sql` (não são recriadas ao rodar o arquivo), mas são preservadas para referência histórica.
- Erros críticos são registrados na tabela `AD_LOG_ERROS` (quando configurado na trigger).
- Antes de rodar `CREATE OR REPLACE` em qualquer trigger de produção, confirmar se ela está `ENABLED`/`DISABLED` no banco — o `.sql` local não guarda esse estado, e o `REPLACE` sempre recria como `ENABLED` (ver §15).
- Uma `PRAGMA AUTONOMOUS_TRANSACTION` sem `COMMIT`/`ROLLBACK` aparente pode existir só para evitar `ORA-04091` (tabela mutante) em leituras cross-trigger — não remover sem checar o grafo de disparo entre triggers das tabelas envolvidas (ver §15).
