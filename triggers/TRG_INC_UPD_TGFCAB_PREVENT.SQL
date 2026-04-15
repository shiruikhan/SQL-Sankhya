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
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
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
	
	BEGIN /*VERIFICA SE É TOP DE PEDIDO DE COMPRA*/
		SELECT DISTINCT CODTIPOPER INTO v_temp
        FROM TGFTOP
        WHERE CODTIPOPER = P_CODTIPOPER
			AND GRUPO = 'Pedido Compra';
			
        P_VERIFICA := 'S';
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN NULL;
    END TRG_INC_UPD_TGFCAB_PREVENT;
	
	BEGIN /*VERIFICA SE JÁ HOUVE ENTREGAS*/
		SELECT DISTINCT NUNOTA INTO v_temp2
        FROM TGFDTP
        WHERE NUNOTA = P_NUNOTA;
			
        P_NOENT := 'N';
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN NULL;
    END;
	
	/*POPULA A TABELA DE ENTREGAS COM AS PREVISÕES*/
	IF P_VERIFICA = 'S' AND P_NOENT = 'S' AND P_STATUSNOTA = 'L' THEN
		INSERT INTO TGFDTP (NUNOTA, SEQUENCIA, SEQPREV, DTPREV, QTD, QTDENTREGUE, CODUSU, DTALTER)
			SELECT P_NUNOTA, I.SEQUENCIA, 1, P_DTPREVENT, I.QTDNEG, 0, I.CODUSU, '01/01/2021' FROM TGFITE I WHERE I.NUNOTA = P_NUNOTA;
	END IF;
    
END;