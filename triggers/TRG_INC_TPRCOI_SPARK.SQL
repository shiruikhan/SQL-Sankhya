create or replace TRIGGER TRG_INC_TPRCOI_SPARK
  BEFORE INSERT OR UPDATE OR DELETE ON TPRCOI
  FOR EACH ROW
  FOLLOWS TRG_TPRCOI_REPLICA_PA
/*==============================================================================
  Nome do Script : TRG_INC_TPRCOI_SPARK
  Tipo           : Trigger
  Descrição      : Valida duplicidade de conferência impedindo mesma série em múltiplos apontamentos
  Tabela         : TPRCOI
  Evento         : BEFORE INSERT OR UPDATE OR DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Setembro/2026 — Performance: removida a PRAGMA
                   AUTONOMOUS_TRANSACTION, que não tinha função (não há
                   COMMIT/ROLLBACK no corpo — só um SELECT de validação) e
                   apenas gerava overhead de abrir/fechar uma transação
                   separada a cada bipagem. Efeito colateral positivo: a
                   validação de duplicidade passa a enxergar também os registros
                   de AD_TPRCOI ainda não commitados na mesma transação (a
                   autonomous transaction os ignorava), tornando o bloqueio de
                   série duplicada mais rígido, nunca mais permissivo — nenhuma
                   funcionalidade existente é perdida.
                   Julho/2026 — Adicionado FOLLOWS TRG_TPRCOI_REPLICA_PA para
                   garantir que essa trigger rode depois da réplica de
                   CONTROLEPA/CODPRODPA (ORA-25025 impede usar PRECEDES na
                   trigger de réplica, então a ordenação foi movida para cá).
==============================================================================*/
DECLARE
P_COUNT  INT;
P_IDIATV TPRIATV.IDIATV%TYPE;
BEGIN

SELECT COUNT(*), MAX(ATV.IDIATV) INTO P_COUNT, P_IDIATV  FROM TPRIATV ATV INNER JOIN TPRCONF CON ON (ATV.IDIATV = CON.IDIATV)
INNER JOIN  AD_TPRCOI COI ON (COI.NUCONF = CON.NUCONF)
  WHERE COI.CODBARRA = :NEW.CODBARRA;



    IF P_COUNT > 0 THEN

    RAISE_APPLICATION_ERROR(-20191,
                    FC_FORMATAHTML('Ação não permitida!',
                        'Série já foi Conferida em outro Apontamento!',
                        'Nro Plano:'||:NEW.CODBARRA ||CHR(10) ||
                        'ID. Atividade:' || P_IDIATV )); 
    END IF;


END;