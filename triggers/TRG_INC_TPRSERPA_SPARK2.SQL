create or replace TRIGGER TRG_INC_TPRSERPA_SPARK2
BEFORE INSERT OR UPDATE ON TPRSERPA 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TPRSERPA_SPARK2
  Tipo           : Trigger
  Descrição      : Insere código de barras em tabela de códigos quando apontamento de PA é liberado para expedição
  Tabela         : TPRSERPA
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 
P_COUNT     INT;
P_CODVOL    VARCHAR2(100);

BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM TGFBAR
     WHERE CODBARRA = :NEW.SERIEPA
       AND CODPROD = :NEW.CODPRODPA;
       
       IF P_COUNT = 0 AND NVL(:NEW.AD_LIBEXPED,'N') = 'S' THEN /*11/02/22 - ALTERADO PARA INSERIR O CÓDIGO DE BARRAS QUANDO APONTAR ENTRADA DO PA */
       
       SELECT CODVOL INTO P_CODVOL
         FROM TGFPRO 
        WHERE CODPROD = :NEW.CODPRODPA;
       
       INSERT INTO TGFBAR (CODBARRA, CODPROD, DHALTER, CODUSU, CODVOL)
       VALUES (:NEW.SERIEPA, :NEW.CODPRODPA, SYSDATE, STP_GET_CODUSULOGADO(), P_CODVOL);
       
       END IF;
  

END TRG_INC_TPRSERPA_SPARK2; 