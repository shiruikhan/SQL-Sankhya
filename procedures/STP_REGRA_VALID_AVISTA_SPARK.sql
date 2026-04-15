create or replace PROCEDURE STP_REGRA_VALID_AVISTA_SPARK (P_NUNOTA INT, P_SUCESSO OUT VARCHAR, P_MENSAGEM OUT VARCHAR2, P_CODUSULIB OUT NUMERIC) IS
/*==============================================================================
  Nome do Script : STP_REGRA_VALID_AVISTA_SPARK
  Tipo           : Stored Procedure (Regra de Negócio)
  Descrição      : Procedure para validação de venda à vista. Verifica se títulos
                   vencidos no dia são recebimento à vista ou requerem confirmação.

  Parâmetros     : P_NUNOTA      — número único da nota fiscal
                   P_SUCESSO     — indicador de sucesso da regra (OUT)
                   P_MENSAGEM    — mensagem de retorno ao usuário (OUT)
                   P_CODUSULIB   — código do usuário liberador (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
	CURSOR c_DTVENC IS
        SELECT DTVENC, CODTIPTIT
        FROM TGFFIN
        WHERE NUNOTA = P_NUNOTA;

    v_DTVENC TGFFIN.DTVENC%TYPE;
    v_CODTIPTIT TGFFIN.CODTIPTIT%TYPE;
    v_valido BOOLEAN := TRUE;
BEGIN
	FOR rec IN c_DTVENC LOOP
        IF TRUNC(rec.DTVENC) = TRUNC(SYSDATE) AND rec.CODTIPTIT NOT IN (34,35,36) THEN 
            v_valido := FALSE;
            EXIT;
        END IF;
    END LOOP;
	
	IF v_valido THEN
        P_SUCESSO := 'S';
    ELSE
		P_MENSAGEM := 'É necessária confirmação do recebimento pelo financeiro';
        P_SUCESSO := 'N';
    END IF;
END STP_REGRA_VALID_AVISTA_SPARK;