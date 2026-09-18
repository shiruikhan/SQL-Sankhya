/*==============================================================================
  Nome do Script : SNK_ANONIMIZA_DADOS_DATE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Anonimiza um valor DATE conforme mascara (DAY/MONTH/YEAR/HIDE/TOTAL) para
                  exportacao de dados sensiveis (LGPD).
  Assinatura     : SNK_ANONIMIZA_DADOS_DATE (CAMPO IN DATE, MASCARA IN VARCHAR)
                   RETURN DATE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_ANONIMIZA_DADOS_DATE', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_ANONIMIZA_DADOS_DATE (CAMPO IN DATE, MASCARA IN VARCHAR)  
   RETURN DATE 
   IS CAMPO_ANONIMIZADO DATE;
   BEGIN 
		IF CAMPO IS NOT NULL THEN
	 		CASE MASCARA
			WHEN 'DAY' THEN
				 /* ###### DIA (p. ex.: 26/05/2020 -> 01/05/2020) */
				CAMPO_ANONIMIZADO := '01' || '-' || LPAD(EXTRACT(MONTH FROM CAMPO),2,'0') || '-' ||	EXTRACT(YEAR FROM CAMPO);
			WHEN 'MONTH' THEN
				/* ###### MES (p. ex.: 26/05/2020 -> 26/01/2020) */
				CAMPO_ANONIMIZADO := LPAD(EXTRACT(DAY FROM CAMPO),2,'0') || '-' || '01' || '-' || EXTRACT(YEAR FROM CAMPO);				
			WHEN 'YEAR' THEN	 			
				/* ###### ANO (p. ex.: 26/05/2020 -> 26/05/1904) */
				CAMPO_ANONIMIZADO := LPAD(EXTRACT(DAY FROM CAMPO),2,'0') || '-' || LPAD(EXTRACT(MONTH FROM CAMPO),2,'0') || '-' || '1904';
			WHEN 'HIDE' THEN
				CAMPO_ANONIMIZADO := NULL;
			WHEN 'TOTAL' THEN
				CAMPO_ANONIMIZADO := '01' || '-' || '01' || '-' || '1900';	
			ELSE
				/* DEFAULT ANO (p. ex.: 26/05/2020 -> 26/05/1904) */
				CAMPO_ANONIMIZADO := LPAD(EXTRACT(DAY FROM CAMPO),2,'0') || '-' || LPAD(EXTRACT(MONTH FROM CAMPO),2,'0') || '-' || '1904';
			END CASE;
		ELSE
			CAMPO_ANONIMIZADO := NULL;
		END IF;
      RETURN(CAMPO_ANONIMIZADO); 
    END;
