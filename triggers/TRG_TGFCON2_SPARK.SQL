create or replace TRIGGER "SPARKPRD"."TRG_TGFCON2_SPARK"
BEFORE INSERT OR UPDATE ON TGFCON2
FOR EACH ROW
WHEN (NEW.STATUS = 'F' AND OLD.STATUS <> NEW.STATUS)
/*==============================================================================
  Nome do Script : TRG_TGFCON2_SPARK
  Tipo           : Trigger
  Descrição      : Insere série em TGFSER ao finalizar conferência
  Tabela         : TGFCON2
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: adicionada cláusula WHEN
                   idêntica ao único IF do corpo (em INSERT, OLD.STATUS é
                   NULL e a comparação já era sempre falsa antes, então o
                   comportamento no INSERT não muda); checagem de existência
                   (SELECT COUNT(*)) ganhou ROWNUM = 1; corrigido END sem
                   rótulo válido (END UNKNOWN;). Comportamento observável
                   inalterado.
==============================================================================*/
DECLARE
P_COUNT      INT;

BEGIN

    SELECT COUNT(*) INTO P_COUNT
      FROM TGFSER
    WHERE NUNOTA = :NEW.NUNOTAORIG
      AND ROWNUM = 1;

        IF P_COUNT = 0 THEN

        INSERT INTO TGFSER ( NUNOTA, CODPROD , SEQUENCIA, SERIE, ATUALESTOQUE, TIPCONTEST, CODUSU, DTALTER)
        (SELECT :NEW.NUNOTAORIG, S.CODPROD, (SELECT MAX(SEQUENCIA) FROM TGFITE WHERE NUNOTA = :NEW.NUNOTAORIG AND CODPROD = S.CODPROD), S.CODBARRA, 0, 'N', STP_GET_CODUSULOGADO(), SYSDATE
           FROM TGFCOI2 S
         WHERE NUCONF = :NEW.NUCONF);

        END IF;

END;
