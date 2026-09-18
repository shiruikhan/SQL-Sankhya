/*==============================================================================
  Nome do Script : SNK_GET_VAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a lista (CSV) de notas vinculadas (TGFVAR) a uma nota de origem.
  Assinatura     : SNK_GET_VAR (P_NUNOTA NUMBER)
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_VAR', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_VAR (P_NUNOTA NUMBER)
RETURN VARCHAR
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
P_RETURN VARCHAR(4000) := '';
BEGIN
	FOR linha IN (SELECT NUNOTA FROM TGFVAR WHERE NUNOTAORIG = P_NUNOTA)
	LOOP
		P_RETURN := P_RETURN || linha.NUNOTA || ',';
	END LOOP;
IF LENGTH(P_RETURN) = 0 THEN
	RETURN NULL;
END IF;

RETURN SUBSTR(P_RETURN,0,LENGTH(P_RETURN)-1);
END;
