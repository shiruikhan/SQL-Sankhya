/*==============================================================================
  Nome do Script : SNK_REMOVE_ZEROS_DIREITA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Remove zeros e pontos a direita de um codigo de conta contabil.
  Assinatura     : SNK_REMOVE_ZEROS_DIREITA (CTACTB CHAR)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_REMOVE_ZEROS_DIREITA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_REMOVE_ZEROS_DIREITA (CTACTB CHAR)
RETURN CHAR
IS 
  P_CTACTB VARCHAR2(100);
  P_RESULT VARCHAR2(100);
BEGIN
  
  P_CTACTB := CTACTB;
  P_RESULT := CTACTB;
  
  WHILE (SUBSTR(P_CTACTB, LENGTH(P_CTACTB)) in ('0', '.')) LOOP
      P_CTACTB := SUBSTR(P_CTACTB, 0, LENGTH(P_CTACTB) -1);

      IF SUBSTR(P_CTACTB, LENGTH(P_CTACTB), LENGTH(P_CTACTB)) = '.' THEN
          P_RESULT := SUBSTR(P_CTACTB, 0, LENGTH(P_CTACTB) - 1);
      END IF;
  END LOOP;

  RETURN P_RESULT;
  
END;
