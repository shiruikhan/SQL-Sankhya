create or replace TRIGGER TRG_INC_UPD_TPRMPS_SPARK 
BEFORE INSERT OR UPDATE ON TPRMPS
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TPRMPS_SPARK
  Tipo           : Trigger
  Descrição      : Restaura tipo original de PI ao gerar MRP para produtos padrão
  Tabela         : TPRMPS
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
P_COUNT INT;
BEGIN

   IF :NEW.DHGERMRP IS NOT NULL THEN 

    FOR X IN (SELECT CODPROD FROM TPRIMPS WHERE NUMPS = :NEW.NUMPS)

    LOOP
    --VOLTA A MARCAÇÃO ORIGINAL DE TIPO DE PI
    UPDATE TPRLPI SET TIPOPI=AD_TIPOPI WHERE CODPRODPA=X.CODPROD AND IDPROC IN (SELECT MAX(PI.IDPROC) FROM TPRPRC PRC INNER JOIN TPRLPI PI ON (PRC.IDPROC = PI.IDPROC)
      WHERE PI.CODPRODPA = X.CODPROD AND PRC.PADRAO='S')
      AND TIPOPI <> AD_TIPOPI;
    END LOOP;

    END IF;


END TRG_INC_UPD_TPRMPS_SPARK; 