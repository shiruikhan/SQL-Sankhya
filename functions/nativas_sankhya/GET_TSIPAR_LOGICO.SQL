/*==============================================================================
  Nome do Script : GET_TSIPAR_LOGICO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o parametro de sistema logico S/N (TSIPAR.LOGICO,
                  CODUSU = 0) pela chave; 'N' se nao existir.
  Assinatura     : GET_TSIPAR_LOGICO (P_PARAMETRO IN VARCHAR) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_LOGICO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_LOGICO (P_PARAMETRO IN VARCHAR)
RETURN CHAR
IS
  V_LOGICO CHAR(1);
BEGIN
  BEGIN
    SELECT LOGICO INTO V_LOGICO FROM TSIPAR WHERE CHAVE = P_PARAMETRO AND CODUSU = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  V_LOGICO := 'N';
  END;
  RETURN V_LOGICO;
END;
