CREATE OR REPLACE TRIGGER TRG_TPRCOI_REPLICA_PA
BEFORE INSERT OR UPDATE ON TPRCOI
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TPRCOI_REPLICA_PA
  Tipo           : Trigger
  Descrição      : Replica CODBARRA e CODPROD para as colunas CONTROLEPA e
                   CODPRODPA da própria linha, mantendo o padrão de
                   rastreamento de produto acabado (*PA) usado pelas demais
                   tabelas do módulo de produção (TPRSERPA, TPRLPI, etc.).
  Tabela         : TPRCOI
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : TPRCOI -- alterada via :NEW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — TRG_INC_TPRCOI_SPARK e TRG_INC_TPRCOI_SPARK2
                   passaram a usar FOLLOWS TRG_TPRCOI_REPLICA_PA para garantir
                   que esta trigger rode primeiro (Oracle não permite PRECEDES
                   em trigger comum — ORA-25025 — só FOLLOWS é aceito, então a
                   ordenação foi movida para as triggers que devem rodar depois).

  Observações    : - Trigger puramente atribuidora; não faz SELECT nem DML.
==============================================================================*/
BEGIN
    :NEW.CONTROLEPA := :NEW.CODBARRA;
    :NEW.CODPRODPA  := :NEW.CODPROD;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20192,
            'TRG_TPRCOI_REPLICA_PA - Erro ao replicar CODBARRA/CODPROD para CONTROLEPA/CODPRODPA. CODBARRA: '
            || :NEW.CODBARRA || ' - ' || SQLERRM);
END TRG_TPRCOI_REPLICA_PA;
