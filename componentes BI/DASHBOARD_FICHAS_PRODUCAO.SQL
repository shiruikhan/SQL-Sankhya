-- Dashboard: Fichas de Produção em Aberto e Andamento
-- Mostra todas as fichas de produção ativas de planos já gerados
-- 
-- Colunas:
-- FICHA: Número da ficha de produção (NROLOTE)
-- PLANO: Número do plano de produção (NUMPS)
-- DESCRICAO_PRODUTO: Descrição do produto sendo produzido
-- TAMANHO_LOTE: Quantidade total a produzir na ficha
-- SALDO_A_PRODUZIR: Quantidade restante a produzir (lote - apontado - perdas)
-- STATUS_PROCESSO: Status atual do processo
-- DATA_PREVISTA_ENTREGA: Data prevista para entrega
-- DATA_INICIO: Data de início do processo
-- LINHA_PRODUCAO: Linha de produção associada
--
-- Filtros aplicados:
-- - Processos com status 'A' (Aberto/Ativo) ou 'P2' (Em Produção)
-- - Processos não finalizados (DHTERMINO IS NULL)
-- - Apenas processos de planos gerados (NUMPS IS NOT NULL)

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