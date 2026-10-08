# Catálogo de Functions Nativas do Sankhya

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de functions:** 348 (153 `SNK_%` + 195 sem prefixo `SNK_`)  
**Banco:** Oracle PL/SQL  
**Origem:** Nativas do ERP Sankhya (schema SPARKPRD) — mantidas aqui apenas como referência/documentação, não são customizações da Spark.

---

> Estas functions **não são mantidas pela Spark** — são nativas do ERP Sankhya. O código foi capturado do banco em 18/09/2026 via `DBMS_METADATA.GET_DDL` e salvo aqui apenas para consulta rápida (evitar depender de VPN/acesso ao banco para entender uma dependência). Atualizações do Sankhya podem alterar ou remover estas functions — revisar após cada upgrade do ERP (mesmo cuidado do `trigger_nativa/README.md`).

## Catálogo — functions `SNK_%`

| Function | Retorno | Descrição |
|---|---|---|
| [`SNK_ANONIMIZA_DADOS_DATE`](SNK_ANONIMIZA_DADOS_DATE.SQL) | `DATE` | Anonimiza um valor DATE conforme mascara (DAY/MONTH/YEAR/HIDE/TOTAL) para exportacao de dados sensiveis (LGPD). |
| [`SNK_ANONIMIZA_DADOS_NUMBER`](SNK_ANONIMIZA_DADOS_NUMBER.SQL) | `NUMBER` | Anonimiza um valor NUMBER (zera o valor) conforme mascara informada. |
| [`SNK_ANONIMIZA_DADOS_STRING`](SNK_ANONIMIZA_DADOS_STRING.SQL) | `VARCHAR2` | Anonimiza uma string mascarando percentual do conteudo (40/50/70/80/100%, CPF, HIDE). |
| [`SNK_BILHETAGEM_POR_FAIXA`](SNK_BILHETAGEM_POR_FAIXA.SQL) | `FLOAT` | Calcula o valor total de bilhetagem de um contrato por faixa de preco, respeitando faturamento minimo (TCSCON/TGFBIL/TCSPPF). |
| [`SNK_BITWISE_OR`](SNK_BITWISE_OR.SQL) | `NUMBER` | OR bit a bit entre dois numeros, via BITAND. |
| [`SNK_BITWISE_XOR`](SNK_BITWISE_XOR.SQL) | `NUMBER` | XOR bit a bit entre dois numeros, usa SNK_BITWISE_OR. |
| [`SNK_BLOQUEIO_FECHAMENTO`](SNK_BLOQUEIO_FECHAMENTO.SQL) | `BOOLEAN` | Verifica se uma movimentacao (estoque/custo/financeiro/contabil/fiscal) esta bloqueada por fechamento na data informada, considerando liberacoes em TCBLBC. |
| [`SNK_BUSCA_ALIQ_REGIME_ESP`](SNK_BUSCA_ALIQ_REGIME_ESP.SQL) | `FLOAT` | Retorna a aliquota especial de ICMS aplicavel a um item de nota (regime especial TGFAEI), ou a aliquota padrao se nao houver regra. |
| [`SNK_CALCULA_FALTAS_TFPFAL`](SNK_CALCULA_FALTAS_TFPFAL.SQL) | `NUMBER` | Calcula o total de faltas de um funcionario no periodo, descontando restituicoes (TFPFAL). |
| [`SNK_CONFIRMOU_DESC_GRAN_CARGA`](SNK_CONFIRMOU_DESC_GRAN_CARGA.SQL) | `VARCHAR2` | Verifica se a descarga de granel de uma nota (pedido ou venda vinculada) ja foi confirmada em TGFDGC. |
| [`SNK_DATE_ADD`](SNK_DATE_ADD.SQL) | `DATE` | Soma um intervalo (ano/mes/dia/hora/minuto/segundo) a uma data. |
| [`SNK_DATE_DIFF`](SNK_DATE_DIFF.SQL) | `NUMBER` | Diferenca em dias entre duas datas. |
| [`SNK_DIF_SEG`](SNK_DIF_SEG.SQL) | `FLOAT` | Diferenca em segundos entre dois timestamps. |
| [`SNK_DIVIDIR`](SNK_DIVIDIR.SQL) | `FLOAT` | Divisao segura: retorna 0/dividendo se o divisor for nulo ou zero, evitando ORA-01476. |
| [`SNK_EXISTE_IDALIQ`](SNK_EXISTE_IDALIQ.SQL) | `BOOLEAN` | Verifica se um IDALIQ existe em TGFICM. |
| [`SNK_EXISTE_IDALIQ_TGFIFE`](SNK_EXISTE_IDALIQ_TGFIFE.SQL) | `BOOLEAN` | Verifica se um IDALIQ existe em TGFIFE. |
| [`SNK_EXISTE_IDALIQ_TGFISS`](SNK_EXISTE_IDALIQ_TGFISS.SQL) | `BOOLEAN` | Verifica se um IDALIQ existe em TGFISS. |
| [`SNK_EXTRAIR_CAMPO_DA_CHAVE`](SNK_EXTRAIR_CAMPO_DA_CHAVE.SQL) | `VARCHAR2` | Extrai um campo especifico (UF, emissao, CNPJ, modelo, serie, numero, codigo aleatorio, DV) da chave de acesso de NF-e por posicao. |
| [`SNK_FORMATA_CODAGNOC`](SNK_FORMATA_CODAGNOC.SQL) | `VARCHAR2` | Formata um codigo numerico no padrao AGNOC (ex.: 0000000 -> 00.00.00). |
| [`SNK_FORMAT_DATE`](SNK_FORMAT_DATE.SQL) | `VARCHAR2` | TO_CHAR de data com o formato informado. |
| [`SNK_FORMAT_MOEDA`](SNK_FORMAT_MOEDA.SQL) | `VARCHAR2` | Formata um valor FLOAT como moeda no padrao brasileiro (separador de milhar e decimal). |
| [`SNK_FORMAT_MSG_BLOQ_FEC_CTB`](SNK_FORMAT_MSG_BLOQ_FEC_CTB.SQL) | `VARCHAR2` | Monta a mensagem padrao de bloqueio fiscal/contabil, prefixando o texto informado. |
| [`SNK_GETCODPRODALT`](SNK_GETCODPRODALT.SQL) | `INT` | Retorna o menor codigo de produto alternativo (agrupamento TGFPAL) ativo vinculado a um produto. |
| [`SNK_GETDTBAIXABEM`](SNK_GETDTBAIXABEM.SQL) | `DATE` | Retorna a data de baixa de um bem do imobilizado, desconsiderando retornos ocorridos no mesmo mes. |
| [`SNK_GETLIB_CODCENCUS`](SNK_GETLIB_CODCENCUS.SQL) | `TSILIB` | Stub de liberacao de fluxo (TSILIB) — sempre retorna 0. |
| [`SNK_GETLIB_CODEMP`](SNK_GETLIB_CODEMP.SQL) | `TSIEMP` | Retorna a empresa vinculada a um evento de liberacao (TSILIB), com regra especifica para apontamento de producao (TPRAPO/TPRIATV). |
| [`SNK_GETLIB_CODNAT`](SNK_GETLIB_CODNAT.SQL) | `TSILIB` | Stub de liberacao de fluxo (TSILIB) — sempre retorna 0. |
| [`SNK_GETLIB_CODPARC`](SNK_GETLIB_CODPARC.SQL) | `TSILIB` | Stub de liberacao de fluxo (TSILIB) — sempre retorna 0. |
| [`SNK_GETLIB_CODPROJ`](SNK_GETLIB_CODPROJ.SQL) | `TSILIB` | Stub de liberacao de fluxo (TSILIB) — sempre retorna 0. |
| [`SNK_GETLIB_NUNOTA`](SNK_GETLIB_NUNOTA.SQL) | `TGFCAB` | Stub de liberacao de fluxo (TSILIB) — sempre retorna NULL. |
| [`SNK_GETMESESSEMPIS`](SNK_GETMESESSEMPIS.SQL) | `INT` | Calcula quantos meses um bem do imobilizado ficou sem apropriacao de credito de PIS/COFINS, considerando baixas e retornos. |
| [`SNK_GETNPARCPISCOF`](SNK_GETNPARCPISCOF.SQL) | `INT` | Calcula o numero de parcelas para apropriacao de credito de PIS/COFINS de bens do imobilizado, conforme regra da MP 540/2011. |
| [`SNK_GETPRODUTOAGRUPADOGIRO`](SNK_GETPRODUTOAGRUPADOGIRO.SQL) | `INT` | Retorna o codigo de produto agrupado para giro de estoque (generico ou alternativo), conforme tipo de agrupamento. |
| [`SNK_GETPRODUTOGENERICO`](SNK_GETPRODUTOGENERICO.SQL) | `INT` | Retorna o produto generico vinculado a um produto especifico (TGFGXE), ou o proprio produto se nao houver vinculo. |
| [`SNK_GETSOMAPARTILHA`](SNK_GETSOMAPARTILHA.SQL) | `NUMBER` | Soma as aliquotas de partilha do Simples Nacional (IRPJ/CSLL/COFINS/PIS/CPP/IPI/ISS) aplicaveis a um item de nota. |
| [`SNK_GETSOMAPARTILHA2`](SNK_GETSOMAPARTILHA2.SQL) | `NUMBER` | Variante de SNK_GETSOMAPARTILHA recebendo empresa/data/produto/uso/tipoSN diretamente, sem NUNOTA/SEQUENCIA. |
| [`SNK_GETSOMAPARTILHA3`](SNK_GETSOMAPARTILHA3.SQL) | `NUMBER` | Outra variante da soma de partilha do Simples Nacional, recebendo o TIPOSN diretamente sem calcula-lo a partir do produto. |
| [`SNK_GETSOMAVLRTGFDIN`](SNK_GETSOMAVLRTGFDIN.SQL) | `NUMBER` | Soma os valores de impostos (TGFDIN) de um item, excluindo os codigos de imposto da reforma tributaria (12 a 17). |
| [`SNK_GETTIMEZONE`](SNK_GETTIMEZONE.SQL) | `VARCHAR2` | Retorna o timezone atual do servidor de banco (formato TZR). |
| [`SNK_GETTSIPARLOGICO`](SNK_GETTSIPARLOGICO.SQL) | `CHAR` | Retorna o valor logico (S/N) de um parametro de sistema (TSIPAR); retorna 'N' se o parametro nao existir. |
| [`SNK_GETVLRREA`](SNK_GETVLRREA.SQL) | `NUMBER` | Calcula o valor de ICMS por reavaliacao/pauta fiscal (TGFREA), usando aliquota interna ou externa conforme UF de origem/destino. |
| [`SNK_GETVLRTGFDIN`](SNK_GETVLRTGFDIN.SQL) | `NUMBER` | Retorna a soma de um campo especifico de TGFDIN (base, valor, credito etc.), filtrando por imposto, incidencia e opcao pelo Simples Nacional. |
| [`SNK_GETVLRTGFDINSIMPLES`](SNK_GETVLRTGFDINSIMPLES.SQL) | `NUMBER` | Soma o valor liquido de ICMS (valor menos reducao) de um item para contribuintes do Simples Nacional com CST preenchido. |
| [`SNK_GET_APURACAO_ICMS`](SNK_GET_APURACAO_ICMS.SQL) | `FLOAT` | Retorna a base de apuracao de ICMS (atualmente repassa o valor de P_BASEICMS recebido). |
| [`SNK_GET_BASEFINESTOQUERENEGGOL`](SNK_GET_BASEFINESTOQUERENEGGOL.SQL) | `FLOAT` | Calcula recursivamente a base de multa/juros/ISS retido de um titulo renegociado (TGFREN) para calculo de estoque em renegociacao. |
| [`SNK_GET_CENTROCUSTO_EFD`](SNK_GET_CENTROCUSTO_EFD.SQL) | `NUMBER` | Retorna o centro de custo para lancamento contabil de EFD (ICMS/IPI ou Contribuicoes), delegando a SNK_GET_DADOS_EFD. |
| [`SNK_GET_CENTROCUSTO_IMOB_EFD`](SNK_GET_CENTROCUSTO_IMOB_EFD.SQL) | `NUMBER` | Retorna o centro de custo para lancamento contabil de imobilizado no EFD, delegando a SNK_GET_DADOS_IMOB_EFD. |
| [`SNK_GET_CFO`](SNK_GET_CFO.SQL) | `NUMBER` | Recalcula o CFO/CFOP de um item conforme substituicao tributaria, uso do produto e diversas regras fiscais (tabela extensa de ajustes). |
| [`SNK_GET_CFO_ANT`](SNK_GET_CFO_ANT.SQL) | `NUMBER` | Ajusta o CFO para a tabela de regras 'antiga' (versao anterior de CFOP), usada como fallback por SNK_GET_CFO. |
| [`SNK_GET_CFO_NOTA`](SNK_GET_CFO_NOTA.SQL) | `NUMBER` | Retorna o CFO de entrada ou saida configurado na TOP da nota, considerando se a operacao e dentro ou fora do estado. |
| [`SNK_GET_CLASSIFICMS`](SNK_GET_CLASSIFICMS.SQL) | `VARCHAR2` | Determina a classificacao de ICMS (consumidor final etc.) resolvendo TOP, TGFPAEM e TGFPAR em cascata. |
| [`SNK_GET_CODCFO`](SNK_GET_CODCFO.SQL) | `NUMBER` | Resolve o codigo de CFO de um item combinando classificacao do parceiro, TOP e as regras de SNK_GET_CFO/SNK_GET_CFO_NOTA. |
| [`SNK_GET_CODEMP_EFDICMS_PKG`](SNK_GET_CODEMP_EFDICMS_PKG.SQL) | `NUMBER` | Retorna o CODEMP corrente armazenado no pacote de sessao EFDICMS_PKG. |
| [`SNK_GET_CODEMP_TGFAJA`](SNK_GET_CODEMP_TGFAJA.SQL) | `NUMBER` | Retorna o CODEMP de um ajuste de estoque/financeiro (TGFAJA). |
| [`SNK_GET_CODIGO_OBSERVACAO`](SNK_GET_CODIGO_OBSERVACAO.SQL) | `VARCHAR2` | Retorna o codigo de observacao/complemento fiscal (CODINF ou CODREFINFCOMPL). |
| [`SNK_GET_CODIGO_PRODUTO`](SNK_GET_CODIGO_PRODUTO.SQL) | `VARCHAR2` | Retorna o codigo do produto a exibir na NF-e (referencia ou codigo interno), conforme configuracao NFE da empresa (TGFEMP/TGFPRO). |
| [`SNK_GET_CODIGO_SITUACAO`](SNK_GET_CODIGO_SITUACAO.SQL) | `VARCHAR2` | Retorna o codigo de situacao do documento fiscal (tabela 4.1.2 do SPED) conforme cancelamento, extemporaneidade e demais flags. |
| [`SNK_GET_CODLOTACAO`](SNK_GET_CODLOTACAO.SQL) | `VARCHAR` | Monta o codigo de lotacao (empresa ou terceiro) para o eSocial, prefixando 'SNK' quando parametrizado. |
| [`SNK_GET_COD_LEGAL`](SNK_GET_COD_LEGAL.SQL) | `NUMBER` | Determina o codigo legal de motivo de restituicao de ICMS-ST em devolucao de venda (TGFNST/TGFDIN). |
| [`SNK_GET_COLUMNS_ESOCIAL`](SNK_GET_COLUMNS_ESOCIAL.SQL) | `VARCHAR2` | Monta condicao SQL comparando colunas antigo/novo (N.col = O.col) de uma tabela, para deteccao de alteracao no eSocial. |
| [`SNK_GET_COLUMNS_REINF`](SNK_GET_COLUMNS_REINF.SQL) | `VARCHAR2` | Monta condicao SQL comparando colunas antigo/novo de uma tabela, para deteccao de alteracao no EFD-Reinf. |
| [`SNK_GET_COLUMNS_TABLE`](SNK_GET_COLUMNS_TABLE.SQL) | `VARCHAR2` | Retorna a lista de colunas de uma tabela concatenada por virgula, excluindo as colunas informadas. |
| [`SNK_GET_CONFIG_TOP_IPIDEVOL`](SNK_GET_CONFIG_TOP_IPIDEVOL.SQL) | `NUMBER` | Verifica se a TOP de uma nota de entrada esta configurada para devolucao de IPI sem destaque. |
| [`SNK_GET_CONTACONTABIL_EFD`](SNK_GET_CONTACONTABIL_EFD.SQL) | `VARCHAR2` | Retorna a conta contabil para EFD ICMS/IPI ou Contribuicoes, delegando a SNK_GET_DADOS_EFD ou SNK_GET_CTACTB_CADASTROS_EFD. |
| [`SNK_GET_CONTACONTABIL_IMOB_EFD`](SNK_GET_CONTACONTABIL_IMOB_EFD.SQL) | `VARCHAR2` | Retorna a conta contabil de lancamentos de imobilizado no EFD, delegando a SNK_GET_DADOS_IMOB_EFD ou cadastros. |
| [`SNK_GET_CONTROLE_CUSTO`](SNK_GET_CONTROLE_CUSTO.SQL) | `VARCHAR` | Retorna CAMPO ou PARAMETRO conforme o parametro de sistema CUSTOPORCONTROLE (custo por controle de serie/lote). |
| [`SNK_GET_CTACTB_CADASTROS_EFD`](SNK_GET_CTACTB_CADASTROS_EFD.SQL) | `VARCHAR2` | Resolve a conta contabil do EFD a partir de cadastros (produto/empresa, natureza, TOP) quando nao ha lancamento contabil (TCBINT), filtrando por grupo de natureza do registro SPED. |
| [`SNK_GET_CUS_VAR_TIT`](SNK_GET_CUS_VAR_TIT.SQL) | `NUMBER` | Calcula o custo variavel de titulo financeiro de uma nota (percentual sobre valor + valor fixo por titulo). |
| [`SNK_GET_DATE_PART`](SNK_GET_DATE_PART.SQL) | `NUMBER` | Extrai uma parte (ano/mes/dia etc.) de uma data como numero. |
| [`SNK_GET_DENTRO_FORA_ESTADO`](SNK_GET_DENTRO_FORA_ESTADO.SQL) | `VARCHAR2` | Determina se uma operacao e dentro ou fora do estado, comparando a UF de origem e destino de parceiro/empresa. |
| [`SNK_GET_DESCPROD_PARC`](SNK_GET_DESCPROD_PARC.SQL) | `VARCHAR2` | Stub sem implementacao — sempre retorna NULL. |
| [`SNK_GET_DESCR_TIPFOLHA`](SNK_GET_DESCR_TIPFOLHA.SQL) | `VARCHAR2` | Retorna a descricao textual do tipo de folha de pagamento (mensal, ferias, rescisao etc.). |
| [`SNK_GET_DTFIM_EFDICMS_PKG`](SNK_GET_DTFIM_EFDICMS_PKG.SQL) | `DATE` | Retorna a data fim corrente armazenada no pacote de sessao EFDICMS_PKG. |
| [`SNK_GET_DTINI_EFDICMS_PKG`](SNK_GET_DTINI_EFDICMS_PKG.SQL) | `DATE` | Retorna a data inicio corrente armazenada no pacote de sessao EFDICMS_PKG. |
| [`SNK_GET_DTREFCUSTOGOL`](SNK_GET_DTREFCUSTOGOL.SQL) | `DATE` | Retorna a ultima data de referencia de custo (TGFCGM) de uma empresa ate a data informada. |
| [`SNK_GET_DTREF_ESOCIAL`](SNK_GET_DTREF_ESOCIAL.SQL) | `DATE` | Retorna a menor data de referencia configurada para o eSocial (TFPSAMB). |
| [`SNK_GET_DTREF_EXEC_ESOCIAL`](SNK_GET_DTREF_EXEC_ESOCIAL.SQL) | `DATE` | Retorna a menor data de referencia de execucao configurada para o eSocial (TFPSAMB). |
| [`SNK_GET_DTREF_META`](SNK_GET_DTREF_META.SQL) | `TGFCAB` | Determina a data de referencia de uma nota para apuracao de meta comercial ou financeira, conforme configuracao em TGMCFG. |
| [`SNK_GET_DTULTCUSPRODGENTEMP`](SNK_GET_DTULTCUSPRODGENTEMP.SQL) | `DATE` | Retorna a ultima data de custo generico temporario de um produto (tabela de trabalho TEMP_CUSPRODGENERICO). |
| [`SNK_GET_DTULTIMOCUSTO`](SNK_GET_DTULTIMOCUSTO.SQL) | `DATE` | Retorna a data do ultimo custo registrado do produto (TGFCUS) ate a data informada, respeitando parametros de custo por empresa/local/controle. |
| [`SNK_GET_EMPRESA_CUSTO`](SNK_GET_EMPRESA_CUSTO.SQL) | `INTEGER` | Retorna CAMPO ou PARAMETRO conforme o parametro de sistema CUSTOPOREMPRESA. |
| [`SNK_GET_FAMILIA`](SNK_GET_FAMILIA.SQL) | `INT` | Retorna o codigo do produto 'pai' da familia de produtos (TGFFAM), ou o proprio produto se nao tiver familia. |
| [`SNK_GET_GRUPO_ICMS`](SNK_GET_GRUPO_ICMS.SQL) | `NUMBER` | Valida e retorna o codigo de grupo de produto para ICMS, ou 0 se nao existir em TGFGRU. |
| [`SNK_GET_HIERARQUIA`](SNK_GET_HIERARQUIA.SQL) | `VARCHAR2` | Monta a lista de codigos ancestrais de um registro hierarquico generico, navegando via SQL dinamico (EXECUTE IMMEDIATE) recursivamente. |
| [`SNK_GET_ICMS_ESPECIAL_CAB`](SNK_GET_ICMS_ESPECIAL_CAB.SQL) | `FLOAT` | Recalcula o valor de ICMS do cabecalho da nota quando ha regime especial de aliquota configurado (TGFAEI). |
| [`SNK_GET_ICMS_ESPECIAL_ITE`](SNK_GET_ICMS_ESPECIAL_ITE.SQL) | `FLOAT` | Recalcula o valor de ICMS de um item da nota quando ha regime especial de aliquota configurado (TGFAEI). |
| [`SNK_GET_IDPROCESSO_IMP_EFD`](SNK_GET_IDPROCESSO_IMP_EFD.SQL) | `?` | Retorna o numero (ou sequencia) de processo judicial de suspensao de imposto aplicavel a uma operacao, para EFD-Reinf/Contribuicoes. |
| [`SNK_GET_INDICADOR_EMITENTE`](SNK_GET_INDICADOR_EMITENTE.SQL) | `VARCHAR2` | Determina se a nota e de emissao propria ou de terceiro (indicador do SPED Fiscal). |
| [`SNK_GET_INDITENS`](SNK_GET_INDITENS.SQL) | `FLOAT` | Calcula o indice de rateio entre o valor total da nota (com acrescimos) e a soma dos itens. |
| [`SNK_GET_INI_FAT_CON`](SNK_GET_INI_FAT_CON.SQL) | `DATE` | Calcula a data de inicio de faturamento de um contrato, considerando pagamento antecipado ou postecipado por periodo mensal/anual. |
| [`SNK_GET_LOCAL_CUSTO`](SNK_GET_LOCAL_CUSTO.SQL) | `INTEGER` | Retorna CAMPO ou PARAMETRO conforme o parametro de sistema CUSTOPORLOCAL. |
| [`SNK_GET_MODELO_DOCUMENTO`](SNK_GET_MODELO_DOCUMENTO.SQL) | `VARCHAR2` | Formata o codigo do modelo de documento fiscal (ex.: 901 -> '1B'), preenchendo zero a esquerda quando necessario. |
| [`SNK_GET_NAT_FILHA_REC_DESP`](SNK_GET_NAT_FILHA_REC_DESP.SQL) | `VARCHAR2` | Determina se uma natureza financeira tem naturezas-filha de receita e despesa mescladas (TIPNAT), navegando pela mascara de natureza. |
| [`SNK_GET_NOTA_DO_PEDIDO`](SNK_GET_NOTA_DO_PEDIDO.SQL) | `INT` | Localiza recursivamente a nota de venda vinculada a um pedido, percorrendo ligacoes em TGFVAR. |
| [`SNK_GET_NUFIN`](SNK_GET_NUFIN.SQL) | `NUMBER` | Gera o proximo NUFIN valido para TGFFIN, varrendo lacunas na sequencia e realinhando a sequence quando necessario. |
| [`SNK_GET_NUNOTA`](SNK_GET_NUNOTA.SQL) | `NUMBER` | Gera o proximo NUNOTA valido para TGFCAB usando o controle TGFNUM, recriando o registro de controle se ele nao existir. |
| [`SNK_GET_NUNOTA_EFDICMS_PKG`](SNK_GET_NUNOTA_EFDICMS_PKG.SQL) | `NUMBER` | Retorna o NUNOTA corrente armazenado no pacote de sessao EFDICMS_PKG. |
| [`SNK_GET_ORIGEM_PRODUTO`](SNK_GET_ORIGEM_PRODUTO.SQL) | `VARCHAR2` | Retorna a origem fiscal do produto, priorizando a configuracao por empresa (TGFPEM) sobre o cadastro geral (TGFPRO). |
| [`SNK_GET_ORIGEM_PRODUTO_ALT`](SNK_GET_ORIGEM_PRODUTO_ALT.SQL) | `VARCHAR2` | Stub para origem alternativa de produto — sempre retorna NULL (ponto de extensao). |
| [`SNK_GET_ORIGEM_PRODUTO_ITE`](SNK_GET_ORIGEM_PRODUTO_ITE.SQL) | `VARCHAR2` | Retorna a origem do produto de um item, tentando primeiro a origem alternativa e caindo para a padrao. |
| [`SNK_GET_PARTE_BLOB`](SNK_GET_PARTE_BLOB.SQL) | `BLOB` | Retorna um trecho (substring) de um BLOB a partir de uma posicao e tamanho informados. |
| [`SNK_GET_PERIODO`](SNK_GET_PERIODO.SQL) | `NUMBER` | Classifica uma data em quinzena (1/2) ou decada do mes (1/2/3) conforme o dia. |
| [`SNK_GET_PK_FOR_ESOCIAL`](SNK_GET_PK_FOR_ESOCIAL.SQL) | `VARCHAR2` | Monta condicao SQL de igualdade de chave primaria (O.col = N.col) de uma tabela, para comparacao de registros no eSocial. |
| [`SNK_GET_PK_FOR_REINF`](SNK_GET_PK_FOR_REINF.SQL) | `VARCHAR2` | Monta condicao SQL de igualdade de chave primaria de uma tabela, para comparacao de registros no EFD-Reinf. |
| [`SNK_GET_PRECO`](SNK_GET_PRECO.SQL) | `FLOAT` | Engine nativo de precificacao: resolve o preco de um produto numa tabela (NUTAB), navegando exceções e tabelas de origem recursivamente ate encontrar o preco vigente. |
| [`SNK_GET_PRODTOK`](SNK_GET_PRODTOK.SQL) | `PIPELINED_TOKP` | Function pipelined que busca produtos por token de busca (TSITOKP/TSITOK), retornando uma tabela de codigos de produto. |
| [`SNK_GET_PROX_SEQ_TGMTRA`](SNK_GET_PROX_SEQ_TGMTRA.SQL) | `NUMBER` | Retorna a proxima sequencia disponivel de transferencia (TGMTRA) dentro de uma faixa (range) informada. |
| [`SNK_GET_ROTINA_FEC_CTB`](SNK_GET_ROTINA_FEC_CTB.SQL) | `CHAR` | Retorna a rotina contabil corrente armazenada no pacote de sessao TCBBFC_LOG_PKG. |
| [`SNK_GET_SATUSCONFERENCIA`](SNK_GET_SATUSCONFERENCIA.SQL) | `VARCHAR2` | Determina o status de conferencia de expedicao de uma nota (aguardando conferencia, conferido, recontagem etc.). |
| [`SNK_GET_SEQ_ATUAL_ESOCIAL`](SNK_GET_SEQ_ATUAL_ESOCIAL.SQL) | `NUMBER` | Retorna a sequencia atual configurada para o eSocial (TFPSAMB). |
| [`SNK_GET_ST_RECUPERAR`](SNK_GET_ST_RECUPERAR.SQL) | `FLOAT` | Calcula o valor de ICMS-ST a recuperar em vendas interestaduais, com base no ICMS unitario da ultima compra com ST nos ultimos 180 dias. |
| [`SNK_GET_TAMANHO_BLOB`](SNK_GET_TAMANHO_BLOB.SQL) | `NUMBER` | Retorna o tamanho em bytes de um BLOB. |
| [`SNK_GET_TIPO_ITEM`](SNK_GET_TIPO_ITEM.SQL) | `NUMBER` | Classifica o tipo de uso de um item de produto (materia-prima, revenda, imobilizado, consumo etc.) em codigo numerico. |
| [`SNK_GET_TPAMB_ESOCIAL`](SNK_GET_TPAMB_ESOCIAL.SQL) | `CHAR` | Retorna o ambiente (producao/homologacao) configurado para o eSocial (TFPSAMB). |
| [`SNK_GET_UF_EFDICMS_PKG`](SNK_GET_UF_EFDICMS_PKG.SQL) | `VARCHAR2` | Retorna a UF corrente armazenada no pacote de sessao EFDICMS_PKG. |
| [`SNK_GET_VALID_S2200_ESOCIAL`](SNK_GET_VALID_S2200_ESOCIAL.SQL) | `BOOLEAN` | Verifica se ha divergencia entre os dados cadastrais atuais e o ultimo evento S-2200 enviado ao eSocial (comparacao extensa de mais de 100 campos). |
| [`SNK_GET_VAR`](SNK_GET_VAR.SQL) | `VARCHAR` | Retorna a lista (CSV) de notas vinculadas (TGFVAR) a uma nota de origem. |
| [`SNK_GET_VLRITENS`](SNK_GET_VLRITENS.SQL) | `FLOAT` | Soma o valor liquido dos itens de uma nota, excluindo itens embutidos em kit (USOPROD = 'D'). |
| [`SNK_GET_VLRLIQUIDO`](SNK_GET_VLRLIQUIDO.SQL) | `FLOAT` | Calcula o valor liquido unitario de um item de nota, com regra especial quando a tabela de preco e do tipo 9 (soma ST e IPI). |
| [`SNK_GET_VLRTOT_ITENS`](SNK_GET_VLRTOT_ITENS.SQL) | `FLOAT` | Soma o valor total dos itens de uma nota, considerando regras de kit e itens embutidos. |
| [`SNK_GET_VLRTOT_SERVICO`](SNK_GET_VLRTOT_SERVICO.SQL) | `FLOAT` | Soma o valor total (menos desconto) dos itens de servico (USOPROD = 'S') de uma nota. |
| [`SNK_INSTR`](SNK_INSTR.SQL) | `FLOAT` | Wrapper para a funcao nativa INSTR (posicao de substring). |
| [`SNK_INT2DATETIME`](SNK_INT2DATETIME.SQL) | `DATE` | Combina uma data com um horario no formato decimal (HHMM) em um unico DATE. |
| [`SNK_IS_IN_PARAMLIST`](SNK_IS_IN_PARAMLIST.SQL) | `CHAR` | Verifica se um valor esta presente em uma lista configurada em parametro de sistema (TSIPAR). |
| [`SNK_MATGIR_GET_MULTCPA`](SNK_MATGIR_GET_MULTCPA.SQL) | `NUMBER` | Retorna o multiplo de compra (embalagem) de um produto para um parceiro no giro de estoque, com fallback para o agrupamento do proprio produto. |
| [`SNK_MATGIR_GET_QTDTOTALMULTCPA`](SNK_MATGIR_GET_QTDTOTALMULTCPA.SQL) | `FLOAT` | Ajusta a quantidade sugerida de compra para multiplos do lote de compra do parceiro, conforme parametro de arredondamento (TIPARMULTCPGIRO). |
| [`SNK_MOD`](SNK_MOD.SQL) | `NUMBER` | Wrapper para a funcao nativa MOD. |
| [`SNK_MULTIPLE_REPLACE`](SNK_MULTIPLE_REPLACE.SQL) | `VARCHAR2` | Substitui nomes de coluna em um texto SQL por bind variables (':coluna'), para montagem dinamica de comandos. |
| [`SNK_PERCENTUAL`](SNK_PERCENTUAL.SQL) | `FLOAT` | Calcula percentual seguro entre dividendo e divisor, retornando 0 se o divisor for nulo ou zero. |
| [`SNK_PRECO`](../SNK_PRECO.SQL) | `FLOAT` | Retorna o preço vigente de um produto numa tabela de preços — já documentada em detalhe em [`functions/SNK_PRECO.SQL`](../SNK_PRECO.SQL) e no [catálogo principal](../README.md), não duplicada aqui. |
| [`SNK_QTD_DIAS_UTEIS`](SNK_QTD_DIAS_UTEIS.SQL) | `INT` | Conta a quantidade de dias uteis entre duas datas para uma empresa, usando EH_DIA_UTIL_EMP_GIRO. |
| [`SNK_REMOVE_CARACTER_ESPECIAL`](SNK_REMOVE_CARACTER_ESPECIAL.SQL) | `VARCHAR2` | Remove caracteres nao imprimiveis (fora das faixas ASCII 32-126 e Latin-1 160-255) de uma string. |
| [`SNK_REMOVE_ZEROS_DIREITA`](SNK_REMOVE_ZEROS_DIREITA.SQL) | `CHAR` | Remove zeros e pontos a direita de um codigo de conta contabil. |
| [`SNK_TEM_VLR_LIQUIDO_ITEM_NFE`](SNK_TEM_VLR_LIQUIDO_ITEM_NFE.SQL) | `VARCHAR2` | Resolve, por hierarquia de configuracao (cabecalho > parceiro > TOP > empresa), se o item deve informar valor liquido na NF-e/NFC-e. |
| [`SNK_TGFTOKCAM`](SNK_TGFTOKCAM.SQL) | `BOOLEAN` | Verifica se existe configuracao de tokenizacao de campo para uma tabela (TGFTOKCAM). |
| [`SNK_TGFTOKCFG`](SNK_TGFTOKCFG.SQL) | `BOOLEAN` | Verifica se a tokenizacao esta habilitada globalmente no sistema (TGFTOKCFG). |
| [`SNK_TOCHARDATE`](SNK_TOCHARDATE.SQL) | `VARCHAR` | TO_CHAR de data no formato DD/MM/YYYY. |
| [`SNK_TOCHARDATETIME`](SNK_TOCHARDATETIME.SQL) | `VARCHAR` | TO_CHAR de data/hora no formato DD/MM/YYYY HH24:MI:SS. |
| [`SNK_TOCHARDAY`](SNK_TOCHARDAY.SQL) | `VARCHAR2` | Retorna o dia (DD) de uma data como string. |
| [`SNK_TOCHARINTEGER`](SNK_TOCHARINTEGER.SQL) | `VARCHAR` | TO_CHAR de um numero inteiro. |
| [`SNK_TODATE`](SNK_TODATE.SQL) | `DATE` | TO_DATE de uma string no formato DD/MM/YYYY. |
| [`SNK_TODATETIME`](SNK_TODATETIME.SQL) | `DATE` | TO_DATE de uma string no formato DD/MM/YYYY HH24:MI:SS. |
| [`SNK_TONUMBER`](SNK_TONUMBER.SQL) | `NUMBER` | Wrapper para a funcao nativa TO_NUMBER. |
| [`SNK_TO_BASE64`](SNK_TO_BASE64.SQL) | `VARCHAR2` | Codifica uma string em Base64. |
| [`SNK_TRIM`](SNK_TRIM.SQL) | `VARCHAR2` | Wrapper para a funcao nativa TRIM. |
| [`SNK_TRUNC`](SNK_TRUNC.SQL) | `FLOAT` | Trunca (sem arredondar) um valor FLOAT para um numero de casas decimais. |
| [`SNK_TRUNC_DATE`](SNK_TRUNC_DATE.SQL) | `DATE` | Wrapper para TRUNC(data, formato). |
| [`SNK_VALIDA_CNPJ`](SNK_VALIDA_CNPJ.SQL) | `NUMBER` | Valida os digitos verificadores de um CNPJ, com opcao de remover mascara antes de validar. |
| [`SNK_VALIDA_CPF`](SNK_VALIDA_CPF.SQL) | `NUMBER` | Valida os digitos verificadores de um CPF, com opcao de remover mascara antes de validar. |
| [`SNK_VAL_DATA_INTERVALO_CON`](SNK_VAL_DATA_INTERVALO_CON.SQL) | `CHAR` | Verifica se uma data esta dentro do intervalo de faturamento vigente de um contrato (mensal ou anual). |
| [`SNK_VERIFICA_NOME_IDX`](SNK_VERIFICA_NOME_IDX.SQL) | `VARCHAR2` | Gera um nome de indice disponivel (sem colisao com USER_INDEXES), incrementando um sufixo numerico. |
| [`SNK_VERIFICA_PK_TGMTRA`](SNK_VERIFICA_PK_TGMTRA.SQL) | `TGMTRA` | Verifica colisao de chave em TGMTRA (NUMTRANSF/SEQUENCIA/SEQUENCIAITE) e retorna um novo NUMTRANSF livre se necessario. |
| [`SNK_VERIFICA_SE_UTILIZA`](SNK_VERIFICA_SE_UTILIZA.SQL) | `VARCHAR` | Executa dinamicamente um COUNT(*) sobre uma tabela/condicao informada e retorna 'S'/'N' conforme existencia de registros. |

## Catálogo — functions sem prefixo `SNK_`

Capturadas em 08/10/2026 do mesmo schema (`SPARKPRD`), a partir do inventário de `scripts/CAPTURA_LISTA_FUNCTIONS_NAO_SNK.SQL`. A maioria foi criada na instalação do ERP (dez/2021) e pertence ao núcleo do Sankhya ou aos módulos que a Spark não usa (imobiliário `TIM_*`, RH, WMS). As customizações da Spark/terceiros ficam em [`../README.md`](../README.md), não aqui.

> **Atenção:** `GET_DEPEND` está `INVALID` no banco desde 2021. `TIM_YEAR` retorna o *dia* do mês (`TO_CHAR(data, 'DD')`), não o ano — comportamento nativo, não corrigir. `SOMA_DIA_UTIL` e `GET_LOCAL_ORIGEM` têm origem não confirmada (criadas após a instalação, sem marca Spark no fonte); se forem customização, mover para `functions/`. Funções que contêm `?` no lugar de acentos (`EXTENSO_MONETARIO`, `GET_TYPE_COLUMN`, `FERIADO`) exibem `?` no lugar de acentos no DDL exportado (não verificado se o caractere está corrompido no banco ou só na exportação).


### Acoes, parametros de execucao e workflow

| Function | Retorno | Descrição |
|---|---|---|
| [`ACT_CONFIRMAR`](ACT_CONFIRMAR.SQL) | `BOOLEAN` | Le a resposta de confirmacao (S/N) da sessao de acao em EXECPARAMS; se ainda nao houve resposta, levanta ORA-20101 para abrir o popup de confirmacao. |
| [`ACT_DEC_FIELD`](ACT_DEC_FIELD.SQL) | `FLOAT` | Le um parametro decimal (NUMDEC) de uma linha especifica da sessao de acao em EXECPARAMS. |
| [`ACT_DEC_PARAM`](ACT_DEC_PARAM.SQL) | `FLOAT` | Le um parametro decimal (NUMDEC) do cabecalho (SEQUENCIA 0) da sessao de acao em EXECPARAMS. |
| [`ACT_DTA_FIELD`](ACT_DTA_FIELD.SQL) | `DATE` | Le um parametro data de uma linha especifica da sessao de acao em EXECPARAMS. |
| [`ACT_DTA_PARAM`](ACT_DTA_PARAM.SQL) | `DATE` | Le um parametro data do cabecalho (SEQUENCIA 0) da sessao de acao em EXECPARAMS. |
| [`ACT_ESCOLHER_SIMNAO`](ACT_ESCOLHER_SIMNAO.SQL) | `VARCHAR2` | Le a escolha Sim/Nao da sessao de acao em EXECPARAMS; se ainda nao houve resposta, levanta ORA-20101 para abrir o popup. |
| [`ACT_INT_FIELD`](ACT_INT_FIELD.SQL) | `NUMBER` | Le um parametro inteiro (NUMINT) de uma linha especifica da sessao de acao em EXECPARAMS. |
| [`ACT_INT_PARAM`](ACT_INT_PARAM.SQL) | `NUMBER` | Le um parametro inteiro (NUMINT) do cabecalho (SEQUENCIA 0) da sessao de acao em EXECPARAMS. |
| [`ACT_TXT_FIELD`](ACT_TXT_FIELD.SQL) | `VARCHAR2` | Le um parametro texto de uma linha especifica da sessao de acao em EXECPARAMS. |
| [`ACT_TXT_PARAM`](ACT_TXT_PARAM.SQL) | `VARCHAR2` | Le um parametro texto do cabecalho (SEQUENCIA 0) da sessao de acao em EXECPARAMS. |
| [`EVP_GET_CAMPO_DEC`](EVP_GET_CAMPO_DEC.SQL) | `FLOAT` | Alias de ACT_DEC_PARAM (parametro decimal de acao/evento). |
| [`EVP_GET_CAMPO_DTA`](EVP_GET_CAMPO_DTA.SQL) | `DATE` | Alias de ACT_DTA_PARAM (parametro data de acao/evento). |
| [`EVP_GET_CAMPO_INT`](EVP_GET_CAMPO_INT.SQL) | `NUMBER` | Alias de ACT_INT_PARAM (parametro inteiro de acao/evento). |
| [`EVP_GET_CAMPO_TEXTO`](EVP_GET_CAMPO_TEXTO.SQL) | `VARCHAR2` | Alias de ACT_TXT_PARAM (parametro texto de acao/evento). |
| [`FAP_GET_NIVEL`](FAP_GET_NIVEL.SQL) | `NUMBER` | Calcula recursivamente o nivel de uma etapa na arvore de etapas da FAP (TCSFET). |
| [`FAP_GET_PATH`](FAP_GET_PATH.SQL) | `VARCHAR` | Monta recursivamente o caminho (sequencias separadas por ponto) de uma etapa na arvore da FAP (TCSFET). |
| [`FLW_GET_CAMPO_DEC`](FLW_GET_CAMPO_DEC.SQL) | `FLOAT` | Retorna a variavel decimal (NUMDEC) de uma instancia de processo do workflow (TWFIVAR). |
| [`FLW_GET_CAMPO_DTA`](FLW_GET_CAMPO_DTA.SQL) | `DATE` | Retorna a variavel data de uma instancia de processo do workflow (TWFIVAR). |
| [`FLW_GET_CAMPO_INT`](FLW_GET_CAMPO_INT.SQL) | `NUMBER` | Retorna a variavel inteira (NUMINT) de uma instancia de processo do workflow (TWFIVAR). |
| [`FLW_GET_CAMPO_TXT`](FLW_GET_CAMPO_TXT.SQL) | `VARCHAR2` | Retorna a variavel texto de uma instancia de processo do workflow (TWFIVAR). |
| [`FLW_GET_RESPONSAVEL_TAREFA`](FLW_GET_RESPONSAVEL_TAREFA.SQL) | `NUMBER` | Retorna o codigo do usuario dono da tarefa pendente mais antiga de uma instancia de processo do workflow (TWFITAR). |
| [`FLW_GET_TAREFA_PENDENTE`](FLW_GET_TAREFA_PENDENTE.SQL) | `VARCHAR2` | Retorna o nome do elemento (tarefa) pendente mais antigo de uma instancia de processo do workflow. |

### Parametros do sistema (TSIPAR) e variaveis de sessao

| Function | Retorno | Descrição |
|---|---|---|
| [`FCHECKOUT_UTILIZA`](FCHECKOUT_UTILIZA.SQL) | `BOOLEAN` | Indica se o cliente utiliza Sankhya Checkout (existe PDV configurado em TFXPDV). |
| [`FPODEVALIDAR`](FPODEVALIDAR.SQL) | `BOOLEAN` | Decide se a validacao de uma tabela deve rodar, considerando DataSync em andamento (variavel de pacote/TSIPAR) e uso do Checkout. |
| [`FTEM_KIT_INDEPENDENTE`](FTEM_KIT_INDEPENDENTE.SQL) | `BOOLEAN` | Indica se a configuracao de kit independente (TSIPAR CONFKITIND) esta ativa. |
| [`GET_ADIARATUALIZACAOESTOQUE`](GET_ADIARATUALIZACAOESTOQUE.SQL) | `VARCHAR2` | Le a variavel de sessao VARIAVEIS_PKG.V_ADIARATUALIZACAOESTOQUE. |
| [`GET_CONTROLE_CUSTO`](GET_CONTROLE_CUSTO.SQL) | `VARCHAR` | Devolve o controle da chave de custo: o proprio campo se custo nao e por controle, senao o parametro informado. |
| [`GET_EMPRESA_CUSTO`](GET_EMPRESA_CUSTO.SQL) | `INTEGER` | Devolve a empresa da chave de custo: o proprio campo se custo nao e por empresa, senao o parametro informado. |
| [`GET_LOCAL_CUSTO`](GET_LOCAL_CUSTO.SQL) | `INTEGER` | Devolve o local da chave de custo: o proprio campo se custo nao e por local, senao o parametro informado. |
| [`GET_TSIPAR_DATA`](GET_TSIPAR_DATA.SQL) | `DATE` | Retorna o parametro de sistema do tipo data (TSIPAR.DATA) pela chave. |
| [`GET_TSIPAR_INTEIRO`](GET_TSIPAR_INTEIRO.SQL) | `INTEGER` | Retorna o parametro de sistema inteiro (TSIPAR.INTEIRO, CODUSU = 0) pela chave; 0 se nao existir. |
| [`GET_TSIPAR_LOGICO`](GET_TSIPAR_LOGICO.SQL) | `CHAR` | Retorna o parametro de sistema logico S/N (TSIPAR.LOGICO, CODUSU = 0) pela chave; 'N' se nao existir. |
| [`GET_TSIPAR_NUMERO`](GET_TSIPAR_NUMERO.SQL) | `FLOAT` | Retorna o parametro de sistema decimal (TSIPAR.NUMDEC, CODUSU = 0) pela chave; 0 se nao existir. |
| [`GET_TSIPAR_TEXTO`](GET_TSIPAR_TEXTO.SQL) | `VARCHAR2` | Retorna o parametro de sistema texto (TSIPAR.TEXTO, CODUSU = 0) pela chave. |
| [`GET_TSIPAR_TIPO_CT`](GET_TSIPAR_TIPO_CT.SQL) | `VARCHAR` | Retorna o valor de um parametro TSIPAR do tipo C (combo) ou T (texto) como texto, conforme o tipo cadastrado. |
| [`GET_TSIPAR_USUARIO_DECIMAL`](GET_TSIPAR_USUARIO_DECIMAL.SQL) | `FLOAT` | Parametro decimal do usuario logado em TSIPAR, com fallback para o valor geral (CODUSU = 0). |
| [`GET_TSIPAR_USUARIO_INTEIRO`](GET_TSIPAR_USUARIO_INTEIRO.SQL) | `NUMBER` | Parametro inteiro do usuario logado em TSIPAR, com fallback para o valor geral (CODUSU = 0). |
| [`GET_TSIPAR_USUARIO_LOGICO`](GET_TSIPAR_USUARIO_LOGICO.SQL) | `CHAR` | Parametro logico do usuario logado em TSIPAR, com fallback para o valor geral (CODUSU = 0). |
| [`GET_TSIPAR_USUARIO_TEXTO`](GET_TSIPAR_USUARIO_TEXTO.SQL) | `VARCHAR2` | Parametro texto do usuario logado em TSIPAR, com fallback para o valor geral (CODUSU = 0). |
| [`GET_VALEST_BLOQWMS_FAT`](GET_VALEST_BLOQWMS_FAT.SQL) | `VARCHAR2` | Le a variavel de sessao VARIAVEIS_PKG.V_VALEST_BLOQWMS_FAT. |
| [`MULTIPLICA`](MULTIPLICA.SQL) | `NUMBER` | Multiplica um valor pelo parametro inteiro de TSIPAR (chave informada); 0 se valor nulo/zero ou parametro inexistente. |
| [`STP_GET_ATUALIZANDO`](STP_GET_ATUALIZANDO.SQL) | `BOOLEAN` | Le a variavel de sessao VARIAVEIS_PKG.V_ATUALIZANDO (processo de atualizacao em andamento). |
| [`STP_GET_CHECKOUT_CALC_IMPOSTO`](STP_GET_CHECKOUT_CALC_IMPOSTO.SQL) | `BOOLEAN` | Le a variavel de sessao VARIAVEIS_PKG.V_SNK_CHECKOUT_CALC_IMP. |
| [`STP_GET_CODUSULOGADO`](STP_GET_CODUSULOGADO.SQL) | `NUMBER` | Retorna o codigo do usuario logado na sessao (TSIUSU_LOG_PKG.V_CODUSULOG). |
| [`STP_GET_DISVALLDT`](STP_GET_DISVALLDT.SQL) | `BOOLEAN` | Indica se o titulo (NUFIN) esta marcado em TGFFIN_DISVALLDT para desabilitar a validacao de data. |
| [`STP_GET_TIMUTILIZAIMOB`](STP_GET_TIMUTILIZAIMOB.SQL) | `BOOLEAN` | Le a variavel de sessao VARIAVEIS_PKG.V_TIMUTILIZAIMOB (uso do modulo imobiliario). |
| [`STP_GET_UTILIZAFECHACTB`](STP_GET_UTILIZAFECHACTB.SQL) | `BOOLEAN` | Le a variavel TCBBFC_LOG_PKG.V_UTILIZA_FECHACTB (uso de fechamento contabil). |
| [`STP_GET_VARIAVEIS`](STP_GET_VARIAVEIS.SQL) | `CHAR` | Retorna uma variavel de VARIAVEIS_PKG pelo nome (insercao automatica, imposto retido, custo por empresa/local/controle). |
| [`TIM_GET_TSIPAR_INTEIRO`](TIM_GET_TSIPAR_INTEIRO.SQL) | `INT` | Parametro inteiro de TSIPAR (CODUSU = 0), busca case-insensitive e com TRIM na chave; NULL se nao existir. |
| [`TIM_PARAM_BOL`](TIM_PARAM_BOL.SQL) | `CHAR` | Parametro logico de TSIPAR por chave (case-insensitive); 'N' se nao existir. Usada pelo modulo imobiliario. |
| [`TIM_PARAM_DEC`](TIM_PARAM_DEC.SQL) | `FLOAT` | Parametro decimal de TSIPAR por chave (case-insensitive); NULL se nao existir. Usada pelo modulo imobiliario. |
| [`TIM_PARAM_INT`](TIM_PARAM_INT.SQL) | `INT` | Parametro inteiro de TSIPAR por chave (case-insensitive); NULL se nao existir. Usada pelo modulo imobiliario. |
| [`TIM_PARAM_TEXT`](TIM_PARAM_TEXT.SQL) | `VARCHAR2` | Parametro texto de TSIPAR por chave (case-insensitive); NULL se nao existir. Usada pelo modulo imobiliario. |

### Datas, feriados e dias uteis

| Function | Retorno | Descrição |
|---|---|---|
| [`EH_DIA_UTIL_EMP`](EH_DIA_UTIL_EMP.SQL) | `INT` | Retorna 1 se a data e dia util para a empresa (nao e sabado/domingo nem feriado da cidade/UF/pais da empresa), senao 0. |
| [`EH_DIA_UTIL_EMP_GIRO`](EH_DIA_UTIL_EMP_GIRO.SQL) | `INT` | Variacao de EH_DIA_UTIL_EMP que considera tambem os dias de folga configurados em TSIPAR (FOLGADOM...FOLGASAB); usada por SNK_QTD_DIAS_UTEIS. |
| [`FERIADO`](FERIADO.SQL) | `NUMBER` | Retorna 1 se a data e feriado (recorrente ou nao) para a localidade do usuario/parceiro/empresa, senao 0. |
| [`FSP_DATA_DIA_UTIL`](FSP_DATA_DIA_UTIL.SQL) | `INT` | Calcula a quantidade de dias uteis (descontando fins de semana e feriados TSIFER) para a data, na localidade do usuario. |
| [`FSP_DIF_DATAS_POR_EXTENSO`](FSP_DIF_DATAS_POR_EXTENSO.SQL) | `VARCHAR2` | Diferenca entre duas datas em texto ('N dias e HH:MM:SS'). |
| [`FSP_RETURN_DATAS_UTEIS`](FSP_RETURN_DATAS_UTEIS.SQL) | `TSP_DATAS_UTEIS_TYPE` | Retorna uma colecao (TSP_DATAS_UTEIS_TYPE) com cada data do intervalo, indicador de dia util e numero sequencial de dia util. |
| [`GET_DIA_PROXMES`](GET_DIA_PROXMES.SQL) | `DATE` | Retorna o dia N do mes seguinte a uma data (ultimo dia do mes + N). |
| [`GET_DIA_UTIL_EC`](GET_DIA_UTIL_EC.SQL) | `DATE` | Retorna a proxima data (a partir da informada) que e dia util para a empresa, usando EH_DIA_UTIL_EMP. |
| [`GET_PROXIMO_DIA_UTIL`](GET_PROXIMO_DIA_UTIL.SQL) | `DATE` | Retorna o proximo dia util a partir de uma data, considerando fim de semana (conforme parametro) e feriados da localidade do parceiro/usuario/cidade. |
| [`MONTH_TO_CHAR`](MONTH_TO_CHAR.SQL) | `VARCHAR2` | Retorna o nome do mes por extenso a partir do numero (formato completo ou resumido). |
| [`SOMA_DIA_UTIL`](SOMA_DIA_UTIL.SQL) | `DATE` | Soma N dias uteis a uma data, usando EH_DIA_UTIL_EMP da empresa. [origem a confirmar] |
| [`TIM_ACUMULAINDICE`](TIM_ACUMULAINDICE.SQL) | `NUMBER` | Acumula indices de uma moeda/indexador (TSICOT) entre duas datas (produtorio de 1 + cotacao/100). |
| [`TIM_ACUMULAINDICEPROP`](TIM_ACUMULAINDICEPROP.SQL) | `NUMBER` | Acumula indices de uma moeda/indexador (TSICOT) entre duas datas, aplicando o primeiro mes proporcionalmente. |
| [`TIM_DATABASE`](TIM_DATABASE.SQL) | `DATE` | Calcula a proxima data-base de reajuste contratual a partir da data de inicio, periodo e duracao em meses. |
| [`TIM_DEFINIR_DATA_REPASSE`](TIM_DEFINIR_DATA_REPASSE.SQL) | `DATE` | Define a data de repasse (dias corridos ou uteis, conforme contrato e parametro) a partir de uma data e quantidade de dias. |
| [`TIM_MONTH`](TIM_MONTH.SQL) | `NUMBER` | Retorna o mes (numero) de uma data. |
| [`TIM_MONTHEXT`](TIM_MONTHEXT.SQL) | `VARCHAR2` | Retorna o nome do mes por extenso de uma data. |
| [`TIM_SOMA_DIA_COMERCIAL`](TIM_SOMA_DIA_COMERCIAL.SQL) | `DATE` | Soma N dias a uma data usando o calendario comercial de 30 dias por mes. |
| [`TIM_TOCHARDATE`](TIM_TOCHARDATE.SQL) | `VARCHAR` | TO_CHAR de data no formato DD/MM/YYYY. |
| [`TIM_TOCHARDATETIME`](TIM_TOCHARDATETIME.SQL) | `VARCHAR` | TO_CHAR de data no formato DD/MM/YYYY HH24:MI:SS. |
| [`TIM_TOCHARDAY`](TIM_TOCHARDAY.SQL) | `VARCHAR2` | TO_CHAR de data com formato DD (dia). |
| [`TIM_TOCHARINTEGER`](TIM_TOCHARINTEGER.SQL) | `VARCHAR` | TO_CHAR de um numero inteiro. |
| [`TIM_TODATE`](TIM_TODATE.SQL) | `DATE` | TO_DATE de string no formato DD/MM/YYYY. |
| [`TIM_TODATETIME`](TIM_TODATETIME.SQL) | `DATE` | TO_DATE de string no formato DD/MM/YYYY HH24:MI:SS. |
| [`TIM_TRUNCMONTH`](TIM_TRUNCMONTH.SQL) | `DATE` | Trunca a data para o primeiro dia do mes. |
| [`TIM_TRUNCYEAR`](TIM_TRUNCYEAR.SQL) | `DATE` | Trunca a data para o primeiro dia do ano. |
| [`TIM_YEAR`](TIM_YEAR.SQL) | `NUMBER` | Retorna TO_CHAR(data, 'DD') como numero, ou seja, o DIA e nao o ano, apesar do nome (comportamento nativo). |

### Horas e carga horaria

| Function | Retorno | Descrição |
|---|---|---|
| [`DEC2HR`](DEC2HR.SQL) | `NUMBER` | Converte horas decimais em hora no formato HHMM (ex.: 8,5 -> 830). |
| [`HORAEXTRACARGAHORARIA`](HORAEXTRACARGAHORARIA.SQL) | `NUMBER` | Calcula os minutos de hora extra de um periodo em relacao a carga horaria (inicio/fim), tratando antes/depois da jornada. |
| [`HORAEXTRACARGAHORARIA2`](HORAEXTRACARGAHORARIA2.SQL) | `NUMBER` | Versao simplificada de HORAEXTRACARGAHORARIA para calculo dos minutos fora da carga horaria. |
| [`HR2DEC`](HR2DEC.SQL) | `NUMBER` | Converte hora no formato HHMM em horas decimais (ex.: 830 -> 8,5). |
| [`HR2MIN`](HR2MIN.SQL) | `NUMBER` | Converte hora no formato HHMM em minutos. |
| [`INTERVALO_CARGA_HORARIA`](INTERVALO_CARGA_HORARIA.SQL) | `NUMBER` | Calcula o intervalo em minutos entre duas horas HHMM, virando a meia-noite quando necessario. |

### Formatacao, texto e utilitarios genericos

| Function | Retorno | Descrição |
|---|---|---|
| [`DANFE_BUILDDRAZAOSOCIAL`](DANFE_BUILDDRAZAOSOCIAL.SQL) | `VARCHAR2` | Monta o nome do emitente do DANFE (razao, fantasia ou razao/fantasia conforme o tipo). |
| [`DANFE_BUILDRAZAOSOCIAL`](DANFE_BUILDRAZAOSOCIAL.SQL) | `VARCHAR2` | Duplicata de DANFE_BUILDDRAZAOSOCIAL (mesmo comportamento, nome sem o D extra). |
| [`EXISTS_STP`](EXISTS_STP.SQL) | `VARCHAR` | Retorna 'S' ou 'N' conforme a procedure informada existe em USER_PROCEDURES. |
| [`EXTENSO_MONETARIO`](EXTENSO_MONETARIO.SQL) | `VARCHAR2` | Escreve um valor monetario por extenso em reais e centavos. |
| [`FC_FORMATAHTML`](FC_FORMATAHTML.SQL) | `VARCHAR2` | Monta o HTML padrao de mensagem de atencao (mensagem, motivo e solucao) exibido nas criticas do Sankhya. |
| [`FC_ROWS_TO_CLOB`](FC_ROWS_TO_CLOB.SQL) | `CLOB` | Executa dinamicamente um SELECT de coluna unica e concatena todas as linhas em um CLOB. |
| [`FNC_CORTA_DECIMAL`](FNC_CORTA_DECIMAL.SQL) | `FLOAT` | Trunca (corta) um valor para N casas decimais somando uma unidade na ultima casa quando ha excedente. |
| [`FORMATAR_CPF_CNPJ`](FORMATAR_CPF_CNPJ.SQL) | `VARCHAR2` | Aplica mascara de CPF ou CNPJ conforme o tamanho do documento. |
| [`FSP_FORMATAR_CPF_CNPJ`](FSP_FORMATAR_CPF_CNPJ.SQL) | `VARCHAR2` | Duplicata de FORMATAR_CPF_CNPJ (mascara de CPF/CNPJ). |
| [`GETBLOB`](GETBLOB.SQL) | `CLOB` | Converte um BLOB em CLOB (leitura em blocos de 32767 bytes). |
| [`GET_DISTANCIA`](GET_DISTANCIA.SQL) | `FLOAT` | Calcula a distancia entre dois pontos por latitude/longitude (formula de haversine). |
| [`GET_LINK_TELA`](GET_LINK_TELA.SQL) | `VARCHAR2` | Monta um link HTML (#app/<tela>/<pk>) em Base64 para abrir uma tela do Sankhya a partir de uma consulta. |
| [`LINHA2COLUNA`](LINHA2COLUNA.SQL) | `VARCHAR2` | Executa um SELECT dinamico de coluna unica e devolve os valores concatenados e separados por virgula (limite de 4000 caracteres). |
| [`MONTA_PATH_CONTROLE`](MONTA_PATH_CONTROLE.SQL) | `VARCHAR` | Monta o caminho hierarquico (pai > filho) de um controle da estrutura TRDCON/TRDFCO. |
| [`OBTEM_ALIQ_IPI`](OBTEM_ALIQ_IPI.SQL) | `NUMBER` | Stub: retorna NULL (ponto de extensao para obter a aliquota de IPI). |
| [`PDES`](PDES.SQL) | `VARCHAR2` | Retorna o primeiro valor de um campo/tabela/filtro informados como texto (SELECT dinamico, transacao autonoma). |
| [`QUEBRALINHACHAR`](QUEBRALINHACHAR.SQL) | `VARCHAR2` | Quebra um texto em linhas de N caracteres (CR+LF entre elas). |
| [`SCORE_PREFIX`](SCORE_PREFIX.SQL) | `NUMBER` | Retorna 1 se o valor comeca com o prefixo informado (ignorando . e -), usado como pontuacao em buscas (ex.: NCM). |
| [`STRAGG`](STRAGG.SQL) | `VARCHAR2` | Funcao agregada de concatenacao de strings (usa o tipo STRING_AGG_TYPE). |
| [`TIM_COMPOEVALORCFI`](TIM_COMPOEVALORCFI.SQL) | `NUMBER` | Stub: retorna 100 (ponto de extensao do modulo imobiliario). |
| [`VALIDA_ATRASO_PARCEIRO`](VALIDA_ATRASO_PARCEIRO.SQL) | `CHAR` | Stub: sempre retorna 'S' (ponto de extensao para validar atraso de parceiro). |

### Dicionario de dados e metadados

| Function | Retorno | Descrição |
|---|---|---|
| [`FIELD_LABEL`](FIELD_LABEL.SQL) | `VARCHAR` | Retorna o rotulo (DESCRCAMPO) de um campo no dicionario de dados (TDDCAM). |
| [`F_CONVERTELONG`](F_CONVERTELONG.SQL) | `VARCHAR2` | Converte a coluna LONG DATA_DEFAULT de USER_TAB_COLUMNS em texto (ate 2000 caracteres). |
| [`F_DESCROPC`](F_DESCROPC.SQL) | `TDDOPC.OPCAO%TYPE` | Retorna a descricao da opcao (TDDOPC) de um campo (TDDCAM) para um valor de lista. |
| [`GET_COLUMNS_TABLE`](GET_COLUMNS_TABLE.SQL) | `VARCHAR2` | Lista as colunas de uma tabela separadas por virgula, excluindo as indicadas. |
| [`GET_TYPE_COLUMN`](GET_TYPE_COLUMN.SQL) | `VARCHAR2` | Retorna o tipo de dado de uma coluna de tabela (com tamanho/precisao). |
| [`OPTION_LABEL`](OPTION_LABEL.SQL) | `VARCHAR2` | Retorna a descricao da opcao de um campo de lista (TDDOPC) para um valor. |
| [`TIM_FIELDSMENURETROAPR`](TIM_FIELDSMENURETROAPR.SQL) | `TYPESET_KEYVALUE` | Retorna pipelined (chave/valor) com o rotulo e o valor de observacao de visitas da ultima administracao do imovel. |

### Custo, preco, estoque e volumes

| Function | Retorno | Descrição |
|---|---|---|
| [`GET_CODPROD_REF`](GET_CODPROD_REF.SQL) | `INTEGER` | Localiza o codigo do produto por referencia, referencia do fornecedor ou descricao, podendo restringir aos itens da nota de origem. |
| [`OBTEMCUSTO`](OBTEMCUSTO.SQL) | `FLOAT` | Retorna o custo do produto (TGFCUS) na data, por empresa/local/controle, conforme o tipo (reposicao, medio, variavel etc.). |
| [`OBTEM_EST_KIT_EC`](OBTEM_EST_KIT_EC.SQL) | `NUMBER` | Estoque disponivel de um kit (variacao 30000 em TGFICP) pelo menor estoque de seus componentes - versao e-commerce. |
| [`OBTEM_EST_KIT_LV`](OBTEM_EST_KIT_LV.SQL) | `NUMBER` | Estoque disponivel de um kit (variacao 30000 em TGFICP) pelo menor estoque de seus componentes - versao loja virtual. |
| [`OBTEM_PRECO_CW`](OBTEM_PRECO_CW.SQL) | `NUMBER` | Retorna o preco de um produto na tabela de precos vigente (TGFTAB) - integracao ChannelWeb. |
| [`QTDEVOLPADRAO`](QTDEVOLPADRAO.SQL) | `FLOAT` | Converte uma quantidade para o volume padrao do produto usando as conversoes de TGFVOA. |
| [`QTDEVOLPADRAO2`](QTDEVOLPADRAO2.SQL) | `FLOAT` | Versao de QTDEVOLPADRAO que considera tambem o controle (lote/serie) na conversao de volume. |
| [`VOLUMEALT`](VOLUMEALT.SQL) | `FLOAT` | Converte quantidade entre volume padrao e volume alternativo de um produto (TGFVOA), com fallback sem controle. |

### WMS e recebimento

| Function | Retorno | Descrição |
|---|---|---|
| [`FWMS_BUSCA_MENOR_OC`](FWMS_BUSCA_MENOR_OC.SQL) | `NUMBER` | Busca a menor ordem de carga entre uma tarefa WMS e suas tarefas dependentes (TGWSEP/TGWTDP). |
| [`F_WMS_GETESTOQUEDOCA`](F_WMS_GETESTOQUEDOCA.SQL) | `FLOAT` | Soma o estoque (volume padrao) em docas de expedicao (TGWEST/TGWDCA) de um produto/controle/empresa/local. |
| [`F_WMS_GETESTOQUEDOCA_PARC`](F_WMS_GETESTOQUEDOCA_PARC.SQL) | `FLOAT` | Variacao de F_WMS_GETESTOQUEDOCA que tambem filtra por parceiro. |
| [`F_WMS_GETPESOTAR`](F_WMS_GETPESOTAR.SQL) | `FLOAT` | Calcula o peso de uma tarefa WMS (peso do produto x quantidade, ajustado pela conversao de volume). |
| [`F_WMS_NIVEL_VALIDO_ENDERECO`](F_WMS_NIVEL_VALIDO_ENDERECO.SQL) | `CHAR` | Valida se os niveis de origem/destino de um endereco WMS sao atendidos pelo equipamento (nivel minimo/maximo, conexao, picking). |
| [`F_WMS_QTDVOLPAD`](F_WMS_QTDVOLPAD.SQL) | `FLOAT` | Converte quantidade para o volume padrao WMS via TGFVOA. |
| [`F_WMS_QTDVOLPAD2`](F_WMS_QTDVOLPAD2.SQL) | `FLOAT` | Variacao de F_WMS_QTDVOLPAD que considera o controle (lote) e arredonda em 4 casas. |
| [`GET_TEM_RASTREAMENTO_ITENS`](GET_TEM_RASTREAMENTO_ITENS.SQL) | `CHAR` | Indica ('S'/'N') se o produto/empresa/TOP exige rastreamento de estoque (TGFRASTEMP/TGFEMP). |
| [`GET_TEM_RASTSTULTENTRADA`](GET_TEM_RASTSTULTENTRADA.SQL) | `CHAR` | Indica se o rastreamento por ultima entrada (parametro RASTSTULTENTRA) se aplica a empresa/produto/TOP. |
| [`RECEBIMENTO_M3_ARMAZ`](RECEBIMENTO_M3_ARMAZ.SQL) | `FLOAT` | Soma o volume (m3) ja armazenado de um recebimento WMS. |
| [`RECEBIMENTO_M3_CONFERIDO`](RECEBIMENTO_M3_CONFERIDO.SQL) | `FLOAT` | Soma o volume (m3) conferido de uma conferencia (TGWCOI), ignorando recontagem. |
| [`RECEBIMENTO_M3_TOTAL`](RECEBIMENTO_M3_TOTAL.SQL) | `FLOAT` | Soma o volume (m3) total das notas de um recebimento WMS. |
| [`RECEBIMENTO_PESO_ARMAZ`](RECEBIMENTO_PESO_ARMAZ.SQL) | `FLOAT` | Soma o peso bruto ja armazenado de um recebimento WMS. |
| [`RECEBIMENTO_PESO_CONFERIDO`](RECEBIMENTO_PESO_CONFERIDO.SQL) | `FLOAT` | Soma o peso bruto conferido de uma conferencia (TGWCOI), ignorando recontagem. |
| [`RECEBIMENTO_PESO_TOTAL`](RECEBIMENTO_PESO_TOTAL.SQL) | `FLOAT` | Soma o peso bruto total das notas de um recebimento WMS. |

### Financeiro, fiscal e comercial

| Function | Retorno | Descrição |
|---|---|---|
| [`DTL_BOLETO_POLIPRINT`](DTL_BOLETO_POLIPRINT.SQL) | `VARCHAR2` | Monta a instrucao de multa, mora e correcao monetaria impressa no boleto Poliprint. |
| [`EHSIMPLESNACIONAL`](EHSIMPLESNACIONAL.SQL) | `BOOLEAN` | Indica se a empresa e optante do Simples Nacional (TSIEMP.SIMPLES = 'S' e regime tributario 1). |
| [`FRMT_LINHA_BOLETO`](FRMT_LINHA_BOLETO.SQL) | `CLOB` | Quebra um texto em N campos de largura fixa (com padding) para linhas de instrucao do boleto. |
| [`FRMT_NOMEBCO_POLIPRINT`](FRMT_NOMEBCO_POLIPRINT.SQL) | `VARCHAR2` | Monta a identificacao banco/agencia/conta do cedente para o boleto Poliprint. |
| [`FSP_GETDTLBOLETO`](FSP_GETDTLBOLETO.SQL) | `VARCHAR2` | Monta o detalhamento (historico, complemento e valor) dos lancamentos de um titulo para o boleto. |
| [`F_OBTEM_SALDO_INDENIZ`](F_OBTEM_SALDO_INDENIZ.SQL) | `FLOAT` | Calcula o saldo de indenizacao de um parceiro na data (saldo inicial + movimentos das notas). |
| [`GETCIDCONTATO`](GETCIDCONTATO.SQL) | `NUMBER` | Retorna o codigo da cidade de um contato de parceiro (TGFCTT). |
| [`GETUF`](GETUF.SQL) | `NUMBER` | Retorna o codigo da UF de uma cidade (TSICID). |
| [`GET_DF_ESTADO`](GET_DF_ESTADO.SQL) | `NUMBER` | Classifica o CFOP por origem (1 = estadual, 2 = interestadual, 3 = exterior). |
| [`GET_EXTRATO_POUPANCA`](GET_EXTRATO_POUPANCA.SQL) | `T_EXTRATO_TABLE` | Retorna (colecao T_EXTRATO_TABLE) o extrato de uma aplicacao indexada por moeda/indice entre duas datas. |
| [`GET_EXTRATO_REPASSE`](GET_EXTRATO_REPASSE.SQL) | `T_EXTRATO_REP_TABLE` | Retorna (colecao T_EXTRATO_REP_TABLE) o extrato de repasse de um titulo com saldo acumulado. |
| [`GET_INDICE_AJUSTE_NOTA`](GET_INDICE_AJUSTE_NOTA.SQL) | `FLOAT` | Calcula o indice de ajuste de itens (1 - |juros - desconto| / total) de uma nota. |
| [`GET_LOCAL_ORIGEM`](GET_LOCAL_ORIGEM.SQL) | `NUMBER` | Retorna o local de origem (CODLOCALORIG) do item da nota de origem de um item atendido (via TGFVAR). [origem a confirmar] |
| [`GET_NUNOTA_EC`](GET_NUNOTA_EC.SQL) | `TGFCAB.NUNOTA%TYPE` | Retorna o NUNOTA da nota gerada a partir de uma nota de origem (via TGFVAR). |
| [`GET_PRECOMOEDA`](GET_PRECOMOEDA.SQL) | `FLOAT` | Retorna a cotacao da moeda (TSICOT) na data, seguindo o parametro PROCMOE e o tratamento para cotacao inexistente (PROCMOEINEX). |
| [`GET_PREVISAO_CREDITO_DEBITO`](GET_PREVISAO_CREDITO_DEBITO.SQL) | `DATE` | Calcula a data prevista de credito/debito de um titulo (baixa, vencimento + carencia, proximo dia util). |
| [`GET_TOTALMOVBANC`](GET_TOTALMOVBANC.SQL) | `FLOAT` | Totaliza movimentos bancarios (TGFMBC) de uma conta e periodo por tipo, convertendo moedas. |
| [`GET_VALOR_TGFAJA`](GET_VALOR_TGFAJA.SQL) | `FLOAT` | Retorna o valor de ajuste de apuracao de imposto (TGFAJA) para empresa/data/imposto/UF. |
| [`GET_VLRFRETE_TGFFNF`](GET_VLRFRETE_TGFFNF.SQL) | `FLOAT` | Soma o valor de frete (TGFFNF) de uma nota, excluindo o titulo informado. |
| [`MONTADESCRICAOCLASSE`](MONTADESCRICAOCLASSE.SQL) | `VARCHAR2` | Traduz a sigla de classe da conta bancaria (C, D, A, X, E, G, S, O, Z) em descricao. |
| [`OBTEM_NUFIN_SITE`](OBTEM_NUFIN_SITE.SQL) | `NUMBER` | Gera e retorna o proximo NUFIN via STP_KEYGEN_NUFIN. |
| [`OBTEM_PROX_PK_EC`](OBTEM_PROX_PK_EC.SQL) | `NUMBER` | Gera e retorna o proximo codigo de uma tabela via STP_KEYGEN_TGFNUM. |
| [`TIM_POSSUI_FIN_JUR`](TIM_POSSUI_FIN_JUR.SQL) | `BOOLEAN` | Indica se o contrato de locacao tem titulos vencidos em juridico (TGFFIN). |

### RH, folha e recrutamento

| Function | Retorno | Descrição |
|---|---|---|
| [`GET_CANDIDATO_APROV`](GET_CANDIDATO_APROV.SQL) | `VARCHAR2` | Indica se o candidato ja foi aprovado em alguma selecao (TRSCAN/TRSSEL). |
| [`GET_DEPEND`](GET_DEPEND.SQL) | `VARCHAR` | Lista os dependentes de um funcionario (TFPDPD) separados por virgula. INVALID no banco desde 2021. |
| [`GET_EVENTO_FOLHA`](GET_EVENTO_FOLHA.SQL) | `INTEGER` | Retorna o codigo do evento de folha ativo para uma caracteristica; -1 se nao houver. |
| [`GET_REQ_ABERTA`](GET_REQ_ABERTA.SQL) | `VARCHAR2` | Indica se existe outra requisicao de vaga em aberto para a mesma selecao (TRSREQ/TRSRQS). |

### Modulo imobiliario (TIM_*)

| Function | Retorno | Descrição |
|---|---|---|
| [`EHCORRETORLOC`](EHCORRETORLOC.SQL) | `CHAR` | Indica se o corretor logado atende locacao (TIMCOR.CORLOCACAO). |
| [`EHCORRETORVENDA`](EHCORRETORVENDA.SQL) | `CHAR` | Indica se o corretor logado atende vendas (TIMCOR.CORVENDA). |
| [`ESTAGIO_INTERESSE`](ESTAGIO_INTERESSE.SQL) | `CHAR` | Classifica o imovel para a FAC como Interessados, Disponiveis ou Nao Disponiveis. |
| [`ESTAGIO_RESERVACHAVE`](ESTAGIO_RESERVACHAVE.SQL) | `VARCHAR2` | Classifica o imovel quanto a reserva de chave para a FAC (Reservados, Disponiveis, Nao Disponiveis). |
| [`FTIM_EXECUTAR`](FTIM_EXECUTAR.SQL) | `BOOLEAN` | Indica se existe empresa (TSIEMP) cadastrada com o CNPJ informado; usada para liberar rotinas do modulo imobiliario. |
| [`GER_DESCR_BUSCA_IMV`](GER_DESCR_BUSCA_IMV.SQL) | `VARCHAR2` | Monta a descricao de busca do imovel (codigo, descricao, bairro, cidade e UF). |
| [`GET_CORRETORLOGADO`](GET_CORRETORLOGADO.SQL) | `NUMBER` | Retorna o codigo do corretor vinculado ao usuario logado (TSIUSU.CORCODIGO). |
| [`GET_QTD_FOTOS_IMV`](GET_QTD_FOTOS_IMV.SQL) | `T_FOTOS_IMOVEIS_TABLE` | Retorna a quantidade de fotos de um imovel (colecao T_FOTOS_IMOVEIS_TABLE). |
| [`TIM_ASSINAFIADOR`](TIM_ASSINAFIADOR.SQL) | `VARCHAR2` | Monta os blocos de assinatura dos fiadores de uma locacao. |
| [`TIM_ASSINAINQUILINO`](TIM_ASSINAINQUILINO.SQL) | `VARCHAR2` | Monta os blocos de assinatura dos inquilinos de uma locacao. |
| [`TIM_ASSINALOCADOR`](TIM_ASSINALOCADOR.SQL) | `VARCHAR2` | Monta os blocos de assinatura dos locadores (proprietarios) de um imovel. |
| [`TIM_BUILD_BAIRROCIDADE`](TIM_BUILD_BAIRROCIDADE.SQL) | `VARCHAR` | Formata 'bairro, cidade' para endereco. |
| [`TIM_BUILD_LOGRADOURO`](TIM_BUILD_LOGRADOURO.SQL) | `VARCHAR` | Formata 'tipo logradouro, numero' para endereco. |
| [`TIM_BUILD_UFCEP`](TIM_BUILD_UFCEP.SQL) | `VARCHAR` | Formata 'UF, CEP' para endereco. |
| [`TIM_CLASSIFICADOS2`](TIM_CLASSIFICADOS2.SQL) | `VARCHAR2` | Resume em texto os anuncios (classificados) publicados de um imovel desde a data de liberacao. |
| [`TIM_COMPOEANUNCIOCFI`](TIM_COMPOEANUNCIOCFI.SQL) | `VARCHAR2` | Compoe o texto do anuncio de um imovel para um classificado. |
| [`TIM_DESCRICAO_IMOVELAP`](TIM_DESCRICAO_IMOVELAP.SQL) | `VARCHAR2` | Retorna a descricao atual do imovel (TIMIMV.IMVDESCRICAOATUAL). |
| [`TIM_DETALHEVISITAS2`](TIM_DETALHEVISITAS2.SQL) | `VARCHAR2` | Detalha em texto os motivos de devolucao/desistencia registrados nas visitas ao imovel. |
| [`TIM_DNORM_ENDERECO`](TIM_DNORM_ENDERECO.SQL) | `VARCHAR2` | Normaliza e escreve o endereco por extenso a partir de codigos de logradouro, bairro e cidade. |
| [`TIM_ENDERECO_IMOVEL_MAPS`](TIM_ENDERECO_IMOVEL_MAPS.SQL) | `VARCHAR` | Monta o endereco completo de um imovel para geocodificacao/mapas. |
| [`TIM_ENDERECO_MAPS`](TIM_ENDERECO_MAPS.SQL) | `VARCHAR` | Monta endereco formatado (logradouro, bairro/cidade, UF/CEP) para mapas. |
| [`TIM_FORMATACPFCNPJ`](TIM_FORMATACPFCNPJ.SQL) | `VARCHAR2` | Aplica mascara de CPF ou CNPJ conforme o tipo de pessoa (F/J). |
| [`TIM_FORMATAENDERECO`](TIM_FORMATAENDERECO.SQL) | `VARCHAR2` | Formata o endereco de uma pessoa (tipo, numero, complemento, bairro, cidade e estado). |
| [`TIM_FORMATAPESSOA`](TIM_FORMATAPESSOA.SQL) | `VARCHAR2` | Qualifica uma pessoa em texto contratual (nome, nacionalidade, estado civil, profissao, documentos, endereco). |
| [`TIM_FORMATATELEFONE`](TIM_FORMATATELEFONE.SQL) | `VARCHAR` | Formata um telefone brasileiro (com/sem DDD, DDI e zero) em mascara padrao. |
| [`TIM_GERADESCRICAO`](TIM_GERADESCRICAO.SQL) | `VARCHAR2` | Gera a descricao comercial do imovel (tipo, bairro, quartos, edificio, endereco). |
| [`TIM_MONTAFIADOR`](TIM_MONTAFIADOR.SQL) | `VARCHAR2` | Qualifica em texto contratual os fiadores de uma locacao. |
| [`TIM_MONTAFORMAREPASSE`](TIM_MONTAFORMAREPASSE.SQL) | `VARCHAR2` | Descreve em texto a forma de repasse (percentuais por proprietario e IRB) de um contrato de administracao. |
| [`TIM_MONTAINQUILINO`](TIM_MONTAINQUILINO.SQL) | `VARCHAR2` | Qualifica em texto contratual os inquilinos de uma locacao. |
| [`TIM_MONTAPROPRIETARIOS`](TIM_MONTAPROPRIETARIOS.SQL) | `VARCHAR2` | Lista os nomes dos proprietarios de um contrato de administracao. |
| [`TIM_VISITASIMOVEL2`](TIM_VISITASIMOVEL2.SQL) | `VARCHAR2` | Resume em texto o percentual de cada motivo de desistencia/devolucao nas visitas ao imovel. |

## Como recapturar / atualizar

```sql
SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'NOME_DA_FUNCTION', 'SPARKPRD') FROM dual;
```

Lista completa obtida via `all_objects` filtrando `object_name LIKE 'SNK\_%' ESCAPE '\'` e `object_type = 'FUNCTION'` no schema `SPARKPRD`.

Para as sem prefixo `SNK_`, o inventário completo (nome, status, datas, linhas) está em `scripts/CAPTURA_LISTA_FUNCTIONS_NAO_SNK.SQL` (Bloco 1) e o DDL no Bloco 2 do mesmo script.
