/*==============================================================================
  Nome do Script : SNK_GET_NUNOTA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Gera o proximo NUNOTA valido para TGFCAB usando o controle TGFNUM,
                  recriando o registro de controle se ele nao existir.
  Assinatura     : SNK_GET_NUNOTA (sem parametros)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_NUNOTA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_NUNOTA 
RETURN NUMBER
AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  P_ULTCOD      NUMBER(10,0);
  P_MINNUNOTA   NUMBER(10,0); 
  P_MAXNUNOTA   NUMBER(10,0);
  P_SERIE       TGFNUM.SERIE%TYPE;
  P_FICA        BOOLEAN;
  P_RECOMECOU   BOOLEAN;
BEGIN
     P_ULTCOD := 0;
     BEGIN
           SELECT  (ULTCOD + 1), SERIE 
           INTO P_ULTCOD, P_SERIE
           FROM TGFNUM
           WHERE ARQUIVO = 'TGFCAB' 
           AND CODEMP = 1
           AND ROWNUM = 1 
           FOR UPDATE;       
     EXCEPTION 
           WHEN NO_DATA_FOUND THEN
                P_ULTCOD := 0;
     END; 

     IF P_ULTCOD = 0 THEN --TGFNUM AINDA N?O EXISTE
            BEGIN
                    --PEGAMOS O MAIOR CODIGO DA TABELA, ASSIM INICIAMOS A TGFNIM COM ESSE VALOR
                    SELECT NVL(MAX(NUNOTA),0) + 1 INTO P_ULTCOD FROM TGFCAB;
            EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                             P_ULTCOD := 1;
            END;
            INSERT INTO TGFNUM (ARQUIVO,CODEMP,ULTCOD) VALUES ('TGFCAB',1,P_ULTCOD);
     ELSE
            --DEVEMOS CHECAR SE O CODIGO GERADO E VALIDO (CHECAMOS PACOTES DE 100 LINHAS POR VEZ)
            P_RECOMECOU := FALSE;
            P_FICA := TRUE;
            WHILE P_FICA  LOOP
               BEGIN
                    SELECT MIN(NUNOTA), MAX(NUNOTA) 
                    INTO P_MINNUNOTA, P_MAXNUNOTA
                    FROM TGFCAB 
                    WHERE NUNOTA BETWEEN P_ULTCOD AND P_ULTCOD + 100; 
               EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        P_MINNUNOTA := P_ULTCOD + 1;
               END;            
               
               IF P_MINNUNOTA IS NULL OR P_MINNUNOTA > P_ULTCOD THEN         
                     P_FICA := FALSE;
               ELSE
                     P_ULTCOD := (P_MAXNUNOTA + 1);
                     IF P_ULTCOD > 1999999999 THEN
                       IF P_RECOMECOU THEN
                         rollback;
                         RAISE_APPLICATION_ERROR (-20101, 'N?o achamos numero disponivel para novos registros na TGFCAB.');
                       END IF;
                       P_ULTCOD := 1;
                       P_RECOMECOU := TRUE;
                     END IF;
               END IF;
            END LOOP;
            UPDATE TGFNUM 
            SET ULTCOD = P_ULTCOD 
            WHERE ARQUIVO = 'TGFCAB' 
            AND CODEMP = 1
            AND SERIE = P_SERIE;
     END IF;
     COMMIT;
     RETURN P_ULTCOD;     
END;

 
