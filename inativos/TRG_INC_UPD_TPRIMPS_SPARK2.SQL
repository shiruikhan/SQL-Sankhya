create or replace TRIGGER TRG_INC_UPD_TPRIMPS_SPARK2 
BEFORE UPDATE ON TPRIMPS
FOR EACH ROW
DECLARE
P_COUNT       INT;
P_SALDO       FLOAT;
PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM TGMMET
     WHERE CODMETA = 3
       AND CODPROD = :NEW.CODPROD;
       
       IF NVL(:NEW.AD_PERMACIMA,'N') = 'S' THEN
       
       RETURN;
       END IF;
       
       IF NVL(:NEW.AD_PERMACIMA,'N') = 'N' AND  P_COUNT > 0 THEN 
       
      -- RAISE_APPLICATION_ERROR(-20191,'PERM: ' || NVL(:NEW.AD_PERMACIMA,'N'));
       BEGIN
       
       SELECT SUM(QTDPREV-QTDPRODUZIR) INTO P_SALDO
         FROM (
            SELECT 0 AS QTDPREV, SUM(QTDPRODUZIR) AS QTDPRODUZIR
             FROM TPRIPROC PROC INNER JOIN TPRIPA PA ON (PROC.IDIPROC=PA.IDIPROC) 
            INNER JOIN TPRMPS MPS ON (PROC.NUMPS = MPS.NUMPS)
             WHERE STATUSPROC IN ('A','F','R','P2')
             AND PA.CODPRODPA = :NEW.CODPROD
             AND TRUNC(PROC.DHINST,'MM') = TRUNC(MPS.DTFINMPS,'MM')
            UNION ALL
            SELECT NVL(QTDPREV,0) AS QTDPREV,  0 AS QTDPRODUZIR 
              FROM TGFMET MET, TPRMPS MPS
             WHERE MET.CODMETA = 3 
               AND MET.CODPROD = :NEW.CODPROD 
               AND MPS.NUMPS = :NEW.NUMPS
               AND  MET.DTREF = TRUNC(MPS.DTFINMPS,'MM')) D;
       END;
       
          -- RAISE_APPLICATION_ERROR(-20191,'SALDO: ' || P_SALDO);
           
               
               IF :NEW.QTDPRODUZIRLIQ > P_SALDO AND NVL(:NEW.AD_PERMACIMA,'N') = 'N' THEN 
               
                           RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML('Ação não permitida!',
                    'Saldo utilizado maior que o previsto!',
                    'Nro Plano:'||:NEW.NUMPS));   
               
               END IF;
       
       END IF;


END; 