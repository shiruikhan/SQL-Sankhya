/*==============================================================================
  Nome do Script : AD_CORRAPONTAMENTO
  Descrição      : Tabela de auditoria das correções de apontamento (TPRAPA)
                   realizadas pela STP_CORRIGEAPONTAMENTO_SPARK. Cada linha
                   registra um apontamento cuja QTDAPONTADA/QTDFAT divergia do
                   nº de séries consolidadas em AD_TPRCOI pela conferência
                   vinculada (TPRCONF.NUAPO), guardando os valores anteriores
                   para permitir o desfazimento manual.
                   Valores de TIPOCORR:
                     AJUSTADO           — QTDAPONTADA e QTDFAT corrigidas para o
                                          nº de séries conferidas
                     IGNORADO_MULTICONF — o mesmo apontamento atende mais de uma
                                          conferência finalizada; nada foi
                                          alterado, requer análise manual
                     IGNORADO_MULTISEQ  — o apontamento tem mais de uma linha em
                                          TPRAPA para o mesmo produto; nada foi
                                          alterado, requer análise manual
  Autor          : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : Outubro/2026
  Última Revisão : Outubro/2026 — Criação da tabela
==============================================================================*/

CREATE TABLE AD_CORRAPONTAMENTO (
    NUCORR      NUMBER                    NOT NULL,  -- Identificador sequencial da correção
    NUCONF      NUMBER                    NOT NULL,  -- Conferência de referência (TPRCONF.NUCONF)
    IDIPROC     NUMBER                    NOT NULL,  -- Ordem de produção (TPRIPROC.IDIPROC)
    NUAPO       NUMBER                    NOT NULL,  -- Apontamento verificado (TPRAPA.NUAPO)
    SEQAPA      NUMBER                    NOT NULL,  -- Sequência do apontamento (TPRAPA.SEQAPA)
    CODPRODPA   NUMBER                    NOT NULL,  -- Produto acabado (TPRAPA.CODPRODPA)
    QTDSERIES   NUMBER                    NOT NULL,  -- Séries da conferência em AD_TPRCOI (valor correto)
    QTDAPO_ANT  NUMBER                    NOT NULL,  -- QTDAPONTADA antes da correção
    QTDFAT_ANT  NUMBER                    NOT NULL,  -- QTDFAT antes da correção
    TIPOCORR    VARCHAR2(20)              NOT NULL,  -- Tipo da correção (ver cabeçalho)
    DHCORR      DATE DEFAULT SYSDATE      NOT NULL,  -- Data/hora da correção
    CONSTRAINT AD_CORRAPONTAMENTO_PK PRIMARY KEY (NUCORR)
);

CREATE INDEX AD_CORRAPONTAMENTO_IDX01 ON AD_CORRAPONTAMENTO (IDIPROC);

CREATE INDEX AD_CORRAPONTAMENTO_IDX02 ON AD_CORRAPONTAMENTO (NUAPO, SEQAPA);
