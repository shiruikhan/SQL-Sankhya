create or replace TRIGGER TRG_INC_UPD_TGFCAB_PREVENT 
BEFORE INSERT OR UPDATE ON TGFCAB 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFCAB_PREVENT
  Tipo           : Trigger
  Descrição      : Popula tabela de entregas (TGFDTP) com previsões de entrega para pedidos de compra
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Setembro/2026 — Performance: as verificações de TOP de pedido
                   de compra e de entregas já lançadas passaram a rodar somente
                   quando STATUSNOTA = 'L' (única situação em que o INSERT final
                   ocorre), e a segunda verificação só roda se a primeira já
                   confirmar TOP de compra — evita os dois SELECTs em praticamente
                   toda gravação de TGFCAB, que é a tabela de maior volume do ERP.
                   Comportamento observável inalterado.
==============================================================================*/
DECLARE
	P_CODTIPOPER NUMBER;
	P_VERIFICA VARCHAR2(1);
	P_DTPREVENT DATE;
	P_NUNOTA NUMBER;
	P_NOENT VARCHAR2(1);
	P_STATUSNOTA VARCHAR2(1);

	/*TEMPORÁRIAS PARA VERIFICAÇÃO*/
	v_temp NUMBER;
	v_temp2 NUMBER;

BEGIN
	/*PREENCHE VARIAVEIS COM O CABEÇALHO ATUAL*/
	P_NUNOTA := :NEW.NUNOTA;
	P_DTPREVENT := :NEW.DTPREVENT;
	P_CODTIPOPER := :NEW.CODTIPOPER;
	P_STATUSNOTA := :NEW.STATUSNOTA;

	P_VERIFICA := 'N';
	P_NOENT := 'S';

	/*AS DUAS VERIFICAÇÕES E O INSERT SÓ SÃO RELEVANTES QUANDO A NOTA ESTÁ LIBERADA*/
	IF P_STATUSNOTA = 'L' THEN
		BEGIN /*VERIFICA SE É TOP DE PEDIDO DE COMPRA*/
			SELECT CODTIPOPER INTO v_temp
	        FROM TGFTOP
	        WHERE CODTIPOPER = P_CODTIPOPER
				AND GRUPO = 'Pedido Compra'
				AND ROWNUM = 1;

	        P_VERIFICA := 'S';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN NULL;
	    END;

		IF P_VERIFICA = 'S' THEN
			BEGIN /*VERIFICA SE JÁ HOUVE ENTREGAS*/
				SELECT NUNOTA INTO v_temp2
		        FROM TGFDTP
		        WHERE NUNOTA = P_NUNOTA
					AND ROWNUM = 1;

		        P_NOENT := 'N';
			EXCEPTION
				WHEN NO_DATA_FOUND THEN NULL;
		    END;
		END IF;
	END IF;

	/*POPULA A TABELA DE ENTREGAS COM AS PREVISÕES*/
	IF P_VERIFICA = 'S' AND P_NOENT = 'S' AND P_STATUSNOTA = 'L' THEN
		INSERT INTO TGFDTP (NUNOTA, SEQUENCIA, SEQPREV, DTPREV, QTD, QTDENTREGUE, CODUSU, DTALTER)
			SELECT P_NUNOTA, I.SEQUENCIA, 1, P_DTPREVENT, I.QTDNEG, 0, I.CODUSU, '01/01/2021' FROM TGFITE I WHERE I.NUNOTA = P_NUNOTA;
	END IF;

END;