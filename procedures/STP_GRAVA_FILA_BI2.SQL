create or replace PROCEDURE STP_GRAVA_FILA_BI2(
	P_CODFILA  IN TMDFMG.CODFILA%TYPE,
	P_ASSUNTO  IN TMDFMG.ASSUNTO%TYPE,
	P_MENSAGEM IN TMDFMG.MENSAGEM%TYPE,
	P_EMAIL    IN TMDFMG.EMAIL%TYPE,
	P_CODSMTP  IN TMDFMG.EMAIL%TYPE) AS
    /*********************************************
    Publicada por: Lucas Gabriel DM TECH
    Data: 01/12/2023
    Objetivo: Grava Fila de Mensagens
    **********************************************/
 
BEGIN
	IF P_EMAIL IS NULL THEN
		RETURN;
	END IF; 
	INSERT INTO TMDFMG (CODFILA, ASSUNTO, DTENTRADA, STATUS, CODCON, TENTENVIO, MENSAGEM, TIPOENVIO, MAXTENTENVIO, EMAIL, MIMETYPE, CODUSU, CODSMTP) 
		VALUES ( P_CODFILA           -- CODFILA
			, P_ASSUNTO           -- ASSUNTO
			, SYSDATE             -- DTENTRADA
			, 'Pendente'          -- STATUS
			, 0                   -- CODCON
			, 1                   -- TENTENVIO
			, P_MENSAGEM          -- MENSAGEM
			, 'E'                 -- TIPOENVIO
			, 3                   -- MAXTENTENVIO
			, P_EMAIL             -- EMAIL 
			--, 'text/html'       -- MIMETYPE 
			, null        		 -- MIMETYPE 
			, 0                   -- CODUSU 
			, P_CODSMTP);
END;