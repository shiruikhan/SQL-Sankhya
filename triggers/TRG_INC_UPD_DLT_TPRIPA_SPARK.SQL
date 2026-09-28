create or replace TRIGGER TRG_INC_UPD_DLT_TPRIPA_SPARK
BEFORE INSERT OR UPDATE OR DELETE
ON TPRIPA
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_DLT_TPRIPA_SPARK
  Tipo           : Trigger
  Descrição      : Gera série automática ou sequencial baseada em tipo de geração do lote de produção
  Tabela         : TPRIPA
  Evento         : BEFORE INSERT OR UPDATE OR DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Setembro/2026 — Performance/correção: o gerador de séries
                   sequenciais passou a usar `CONNECT BY LEVEL` em vez de
                   `ROWNUM <= QTDPRODUZIR` sobre TGFPRO (tabela de produtos, sem
                   nenhuma relação com a geração de série). Antes, o custo e a
                   própria quantidade de séries geradas dependiam do tamanho de
                   TGFPRO; agora gera exatamente QTDPRODUZIR linhas sem tocar em
                   TGFPRO. Mesmo resultado em qualquer cenário em que QTDPRODUZIR
                   seja menor que a quantidade de produtos cadastrados (sempre
                   verdadeiro em produção).
==============================================================================*/
DECLARE 
P_QTDPRODUZIR  TPRIPA.QTDPRODUZIR%TYPE;
P_NROLOTE      TPRIPA.NROLOTE%TYPE;
P_IDIPROC      TPRIPA.IDIPROC%TYPE;
P_TIPOGERASERIE TPRLPA.TIPOGERASERIE%TYPE;
P_COUNT        INT;

BEGIN

-- VERSÃO PROCESSO PRODUTIVO QUE ESTAVA GERANDO AUTOMÁTICO
BEGIN
SELECT NVL(LPA.TIPOGERASERIE,'Z') INTO P_TIPOGERASERIE FROM TPRLPA LPA INNER JOIN TPRIPROC PR ON (LPA.IDPROC = PR.IDPROC) WHERE PR.IDIPROC = :NEW.IDIPROC
AND LPA.CODPRODPA = :NEW.CODPRODPA;
EXCEPTION WHEN NO_DATA_FOUND THEN
P_TIPOGERASERIE := 'Z'; --APONTAMENTO MANUAL
END;

IF P_TIPOGERASERIE = 'A' THEN
INSERT INTO AD_TPRSERPA (IDIPROC, CODPRODPA, SERIEPA)
SELECT :NEW.IDIPROC, :NEW.CODPRODPA, SERIEPA FROM TPRSERPA WHERE IDIPROC = :NEW.IDIPROC;
END IF;  

IF P_TIPOGERASERIE ='P' THEN
-- SE FOR EDITADO  TAMANHO DO LOTE OU SUBSTITUIR PA PRECISA DELETAR TUDO E RECRIAR AS SÉRIES NO PADRÃO SNLLLLLLLLXXXX (ONDE SN É FIXO, L É LOTE E X É SEQUENCIAL COM BASE QTDE LOTE)
DELETE FROM AD_TPRSERPA WHERE IDIPROC = :NEW.IDIPROC ;

-- INCLUI A SÉRIE CONFORME QUANTIDADE APONTADA DE FORMA SEQUENCIAL,
INSERT INTO AD_TPRSERPA (IDIPROC, CODPRODPA, SERIEPA)
SELECT :NEW.IDIPROC, :NEW.CODPRODPA, 'SN'||:NEW.NROLOTE||LPAD(LEVEL,4,0) FROM DUAL CONNECT BY LEVEL <= :NEW.QTDPRODUZIR;

END IF;


END; 