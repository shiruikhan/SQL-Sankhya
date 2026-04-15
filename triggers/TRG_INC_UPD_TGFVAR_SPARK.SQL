create or replace TRIGGER TRG_INC_UPD_TGFVAR_SPARK
BEFORE UPDATE OR INSERT ON TGFVAR
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFVAR_SPARK
  Tipo           : Trigger
  Descrição      : Atualiza custos adicionais de complementos em variações de pedido de compra
  Tabela         : TGFVAR
  Evento         : BEFORE UPDATE OR INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
WHEN (
(NEW.SEQUENCIA <> 0) AND (NEW.SEQUENCIAORIG <> 0) AND (NEW.QTDATENDIDA <> 0)
      )
DECLARE
P_TIPMOV          VARCHAR2(10);
P_VLRCHEIO                   FLOAT;

BEGIN

    SELECT TIPMOV INTO P_TIPMOV
       FROM TGFCAB
     WHERE NUNOTA = :NEW.NUNOTA;

     IF P_TIPMOV = 'C' THEN 

        SELECT AD_VLRCHEIOCOM INTO P_VLRCHEIO
          FROM TGFITE
        WHERE NUNOTA = :NEW.NUNOTAORIG
           AND SEQUENCIA = :NEW.SEQUENCIAORIG; 

           IF P_VLRCHEIO > 0 THEN 

           UPDATE TGFITE SET AD_VLRCHEIOCOM = P_VLRCHEIO, AD_VLROUTROSCOMP = (P_VLRCHEIO - VLRUNIT) * QTDNEG
           WHERE NUNOTA = :NEW.NUNOTA
              AND SEQUENCIA = :NEW.SEQUENCIA; 

           UPDATE TGFCAB SET VLROUTROS = (SELECT SUM(AD_VLROUTROSCOMP) FROM TGFITE WHERE NUNOTA = :NEW.NUNOTA)
           WHERE NUNOTA = :NEW.NUNOTA;

           END IF;

     END IF;

END TRG_INC_UPD_TGFVAR_SPARK; 