create or replace PROCEDURE STP_GRAVA_FILA_BI2(
	P_CODFILA  IN TMDFMG.CODFILA%TYPE,
	P_ASSUNTO  IN TMDFMG.ASSUNTO%TYPE,
	P_MENSAGEM IN TMDFMG.MENSAGEM%TYPE,
	P_EMAIL    IN TMDFMG.EMAIL%TYPE,
	P_CODSMTP  IN TMDFMG.EMAIL%TYPE) AS
/*==============================================================================
  Nome do Script : STP_GRAVA_FILA_BI2
  Tipo           : Stored Procedure (Processamento de Dados)
  Descrição      : Insere mensagens de envio de email na fila de processamento
                   com status pendente, controlando tentativas de envio.

  Parâmetros     : P_CODFILA    — código da fila de mensagens
                   P_ASSUNTO    — assunto do email
                   P_MENSAGEM   — corpo da mensagem de email
                   P_EMAIL      — endereço de email de destino
                   P_CODSMTP    — configuração de servidor SMTP

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 01/12/2023 (Lucas Gabriel - DM TECH)
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
 
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