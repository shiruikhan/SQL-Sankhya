/*==============================================================================
  Nome do Script : PDES
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o primeiro valor de um campo/tabela/filtro
                  informados como texto (SELECT dinamico, transacao autonoma).
  Assinatura     : PDES (P_CAMPO IN VARCHAR2, P_TABELA IN VARCHAR2, P_FILTRO IN
                  VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'PDES', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION PDES (P_CAMPO IN VARCHAR2, P_TABELA IN VARCHAR2, P_FILTRO IN VARCHAR2 DEFAULT NULL) 
RETURN VARCHAR2 
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  SAIDA VARCHAR2(4000);
  P_SELECT VARCHAR2(4000);
  TYPE DINCURSOR IS REF CURSOR;
  ORIGEM DINCURSOR;
BEGIN
  P_SELECT := 'SELECT ' || P_CAMPO || ' FROM ' || P_TABELA;
  IF P_FILTRO IS NOT NULL THEN
    P_SELECT := P_SELECT || ' WHERE ' || P_FILTRO;
  END IF;
  
  SAIDA := NULL; 
  OPEN ORIGEM FOR P_SELECT;
  FETCH ORIGEM INTO SAIDA;
  CLOSE ORIGEM;
  RETURN SAIDA;
END;
