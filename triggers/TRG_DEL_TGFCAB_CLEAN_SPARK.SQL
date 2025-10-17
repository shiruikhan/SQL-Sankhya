create or replace TRIGGER TRG_DEL_TGFCAB_CLEAN_SPARK
BEFORE DELETE ON TGFCAB
FOR EACH ROW
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
END;