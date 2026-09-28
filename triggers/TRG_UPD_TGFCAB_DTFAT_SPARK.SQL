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
  Data de Criação: 04/2025
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: avaliada a proposta de guardar
                   o SELECT a TGFTOP (que depende de :NEW.CODTIPOPER e
                   :NEW.DHTIPOPER) num IF "INSERTING OR coluna mudou", para
                   evitar reconsulta em UPDATEs que não alteram a operação.
                   NÃO aplicada: o efeito do bloco (:NEW.DTFATUR := :NEW.DTNEG)
                   também depende de :NEW.DTNEG, que pode mudar num UPDATE sem
                   que CODTIPOPER/DHTIPOPER mudem — nesse caso a guarda deixaria
                   de sincronizar DTFATUR com o novo DTNEG, alterando o
                   comportamento observável. Corrigido apenas o rótulo do END
                   do bloco interno (usava indevidamente o nome do trigger) para
                   "END;" — sem impacto funcional, comportamento observável
                   inalterado.
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
      END;

        IF P_FATIGUALNEG = 'S' THEN 

            :NEW.DTFATUR := :NEW.DTNEG;

        END IF;


END;