# Catálogo de Procedures

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de procedures:** 103  
**Banco:** Oracle PL/SQL  

---

## Tipos de Procedure

| Prefixo | Tipo | Assinatura padrão |
|---|---|---|
| `STP_` | Stored Procedure — botão de ação no Sankhya | `(P_CODUSU, P_IDSESSAO, P_QTDLINHAS, P_MENSAGEM OUT)` |
| `EVP_` | Evento de visão externa — evento de tela | `(P_TIPOEVENTO, P_IDSESSAO, P_CODUSU)` |

As procedures de botão de ação recebem parâmetros via `ACT_TXT_PARAM` / `ACT_INT_FIELD` (funções nativas do Sankhya), que buscam valores informados pelo usuário ou campos selecionados na tela.

> **O prefixo nem sempre corresponde à assinatura.** Há `STP_` com assinatura de evento (`P_TIPOEVENTO`), como `STP_ORIGPROD_SPARK`, `STP_TPRCOI_SPARK`, `STP_ENVIAEMAILOS_SPARK`, `STP_NOTIFICASOLICCOMPRA_SPARK` e várias da seção 15; `STP_` de regra de negócio (`P_NUNOTA, P_SUCESSO OUT, P_MENSAGEM OUT, P_CODUSULIB OUT`), como `STP_REGRALOCALDESTINO_SPARK` e `Stp_ALTCAMOUTROS_SPARK`; `STP_` agendadas sem parâmetros; e `EVP_GEROBRGDIFAL_SPARK`, que apesar do prefixo é botão de ação. Confira a assinatura no fonte antes de vincular.

---

## Catálogo por Domínio

### 1. Planejamento e Controle da Produção (PCP / MRP)

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_PCP_SPARK.sql` | `STP_PCP_SPARK` | Chamada pelo MPS (parâmetros `P_CODPROD`, `P_CONTROLE`, `P_DATA_INICIAL`, `P_DATA_FINAL`; devolve `P_QTDDEMBRUTA`/`P_NUMPS`): calcula a demanda bruta de produção do PA considerando giro mensal, estoque e lote padrão |
| `STP_PCPMETA_SPARK.sql` | `STP_PCPMETA_SPARK` | Mesma assinatura do `STP_PCP_SPARK`, mas a demanda bruta vem da meta (`AD_TGFMET`, `CODMETA = 3`, `QTDPREV - QTDREDMET` do mês) somada a `OBTEM_TOTAIS_MRP` do MPS. O bloco que forçava PIs como sub-ordem (`TPRLPI.TIPOPI = 'O'`) está comentado desde 24/06/2026 |
| `STP_TGFMET_SPARK.sql` | `STP_TGFMET_SPARK` | Cria registros de meta em `AD_TGFMET` para produtos de venda na data de referência informada (`DTREF`), sem duplicar meta por data/produto |
| `STP_ALTERAMETA_SPARK.SQL` | `STP_ALTERAMETA_SPARK` | Altera a data de referência (`DTREF`) das metas selecionadas em `AD_TGFMET` para a data informada (`NOVADATA`) |
| `STP_OBSPLANEJA_SPARK.SQL` | `STP_OBSPLANEJA_SPARK` | Grava a observação de planejamento em `TPRLPA` para os produtos selecionados na tela de planejamento, depois de o plano ter sido gerado |
| `STP_GERALISTAMPS_SPARK.sql` | `STP_GERALISTAMPS_SPARK` | Gera requisições de material (TOP 402) para os materiais com requisição ativa nos planos de produção, a partir da quantidade de matéria-prima calculada e dos locais de baixa do apontamento |
| `STP_GERALISTAMPS_SPARK_TERC.sql` | `STP_GERALISTAMPS_SPARK_TERC` | Análoga à `STP_GERALISTAMPS_SPARK`, para terceirizados: TOP 403, `CODPARC = 425`, tipo de venda 99 |
| `STP_COPIALISTAMP_SPARK.sql` | `STP_COPIALISTAMP_SPARK` | Copia a lista de matérias-primas de um processo de manufatura para outro (`TPRLMP`, `TPRMPA`, `TPRLPI`, `TPRTPP`): composição, substitutos, operações e índices de qualidade |

---

### 2. Compras / Solicitação de Compra

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_APROVA_SOLIC_COMPRA.sql` | `STP_APROVA_SOLIC_COMPRA` | Aprova ou cancela solicitações de compra. Valida status `EA`, registra aprovador/motivo, notifica solicitante via fila |
| `STP_NOTIFICASOLICCOMPRA_SPARK.sql` | `STP_NOTIFICASOLICCOMPRA_SPARK` | Evento (assinatura `P_TIPOEVENTO`) que envia e-mail na inclusão de solicitação de compra, na aprovação e na finalização da compra (preenchimento do `NUNOTA`) |
| `STP_MARCARNPENDENTE_SPARK.SQL` | `STP_MARCARNPENDENTE_SPARK` | Marca os itens selecionados como **não** pendentes (`TGFITE.PENDENTE = 'N'`) e grava a observação informada (`OBSERVACAO`) |
| `STP_REABRIRPENDENTE_SPARK.SQL` | `STP_REABRIRPENDENTE_SPARK` | Marca o item de uma movimentação como pendente, corrigindo saldo remanescente em transferências de material |
| `STP_IMPORTTAB_SPARK.sql` | `STP_IMPORTTAB_SPARK` | **Esqueleto sem lógica**: lê `P_CODTABORIG` e o `CODTAB` das linhas, mas o corpo do loop está vazio — não faz nada. Finalidade a confirmar |

---

### 3. Estoque / Movimentação

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_TRANSFEMP_SPARK.SQL` | `STP_TRANSFEMP_SPARK` | Realiza transferência de produtos entre empresas. Cria cabeçalho (TGFCAB), itens (TGFITE) com SEQUENCIA calculada via ROW_NUMBER e usa SAVEPOINTs para rollback seletivo |
| `STP_VGERENCIAL_SPARK.SQL` | `STP_VGERENCIAL_SPARK` | A partir da nota informada (`NUNOTA`, `DTTRANSF`), gera nota de transferência entre empresas (`TGFCAB`/`TGFITE`/`TGFSER`, numeração do arquivo 700 em `TGFNUM`) para controle gerencial de vendas e grava o vínculo em `TGFCAB.AD_NUNOTATRAN` da nota de origem |
| `STP_GARANTEESTOQUE_SPARK.SQL` | `STP_GARANTEESTOQUE_SPARK` | Sem parâmetros: atualiza **todos** os grupos de produto (`TGFGRU`) para `VALEST = 'G'` e `AGRUPALOCVALEST = 'S'` |
| `STP_RESERVA_SPARK.SQL` | `STP_RESERVA_SPARK` | Reserva produtos gerando, a partir da nota informada (`NUNOTA`, `DTTRANSF`), uma nota de transferência para o local de reserva (`TGFCAB`/`TGFITE`/`TGFSER`, numeração do arquivo 716), já liberada (`STATUSNOTA = 'L'`) |
| `STP_ATUALIZA_DTPREV_SPARK.sql` | `STP_ATUALIZA_DTPREV_SPARK` | Propaga a data prevista de entrega do cabeçalho para os itens de pedidos sem quantidade entregue; insere em `TGFDTP` quando não existe |
| `STP_VERCORCUSTO_SPARK.SQL` | `STP_VERCORCUSTO_SPARK` | Compara custo bloqueado com o custo calculado por `OBTEMCUSTO` e atualiza/insere em `TGFCUS` |
| `STP_LIMPAREMESSA_SPARK.sql` | `STP_LIMPAREMESSA_SPARK` | Remove os vínculos de remessa entre notas fiscais selecionadas |

---

### 4. Logística / Expedição / Frete

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_GERARVOLUMES_SPARK.sql` | `STP_GERARVOLUMES_SPARK` | Gera a sugestão de volumetria para cotação de frete: agrupa os itens em caixas otimizadas por peso e dimensão (`AD_EMBPED`) e atualiza volumes/peso em `TGFCAB` |
| `STP_INCEMB_SPARK.sql` | `STP_INCEMB_SPARK` | Inclui manualmente embalagem no pedido (`P_CODPROD`, `P_CODEMB`, `P_PESO`) em `AD_EMBPED` e atualiza volumes/peso em `TGFCAB` |
| `STP_ATUALIZA_FRETE_COTA.sql` | `STP_ATUALIZA_FRETE_COTA` | Atualiza `VLRFRETE` da nota com o valor da cotação de frete associada (`AD_TGSCTF`) |
| `STP_AJUSTARRATFRETE_SAPARK.SQL` | `STP_AJUSTARRATFRETE_SAPARK` | Rateia proporcionalmente frete, ICMS e PIS/COFINS entre as notas vinculadas ao mesmo CT-e (o "SAPARK" no nome é grafia original) |
| `STP_VALIDAFRETE_SPARK.SQL` | `STP_VALIDAFRETE_SPARK` | Valida e rateia o frete de CT-e entre as notas de compra relacionadas, distribuindo ICMS e PIS proporcionalmente ao valor de cada nota |
| `STP_VALIDAFRETE_SPARK2.SQL` | `STP_VALIDAFRETE_SPARK2` | Variante em lote da anterior para CT-e da TOP 225 |
| `STP_IMPRIMIETIQUETA_SPARK.sql` | `STP_IMPRIMIETIQUETA_SPARK` | Recebe `P_NUNOTA`/produto/data e registra a data/hora de impressão da etiqueta em `TGFITE.AD_DHIMPRESSAO` |
| `STP_REGRALOCALDESTINO_SPARK.sql` | `STP_REGRALOCALDESTINO_SPARK` | Regra de negócio (assinatura `P_NUNOTA, P_SUCESSO OUT, ...`): atualiza `TGFITE.CODLOCALORIG` dos itens da nota conforme configuração |
| `STP_TGFCAB_AGRUPSEP_SPARK.sql` | `STP_TGFCAB_AGRUPSEP_SPARK` | Agrupa notas de venda selecionadas com o mesmo tipo de movimento, gravando um código de agrupamento sequencial em `TGFCAB.NUMPEDIDO2` |

---

### 5. Vendas / NF-e / Conferência

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_VALIDARCONF_SPARK.SQL` | `STP_VALIDARCONF_SPARK` | Valida conferências de recebimento: confere séries/códigos de barras contra a quantidade de itens da nota de origem |
| `STP_VALIDARSERIE_SPARK.SQL` | `STP_VALIDARSERIE_SPARK` | Para produtos com controle de série (`TIPCONTEST = 'S'`), compara a quantidade de séries apontadas com a quantidade negociada do item |
| `STP_VALIDARSERIECONS_SPARK.SQL` | `STP_VALIDARSERIECONS_SPARK` | Valida séries de devoluções contra as séries da nota original (divergência de quantidade e séries não encontradas) |
| `STP_TGFCAB_VINCSERIECONF_SPARK.sql` | `STP_TGFCAB_VINCSERIECONF_SPARK` | Vincula séries de produtos a uma conferência aberta, sem duplicar |
| `STP_NFREFDEV_SPARK.SQL` | `STP_NFREFDEV_SPARK` | Busca as últimas notas de compra do produto para referenciar na nota de devolução, valida a empresa e atualiza `VLRUNIT` |
| `STP_LIBERASERIE_SPARK.sql` | `STP_LIBERASERIE_SPARK` | Procedure **agendada**, sem parâmetros: libera séries de produção (`TPRSERPA`) e limpa código de barras em `TGFEST` |
| `STP_VALIDACAMPONOTA_SPARK.SQL` | `STP_VALIDACAMPONOTA_SPARK` | Valida CST do ICMS e CST do IPI de cada item; se nulo ou não preenchido (9999), aborta com erro |
| `STP_MARCAEFD08_TGFITE.SQL` | `STP_MARCAEFD08_TGFITE` | Marca/desmarca itens de nota como situação 08 da EFD, alternando `S`/`N` |
| `STP_PREENCHEVLRUNIT_SPARK.SQL` | `STP_PREENCHEVLRUNIT_SPARK` | Preenche o valor unitário em movimentações internas a partir da função `OBTEMCUSTO_SPARK` |
| `STP_ALT_CFOP_TGFITE.sql` | `STP_ALT_CFOP_TGFITE` | Botão de ação que altera o CFOP (`TGFITE.CODCFO`) dos itens selecionados para o novo CFOP informado no formulário; localiza cada item por `NUNOTA` + `SEQUENCIA` e valida o CFOP (máx. 4 dígitos) |
| `STP_CALCULAPROPORCAO_SPARK.SQL` | `STP_CALCULAPROPORCAO_SPARK` | Calcula a proporcionalidade do ICMS com base nas notas dos últimos 12 meses (excluindo o mês atual), por CFOP, e grava o índice em `AD_TGFPIM` |

---

### 6. Assistência Técnica / Ordem de Serviço

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCMOVASSIST_SPARK.SQL` | `STP_INCMOVASSIST_SPARK` | Gera a movimentação de materiais do consumo da Assistência Técnica Spark |
| `STP_INCNCONFORM_SPARK.SQL` | `STP_INCNCONFORM_SPARK` | Lança não conformidade em `AD_TGFNCO` para as notas selecionadas, com produto, descrição e quantidade informados |
| `STP_INCMOVOSINT_SPARK.SQL` | `STP_INCMOVOSINT_SPARK` | Gera a movimentação de materiais consumidos no atendimento de O.S. Internas: setor `T` (TI — TOP 515, local 115, CC 20300) ou `M` (PCM — TOP 400, local 101, CC 20600) |
| `STP_OSINTERNA_INC_SPARK.sql` | `STP_OSINTERNA_INC_SPARK` | Cria nova O.S. Interna via botão de ação |
| `STP_ENVIAEMAILOS_SPARK.SQL` | `STP_ENVIAEMAILOS_SPARK` | Evento (assinatura `P_TIPOEVENTO`) que envia e-mail aos setores responsáveis quando nova O.S. é criada |
| `STP_MOVMATASSIST_SPARK.sql` | `STP_MOVMATASSIST_SPARK` | Botão de ação em `AD_SPKCAE`: por O.S., gera primeiro a nota de transferência (TOP 708) levando os componentes de `AD_SPKICAE` do local 201 para o local do parceiro (`TGFPAR.AD_CODLOCAL`) e depois a nota de consumo (TOP 503) baixando-os do local do parceiro; grava `NUNOTADESC`/`NUNOTATRF` como idempotência, valida saldo antes e desfaz tudo em caso de erro |
| `STP_GRAVANOTA_ASSISTENCIA.sql` | `STP_GRAVANOTA_ASSISTENCIA` | Botão de ação: vincula a nota de serviço à O.S. selecionada em `AD_TGFASS` — valida o Nro. Único informado (`NUNOTA`) em `TGFCAB` e grava em `AD_TGFASS.NUNOTA`, ou aborta com erro. Nome sem sufixo `_SPARK` por já estar vinculado ao botão |

---

### 7. Financeiro

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCFINASSIST_SPARK.sql` | `STP_INCFINASSIST_SPARK` | Gera lançamento financeiro avulso (TGFFIN, sem NUNOTA) a partir de O.S. de assistência técnica selecionadas em `AD_SPKCAE`, aglutinando por parceiro (soma VLRCONSERTO) e marcando `AD_SPKCAE.NUFIN` como idempotência |
| `STP_EXCLUIRFINCOM_SPARK.sql` | `STP_EXCLUIRFINCOM_SPARK` | Para as linhas selecionadas de `AD_DBFECHCOMFIN` (`NUFECH` + `SEQUENCIA`), exclui o título em `TGFFIN` e limpa o `NUFIN` do registro |
| `STP_ATTCOTACAO_SPARK.SQL` | `STP_ATTCOTACAO_SPARK` | Atualiza `TGFFIN.VLRMOEDA` dos títulos selecionados com a cotação informada (`P_VLRMOEDA`) |
| `STP_ATUALIZARVLRMOEDA_SPARK.sql` | `STP_ATUALIZARVLRMOEDA_SPARK` | Recalcula preço unitário, total e desconto dos itens de notas de compra em moeda estrangeira (TOP 2200/2201) pela cotação |
| `STP_REGRA_VALID_FINAN_SPARK.sql` | `STP_REGRA_VALID_FINAN_SPARK` | Regra de validação: confere o total da nota com o total do financeiro |
| `STP_REGRA_VALID_FINAN_SPARK_C.sql` | `STP_REGRA_VALID_FINAN_SPARK_C` | Variante por cliente: confere o saldo entre valores da nota e movimentações financeiras |
| `STP_REGRA_VALID_AVISTA_SPARK.sql` | `STP_REGRA_VALID_AVISTA_SPARK` | Valida venda à vista: títulos com vencimento no dia exigem liberação do financeiro, exceto `CODTIPTIT` 34/35/36 e notas de marketplace/e-commerce (`CODVEND` 5, 6, 42, 43, 44) |
| `EVP_GEROBRGDIFAL_SPARK.SQL` | `EVP_GEROBRGDIFAL_SPARK` | **Botão de ação** (apesar do prefixo `EVP_`), autor Lucas Gabriel, out/2026: gera obrigações fiscais DIFAL (`CODOBR` 90) e FCP (`CODOBR` 6) em `TGFOIR` para o período/empresa informados (`P_DATAINI`, `P_DATAFIN`, `P_CODEMP`). Por operação (empresa sem IE na UF de destino: uma obrigação por nota, `AD_NUNOTA` preenchido) ou por apuração (com IE: agrupa por empresa/UF/competência, vendas − devoluções). Controla duplicidade e faz rollback integral em erro |

---

### 8. Produto / Cadastro

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_ALTDADOSPRO_SPARK.sql` | `STP_ALTDADOSPRO_SPARK` | Altera em lote parâmetros de produto: fornecedor, leadtime, estoques mínimo/máximo e agrupamento mínimo |
| `STP_MUDANCADECODIGO_SPARK.SQL` | `STP_MUDANCADECODIGO_SPARK` | Limpa os números de série em `TGFBAR` para que a mudança de código de produto funcione |
| `STP_ORIGPROD_SPARK.sql` | `STP_ORIGPROD_SPARK` | Evento (assinatura `P_TIPOEVENTO`) que sincroniza a origem do produto entre o item da nota (`TGFITE`) e o cadastro (`TGFPRO`) em notas de saída |
| `STP_CORCSTIPI_SPARK.sql` | `STP_CORCSTIPI_SPARK` | Corrige CST do IPI e código de enquadramento (`CODENQIPI`, entrada/saída) dos itens selecionados; remove lançamentos contábeis (`TCBLAN`/`TCBINT`) e valida CST × CFOP |
| `Stp_ALTCAMOUTROS_SPARK.sql` | `STP_ALTCAMOUTROS_SPARK` | Regra de negócio (`P_NUNOTA, P_SEQUENCIA, ...`): atualiza o total de outros gastos da nota com a soma dos itens |
| `Stp_ALTCAMOUTROS_SPARK_COMP.sql` | `STP_ALTCAMOUTROS_SPARK_COMP` | Atualiza `TGFCAB.VLROUTROS` com a soma de `TGFITE.AD_VLROUTROSCOMP` dos itens |
| `STP_LIMPAAGENDAIBPT_SPARK.SQL` | `STP_LIMPAAGENDAIBPT_SPARK` | Sem parâmetros: limpa os campos de percentual de ICMS e IPI em `TGFPRO` e `TGFPEM` |

---

### 9. Produção — Operacional

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_TPRCOI_SPARK.SQL` | `STP_TPRCOI_SPARK` | Evento (assinatura `P_TIPOEVENTO`) na conferência de produtos (`TPRCOI`): no `BEFORE_INSERT` copia `CODBARRA` para `CONTROLE` |
| `STP_TPRIATV_SPARK.SQL` | `STP_TPRIATV_SPARK` | Reabre (com confirmação) ou fecha atividades de produção (`TPRIATV`), gravando tempo gasto e usuário; na planta 1 bloqueia o fechamento se houver movimentação acessória sem apontamento de PA, e, se o processo não tiver nenhuma nota (PA nem materiais), grava `TPRIPROC.STATUSPROC = 'C'` |
| `STP_TPRIPROC_CANC_SPARK.SQL` | `STP_TPRIPROC_CANC_SPARK` | Reabre uma OP cancelada: limpa atividades/apontamentos e volta `TPRIPROC.STATUSPROC` para `'R'` |
| `STP_AGRUPAIMP_SPARK.sql` | `STP_AGRUPAIMP_SPARK` | Agrupa os processos de produção selecionados (`TPRIPROC`) com um identificador sequencial em `AD_AGRUPADORIMP` |
| `STP_REABRIR_PA_SPARK.SQL` | `STP_REABRIR_PA_SPARK` | Botão de ação na grade de atividades (`TPRIATV`): reabre o(s) PA(s) do lote (`TPRIPA.CONCLUIDO = 'N'`) para destravar apontamentos travados por conclusão indevida; o `NROLOTE` é obtido automaticamente de `TPRIPROC` |
| `STP_CORRIGENOTAPROD_SPARK.SQL` | `STP_CORRIGENOTAPROD_SPARK` | Rede de segurança executada por agendador externo: verifica se cada conferência de produção finalizada (`TPRCONF` `STATUS='F'`) gerou corretamente a sua nota de produção (TOP 800) e corrige divergências — nota ausente, séries faltantes em `TGFSER` e quantidade divergente em `TGFITE` (ajustando `TGFEST` no mesmo delta). Audita em `AD_CORRNOTAPROD` |
| `STP_CORRIGEAPONTAMENTO_SPARK.SQL` | `STP_CORRIGEAPONTAMENTO_SPARK` | Procedure agendável **sem parâmetros** (o agendador do Sankhya a invoca sem argumentos): aciona a `STP_CORRIGEAPO_PERIODO_SPARK` com a janela fixa de 3 dias (constante `V_DIAS`). Compilar depois da `PERIODO` |
| `STP_CORRIGEAPO_PERIODO_SPARK.SQL` | `STP_CORRIGEAPO_PERIODO_SPARK` | Lógica da validação dos apontamentos (`TPRAPA`) de conferências finalizadas a partir de `P_DTINI`: corrige `QTDAPONTADA`/`QTDFAT` para o nº de séries em `AD_TPRCOI` da conferência (vínculo `TPRCONF.NUAPO`). Casos ambíguos (apontamento de várias conferências / várias linhas do mesmo PA) são só registrados. Atua só em apontamentos da etapa de expedição (única que movimenta estoque). Nunca altera OPs canceladas (`C`), em cancelamento (`C2`) ou finalizadas (`F`). Uso manual: carga de período, `P_IDIPROC` ou simulação (`P_SIMULA => 'S'`; versão em `SELECT`: `scripts/DRYRUN_CORRIGEAPONTAMENTO.SQL`). Audita em `AD_CORRAPONTAMENTO` |

---

### 10. Integração E-commerce / Marketplace

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INTEGRAPEDIDO_SITESPARK.sql` | `STP_INTEGRAPEDIDO_SITESPARK` | Botão de ação: converte os pedidos selecionados do portal de vendas (`AD_TGSCAB`/`AD_TGSITE`, parceiro em `AD_TGSPAR`) em pedido de venda no ERP (`TGFCAB` `TIPMOV 'P'`, `TGFITE`, `TGFSER`). Observação "venda realizada durante AUTOMEC". **Atenção:** o `UPDATE AD_TGSCAB SET NUNOTA = ...` após criar o cabeçalho não tem `WHERE` |
| `STP_INTEGRAPEDIDO_AGENDADA.sql` | `STP_INTEGRAPEDIDO_AGENDADA` | Versão automática (sem seleção) da integração: cria notas/itens/séries a partir dos pedidos pendentes de feiras e eventos em `AD_TGSCAB` e grava o `NUNOTA` gerado |

> As procedures da integração antiga com o Mercado Livre (`STP_ATTESTML_SPARK` e `STP_BUSCAATRIBML_SPARK`) foram movidas para [`inativos/`](../inativos/README.md) em 08/10/2026 — não existem mais no banco.

---

### 11. Colaboradores / RH

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_TFPFUN_ALTERADEP.SQL` | `STP_TFPFUN_ALTERADEP` | Altera departamento de funcionário no cadastro de RH |

---

### 12. Eventos de Tela (EVP)

| Arquivo | Procedure | Descrição |
|---|---|---|
| `EVP_CLASSIFICACTE_SPARK.sql` | `EVP_CLASSIFICACTE_SPARK` | Evento de visão externa em `TGFIXN` que classifica o `CODTIPOPER` do CT-e a partir das NF-e referenciadas no XML (via `VW_CTE_AUTORIZADOS`): no `AFTER_INSERT` do CT-e e no `AFTER_UPDATE` da NF-e (classifica CT-e pendentes que a referenciam) |
| `EVP_TGFIXN_EMAIL_SPARK.sql` | `EVP_TGFIXN_EMAIL_SPARK` | Evento de visão externa que, no `AFTER_INSERT`, envia e-mail às áreas fiscal e de controladoria quando entram notas de devolução (CFOP 5201, 5202, 6201, 6202, 5410, 6410) |
| `STP_CLASSIFICACTE_SPARK.sql` | `STP_CLASSIFICACTE_SPARK` | Sucessora agendada de `EVP_CLASSIFICACTE_SPARK` (roda a cada 5 min). Classifica automaticamente o `CODTIPOPER` de CT-e **pendentes** (`TGFIXN.STATUS = 0`) a partir do `CODTIPOPER` das NF-e referenciadas no XML, via `VW_CTE_AUTORIZADOS`. Mapeamento por prioridade para as TOPs 225 / 226 / 242 / 234. Registra `CTE_OK` / `CTE_SKIP` / `CTE_ERR` em `AD_LOG_ERROS`. Complementada pela regra `formulas/regra_processa_xml_cte.sql` |

---

### 13. Auxiliares / Configuração

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_AVISOINC_SPARK.SQL` | `STP_AVISOINC_SPARK` | Envia e-mail aos grupos de desenvolvimento e fiscal avisando da inclusão de um novo produto |
| `STP_GRAVA_FILA_BI2.SQL` | `STP_GRAVA_FILA_BI2` | Grava mensagem de e-mail na fila de envio do Sankhya (`TMDFMG`) com status pendente e controle de tentativas |
| `STP_INICIADATA_SPARK.SQL` | `STP_INICIADATA_SPARK` | Retroage a data de alteração dos tipos de negociação (`TGFTPV`) para 31/01/2022 |
| `STP_INCLUIRLANCTO_SPARK.SQL` | `STP_INCLUIRLANCTO_SPARK` | *(em testes)* Lança previsão de manutenção em `AD_PRVCTR` (bem, controle, data prevista, tipo/natureza de manutenção, operador, custo, observação) |

---

### 14. Conferência de Importação de XML (`AD_TGSIXN`)

Apontamento de conferência de notas importadas. Como `TGFIXN` não aceita botão de
ação, o fluxo migrou para a tela de `AD_TGSIXN` — parte do papel destas procedures
passou para as triggers `TRG_*_AD_TGSIXN_SPARK` (ver `tables/AD_TGSIXN.SQL`).

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_APONTACONFERENCIA_SPARK.SQL` | `STP_APONTACONFERENCIA_SPARK` | *(uso legado)* Botão de ação sobre `TGFIXN` que gravava o apontamento em `AD_TGSIXN` (novo `NUCONF`, usuário, arquivo), bloqueando duplicidade por `NUARQUIVO`. Substituída pela criação direta na tela + `TRG_INC_AD_TGSIXN_SPARK` |
| `STP_ATUALIZADTFIM_TGSIXN_SPARK.sql` | `STP_ATUALIZADTFIM_TGSIXN_SPARK` | Procedure **agendada**: reavalia apontamentos em aberto (`STATUS = 1`), localiza a nota lançada correspondente (`TGFIXN.CHAVEACESSO` → `TGFCAB.CHAVENFE`, `STATUSNOTA = 'L'`), grava `TGFCAB.DTMOV` em `DTFIM` e recalcula `DURACAO_DIAS_UTEIS` (dias úteis, sem sábado/domingo). Erros por apontamento vão para `AD_LOG_ERROS` sem abortar o lote |

---

### 15. Objetos descobertos no banco em 08/10/2026 (autoria de terceiros)

> **Contexto.** O inventário de 08/10/2026 (`scripts/inventario_2026-10-08/`) mostrou 21 procedures `*_SPARK` que existiam no banco mas não tinham nenhum arquivo neste repositório. A maioria traz no próprio fonte a autoria de **Lucas Gabriel (ONTIME TECH / DM TECH)**, o mesmo autor das functions `FC_RATEIOFRETE_SAPARK` e `FN_GET_ULTIMO_CUSTO_SPARK1` (ver `functions/README.md`). Os arquivos foram capturados do banco **sem alteração do corpo** (só a qualificação `"SPARKPRD".` foi removida) e ganharam um cabeçalho de captura; **a padronização do cabeçalho e a documentação dos parâmetros ainda estão pendentes**. A coluna "Descrição" vem do campo *Objetivo* do comentário do autor; onde o fonte não traz descrição, ela foi inferida do código e está marcada *(do código)*.

| Arquivo | Procedure | Tipo | Descrição (do fonte) | Autor (no fonte) |
|---|---|---|---|---|
| `EVP_DEVICMSSIMPLES_SPARK.SQL` | `EVP_DEVICMSSIMPLES_SPARK` | EVP (evento de tela) | Corrigir as devolução do simples nacional para poder gerar o ajsute posteriormente. | Lucas Gabriel |
| `EVP_GEROBSPADEFD_SPARK.SQL` | `EVP_GEROBSPADEFD_SPARK` | EVP (evento de tela) | Preencher o campo CODOBSPADRAO do cabeçalho da nota para que o SPED entenda que aquela nota precisa de documento relacionado, e apartir dai gere os registro que precise, tentamos via forma nativa de preencher a sugstão no layout porém nem sempre os usuarios clicam em novo gerando erros no EFD. | Lucas Gabriel |
| `EVP_ICMSSIMPLES_SPARK.SQL` | `EVP_ICMSSIMPLES_SPARK` | EVP (evento de tela) | Não levar mais o ICMS do Simples nacional em campos proprio, devido a adequação da legislação, a costumização se fez necessaria para não ter que separar em top, aquisição de RPTA e simples, facilitar a vida do fiscal. | Lucas Gabriel |
| `EVP_PISCOFINSSPARK.SQL` | `EVP_PISCOFINSSPARK` | EVP (evento de tela) | corrigir o PIS e COFINS das notas fiscais de Devolução do Simples nacional pois não pode ser devolvido o ICMS em campos próprios e sim em ajuste. | Lucas Gabriel |
| `EVP_PISCOFINSSP_SPARK.SQL` | `EVP_PISCOFINSSP_SPARK` | EVP (evento de tela) | corrigir o PIS e COFINS das notas fiscais de Devolução do Simples nacional pois não pode ser devolvido o ICMS em campos próprios e sim em ajuste. | Lucas Gabriel |
| `STP_AJUSTEC197DEV_SPARK.SQL` | `STP_AJUSTEC197DEV_SPARK` | Botão de ação | Automatizar o preenchimento do registro C197, pois hoje ta sendo feito manualmente, sendo assim o usuario vai utilizar o dashboard para analisar as notas e dentro do dashboard vai rodar o botão de ação para automatizar o passo de preenchimento. | Lucas Gabriel |
| `STP_ATUALFINLOTE_SPARK.SQL` | `STP_ATUALFINLOTE_SPARK` | Botão de ação | Ajustar data de vencimento de mais de um titulo de uma so vez. | Lucas Gabriel - DM TECH |
| `STP_BLOCOK200_SPARK.SQL` | `STP_BLOCOK200_SPARK` | Botão de ação | Corrigir a copia de estoque baseado na planilha externa apurada | Lucas Gabriel - DM TECH |
| `STP_BLOQITEMFLINHA_SPARK.SQL` | `STP_BLOQITEMFLINHA_SPARK` | Procedure | Evitar erros do comercial quando recebe o pedido com código antigo e acaba digitando o pedido mesmo assim | Lucas Gabriel |
| `STP_BOLJUROSMULTA_SPARK.SQL` | `STP_BOLJUROSMULTA_SPARK` | EVP (evento de tela) | Desmembrar o valor do juros e multa no momento da baixa pois o banco Itaú envia tudo consolidado e o Sankhya ainda não tem preparo na API para essa tratativa. | Lucas Gabriel - ONTIME TECH |
| `STP_CABPESOEXP_SPARK.SQL` | `STP_CABPESOEXP_SPARK` | EVP (evento de tela) | informar o codigo de parceiro e realizar travas importantes para que tenha integridade do numero unico da pesagem com o numero unico do pedido. | Lucas Gabriel |
| `STP_CALCPROPOICMS_SPARK.SQL` | `STP_CALCPROPOICMS_SPARK` | Botão de ação | Calcular o ICMS Porpocional dos utlimos meses para calcular o estorno de ICMS Baseado no acumulativo dos ultimos 12 meses. | Lucas Gabriel - ONTIME TECH |
| `STP_CORPISCOFINSIMP_SPARK.SQL` | `STP_CORPISCOFINSIMP_SPARK` | Botão de ação | Corrigir informações de PIS e COFINS de importação | Lucas Gabriel |
| `STP_CORRIGERATEIOCT_SPARK.SQL` | `STP_CORRIGERATEIOCT_SPARK` | EVP (evento de tela) | Corrigir o valor do rateio do frete, pois estão corrigindo manualmente a cada lançamento de CTE. O objetivo da personalização é corrigir o CTE se encontrar a nota. Caso contrário, segue o fluxo sem travar os lançamentos de CTE. | Lucas Gabriel - DM TECH |
| `STP_DUP_METAS_SPARK.SQL` | `STP_DUP_METAS_SPARK` | Botão de ação | *(do código)* Duplica as metas selecionadas em `AD_TGSSGM` (`CODSGRU`, `VLRMET`, `APELIDO`) para o ano/mês informados (`Ano`, `MES`); metas já existentes no destino são ignoradas (`DUP_VAL_ON_INDEX`) e contadas na mensagem | — |
| `STP_EMAIL_CONTRATO_SPARK.SQL` | `STP_EMAIL_CONTRATO_SPARK` | Procedure | Envio de E-mail avisando da proximidade do termino do contrato para o gestor do contrato, para que faça a gestão do contrato. | Lucas Gabriel - DM TECH |
| `STP_GERGUIAICMS_SPARK.SQL` | `STP_GERGUIAICMS_SPARK` | Botão de ação | Criar os financeiros automatico apartir do preenchimento da tela de obrigações | Lucas Gabriel |
| `STP_INCSUSPIPI_SPARK.SQL` | `STP_INCSUSPIPI_SPARK` | Botão de ação | Informar os produtos que contém suspensão do IPI na tabela de IPI de forma automática. | Lucas Gabriel - DM TECH |
| `STP_ITEPESOEXP_SPARK.SQL` | `STP_ITEPESOEXP_SPARK` | EVP (evento de tela) | Validar informações do preenchimento da pesagem de exportação | Lucas Gabriel - ONTIME TECH |
| `STP_STATUSCHQ_SPARK.SQL` | `STP_STATUSCHQ_SPARK` | Botão de ação | *(do código)* Gestão de cheque nos títulos selecionados (`TGFFIN`): conforme `P_STATUS` (1–6) marca `S`/`N` em `AD_CHEQUECOM`, `AD_CHEQUECLI` ou `AD_CHEQUEFIN`; se `P_HISTORICO` for informado, grava em `HISTORICO` | — |
| `STP_TIPOVOLPESO_SPARK.SQL` | `STP_TIPOVOLPESO_SPARK` | Botão de ação | Alterar as informações de Peso, volume, peso apos a confirmação da nota e for feito carta de correção, pois acontece do fiscal fazer carta de correção a transportadora aprova, e precisa reimprimir as etiquetas fica impedido. | Lucas Gabriel |

---

## Observações Gerais

- Procedures do tipo `STP_` que operam sobre registros selecionados usam sempre o padrão de loop `FOR I IN 1..P_QTDLINHAS LOOP` com `ACT_INT_FIELD` para buscar cada linha.
- Erros de negócio são lançados via `RAISE_APPLICATION_ERROR(-2000x, '...')` com mensagens em português, exibidas diretamente ao usuário no ERP.
- Procedures com `SAVEPOINT` / `ROLLBACK TO SAVEPOINT` garantem que falhas em linhas individuais não revertam todo o lote.
- Procedures que enviam e-mail ou gravações em fila (`TMDFMG`) dependem do servidor de e-mail configurado no Sankhya.
