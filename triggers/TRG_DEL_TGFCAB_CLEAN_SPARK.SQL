create or replace TRIGGER TRG_DEL_TGFCAB_CLEAN_SPARK
BEFORE DELETE ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_DEL_TGFCAB_CLEAN_SPARK
  Tipo           : Trigger
  Descrição      : Limpa registros de frete ao deletar nota (cascata de delete).
                  Remove AD_TGSLCB (linhas de cálculo) e AD_TGSCTF (cotação).
  Tabela         : TGFCAB
  Evento         : BEFORE DELETE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
  -- Remover primeiro os registros filhos em AD_TGSLCB (dependem de AD_TGSCTF via NUCTF)
  DELETE FROM AD_TGSLCB
   WHERE NUCTF IN (
         SELECT DISTINCT NUCTF
           FROM AD_TGSCTF
          WHERE NUNOTA = :OLD.NUNOTA
   );

  -- Em seguida, remover os registros em AD_TGSCTF vinculados à nota
  DELETE FROM AD_TGSCTF
   WHERE NUNOTA = :OLD.NUNOTA;
END TRG_DEL_TGFCAB_CLEAN_SPARK;