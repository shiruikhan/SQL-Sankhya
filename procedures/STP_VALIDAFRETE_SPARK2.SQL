create or replace PROCEDURE STP_VALIDAFRETE_SPARK2
AS
/*==============================================================================
  Nome do Script : STP_VALIDAFRETE_SPARK2
  Tipo           : Stored Procedure (Execução Programada)
  Descrição      : Processa em lote fretes de CTe para operações tipo 225,
                   distribuindo automaticamente custos de frete, ICMS e PIS
                   entre as notas de compra relacionadas.

  Parâmetros     : (sem parâmetros de entrada)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
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
       P_NUNOTA                          INT;

       CURSOR CUR_NOTASCAB IS
       SELECT NUNOTA
         FROM TGFCAB 
        WHERE CODTIPOPER = 225;

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

    OPEN CUR_NOTASCAB;
    LOOP
    FETCH CUR_NOTASCAB INTO P_NUNOTA;
    EXIT WHEN CUR_NOTASCAB%NOTFOUND;



      SELECT VLRNOTA, 
      nvl((SELECT SUM(VALOR) 
         FROM TGFDIN 
        WHERE NUNOTA =  P_NUNOTA
          AND CODIMP = 1),0) ,
      nvl((SELECT SUM(VALOR) 
         FROM TGFDIN 
        WHERE NUNOTA =  P_NUNOTA
          AND CODIMP IN (6,7)),0)
       INTO P_VLRNOTACTE, P_VLRICMS, P_VLRPIS
        FROM TGFCAB 
       WHERE NUNOTA = P_NUNOTA;

       SELECT SUM(CAB.VLRNOTA) INTO P_TOTNOTA
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

                UPDATE TGFCAB SET VLRFRETE = ROUND(P_VLRNOTACTE * P_VLRNOTA / P_TOTNOTA,2),
                                  ICMSFRETE  = ROUND(P_VLRICMS * P_VLRNOTA / P_TOTNOTA,2),
                                  AD_VLRPISCOFINS_FRETE = ROUND(P_VLRPIS * P_VLRNOTA / P_TOTNOTA,2),
                                  AD_FRETERATEADO = 'S'
                WHERE NUNOTA = P_NUNOTAORIG AND TIPMOV = 'C' AND TIPFRETE <> 'S';

                END LOOP;
                CLOSE CUR_NOTAS;


    END LOOP;
    CLOSE CUR_NOTASCAB;


END;
END; 