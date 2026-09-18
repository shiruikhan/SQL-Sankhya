/*==============================================================================
  Nome do Script : SNK_ANONIMIZA_DADOS_STRING
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Anonimiza uma string mascarando percentual do conteudo (40/50/70/80/100%,
                  CPF, HIDE).
  Assinatura     : SNK_ANONIMIZA_DADOS_STRING (CAMPO IN VARCHAR2, MASCARA IN VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_ANONIMIZA_DADOS_STRING', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_ANONIMIZA_DADOS_STRING (CAMPO IN VARCHAR2, MASCARA IN VARCHAR2)
   RETURN VARCHAR2
   IS
  	CAMPO_ANONIMIZADO VARCHAR2(4000);
	INICIO NUMBER(10);
	FIM NUMBER(10);
   BEGIN

		IF CAMPO IS NOT NULL THEN
	 		CASE MASCARA

			WHEN 'PROTECT_FORTY_PERCNT' THEN
				 /* ###### 40% (p. ex.: abc****xyz) */
				IF LENGTH(CAMPO) > 3 THEN
                    CAMPO_ANONIMIZADO := REPLACE(CAMPO, ' ', '');
                    INICIO := ROUND((30 * LENGTH(CAMPO_ANONIMIZADO) / 100),0);
                    FIM := ROUND((30 * LENGTH(CAMPO_ANONIMIZADO) / 100),0);
                    CAMPO_ANONIMIZADO := CONCAT(CONCAT(SUBSTR(CAMPO_ANONIMIZADO, 0, INICIO), '****'), SUBSTR(CAMPO_ANONIMIZADO, -FIM, FIM));
                ELSE
			        CAMPO_ANONIMIZADO := '**********';
		        END IF;

			WHEN 'PROTECT_FIFTY_PERCNT' THEN
				 /* ###### 50% (p. ex.: *****vwxyz) */
                IF LENGTH(CAMPO) > 1 THEN
                    CAMPO_ANONIMIZADO := REPLACE(CAMPO, ' ', '');
                    FIM := ROUND((50 * LENGTH(CAMPO_ANONIMIZADO) / 100),0);
                    CAMPO_ANONIMIZADO := CONCAT('*****',SUBSTR(CAMPO_ANONIMIZADO,-FIM,FIM));
				ELSE
			        CAMPO_ANONIMIZADO := '**********';
		        END IF;

			WHEN 'PROTECT_SEVENTY_PERCNT' THEN
				/* ###### 70% (p. ex.: abc*******) */
				IF LENGTH(CAMPO) > 3 THEN
                    CAMPO_ANONIMIZADO := REPLACE(CAMPO, ' ', '');
                    INICIO := ROUND((30 * LENGTH(CAMPO_ANONIMIZADO) / 100),0);
                    CAMPO_ANONIMIZADO := CONCAT(SUBSTR(CAMPO_ANONIMIZADO,0,INICIO),'*******');
		        ELSE
			        CAMPO_ANONIMIZADO := '**********';
		        END IF;

			WHEN 'PROTECT_EIGHTY_PERCNT' THEN
				 /* ###### 80% (p. ex.: ********yz) */
				IF LENGTH(CAMPO) > 4 THEN
                    CAMPO_ANONIMIZADO := REPLACE(CAMPO, ' ', '');
                    FIM := ROUND((20 * LENGTH(CAMPO_ANONIMIZADO) / 100),0);
                    CAMPO_ANONIMIZADO := CONCAT('********',SUBSTR(CAMPO_ANONIMIZADO,-FIM,FIM));
                ELSE
			        CAMPO_ANONIMIZADO := '**********';
		        END IF;

			WHEN 'CPF' THEN
				 /* ###### 80% (p. ex.: ********yz) */
                 CAMPO_ANONIMIZADO := '01000000001';

			WHEN 'TOTAL' THEN
				/* ###### 100% (p. ex.: **********) */
				CAMPO_ANONIMIZADO := '**********';

			WHEN 'HIDE' THEN
				CAMPO_ANONIMIZADO := NULL;

			END CASE;
		ELSE
			CAMPO_ANONIMIZADO := NULL;
		END IF;

      RETURN(CAMPO_ANONIMIZADO);

    END;
