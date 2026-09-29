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
                   Setembro/2026 — Performance: a checagem de existência em
                   TGFBAR só era usada quando AD_LIBEXPED = 'S' — movida para
                   dentro desse IF (condição puramente em memória, sem custo
                   de consulta), evitando 1 consulta em todo INSERT/UPDATE de
                   TPRSERPA que não é liberação para expedição. Também ganhou
                   ROWNUM = 1, já que o resultado só é comparado a 0.
                   Comportamento observável inalterado.
==============================================================================*/
DECLARE
P_COUNT     INT;
P_CODVOL    VARCHAR2(100);

BEGIN

    IF NVL(:NEW.AD_LIBEXPED,'N') = 'S' THEN /*11/02/22 - ALTERADO PARA INSERIR O CÓDIGO DE BARRAS QUANDO APONTAR ENTRADA DO PA */

       SELECT COUNT(*) INTO P_COUNT
         FROM TGFBAR
        WHERE CODBARRA = :NEW.SERIEPA
          AND CODPROD = :NEW.CODPRODPA
          AND ROWNUM = 1;

       IF P_COUNT = 0 THEN

       SELECT CODVOL INTO P_CODVOL
         FROM TGFPRO
        WHERE CODPROD = :NEW.CODPRODPA;

       INSERT INTO TGFBAR (CODBARRA, CODPROD, DHALTER, CODUSU, CODVOL)
       VALUES (:NEW.SERIEPA, :NEW.CODPRODPA, SYSDATE, STP_GET_CODUSULOGADO(), P_CODVOL);

       END IF;

    END IF;


END TRG_INC_TPRSERPA_SPARK2;
