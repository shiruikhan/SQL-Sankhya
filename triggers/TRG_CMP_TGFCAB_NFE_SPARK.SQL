create or replace TRIGGER TRG_CMP_TGFCAB_NFE_SPARK
    FOR  UPDATE ON TGFCAB 
/*==============================================================================
  Nome do Script : TRG_CMP_TGFCAB_NFE_SPARK
  Tipo           : Trigger
  Descrição      : Sincroniza dados de NFe entre notas de entrada/saída (COMPOUND TRIGGER).
                  Atualiza valores, tributação e itens entre NUNOTA original e transferência.
  Tabela         : TGFCAB
  Evento         : FOR UPDATE (COMPOUND TRIGGER)
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
COMPOUND TRIGGER

    V_COUNT     INT;
    V_NUNOTA    INT;
    V_SEQUENCIA INT;
    V_VLRUNIT   FLOAT;
    V_BASEICMS  FLOAT;
    V_ALIQICMS  FLOAT;
    V_VLRICMS   FLOAT;
    V_BASEIPI   FLOAT;
    V_ALIQIPI   FLOAT;
    V_VLRIPI    FLOAT;
    V_CHAVENFE TGFCAB.CHAVENFE%TYPE;
    V_TIPMOV  TGFCAB.TIPMOV%TYPE;
    V_NUNOTA_ENT INT;
    V_NUMNOTA  TGFCAB.NUMNOTA%TYPE;
     V_VLRNOTA  TGFCAB.VLRNOTA%TYPE;
    V_SERIENOTA TGFCAB.SERIENOTA%TYPE;
    V_CODTRIB   TGFITE.CODTRIB%TYPE;

    
    CURSOR CUR_ITENS IS 
     SELECT SEQUENCIA
                   , VLRUNIT 
                   , BASEICMS
                   , ALIQICMS
                   , VLRICMS
                   , BASEIPI
                   , ALIQIPI
                   , VLRIPI
                   , CODTRIB
       FROM TGFITE
     WHERE NUNOTA = :NEW.NUNOTA;

   
BEFORE EACH ROW IS
BEGIN
        BEGIN
           
            IF :NEW.TIPMOV = 'V' AND :NEW.CHAVENFE IS NOT NULL AND :OLD.CHAVENFE IS NULL THEN 
                     
                     V_CHAVENFE :=  :NEW.CHAVENFE;
                      V_TIPMOV :=   :NEW.TIPMOV;
                      V_NUNOTA :=  :NEW.NUNOTA;
                      V_NUMNOTA := :NEW.NUMNOTA;
                      V_VLRNOTA := :NEW.VLRNOTA;
                      V_SERIENOTA     := :NEW.SERIENOTA;
                      
             END IF;
          
        END;
        
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
  
           SELECT COUNT(0)
                 INTO V_COUNT
                FROM TGFCAB
              WHERE AD_NUNOTASAI = V_NUNOTA;
              
             IF V_COUNT > 0 THEN 
                          
                   SELECT MAX(AD_NUNOTAENT)
                     INTO V_NUNOTA_ENT
                     FROM TGFCAB
                    WHERE AD_NUNOTASAI = V_NUNOTA;
                 
                 UPDATE TGFCAB SET NUMNOTA = V_NUMNOTA
                                               , CHAVENFE = V_CHAVENFE
                                               , VLRNOTA =  V_VLRNOTA
                  WHERE NUNOTA = V_NUNOTA_ENT;
                               
                    OPEN CUR_ITENS;
                       LOOP
                          FETCH CUR_ITENS INTO V_SEQUENCIA, V_VLRUNIT , V_BASEICMS, V_ALIQICMS, V_VLRICMS, V_BASEIPI, V_ALIQIPI, V_VLRIPI, V_CODTRIB;
                          EXIT WHEN CUR_ITENS%NOTFOUND;
                          
                          
                          IF V_BASEIPI > 0 THEN
                                                   
                          UPDATE TGFITE SET VLRUNIT = V_VLRUNIT, 
                                             VLRTOT = V_VLRUNIT * QTDNEG,
                                           BASEICMS = V_BASEICMS,
                                           ALIQICMS = V_ALIQICMS,
                                            VLRICMS = V_VLRICMS,
                                            CSTIPI = 49,
                                            BASEIPI = V_BASEIPI, 
                                            ALIQIPI = V_ALIQIPI, 
                                             VLRIPI = V_VLRIPI,
                                             CODTRIB = V_CODTRIB
                               WHERE NUNOTA = V_NUNOTA_ENT
                                 AND SEQUENCIA = V_SEQUENCIA;
                               
                           END IF;   
                           
                           IF NVL(V_BASEIPI,0) = 0 THEN
                           
                              UPDATE TGFITE SET VLRUNIT = V_VLRUNIT, 
                                                 VLRTOT = V_VLRUNIT * QTDNEG,
                                                BASEICMS = V_BASEICMS,
                                                ALIQICMS = V_ALIQICMS,
                                                VLRICMS = V_VLRICMS,
                                                CSTIPI = 1,
                                                BASEIPI = V_BASEIPI, 
                                                ALIQIPI = V_ALIQIPI, 
                                                 VLRIPI = V_VLRIPI,
                                                CODTRIB = V_CODTRIB
                                   WHERE NUNOTA = V_NUNOTA_ENT
                                     AND SEQUENCIA = V_SEQUENCIA;

                           END IF;   
                           
                       END LOOP;
                    CLOSE CUR_ITENS;
                       
             END IF;

END AFTER STATEMENT;
END TRG_CMP_TGFCAB_NFE_SPARK;