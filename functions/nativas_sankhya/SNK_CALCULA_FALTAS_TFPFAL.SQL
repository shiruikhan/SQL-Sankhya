/*==============================================================================
  Nome do Script : SNK_CALCULA_FALTAS_TFPFAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Calcula o total de faltas de um funcionario no periodo, descontando
                  restituicoes (TFPFAL).
  Assinatura     : SNK_CALCULA_FALTAS_TFPFAL (P_CODEMP NUMBER, P_CODFUNC NUMBER, P_DTFINAQUI DATE, P_DTINIAQUI DATE)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_CALCULA_FALTAS_TFPFAL', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_CALCULA_FALTAS_TFPFAL (P_CODEMP NUMBER, P_CODFUNC NUMBER, P_DTFINAQUI DATE, P_DTINIAQUI DATE)
    RETURN NUMBER
	AS 
		P_FALTAS NUMBER;
		P_RESTITUICAO NUMBER;
		BEGIN
			SELECT COUNT(1) AS FALT INTO P_FALTAS
			FROM TFPFAL
			WHERE 
				CODEMP = P_CODEMP 
				AND CODFUNC = P_CODFUNC 
				AND DTFALTA <= P_DTFINAQUI 
				AND DTFALTA >= P_DTINIAQUI
				AND TIPREG = -1;
			
			SELECT COUNT(1) AS REST INTO P_RESTITUICAO
			FROM TFPFAL
			WHERE 
				CODEMP = P_CODEMP 
				AND CODFUNC = P_CODFUNC 
				AND DTFALTA <= P_DTFINAQUI 
				AND DTFALTA >= P_DTINIAQUI
				AND TIPREG = 1;

			RETURN P_FALTAS - P_RESTITUICAO;
		END;
