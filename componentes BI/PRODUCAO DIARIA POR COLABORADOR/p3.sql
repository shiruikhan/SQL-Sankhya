/*==============================================================================
  Nome do Script : P3
  Tipo           : Componente BI — Tabela (relação de apontamentos do
                   colaborador selecionado)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P3
  Descrição      : Detalha, um apontamento por linha, a produção registrada
                   pelo colaborador selecionado via drill-down no P2 (coluna
                   CODFUNC), dentro do mesmo recorte de filtros já ativo no
                   restante do dashboard (P1/P2/G1): período, status do
                   processo, processo específico, código de processo e lista
                   de setores do dash. Sem :A_CODFUNC informado, não retorna
                   linhas — não é uma tabela para navegação livre, apenas o
                   detalhe do colaborador clicado.

  Parâmetros     : :A_CODFUNC    — código do colaborador (TFPFUN.CODFUNC),
                                   recebido por drill-down a partir da coluna
                                   CODFUNC do P2. Obrigatório na prática — sem
                                   ele a condição não casa com nenhum
                                   apontamento e o painel fica vazio.
                   :P_PERIODO    — período do apontamento (INI/FIN), aplicado
                                   sobre APO.DHAPO
                   :P_FINAL      — 'N' considera apenas atividades não
                                   finalizadas (TV.DHFINAL IS NULL); 'S' inclui
                                   também as finalizadas
                   :P_STATUSPROC — status do processo (array)
                   :P_IDIPROD    — ID do processo de produção (opcional)
                   :P_CODPRC     — código do processo (array)

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TPRIPROC, TPRPRC, TPRIPA,
                   TGFPRO

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Setembro/2026
  Última Revisão : Setembro/2026 — Criação inicial.
                   Setembro/2026 — Adicionado CODPRODPA e DESCRPROD
                   (TPRIPA/TGFPRO) para identificar o produto de cada
                   apontamento.

  Observações    : Grão = 1 linha por apontamento (TPRAPO × TPRAPA), não por
                   atividade — por isso não repete TAMLOTE/QTDPRODUZIR do P1
                   nem soma apontamento entre etapas (ver memória
                   "apontamento-por-etapa-nao-e-quantidade": somar apontamento
                   de atividades diferentes do mesmo processo não é uma
                   quantidade válida).
                   TPRIPA é ligado só por IDIPROC (não há chave para uma
                   atividade específica) — assume 1 item de lote por processo,
                   confirmado empiricamente na investigação do P1 (Bloco 1:
                   zero processos com QTD_ITENS_LOTE > 1 no universo filtrado
                   por estes mesmos setores/status). Se algum dia um processo
                   tiver mais de 1 item de lote, este join duplica a linha do
                   apontamento (uma vez por item) sem que isso signifique mais
                   de um apontamento — reavalie se o volume de linhas do P3
                   parecer inflado.
                   TFPFUN não é necessário aqui: o nome do colaborador já
                   aparece na linha selecionada do P2; o filtro já restringe a
                   um único CODFUNC.
==============================================================================*/

SELECT  APO.NUAPO                                               AS NUAPO
       ,TRUNC(APO.DHAPO)                                        AS DTAPONTAMENTO
       ,APO.DHAPO                                                AS DHAPONTAMENTO
       ,FX.DESCRICAO                                             AS SETOR
       ,PRC.DESCRABREV                                           AS PROCESSO
       ,PROC.NROLOTE                                             AS NROLOTE
       ,IPA.CODPRODPA                                            AS CODPRODPA
       ,PRO.DESCRPROD                                            AS DESCRPROD
       ,APA.QTDAPONTADA                                          AS QTDAPONTADA
       ,APA.QTDPERDA                                             AS QTDPERDA
  FROM TPRAPA APA
       INNER JOIN TPRAPO   APO  ON APA.NUAPO      = APO.NUAPO
       INNER JOIN TPRIATV  TV   ON APO.IDIATV     = TV.IDIATV
       INNER JOIN TPREFX   FX   ON TV.IDEFX       = FX.IDEFX
       INNER JOIN TPRIPROC PROC ON TV.IDIPROC     = PROC.IDIPROC
       INNER JOIN TPRPRC   PRC  ON PROC.IDPROC    = PRC.IDPROC
       INNER JOIN TPRIPA   IPA  ON IPA.IDIPROC    = PROC.IDIPROC
       INNER JOIN TGFPRO   PRO  ON PRO.CODPROD    = IPA.CODPRODPA
 WHERE APA.AD_CODFUNC = :A_CODFUNC
   AND TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
   AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
   AND APO.SITUACAO = 'C'
   AND PROC.STATUSPROC IN :P_STATUSPROC
   AND (PROC.IDIPROC = :P_IDIPROD OR :P_IDIPROD IS NULL)
   AND NVL(TV.DHFINAL, TO_DATE('01/01/2099')) = CASE WHEN :P_FINAL = 'S'
                                                      THEN NVL(TV.DHFINAL, TO_DATE('01/01/2099'))
                                                      ELSE TO_DATE('01/01/2099')
                                                 END
   AND PRC.CODPRC IN :P_CODPRC
 ORDER BY APO.DHAPO DESC
