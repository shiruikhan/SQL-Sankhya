/*==============================================================================
  Nome do Script : SNK_ANONIMIZA_DADOS_NUMBER
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Anonimiza um valor NUMBER (zera o valor) conforme mascara informada.
  Assinatura     : SNK_ANONIMIZA_DADOS_NUMBER (CAMPO IN NUMBER, MASCARA IN VARCHAR2)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_ANONIMIZA_DADOS_NUMBER', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_ANONIMIZA_DADOS_NUMBER (CAMPO IN NUMBER, MASCARA IN VARCHAR2)
   RETURN NUMBER
   IS
  	CAMPO_ANONIMIZADO VARCHAR2(4000);
   BEGIN
		IF CAMPO IS NOT NULL THEN
	 		CASE MASCARA
			WHEN 'NUMBER' THEN
				/* ###### NUMERO (p. ex.: 000000) */
			    CAMPO_ANONIMIZADO := 000000;
			END CASE;
		ELSE
			CAMPO_ANONIMIZADO := NULL;
		END IF;
      RETURN(CAMPO_ANONIMIZADO);
    END;
