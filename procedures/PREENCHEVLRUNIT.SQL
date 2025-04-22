create or replace PROCEDURE "PREENCHEVLRUNIT" (
       P_CODUSU NUMBER,
       P_IDSESSAO VARCHAR2,
       P_QTDLINHAS NUMBER,
       P_MENSAGEM OUT VARCHAR2
) AS
       FIELD_NUNOTA NUMBER;
       FIELD_CODPROD NUMBER;
       V_VLRUNIT NUMBER;
BEGIN

       FOR I IN 1..P_QTDLINHAS LOOP
           FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');           
           FIELD_CODPROD := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPROD');
           
           BEGIN
               SELECT CUSMED
               INTO V_VLRUNIT
               FROM TGFCUS
               WHERE CODPROD = FIELD_CODPROD
               AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS WHERE CODPROD = FIELD_CODPROD);
           
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   V_VLRUNIT := 0.1;
               WHEN OTHERS THEN
                   V_VLRUNIT := 0.1;
           END;
           
           IF V_VLRUNIT IS NOT NULL THEN
               UPDATE TGFITE 
               SET VLRUNIT = nvl(V_VLRUNIT,0.1), 
                   VLRTOT = QTDNEG * nvl(V_VLRUNIT,0.1)
               WHERE NUNOTA = FIELD_NUNOTA;
               
               
           END IF;

       END LOOP;

       
           P_MENSAGEM := ' Registros atualizados com sucesso.';

END;