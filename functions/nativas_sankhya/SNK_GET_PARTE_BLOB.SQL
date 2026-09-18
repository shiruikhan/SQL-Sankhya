/*==============================================================================
  Nome do Script : SNK_GET_PARTE_BLOB
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna um trecho (substring) de um BLOB a partir de uma posicao e tamanho
                  informados.
  Assinatura     : SNK_GET_PARTE_BLOB (P_BLOB BLOB, P_INI INT, P_PARTE INT)
                   RETURN BLOB
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_PARTE_BLOB', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_PARTE_BLOB (P_BLOB BLOB, P_INI INT, P_PARTE INT)
RETURN BLOB IS
  RESULT BLOB;
  P_PART BLOB;  
BEGIN
  IF (P_BLOB IS NULL) THEN
    RETURN NULL;
  END IF;
  
  IF (DBMS_LOB.GETLENGTH(P_BLOB)=0) THEN
    RETURN NULL;
  END IF;
  
  DBMS_LOB.CREATETEMPORARY(RESULT,TRUE);    
  
  RESULT := DBMS_LOB.SUBSTR(P_BLOB,P_PARTE, P_INI);
  
  RETURN RESULT;
END;

 
 
