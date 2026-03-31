/*==============================================================================
  Nome do Script : AD_MAP_SETOR_FUNC
  Descrição      : Tabela de mapeamento entre o departamento do colaborador
                   (TFPDEP.DESCDEP) e a etapa de produção (TPREFX.DESCRICAO).
                   Necessária porque os nomes não são padronizados entre as
                   duas origens.
                   Utilizada pela trigger TRG_VAL_SETOR_CODFUNC_TPRAPA para
                   validar se o colaborador pertence ao setor do apontamento.
  Autor          : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : 31/03/2026
==============================================================================*/

CREATE TABLE AD_MAP_SETOR_FUNC (
    DESCDEP    VARCHAR2(100) NOT NULL,   -- TFPDEP.DESCDEP  (setor do colaborador)
    DESCIDEFX  VARCHAR2(100) NOT NULL,   -- TPREFX.DESCRICAO (etapa do apontamento)
    CONSTRAINT AD_MAP_SETOR_FUNC_PK PRIMARY KEY (DESCDEP, DESCIDEFX)
);

-- -----------------------------------------------------------------------
-- Mapeamentos iniciais
-- -----------------------------------------------------------------------

INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('INSERCAO',                          'INSERÇÃO');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('INSERSORA',                         'APONTAMENTO INSERSORA');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('INSERSORA',                         'APONTAMENTO REVISORA');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('SOLDA',                             'SOLDA');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('TESTE',                             'TESTE');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('DISSIPADOR',                        'DISSIPADOR');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('MONTAGEM FINAL',                    'MONTAGEM FINAL');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('MONTAGEM DISPLAY',                  'DISPLAY');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('EXPEDICAO',                         'EXPEDIÇÃO/CONFERENCIA');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('EXPEDICAO',                         'EXPEDICAO/CONF');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('MONTAGEM TAMPA E GABINETE',         'TAMPA/GABINETE');
INSERT INTO AD_MAP_SETOR_FUNC (DESCDEP, DESCIDEFX) VALUES ('FABRICACAO TRANSFORMADOR E INDUTOR','APONTAMENTO TRANSFORMADOR');

COMMIT;
