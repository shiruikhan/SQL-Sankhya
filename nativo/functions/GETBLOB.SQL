/*==============================================================================
  Nome do Script : GETBLOB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Converte um BLOB em CLOB (leitura em blocos de 32767 bytes).
  Assinatura     : GETBLOB (B BLOB) RETURN CLOB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GETBLOB', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GETBLOB (B BLOB)
RETURN CLOB IS
  c CLOB;
  n NUMBER;
BEGIN
  IF (b IS NULL) THEN
    RETURN NULL;
  END IF;
  IF (DBMS_LOB.GETLENGTH(b)=0) THEN
    RETURN EMPTY_CLOB();
  END IF;
  dbms_lob.createtemporary(c,TRUE);
  n:=1;
  WHILE (n+32767<=DBMS_LOB.GETLENGTH(b)) LOOP
    dbms_lob.writeappend(c,32767,utl_raw.cast_to_varchar2(dbms_lob.SUBSTR(b,32767,n)));
    n:=n+32767;
  END LOOP;
  dbms_lob.writeappend(c,DBMS_LOB.GETLENGTH(b)-n+1,utl_raw.cast_to_varchar2(dbms_lob.SUBSTR(b,DBMS_LOB.GETLENGTH(b)-n+1,n)));
  RETURN c;
END;
