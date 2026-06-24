create or replace TRIGGER TRG_INC_UPD_TPRPRC_SPARK 
BEFORE INSERT OR UPDATE ON TPRPRC
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TPRPRC_SPARK
  Tipo           : Trigger
  Descrição      : Gerencia tipos de PI em processos produtivos (sub-ordem ou estoque)
  Tabela         : TPRPRC
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Junho/2026 — Blocos de UPDATE (P_COUNT=1) comentados: a trigger
                   propagava o AD_TIPOPI do processo para todos os PIs existentes,
                   sobrescrevendo configurações individuais em TPRLPI. Como um mesmo
                   processo pode conter PIs com TIPOPI='O' (apenas lista de materiais,
                   sem sub-ordem) e TIPOPI='E' (sub-ordem + explosão de composição)
                   coexistindo, a atualização em massa apagava essa distinção a cada
                   edição do processo. Os blocos de INSERT (P_COUNT=0) foram mantidos
                   para que novos PIs adicionados ao processo recebam o valor inicial
                   correto de AD_TIPOPI. Registros já existentes não são mais tocados.
==============================================================================*/
DECLARE
P_COUNT INT;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

FOR PI IN (SELECT CODPRODPA AS CODPRODPI FROM TPRLPA WHERE IDPROC = :NEW.IDPROC)

LOOP 

-- ACHA EM QUAIS PROCESSOS PRODUTIVOS O PI ACIMA ESTÁ PRESENTE COMO MATÉRIA PRIMA PARA ALTERAR O TIPO DO PI E EM CASOS DE NÃO EXISTIR INSERIR
FOR MP IN (SELECT LPA.IDPROC,MP.CODPRODPA, MP.CODPRODMP AS CODPRODPI 
            FROM TPRLPA LPA INNER JOIN TPRATV ATV ON (LPA.IDPROC = ATV.IDPROC)
              INNER JOIN TPRPRC PRC ON (PRC.IDPROC = LPA.IDPROC)
                INNER JOIN TPRLMP MP ON (MP.IDEFX = ATV.IDEFX AND MP.CODPRODPA = LPA.CODPRODPA)
                  WHERE MP.CODPRODMP = PI.CODPRODPI -- PEGA O PA DO LAÇO ONDE ESTÁ SENDO ALTERADO O PROCESSO PRODUTIVO, POIS ELE É PI DE  ALGUM OUTRO PROCESSO
                     AND PRC.IDPROC IN (SELECT MAX(PR.IDPROC) FROM TPRPRC PR WHERE PR.CODPRC = PRC.CODPRC) --PEGAR ULTIMA VERSÃO DO PROCESSO PRODUTIVO
)

LOOP

-- TIPO GERAÇÃO PI COMO SUB-ORDEM
SELECT COUNT(*) INTO P_COUNT FROM TPRLPI WHERE CODPRODPA = MP.CODPRODPA AND CODPRODPI = MP.CODPRODPI AND IDPROC = MP.IDPROC;

IF NVL(:NEW.AD_TIPOPI,'N')= 'O' AND P_COUNT=0 THEN

INSERT INTO TPRLPI (IDPROC, CODPRODPA,CONTROLEPA,CODPRODPI,CONTROLEPI,
                    TIPOPI,TIPOSUBOP,AGUARDARSUBOP,TIPONROLOTE,CONSIDERAQTDEST,
                    REDIMENSIONAPA,REDIMENSIONAPAPERDA,CONSIDERALOTEPI, AD_TIPOPI)
    VALUES (MP.IDPROC,MP.CODPRODPA,' ',MP.CODPRODPI, ' ',
            'O','I','N','L','N',
            'U','U', 'N','O');
--COMMIT;
END IF;

-- REGISTROS JÁ EXISTENTES NA TPRLPI, ATUALIZA OS CAMPOS TIPO SUB-ORDEM
-- *** INATIVADO Jun/2026 ***
-- Motivo: sobrescrevia a configuração individual de cada PI (TIPOPI/AD_TIPOPI em TPRLPI)
-- sempre que qualquer campo do processo (TPRPRC) era alterado, impedindo a coexistência
-- de PIs com TIPOPI='O' e TIPOPI='E' dentro do mesmo processo produtivo.
-- O INSERT (P_COUNT=0) abaixo continua ativo para inicializar novos PIs corretamente.
/*
IF NVL(:NEW.AD_TIPOPI,'N')= 'O' AND P_COUNT=1 THEN

UPDATE TPRLPI SET TIPOPI='O',TIPOSUBOP='I',AGUARDARSUBOP='N',TIPONROLOTE='L',CONSIDERAQTDEST='N',
                    REDIMENSIONAPA='U',REDIMENSIONAPAPERDA='U',CONSIDERALOTEPI='N', AD_TIPOPI='O'
                    WHERE IDPROC = MP.IDPROC AND CODPRODPA = MP.CODPRODPA AND CODPRODPI = MP.CODPRODPI;

--COMMIT;
END IF;
*/

-- TIPO PI COMO ESTOQUE INCLUI
IF NVL(:NEW.AD_TIPOPI,'N')= 'E' AND P_COUNT=0 THEN

INSERT INTO TPRLPI (IDPROC, CODPRODPA,CONTROLEPA,CODPRODPI,CONTROLEPI,
                    TIPOPI,TIPOSUBOP,AGUARDARSUBOP,TIPONROLOTE,CONSIDERAQTDEST,
                    REDIMENSIONAPA,REDIMENSIONAPAPERDA,CONSIDERALOTEPI,AD_TIPOPI)
    VALUES (MP.IDPROC,MP.CODPRODPA,' ',MP.CODPRODPI, ' ',
            'E','I','S','I','N',
            'U','U', 'N','E');
--COMMIT;
END IF;

-- TIPO PI COMO ESTOQUE ATUALIZA SE JÁ EXISTIR
-- *** INATIVADO Jun/2026 ***
-- Mesmo motivo do bloco 'O' acima: aplicava o AD_TIPOPI do processo sobre todos os
-- PIs já existentes em TPRLPI, apagando diferenças individuais entre 'O' e 'E'.
/*
IF NVL(:NEW.AD_TIPOPI,'N')= 'E' AND P_COUNT=1 THEN

UPDATE TPRLPI SET TIPOPI='E',TIPOSUBOP='I',AGUARDARSUBOP='S',TIPONROLOTE='I',CONSIDERAQTDEST='N',
                    REDIMENSIONAPA='U',REDIMENSIONAPAPERDA='U',CONSIDERALOTEPI='N', AD_TIPOPI='E'
                    WHERE IDPROC = MP.IDPROC AND CODPRODPA = MP.CODPRODPA AND CODPRODPI = MP.CODPRODPI;

--COMMIT;
END IF;
*/


END LOOP;


END LOOP;

COMMIT;

END TRG_INC_UPD_TPRPRC_SPARK;





--SELECT * FROM TPRLPI WHERE TIPOPI='O' AND CONTROLEPA=' ' AND CONTROLEPI=' ' ORDER BY IDPROC DESC 