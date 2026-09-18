# Catálogo de Functions Nativas do Sankhya (SNK_%)

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  
**Total de functions:** 153  
**Banco:** Oracle PL/SQL  
**Origem:** Nativas do ERP Sankhya (schema SPARKPRD) — mantidas aqui apenas como referência/documentação, não são customizações da Spark.

---

> Estas functions **não são mantidas pela Spark** — são nativas do ERP Sankhya. O código foi capturado do banco em 18/09/2026 via `DBMS_METADATA.GET_DDL` e salvo aqui apenas para consulta rápida (evitar depender de VPN/acesso ao banco para entender uma dependência). Atualizações do Sankhya podem alterar ou remover estas functions — revisar após cada upgrade do ERP (mesmo cuidado do `trigger_nativa/README.md`).

## Catálogo

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

## Como recapturar / atualizar

```sql
SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'NOME_DA_FUNCTION', 'SPARKPRD') FROM dual;
```

Lista completa obtida via `all_objects` filtrando `object_name LIKE 'SNK\_%' ESCAPE '\'` e `object_type = 'FUNCTION'` no schema `SPARKPRD`.
