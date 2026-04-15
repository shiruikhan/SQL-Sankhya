/*==============================================================================
  Nome do Script : DASHBOARD_FICHAS_PRODUCAO
  Tipo           : Componente BI — Tabela
  Dashboard      : Fichas de Produção
  Descrição      : Fichas de produção em aberto e andamento, com saldo
                   a produzir, status e datas de entrega/início.

  Parâmetros     : Sem parâmetros

  Tabelas        : TPRIPROC, TPRIPA, TGFPRO, TPRAPO, TPRAPA, TPRIATV

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A definir
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/

SELECT 
    PRC.NROLOTE AS FICHA,
    PRC.NUMPS AS PLANO,
    PRO.DESCRPROD AS DESCRICAO_PRODUTO,
    IPA.QTDPRODUZIR AS TAMANHO_LOTE,
    IPA.QTDPRODUZIR - NVL((
        SELECT SUM(APA.QTDAPONTADA + APA.QTDPERDA) 
        FROM TPRAPO APO 
        INNER JOIN TPRAPA APA ON APO.NUAPO = APA.NUAPO 
        INNER JOIN TPRIATV TV ON APO.IDIATV = TV.IDIATV 
        WHERE APO.SITUACAO = 'C' 
        AND TV.IDIPROC = PRC.IDIPROC
    ), 0) AS SALDO_A_PRODUZIR,
    OPTION_LABEL('TPRIPROC', 'STATUSPROC', PRC.STATUSPROC) AS STATUS_PROCESSO,
    PRC.DTPREVENT AS DATA_PREVISTA_ENTREGA,
    PRC.DHINST AS DATA_INICIO,
    (CASE WHEN PRO.AD_LINHA = 1 THEN 'Linha 1' 
          WHEN PRO.AD_LINHA = 2 THEN 'Linha 2' 
          ELSE 'Sem info' END) AS LINHA_PRODUCAO
FROM TPRIPROC PRC
INNER JOIN TPRIPA IPA ON PRC.IDIPROC = IPA.IDIPROC
INNER JOIN TGFPRO PRO ON IPA.CODPRODPA = PRO.CODPROD
WHERE PRC.STATUSPROC IN ('A', 'P2')  -- A: Aberto/Ativo, P2: Em Produção
    AND PRC.DHTERMINO IS NULL  -- Não finalizadas
    AND PRC.NUMPS IS NOT NULL  -- Apenas de planos gerados
ORDER BY PRC.DTPREVENT, PRC.NROLOTE;