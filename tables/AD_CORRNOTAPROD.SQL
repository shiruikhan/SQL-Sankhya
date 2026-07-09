/*==============================================================================
  Nome do Script : AD_CORRNOTAPROD
  Descrição      : Tabela de auditoria das verificações/correções de notas de
                   produção realizadas pela STP_CORRIGENOTAPROD_SPARK.
                   Cada linha registra uma correção aplicada (ou divergência
                   detectada) ao comparar as conferências finalizadas (TPRCONF/
                   AD_TPRCOI) com o lançamento da nota de produção (TGFCAB/
                   TGFITE/TGFSER) da mesma OP.
                   Valores de TIPOCORR:
                     NOTA_CRIADA     — nota de produção estava ausente e foi criada
                     QTD_AJUSTADA    — QTDNEG do item PA ajustada na nota existente
                                       para coincidir com as séries conferidas
                                       (QTDCORR positivo = a menor; negativo = a maior)
                     SERIE_INCLUIDA  — séries conferidas ausentes incluídas em TGFSER
                     DIVERG_NEGATIVA — (legado, até Jul/2026) lançado maior que
                                       conferido, quando ainda não era corrigido
                                       automaticamente
  Autor          : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : 09/07/2026
  Última Revisão : Julho/2026 — Adicionada a coluna NUCONF (conciliação passou
                   a ser por conferência; ver ALTER no final para bases onde a
                   tabela já existe)
==============================================================================*/

CREATE TABLE AD_CORRNOTAPROD (
    NUCORR     NUMBER                    NOT NULL,  -- Identificador sequencial da correção
    NUCONF     NUMBER,                              -- Conferência verificada (TPRCONF.NUCONF)
    IDIPROC    NUMBER                    NOT NULL,  -- Ordem de produção (TPRIPROC.IDIPROC)
    NUNOTA     NUMBER,                              -- Nota de produção criada/corrigida (TGFCAB.NUNOTA)
    CODPRODPA  NUMBER                    NOT NULL,  -- Produto acabado da OP (TPRIPA.CODPRODPA)
    QTDCONF    NUMBER                    NOT NULL,  -- Total conferido (séries em AD_TPRCOI da OP)
    QTDLANC    NUMBER                    NOT NULL,  -- Total lançado (QTDNEG do PA nas notas da OP)
    QTDCORR    NUMBER,                              -- Quantidade corrigida/incluída nesta ação
    TIPOCORR   VARCHAR2(20)              NOT NULL,  -- Tipo da correção (ver cabeçalho)
    DESCRICAO  VARCHAR2(500),                       -- Detalhamento da correção
    DHCORR     DATE DEFAULT SYSDATE      NOT NULL,  -- Data/hora da correção
    CONSTRAINT AD_CORRNOTAPROD_PK PRIMARY KEY (NUCORR)
);

CREATE INDEX AD_CORRNOTAPROD_IDX01 ON AD_CORRNOTAPROD (IDIPROC);

CREATE INDEX AD_CORRNOTAPROD_IDX02 ON AD_CORRNOTAPROD (NUCONF);

-- -----------------------------------------------------------------------
-- Upgrade: executar SOMENTE em bases onde a tabela já existia sem NUCONF
-- (criada antes de Julho/2026); não executar junto com o CREATE acima.
-- -----------------------------------------------------------------------
-- ALTER TABLE AD_CORRNOTAPROD ADD NUCONF NUMBER;
-- CREATE INDEX AD_CORRNOTAPROD_IDX02 ON AD_CORRNOTAPROD (NUCONF);
