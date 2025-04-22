create or replace PROCEDURE STP_VALIDAFRETE_SPARK(P_NUNOTA INT,  P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2,  P_CODUSULIB OUT NUMBER)
AS
BEGIN
DECLARE
       P_COUNT                           INT;
       P_DTCERTIDAO                      DATE;
       P_CODUF                           INT;
       P_VLRNOTACTE                      FLOAT;
       P_NUNOTAORIG                      INT; 
       P_VLRNOTA                         FLOAT;
       P_TOTNOTA                         FLOAT;
       P_VLRICMS                         FLOAT;
       P_VLRPIS                          FLOAT;
       P_SEQ                             INT;
       P_VLRNOVO                         FLOAT;
       
       CURSOR CUR_CTE IS
       SELECT NCT.SEQUENCIA, CAB.VLRNOTA
         FROM TGFNCT NCT, TGFCAB CAB
        WHERE NCT.CHAVENFE = CAB.CHAVENFE
          AND NCT.NUNOTA = P_NUNOTA
          AND CAB.TIPMOV = 'C';
       
       
       CURSOR CUR_NOTAS IS
       SELECT CAB.NUNOTA, CAB.VLRNOTA
         FROM TGFNCT NCT, TGFCAB CAB
        WHERE NCT.CHAVENFE = CAB.CHAVENFE
          AND NCT.NUNOTA = P_NUNOTA
          AND CAB.TIPMOV = 'C';



BEGIN

P_SUCESSO := 'S';


      SELECT VLRNOTA, 
      NVL((SELECT SUM(VALOR) 
         FROM TGFDIN 
        WHERE NUNOTA =  P_NUNOTA
          AND CODIMP = 1),0) ,
      NVL((SELECT SUM(VALOR) 
         FROM TGFDIN 
        WHERE NUNOTA =  P_NUNOTA
          AND CODIMP IN (6,7)),0)
       INTO P_VLRNOTACTE, P_VLRICMS, P_VLRPIS
        FROM TGFCAB 
       WHERE NUNOTA = P_NUNOTA;
       
       SELECT NVL(SUM(CAB.VLRNOTA),0) INTO P_TOTNOTA
         FROM TGFNCT NCT, TGFCAB CAB
        WHERE NCT.CHAVENFE = CAB.CHAVENFE
          AND NCT.NUNOTA = P_NUNOTA;
          
                OPEN CUR_CTE;
                LOOP
                FETCH CUR_CTE INTO P_SEQ, P_VLRNOVO;
                EXIT WHEN CUR_CTE%NOTFOUND;
                
                UPDATE TGFNCT SET VLRNOTA = P_VLRNOVO
                WHERE NUNOTA = P_NUNOTA
                  AND SEQUENCIA = P_SEQ;
                
                END LOOP;
                CLOSE CUR_CTE;
          
          
       
                OPEN CUR_NOTAS;
                LOOP
                FETCH CUR_NOTAS INTO P_NUNOTAORIG, P_VLRNOTA;
                EXIT WHEN CUR_NOTAS%NOTFOUND;
                
                IF P_TOTNOTA > 0 THEN 
                
                UPDATE TGFCAB SET VLRFRETE = ROUND(P_VLRNOTACTE * P_VLRNOTA / P_TOTNOTA,2),
                                  ICMSFRETE  = ROUND(P_VLRICMS * P_VLRNOTA / P_TOTNOTA,2),
                                  AD_VLRPISCOFINS_FRETE = ROUND(P_VLRPIS * P_VLRNOTA / P_TOTNOTA,2),
                                  AD_FRETERATEADO = 'S'
                WHERE NUNOTA = P_NUNOTAORIG;
                
                END IF;
                
                END LOOP;
                CLOSE CUR_NOTAS;
       




END;
END; 