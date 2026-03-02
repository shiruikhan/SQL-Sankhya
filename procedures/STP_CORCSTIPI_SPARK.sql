create or replace PROCEDURE "STP_CORCSTIPI_SPARK" (
													P_CODUSU NUMBER,       
													P_IDSESSAO VARCHAR2,    
													P_QTDLINHAS NUMBER,   
													P_MENSAGEM OUT VARCHAR2 
) AS
       PARAM_P_CSTIPI VARCHAR2(4000);
       PARAM_P_CODENQENT NUMBER;
       PARAM_P_CODENQSAI NUMBER;
       FIELD_NUNOTA NUMBER;
       FIELD_SEQUENCIA NUMBER;
	   V_CODCFO TGFITE.CODCFO%TYPE;
/*******************************************************************
Autor:Lucas Gabriel 
Data: 23/04/2025
Objetivo: Corrigir a CST de IPI caso aconteça de realizar uma venda 
e no fechamento identificar que a CST ficou errada, como a nota esta
aprovada não da para fazer de forma manual.
*******************************************************************/
BEGIN
       PARAM_P_CSTIPI    := ACT_TXT_PARAM(P_IDSESSAO, 'P_CSTIPI');
       PARAM_P_CODENQENT := ACT_INT_PARAM(P_IDSESSAO, 'P_CODENQENT');
       PARAM_P_CODENQSAI := ACT_INT_PARAM(P_IDSESSAO, 'P_CODENQSAI');

       FOR I IN 1..P_QTDLINHAS 
       LOOP                   

        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
        FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');       
		IF PARAM_P_CSTIPI = 5
			AND PARAM_P_CODENQENT IS NULL 
		THEN 
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a Alteração!',
                        'A CST do IPI é suspensão não consta informado o Código Enq. Legal IPI Entrada.',
                        'Favor preencher o campo Código Enq. Legal IPI Entrada e tente novamente!'
                    ));		
		END IF;


		IF PARAM_P_CSTIPI = 55
			AND PARAM_P_CODENQSAI IS NULL  -- ajsutei aqui
		THEN 
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a Alteração!',
                        'A CST do IPI é suspensão não consta informado o Código Enq. Legal IPI Saida.',
                        'Favor preencher o campo Código Enq. Legal IPI Saida e tente novamente!'
                    ));		
		END IF;
		SELECT CODCFO 
			INTO V_CODCFO
		FROM TGFITE 
		WHERE NUNOTA = FIELD_NUNOTA
		 AND SEQUENCIA = FIELD_SEQUENCIA;

		IF PARAM_P_CSTIPI < 50 
			AND V_CODCFO > 3999
			AND PARAM_P_CSTIPI <> -1 -- asjustei aqui deu ruim -1 e usado na saida e na entrada
		THEN 
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a Alteração!',
                        'A CST do IPI é de entrada e o CFOP refere-se ao de saida',
                        'Favor preencher o campo de CST do IPI de forma correta!'
                    ));			
		END IF;


		IF PARAM_P_CSTIPI >= 50
			AND V_CODCFO < 3999
			AND PARAM_P_CSTIPI <> -1 -- asjustei aqui deu ruim -1 e usado na saida e na entrada
		THEN 
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a Alteração!',
                        'A CST do IPI é de Saída e o CFOP refere-se ao de Entrada',
                        'Favor preencher o campo de CST do IPI de forma correta!'
                    ));			
		END IF;

		IF PARAM_P_CODENQENT IS NOT NULL 
		THEN 
			UPDATE TGFITE
				SET CODENQIPI = PARAM_P_CODENQENT 
			WHERE NUNOTA = FIELD_NUNOTA
		      AND SEQUENCIA = FIELD_SEQUENCIA;
		END IF;

		IF PARAM_P_CODENQSAI IS NOT NULL 
		THEN 
			UPDATE TGFITE
				SET CODENQIPI = PARAM_P_CODENQSAI 
			WHERE NUNOTA = FIELD_NUNOTA
		      AND SEQUENCIA = FIELD_SEQUENCIA;
		END IF;
       END LOOP;

       UPDATE TGFITE 
			SET CSTIPI = PARAM_P_CSTIPI
		WHERE NUNOTA = FIELD_NUNOTA
		  AND SEQUENCIA = FIELD_SEQUENCIA;

	   P_MENSAGEM :='Alteração da CST do IPI realizada com sucesso';
END;