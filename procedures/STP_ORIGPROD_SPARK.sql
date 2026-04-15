create or replace PROCEDURE "STP_ORIGPROD_SPARK" (
       P_TIPOEVENTO INT,
       P_IDSESSAO VARCHAR2,
       P_CODUSU INT
) AS
/*==============================================================================
  Nome do Script : STP_ORIGPROD_SPARK
  Tipo           : Stored Procedure (Trigger de Evento)
  Descrição      : Procedure para atualização de origem de produto em notas de saída.
                   Sincroniza origem do item com o cadastro de produto.

  Parâmetros     : P_TIPOEVENTO — tipo de evento (BEFORE_INSERT, AFTER_INSERT, etc.)
                   P_IDSESSAO   — identificador da execução
                   P_CODUSU     — código do usuário logado

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;
       V_TIPMOV  TGFCAB.TIPMOV%TYPE;
       V_CODPROD TGFITE.CODPROD%TYPE;
       V_SEQUENCIA TGFITE.SEQUENCIA%TYPE;
       V_ORIGPROD  TGFITE.ORIGPROD%TYPE;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
       
/*******************************************************************************
TESTE
********************************************************************************/

    IF P_TIPOEVENTO = AFTER_UPDATE
         THEN

        SELECT CAB.TIPMOV
         INTO V_TIPMOV
        FROM TGFCAB CAB
        WHERE CAB.NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');  

    IF V_TIPMOV = 'C'
        THEN 
        
        SELECT   CODPROD 
                ,SEQUENCIA
                ,AD_ORIGPROD

            INTO  V_CODPROD
                 ,V_SEQUENCIA
                 ,V_ORIGPROD
         FROM TGFITE ITE 
        WHERE NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA')   
          AND SEQUENCIA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');  

         IF V_ORIGPROD IS NOT NULL
            THEN 
    
                UPDATE TGFITE 
                SET AD_ORIGPROD = V_ORIGPROD
                WHERE NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA')   
                  AND SEQUENCIA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');
     
         
                UPDATE TGFPRO 
                SET ORIGPROD = V_ORIGPROD
                WHERE CODPROD = V_CODPROD;
        
        
         END IF;
     END IF;
    END IF;
END;