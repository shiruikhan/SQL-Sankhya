create or replace TRIGGER TRG_UPD_TGFCAB_DTFAT_SPARK
BEFORE INSERT OR UPDATE ON TGFCAB 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_DTFAT_SPARK
  Tipo           : Trigger
  Descrição      : Atualiza data de faturamento igual data da negociação
                   quando configurado na operação
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE

P_FATIGUALNEG             VARCHAR2(10);

BEGIN
      BEGIN
        SELECT NVL(AD_FATIGUALNEG,'N') INTO P_FATIGUALNEG
          FROM TGFTOP 
         WHERE CODTIPOPER = :NEW.CODTIPOPER
           AND DHALTER = :NEW.DHTIPOPER;

        EXCEPTION WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR (-20101, 'Cód. Operacao: ' || :NEW.CODTIPOPER || ' Data operacao: ' || :NEW.DHTIPOPER);      
      END TRG_UPD_TGFCAB_DTFAT_SPARK;

        IF P_FATIGUALNEG = 'S' THEN 

            :NEW.DTFATUR := :NEW.DTNEG;

        END IF;


END;