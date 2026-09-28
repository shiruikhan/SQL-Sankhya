/* TRIGGER OBSOLETA / INATIVADA EM PRODUÇÃO (28/09/2026)
   Estava desativada (ALTER TRIGGER ... DISABLE) em produção antes da rodada de
   otimização de performance de Setembro/2026. O CREATE OR REPLACE TRIGGER
   feito durante a refatoração reativou-a silenciosamente, pois o Oracle
   sempre recria uma trigger como ENABLED independente do estado anterior no
   banco — esse estado não é visível no texto .sql versionado. Mantida aqui,
   comentada por completo, apenas como referência histórica. Ver
   triggers/README.md §15 e a memória "armadilhas-create-or-replace-trigger"
   para o caso completo. NÃO reativar sem confirmação explícita do
   responsável pelo ambiente de produção.

create or replace TRIGGER TRG_UPD_TGSLOGLIB_SPARK
BEFORE UPDATE ON TSILIB
FOR EACH ROW
==============================================================================
  Nome do Script : TRG_UPD_TGSLOGLIB_SPARK
  Tipo           : Trigger
  Descrição      : Registra log de liberação de crédito ao autorizar nota
                   fiscal de venda
  Tabela         : TSILIB
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 04/2025
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Setembro/2026 — Performance: as duas consultas a TGFCAB pelo
                   mesmo NUNOTA (CODPARC e VLRNOTA+VLROUTROS+AD_VLROUTROSFRETE)
                   foram unificadas em um único SELECT, eliminando uma leitura
                   redundante à tabela; e a checagem de existência em TGSLOGLIB
                   ganhou ROWNUM = 1, já que o resultado só é comparado a 0/1.
                   Comportamento observável inalterado (mesmo resultado quando
                   a nota existe; mesma falha por NO_DATA_FOUND quando não).
==============================================================================
WHEN (NEW.DHLIB IS NOT NULL AND NEW.EVENTO = 3)
DECLARE
    V_VLRTOTFIN TGFFIN.VLRDESDOB%TYPE;
    V_VLRTOTPED TGFCAB.VLRNOTA%TYPE;
    V_CODPARC TGFPAR.CODPARC%TYPE;
    V_CODPARCMATRIZ TGFPAR.CODPARCMATRIZ%TYPE;
    V_EXISTE NUMBER;
BEGIN

    IF STP_GET_ATUALIZANDO() THEN
        RETURN;
    END IF;

    SELECT C.CODPARC
          ,(C.VLRNOTA + NVL(C.VLROUTROS,0) + NVL(C.AD_VLROUTROSFRETE,0))
      INTO V_CODPARC
          ,V_VLRTOTPED
      FROM TGFCAB C
     WHERE C.NUNOTA = :NEW.NUCHAVE;

    BEGIN
        SELECT P.CODPARCMATRIZ INTO V_CODPARCMATRIZ
        FROM TGFPAR P
        WHERE P.CODPARC = V_CODPARC;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CODPARCMATRIZ := 0;
    END;

    BEGIN
        SELECT SUM(VLRDESDOB) INTO V_VLRTOTFIN
        FROM TGFFIN
        WHERE CODPARC = V_CODPARC
            AND RECDESP = 1
            AND PROVISAO = 'N'
            AND DHBAIXA IS NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_VLRTOTFIN := 0;
    END;

   SELECT COUNT(0) INTO V_EXISTE
    FROM TGSLOGLIB
    WHERE NUNOTA = :NEW.NUCHAVE AND DHLIB = :NEW.DHLIB AND ROWNUM = 1;

    IF V_EXISTE = 0 THEN
        INSERT INTO TGSLOGLIB (NUNOTA, DHLIB, CODUSULIB, VLRLIBERADO, VLRTOTPED, OBSLIB, VLRLIMITE, VLRTOTFIN, CODPARC, CODPARCMATRIZ)
        VALUES (:NEW.NUCHAVE, :NEW.DHLIB, :NEW.CODUSULIB, :NEW.VLRLIBERADO, V_VLRTOTPED, :NEW.OBSLIB, :NEW.VLRLIMITE, V_VLRTOTFIN, V_CODPARC, V_CODPARCMATRIZ);
    END IF;
END;
*/
