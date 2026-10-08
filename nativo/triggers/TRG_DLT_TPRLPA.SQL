/*==============================================================================
  Nome do Script : TRG_DLT_TPRLPA
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW DELETE sobre TPRLPA.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 24/02/2023.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_DLT_TPRLPA', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_DLT_TPRLPA" 
  BEFORE DELETE ON TPRLPA 
  FOR EACH ROW 
DECLARE 
    CURSOR PA IS 
      SELECT PRC.IDPROC, 
             LMP.CODPRODPA, 
             LMP.CONTROLEPA, 
             LMP.CODPRODMP, 
             LMP.CONTROLEMP 
      FROM   TPRLMP LMP 
             INNER JOIN TPREFX EFX 
                     ON ( LMP.IDEFX = EFX.IDEFX ) 
             INNER JOIN TPRPRC PRC 
                     ON ( EFX.IDPROC = PRC.IDPROC ) 
      WHERE  LMP.CODPRODMP = :OLD.CODPRODPA 
             -- AND (LMP.CONTROLEMP IS NULL OR LMP.CONTROLEMP = '') 
             AND NOT EXISTS (SELECT 1 
                             FROM   TPRLPA LPA 
                             WHERE  LPA.IDPROC <> :OLD.IDPROC 
                                    AND LPA.CODPRODPA = :OLD.CODPRODPA 
                                    AND ( NVL(LPA.CONTROLEPA, ' ') = ' ' 
                                           OR NVL(LPA.CONTROLEPA, ' ') = 
                                              NVL(:OLD.CONTROLEPA, ' ') )); 
    V_IDPROC     INT; 
    V_CODPRODPA  INT; 
    V_CONTROLEPA TPRLPA.CONTROLEPA%TYPE; 
    V_CODPRODMP  INT; 
    V_CONTROLEMP TPRLPA.CONTROLEPA%TYPE; 
    PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN 
    OPEN PA; 

    LOOP 
        FETCH PA INTO V_IDPROC, V_CODPRODPA, V_CONTROLEPA, V_CODPRODMP, 
        V_CONTROLEMP 
        ; 

        EXIT WHEN PA%NOTFOUND; 

        DELETE FROM TPRLPI LPI 
        WHERE  LPI.IDPROC = V_IDPROC 
               AND LPI.CODPRODPA = V_CODPRODPA 
               AND LPI.CONTROLEPA = NVL(V_CONTROLEPA, ' ') 
               AND LPI.CODPRODPI = V_CODPRODMP 
               AND LPI.CONTROLEPI = NVL(V_CONTROLEMP, ' '); 
    END LOOP; 

    COMMIT; 

    CLOSE PA; 
END; 
/
ALTER TRIGGER "SPARKPRD"."TRG_DLT_TPRLPA" ENABLE;
