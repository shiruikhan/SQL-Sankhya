create or replace TRIGGER TRG_INC_TPRCOI_SPARK2
BEFORE INSERT ON TPRCOI
FOR EACH ROW
FOLLOWS TRG_TPRCOI_REPLICA_PA
/*==============================================================================
  Nome do Script : TRG_INC_TPRCOI_SPARK2
  Tipo           : Trigger
  Descrição      : Valida correspondência entre código de barras e lote de produção (14 ou 15 dígitos)
  Tabela         : TPRCOI
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Julho/2026 — Adicionado FOLLOWS TRG_TPRCOI_REPLICA_PA para
                   garantir que essa trigger rode depois da réplica de
                   CONTROLEPA/CODPRODPA (ORA-25025 impede usar PRECEDES na
                   trigger de réplica, então a ordenação foi movida para cá).
                   Setembro/2026 — Performance: as 3 consultas sequenciais
                   (TPRCONF -> TPRIATV -> TPRIPA, cada uma usando o MAX da
                   anterior como filtro) foram unificadas em um único SELECT
                   com subqueries aninhadas, eliminando 2 idas ao banco. P_
                   IDIATV/P_IDIPROC não eram usadas em mais nenhum lugar do
                   corpo. PRAGMA AUTONOMOUS_TRANSACTION comentada NÃO foi
                   tocada — mantida exatamente como estava.
==============================================================================*/
DECLARE
P_COUNT  INT;
P_LOTE         VARCHAR2(100);

--PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    SELECT MAX(NROLOTE) INTO P_LOTE
      FROM TPRIPA
     WHERE IDIPROC = (
        SELECT MAX(IDIPROC) FROM TPRIATV WHERE IDIATV = (
            SELECT MAX(IDIATV) FROM TPRCONF WHERE NUCONF = :NEW.NUCONF
        )
     );

     IF LENGTH(:NEW.CODBARRA) = 14 THEN
        IF SUBSTR(:NEW.CODBARRA, 3, 8) <> LTRIM(P_LOTE) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Esse Código de Barras não pertence a esse Lote!');
        END IF;
    ELSIF LENGTH(:NEW.CODBARRA) = 15 THEN
        IF SUBSTR(:NEW.CODBARRA, 3, 9) <> LTRIM(P_LOTE) THEN
            RAISE_APPLICATION_ERROR(-20101, 'Esse Código de Barras não pertence a esse Lote!');
        END IF;
    END IF;

END TRG_INC_TPRCOI_SPARK2;