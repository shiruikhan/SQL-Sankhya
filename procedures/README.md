# Catálogo de Procedures

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de procedures:** 102  
**Banco:** Oracle PL/SQL  

---

## Tipos de Procedure

| Prefixo | Tipo | Assinatura padrão |
|---|---|---|
| `STP_` | Stored Procedure — botão de ação no Sankhya | `(P_CODUSU, P_IDSESSAO, P_QTDLINHAS, P_MENSAGEM OUT)` |
| `EVP_` | Evento de visão externa — evento de tela | `(P_TIPOEVENTO, P_IDSESSAO, P_CODUSU)` |

As procedures de botão de ação recebem parâmetros via `ACT_TXT_PARAM` / `ACT_INT_FIELD` (funções nativas do Sankhya), que buscam valores informados pelo usuário ou campos selecionados na tela.

---

## Catálogo por Domínio

### 1. Planejamento e Controle da Produção (PCP / MRP)

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_PCP_SPARK.sql` | `STP_PCP_SPARK` | Gera o Plano Mestre de Produção (MPS) para um PA: calcula demanda bruta, estoque inicial, giro mensal, lote padrão e projeta necessidades de produção por período |
| `STP_PCPMETA_SPARK.sql` | `STP_PCPMETA_SPARK` | Variante do `STP_PCP_SPARK` orientada por meta de produção: força PIs como sub-ordens para o MRP considerar na composição do MPS |
| `STP_TGFMET_SPARK.sql` | `STP_TGFMET_SPARK` | Gerencia metas de produção: cria ou atualiza registros em `TGMMET` por produto |
| `STP_ALTERAMETA_SPARK.SQL` | `STP_ALTERAMETA_SPARK` | Altera meta de produção de um ou mais produtos via botão de ação |
| `STP_OBSPLANEJA_SPARK.SQL` | `STP_OBSPLANEJA_SPARK` | Registra observações de planejamento associadas ao produto/plano |
| `STP_GERALISTAMPS_SPARK.sql` | `STP_GERALISTAMPS_SPARK` | Gera lista de materiais (stamp list) para produção — uso interno |
| `STP_GERALISTAMPS_SPARK_TERC.sql` | `STP_GERALISTAMPS_SPARK_TERC` | Versão da lista de materiais para processos terceirizados |
| `STP_COPIALISTAMP_SPARK.sql` | `STP_COPIALISTAMP_SPARK` | Copia lista de materiais de um produto para outro |

---

### 2. Compras / Solicitação de Compra

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_APROVA_SOLIC_COMPRA.sql` | `STP_APROVA_SOLIC_COMPRA` | Aprova ou cancela solicitações de compra. Valida status `EA`, registra aprovador/motivo, notifica solicitante via fila |
| `STP_NOTIFICASOLICCOMPRA_SPARK.sql` | `STP_NOTIFICASOLICCOMPRA_SPARK` | Envia notificação ao aprovador quando há novas solicitações pendentes |
| `STP_ATTCOTACAO_SPARK.SQL` | `STP_ATTCOTACAO_SPARK` | Atualiza cotação de compra com o fornecedor escolhido |
| `STP_ATUALIZA_FRETE_COTA.sql` | `STP_ATUALIZA_FRETE_COTA` | Atualiza valor de frete na cotação de compra |
| `STP_MARCARNPENDENTE_SPARK.SQL` | `STP_MARCARNPENDENTE_SPARK` | Marca itens de pedido de compra como pendentes |
| `STP_REABRIRPENDENTE_SPARK.SQL` | `STP_REABRIRPENDENTE_SPARK` | Reabre itens de pedido de compra que foram fechados indevidamente |
| `STP_IMPORTTAB_SPARK.sql` | `STP_IMPORTTAB_SPARK` | Importa tabela de preços de fornecedor para o ERP |

---

### 3. Estoque / Movimentação

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_TRANSFEMP_SPARK.SQL` | `STP_TRANSFEMP_SPARK` | Realiza transferência de produtos entre empresas. Cria cabeçalho (TGFCAB), itens (TGFITE) com SEQUENCIA calculada via ROW_NUMBER e usa SAVEPOINTs para rollback seletivo |
| `STP_GARANTEESTOQUE_SPARK.SQL` | `STP_GARANTEESTOQUE_SPARK` | Garante que todos os grupos de produtos estejam com validação de estoque ativada (`VALEST = 'G'`) |
| `STP_RESERVA_SPARK.SQL` | `STP_RESERVA_SPARK` | Reserva estoque de produto para pedido específico |
| `STP_ATUALIZA_DTPREV_SPARK.sql` | `STP_ATUALIZA_DTPREV_SPARK` | Atualiza data de previsão de entrega em pedidos |
| `STP_VERCORCUSTO_SPARK.SQL` | `STP_VERCORCUSTO_SPARK` | Verifica e corrige custos de produto por empresa/local |
| `STP_LIMPAREMESSA_SPARK.sql` | `STP_LIMPAREMESSA_SPARK` | Limpa remessa/embarque cancelada ou com erro |

---

### 4. Logística / Expedição / Frete

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_GERARVOLUMES_SPARK.SQL` | `STP_GERARVOLUMES_SPARK` | Gera volumes de embalagem para expedição com base nos itens do pedido |
| `STP_INCEMB_SPARK.sql` | `STP_INCEMB_SPARK` | Inclui pedido no embarque de expedição |
| `STP_AJUSTARRATFRETE_SAPARK.SQL` | `STP_AJUSTARRATFRETE_SAPARK` | Ajusta o rateio de frete entre os itens da nota |
| `STP_VALIDAFRETE_SPARK.SQL` | `STP_VALIDAFRETE_SPARK` | Valida valor de frete informado antes de confirmar nota |
| `STP_VALIDAFRETE_SPARK2.SQL` | `STP_VALIDAFRETE_SPARK2` | Segunda validação de frete (regras complementares) |
| `STP_IMPRIMIETIQUETA_SPARK.sql` | `STP_IMPRIMIETIQUETA_SPARK` | Dispara impressão de etiqueta de produto/volume via botão de ação |
| `STP_AGRUPAIMP_SPARK.sql` | `STP_AGRUPAIMP_SPARK` | Agrupa impressão de etiquetas por lote de expedição |
| `STP_REGRALOCALDESTINO_SPARK.sql` | `STP_REGRALOCALDESTINO_SPARK` | Define local de destino dos itens conforme regra de negócio de expedição |
| `STP_TGFCAB_AGRUPSEP_SPARK.sql` | `STP_TGFCAB_AGRUPSEP_SPARK` | Agrupa separação de pedidos para expedição |

---

### 5. Vendas / NF-e / Conferência

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_VALIDARCONF_SPARK.SQL` | `STP_VALIDARCONF_SPARK` | Valida séries e itens antes de confirmar conferência de nota de venda |
| `STP_VALIDARSERIE_SPARK.SQL` | `STP_VALIDARSERIE_SPARK` | Valida se séries do pedido estão corretamente vinculadas |
| `STP_VALIDARSERIECONS_SPARK.SQL` | `STP_VALIDARSERIECONS_SPARK` | Valida consistência de séries consolidadas |
| `STP_TGFCAB_VINCSERIECONF_SPARK.sql` | `STP_TGFCAB_VINCSERIECONF_SPARK` | Vincula séries ao pedido de venda na confirmação |
| `STP_NFREFDEV_SPARK.SQL` | `STP_NFREFDEV_SPARK` | Cria referência de NF-e em devolução |
| `STP_LIBERASERIE_SPARK.sql` | `STP_LIBERASERIE_SPARK` | Libera série de produto bloqueada para uso em outro pedido |
| `STP_VALIDACAMPONOTA_SPARK.SQL` | `STP_VALIDACAMPONOTA_SPARK` | Valida campos obrigatórios da nota antes da confirmação |
| `STP_MARCAEFD08_TGFITE.SQL` | `STP_MARCAEFD08_TGFITE` | Marca itens para EFD registro 08 (escrituração fiscal) |
| `STP_PREENCHEVLRUNIT_SPARK.SQL` | `STP_PREENCHEVLRUNIT_SPARK` | Preenche valor unitário dos itens conforme tabela de preço |
| `STP_ALT_CFOP_TGFITE.sql` | `STP_ALT_CFOP_TGFITE` | Botão de ação que altera o CFOP (`TGFITE.CODCFO`) dos itens selecionados para o novo CFOP informado no formulário; localiza cada item por `NUNOTA` + `SEQUENCIA` e valida o CFOP (máx. 4 dígitos) |

---

### 6. Assistência Técnica / Ordem de Serviço

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCMOVASSIST_SPARK.SQL` | `STP_INCMOVASSIST_SPARK` | Inclui movimentação de peça/produto na assistência técnica |
| `STP_INCNCONFORM_SPARK.SQL` | `STP_INCNCONFORM_SPARK` | Registra não conformidade no processo de assistência |
| `STP_INCMOVOSINT_SPARK.SQL` | `STP_INCMOVOSINT_SPARK` | Inclui movimentação em O.S. interna |
| `STP_OSINTERNA_INC_SPARK.sql` | `STP_OSINTERNA_INC_SPARK` | Cria nova O.S. Interna via botão de ação |
| `STP_ENVIAEMAILOS_SPARK.SQL` | `STP_ENVIAEMAILOS_SPARK` | Envia e-mail aos setores responsáveis quando nova O.S. é criada |
| `STP_MOVMATASSIST_SPARK.sql` | `STP_MOVMATASSIST_SPARK` | Botão de ação em `AD_SPKCAE`: por O.S., gera nota de consumo (TOP 503) baixando os componentes de `AD_SPKICAE` do local do parceiro (`TGFPAR.AD_CODLOCAL`) e nota de transferência (TOP 708) repondo do local 201 para o local do parceiro; grava `NUNOTADESC`/`NUNOTATRF` como idempotência, valida saldo antes e desfaz tudo em caso de erro |
| `STP_GRAVANOTA_ASSISTENCIA.sql` | `STP_GRAVANOTA_ASSISTENCIA` | Botão de ação: vincula a nota de serviço à O.S. selecionada em `AD_TGFASS` — valida o Nro. Único informado (`NUNOTA`) em `TGFCAB` e grava em `AD_TGFASS.NUNOTA`, ou aborta com erro. Nome sem sufixo `_SPARK` por já estar vinculado ao botão |

---

### 7. Financeiro

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCLUIRLANCTO_SPARK.SQL` | `STP_INCLUIRLANCTO_SPARK` | Inclui lançamento financeiro avulso vinculado a nota |
| `STP_INCFINASSIST_SPARK.sql` | `STP_INCFINASSIST_SPARK` | Gera lançamento financeiro avulso (TGFFIN, sem NUNOTA) a partir de O.S. de assistência técnica selecionadas em `AD_SPKCAE`, aglutinando por parceiro (soma VLRCONSERTO) e marcando `AD_SPKCAE.NUFIN` como idempotência |
| `STP_EXCLUIRFINCOM_SPARK.sql` | `STP_EXCLUIRFINCOM_SPARK` | Exclui lançamento financeiro complementar |
| `STP_ATUALIZARVLRMOEDA_SPARK.sql` | `STP_ATUALIZARVLRMOEDA_SPARK` | Atualiza valor monetário convertendo pela taxa de câmbio vigente |
| `STP_REGRA_VALID_FINAN_SPARK.sql` | `STP_REGRA_VALID_FINAN_SPARK` | Regra de validação financeira: verifica condições de pagamento e natureza |
| `STP_REGRA_VALID_FINAN_SPARK_C.sql` | `STP_REGRA_VALID_FINAN_SPARK_C` | Complemento da validação financeira (regras adicionais) |
| `STP_REGRA_VALID_AVISTA_SPARK.sql` | `STP_REGRA_VALID_AVISTA_SPARK` | Valida condições específicas para vendas à vista |
| `STP_VGERENCIAL_SPARK.SQL` | `STP_VGERENCIAL_SPARK` | Prepara visão gerencial financeira para dashboard |

---

### 8. Produto / Cadastro

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_ALTDADOSPRO_SPARK.sql` | `STP_ALTDADOSPRO_SPARK` | Altera dados de produto em lote (campos específicos) |
| `STP_MUDANCADECODIGO_SPARK.SQL` | `STP_MUDANCADECODIGO_SPARK` | Realiza mudança de código de produto e atualiza referências |
| `STP_ORIGPROD_SPARK.sql` | `STP_ORIGPROD_SPARK` | Define origem do produto conforme CST |
| `STP_CORCSTIPI_SPARK.sql` | `STP_CORCSTIPI_SPARK` | Corrige CST do IPI em itens com valor inconsistente |
| `Stp_ALTCAMOUTROS_SPARK.sql` | `Stp_ALTCAMOUTROS_SPARK` | Altera campos "Outros" em itens de nota |
| `Stp_ALTCAMOUTROS_SPARK_COMP.sql` | `Stp_ALTCAMOUTROS_SPARK_COMP` | Versão complementar do `ALTCAMOUTROS` (regras adicionais) |
| `STP_LIMPAAGENDAIBPT_SPARK.SQL` | `STP_LIMPAAGENDAIBPT_SPARK` | Limpa agenda de atualização IBPT de produtos |

---

### 9. Produção — Operacional

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_TPRCOI_SPARK.SQL` | `STP_TPRCOI_SPARK` | Cria componentes de ordens internas de produção |
| `STP_TPRIATV_SPARK.SQL` | `STP_TPRIATV_SPARK` | Ativa processo de produção |
| `STP_TPRIPROC_CANC_SPARK.SQL` | `STP_TPRIPROC_CANC_SPARK` | Cancela item de processo de produção |
| `STP_INICIADATA_SPARK.SQL` | `STP_INICIADATA_SPARK` | Define data de início de processo de produção |
| `STP_CALCULAPROPORCAO_SPARK.SQL` | `STP_CALCULAPROPORCAO_SPARK` | Calcula proporcionalidade de componentes entre ordens |
| `STP_REABRIR_PA_SPARK.SQL` | `STP_REABRIR_PA_SPARK` | Botão de ação na grade de atividades (`TPRIATV`): reabre o(s) PA(s) do lote (`TPRIPA.CONCLUIDO = 'N'`) para destravar apontamentos travados por conclusão indevida; o `NROLOTE` é obtido automaticamente de `TPRIPROC` |
| `STP_CORRIGENOTAPROD_SPARK.SQL` | `STP_CORRIGENOTAPROD_SPARK` | Rede de segurança executada por agendador externo: verifica se cada conferência de produção finalizada (`TPRCONF` `STATUS='F'`) gerou corretamente a sua nota de produção (TOP 800) e corrige divergências — nota ausente, séries faltantes em `TGFSER` e quantidade divergente em `TGFITE` (ajustando `TGFEST` no mesmo delta). Audita em `AD_CORRNOTAPROD` |
| `STP_CORRIGEAPONTAMENTO_SPARK.SQL` | `STP_CORRIGEAPONTAMENTO_SPARK` | Procedure agendável **sem parâmetros** (o agendador do Sankhya a invoca sem argumentos): aciona a `STP_CORRIGEAPO_PERIODO_SPARK` com a janela fixa de 3 dias (constante `V_DIAS`). Compilar depois da `PERIODO` |
| `STP_CORRIGEAPO_PERIODO_SPARK.SQL` | `STP_CORRIGEAPO_PERIODO_SPARK` | Lógica da validação dos apontamentos (`TPRAPA`) de conferências finalizadas a partir de `P_DTINI`: corrige `QTDAPONTADA`/`QTDFAT` para o nº de séries em `AD_TPRCOI` da conferência (vínculo `TPRCONF.NUAPO`). Casos ambíguos (apontamento de várias conferências / várias linhas do mesmo PA) são só registrados. Atua só em apontamentos da etapa de expedição (única que movimenta estoque). Nunca altera OPs canceladas (`C`), em cancelamento (`C2`) ou finalizadas (`F`). Uso manual: carga de período, `P_IDIPROC` ou simulação (`P_SIMULA => 'S'`; versão em `SELECT`: `scripts/DRYRUN_CORRIGEAPONTAMENTO.SQL`). Audita em `AD_CORRAPONTAMENTO` |

---

### 10. Integração E-commerce / Marketplace

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INTEGRAPEDIDO_SITESPARK.sql` | `STP_INTEGRAPEDIDO_SITESPARK` | Converte pedido do site da Spark em nota de venda no ERP |
| `STP_INTEGRAPEDIDO_AGENDADA.sql` | `STP_INTEGRAPEDIDO_AGENDADA` | Versão agendada da integração de pedidos — execução automática via scheduler |
| `STP_GRAVA_FILA_BI2.SQL` | `STP_GRAVA_FILA_BI2` | Grava mensagem na fila de processamento assíncrono do Sankhya (BI/Integração) |

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
| `EVP_CLASSIFICACTE_SPARK.sql` | `EVP_CLASSIFICACTE_SPARK` | Evento de visão externa que classifica CT-e importado conforme regras de tipo e situação |
| `EVP_TGFIXN_EMAIL_SPARK.sql` | `EVP_TGFIXN_EMAIL_SPARK` | Evento de visão externa que dispara envio de e-mail ao importar CT-e/NF-e |
| `STP_CLASSIFICACTE_SPARK.sql` | `STP_CLASSIFICACTE_SPARK` | Sucessora agendada de `EVP_CLASSIFICACTE_SPARK` (roda a cada 5 min). Classifica automaticamente o `CODTIPOPER` de CT-e **pendentes** (`TGFIXN.STATUS = 0`) a partir do `CODTIPOPER` das NF-e referenciadas no XML, via `VW_CTE_AUTORIZADOS`. Mapeamento por prioridade para as TOPs 225 / 226 / 242 / 234. Registra `CTE_OK` / `CTE_SKIP` / `CTE_ERR` em `AD_LOG_ERROS`. Complementada pela regra `formulas/regra_processa_xml_cte.sql` |

---

### 13. Auxiliares / Configuração

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_AVISOINC_SPARK.SQL` | `STP_AVISOINC_SPARK` | Inclui aviso no sistema para usuário ou grupo |
| `STP_INCEMB_SPARK.sql` | `STP_INCEMB_SPARK` | Inclui nota no embarque de expedição |

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

> **Contexto.** O inventário de 08/10/2026 (`scripts/inventario_2026-10-08/`) mostrou 21 procedures `*_SPARK` que existiam no banco mas não tinham nenhum arquivo neste repositório. A maioria traz no próprio fonte a autoria de **Lucas Gabriel (ONTIME TECH / DM TECH)**, o mesmo autor das functions `FC_RATEIOFRETE_SAPARK` e `FN_GET_ULTIMO_CUSTO_SPARK1` (ver `functions/README.md`). Os arquivos foram capturados do banco **sem alteração do corpo** (só a qualificação `"SPARKPRD".` foi removida) e ganharam um cabeçalho de captura; **a padronização do cabeçalho e a documentação dos parâmetros ainda estão pendentes**. A coluna "Descrição" vem do campo *Objetivo* do comentário do autor; `[A DOCUMENTAR]` indica que o fonte não traz descrição.

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
| `STP_DUP_METAS_SPARK.SQL` | `STP_DUP_METAS_SPARK` | Botão de ação | [A DOCUMENTAR] | — |
| `STP_EMAIL_CONTRATO_SPARK.SQL` | `STP_EMAIL_CONTRATO_SPARK` | Procedure | Envio de E-mail avisando da proximidade do termino do contrato para o gestor do contrato, para que faça a gestão do contrato. | Lucas Gabriel - DM TECH |
| `STP_GERGUIAICMS_SPARK.SQL` | `STP_GERGUIAICMS_SPARK` | Botão de ação | Criar os financeiros automatico apartir do preenchimento da tela de obrigações | Lucas Gabriel |
| `STP_INCSUSPIPI_SPARK.SQL` | `STP_INCSUSPIPI_SPARK` | Botão de ação | Informar os produtos que contém suspensão do IPI na tabela de IPI de forma automática. | Lucas Gabriel - DM TECH |
| `STP_ITEPESOEXP_SPARK.SQL` | `STP_ITEPESOEXP_SPARK` | EVP (evento de tela) | Validar informações do preenchimento da pesagem de exportação | Lucas Gabriel - ONTIME TECH |
| `STP_STATUSCHQ_SPARK.SQL` | `STP_STATUSCHQ_SPARK` | Botão de ação | [A DOCUMENTAR] | — |
| `STP_TIPOVOLPESO_SPARK.SQL` | `STP_TIPOVOLPESO_SPARK` | Botão de ação | Alterar as informações de Peso, volume, peso apos a confirmação da nota e for feito carta de correção, pois acontece do fiscal fazer carta de correção a transportadora aprova, e precisa reimprimir as etiquetas fica impedido. | Lucas Gabriel |

---

## Observações Gerais

- Procedures do tipo `STP_` que operam sobre registros selecionados usam sempre o padrão de loop `FOR I IN 1..P_QTDLINHAS LOOP` com `ACT_INT_FIELD` para buscar cada linha.
- Erros de negócio são lançados via `RAISE_APPLICATION_ERROR(-2000x, '...')` com mensagens em português, exibidas diretamente ao usuário no ERP.
- Procedures com `SAVEPOINT` / `ROLLBACK TO SAVEPOINT` garantem que falhas em linhas individuais não revertam todo o lote.
- Procedures que enviam e-mail ou gravações em fila (`TMDFMG`) dependem do servidor de e-mail configurado no Sankhya.
