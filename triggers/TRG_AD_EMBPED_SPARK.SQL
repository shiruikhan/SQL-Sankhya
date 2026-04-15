create or replace TRIGGER TRG_AD_EMBPED_SPARK
BEFORE DELETE ON AD_EMBPED
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_AD_EMBPED_SPARK
  Tipo           : Trigger
  Descrição      : Atualiza QTDVOL e PESO em TGFCAB ao deletar embalagem.
                  Recalcula quantidade de volumes e peso total de forma autônoma.
  Tabela         : AD_EMBPED
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE 

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

                   UPDATE TGFCAB 
        SET QTDVOL = (
                SELECT COUNT(DISTINCT IDCAIXA)
                FROM AD_EMBPED 
                WHERE NUNOTA = :OLD.NUNOTA
                AND SEQ <> :OLD.SEQ),
           PESO = (                
SELECT SUM(PESOEMB) FROM(
SELECT 
COUNT(DISTINCT IDCAIXA)*SUM(DISTINCT PRO.PESOBRUTO) AS PESOEMB
                FROM AD_EMBPED EMB INNER JOIN TGFPRO PRO ON (EMB.CODPRODEMB = PRO.CODPROD)
                WHERE NUNOTA = :OLD.NUNOTA
                AND SEQ <> :OLD.SEQ
                GROUP BY CODPRODEMB
                UNION
SELECT SUM(EMB.PESOBRUTO) AS PESOEMB
                FROM AD_EMBPED EMB
                WHERE NUNOTA = :OLD.NUNOTA 
                AND SEQ <> :OLD.SEQ
                ))             
        WHERE NUNOTA = :OLD.NUNOTA ;
        
        COMMIT;

END TRG_AD_EMBPED_SPARK; 