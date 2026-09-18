/*==============================================================================
  Nome do Script : SNK_GET_DESCR_TIPFOLHA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a descricao textual do tipo de folha de pagamento (mensal, ferias,
                  rescisao etc.).
  Assinatura     : SNK_GET_DESCR_TIPFOLHA (TIPFOLHA IN CHAR)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_DESCR_TIPFOLHA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_DESCR_TIPFOLHA (TIPFOLHA IN CHAR) RETURN VARCHAR2 
AS 
	DESCR VARCHAR2(100);
BEGIN
	SELECT CASE
		    WHEN TIPFOLHA IS NULL
		    THEN 'Não especificada'
		    WHEN TIPFOLHA = 'N'
		    THEN 'Mensal'
		    WHEN TIPFOLHA = 'R'
		    THEN 'Rescisão'
		    WHEN TIPFOLHA = 'F'
		    THEN 'Férias'
		    WHEN TIPFOLHA = '1'
		    THEN 'Férias 1'
		    WHEN TIPFOLHA = '2'
		    THEN 'Férias 2'
		    WHEN TIPFOLHA = 'D'
		    THEN 'Décimo Terceiro'
		    WHEN TIPFOLHA = 'S'
		    THEN 'Semanal'
		    WHEN TIPFOLHA = 'A'
		    THEN 'Adiamento'
		    WHEN TIPFOLHA = 'P'
		    THEN 'Pensionista'
		    WHEN TIPFOLHA = 'L'
		    THEN 'Rescisão Parcial'
		    WHEN TIPFOLHA = 'C'
		    THEN 'Rescisão Complementar'
		    WHEN TIPFOLHA = 'X'
		    THEN 'Incorporação'
		    WHEN TIPFOLHA = 'O'
		    THEN 'Folha Complementar (Mensal, Férias e Décimo Terceiro)'
		    WHEN TIPFOLHA = 'U'
		    THEN 'Folha de Participação nos Lucros'
		    WHEN TIPFOLHA = 'T'
		    THEN 'Folha Autônomo'
		END 
		INTO DESCR 
		FROM DUAL;
	RETURN DESCR;
END;
