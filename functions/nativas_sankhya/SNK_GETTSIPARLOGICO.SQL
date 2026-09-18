/*==============================================================================
  Nome do Script : SNK_GETTSIPARLOGICO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o valor logico (S/N) de um parametro de sistema (TSIPAR); retorna
                  'N' se o parametro nao existir.
  Assinatura     : SNK_GETTSIPARLOGICO (P_CHAVE IN VARCHAR2)
                   RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GETTSIPARLOGICO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GETTSIPARLOGICO (P_CHAVE IN VARCHAR2)
RETURN CHAR
IS
  strLogico VARCHAR2(1);
BEGIN
  SELECT LOGICO 
  INTO strLogico
  FROM TSIPAR
  WHERE CHAVE = p_CHAVE;
  RETURN ( strLogico );
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN ( 'N' );
END;

 
 
