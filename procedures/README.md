# Catálogo de Procedures

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de procedures:** 68  
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

---

### 6. Assistência Técnica / Ordem de Serviço

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCMOVASSIST_SPARK.SQL` | `STP_INCMOVASSIST_SPARK` | Inclui movimentação de peça/produto na assistência técnica |
| `STP_INCNCONFORM_SPARK.SQL` | `STP_INCNCONFORM_SPARK` | Registra não conformidade no processo de assistência |
| `STP_INCMOVOSINT_SPARK.SQL` | `STP_INCMOVOSINT_SPARK` | Inclui movimentação em O.S. interna |
| `STP_OSINTERNA_INC_SPARK.sql` | `STP_OSINTERNA_INC_SPARK` | Cria nova O.S. Interna via botão de ação |
| `STP_ENVIAEMAILOS_SPARK.SQL` | `STP_ENVIAEMAILOS_SPARK` | Envia e-mail aos setores responsáveis quando nova O.S. é criada |

---

### 7. Financeiro

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INCLUIRLANCTO_SPARK.SQL` | `STP_INCLUIRLANCTO_SPARK` | Inclui lançamento financeiro avulso vinculado a nota |
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

---

### 10. Integração E-commerce / Marketplace

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_INTEGRAPEDIDO_SITESPARK.sql` | `STP_INTEGRAPEDIDO_SITESPARK` | Converte pedido do site da Spark em nota de venda no ERP |
| `STP_INTEGRAPEDIDO_AGENDADA.sql` | `STP_INTEGRAPEDIDO_AGENDADA` | Versão agendada da integração de pedidos — execução automática via scheduler |
| `STP_ATTESTML_SPARK.sql` | `STP_ATTESTML_SPARK` | Atualiza status de pedido no Mercado Livre |
| `STP_BUSCAATRIBML_SPARK.sql` | `STP_BUSCAATRIBML_SPARK` | Busca atributos de produto no Mercado Livre para atualização no ERP |
| `STP_GRAVA_FILA_BI2.SQL` | `STP_GRAVA_FILA_BI2` | Grava mensagem na fila de processamento assíncrono do Sankhya (BI/Integração) |

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

---

### 13. Auxiliares / Configuração

| Arquivo | Procedure | Descrição |
|---|---|---|
| `STP_AVISOINC_SPARK.SQL` | `STP_AVISOINC_SPARK` | Inclui aviso no sistema para usuário ou grupo |
| `STP_INCEMB_SPARK.sql` | `STP_INCEMB_SPARK` | Inclui nota no embarque de expedição |

---

## Observações Gerais

- Procedures do tipo `STP_` que operam sobre registros selecionados usam sempre o padrão de loop `FOR I IN 1..P_QTDLINHAS LOOP` com `ACT_INT_FIELD` para buscar cada linha.
- Erros de negócio são lançados via `RAISE_APPLICATION_ERROR(-2000x, '...')` com mensagens em português, exibidas diretamente ao usuário no ERP.
- Procedures com `SAVEPOINT` / `ROLLBACK TO SAVEPOINT` garantem que falhas em linhas individuais não revertam todo o lote.
- Procedures que enviam e-mail ou gravações em fila (`TMDFMG`) dependem do servidor de e-mail configurado no Sankhya.
