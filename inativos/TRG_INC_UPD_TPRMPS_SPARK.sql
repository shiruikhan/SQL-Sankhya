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
  Última Revisão : Junho/2026 — Bloco de restauração de TIPOPI comentado: a lógica
                   dependia do forçamento UPDATE TPRLPI SET TIPOPI='O' que existia em
                   STP_PCPMETA_SPARK. Com a inativação daquele UPDATE (Jun/2026), não
                   há mais nada a restaurar — os PIs já chegam ao MRP com seus valores
                   originais de TIPOPI/AD_TIPOPI intactos.
==============================================================================*/
DECLARE
P_COUNT INT;
BEGIN

   -- *** INATIVADO Jun/2026 ***
   -- Este bloco restaurava TIPOPI=AD_TIPOPI após a geração do MRP para desfazer o
   -- forçamento UPDATE TPRLPI SET TIPOPI='O' que existia em STP_PCPMETA_SPARK.
   -- Como aquele UPDATE foi comentado em Jun/2026, os PIs já chegam ao MRP com seus
   -- valores originais e não há mais nada a restaurar aqui.
   /*
   IF :NEW.DHGERMRP IS NOT NULL THEN

    FOR X IN (SELECT CODPROD FROM TPRIMPS WHERE NUMPS = :NEW.NUMPS)

    LOOP
    --VOLTA A MARCAÇÃO ORIGINAL DE TIPO DE PI
    UPDATE TPRLPI SET TIPOPI=AD_TIPOPI WHERE CODPRODPA=X.CODPROD AND IDPROC IN (SELECT MAX(PI.IDPROC) FROM TPRPRC PRC INNER JOIN TPRLPI PI ON (PRC.IDPROC = PI.IDPROC)
      WHERE PI.CODPRODPA = X.CODPROD AND PRC.PADRAO='S')
      AND TIPOPI <> AD_TIPOPI;
    END LOOP;

    END IF;
   */


END TRG_INC_UPD_TPRMPS_SPARK; 