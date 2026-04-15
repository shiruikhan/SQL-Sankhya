create or replace TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCAB_PROD_SPARK"
BEFORE INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : UNKNOWN
  Tipo           : Trigger
  Descrição      : Define local destino e número PS baseado em atividade vinculada à ordem de produção
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
	P_COUNT  INT;
	P_CODLOCALORIG TGFITE.CODLOCALORIG%TYPE;
	P_LOCAL        TGFLOC.DESCRLOCAL%TYPE;
	P_NUMPS        TPRIPROC.NUMPS%TYPE;
    P_CODTIPOPER   TGFCAB.CODTIPOPER%TYPE;
BEGIN
    P_CODTIPOPER := :NEW.CODTIPOPER;
	BEGIN
		SELECT EST.CODLOCALBAIXAMP INTO P_CODLOCALORIG
		FROM TPRROPE OPE 
            INNER JOIN TPROEST EST ON (OPE.IDEFX = EST.IDEFX)
		WHERE NUNOTA = :NEW.NUNOTA
			AND EST.TIPOITENS = 'PA';
		EXCEPTION WHEN NO_DATA_FOUND THEN P_CODLOCALORIG := 0;
	END UNKNOWN;
	
	/*INSERE O LOCAL DESTINO PARA FATURAR O PEDIDO REQUISIÇÃO, BASEADO NA ATIVIDADE QUE REALIZOU O APONTAMENTO */
	IF :NEW.IDIPROC > 0 AND P_CODLOCALORIG > 0 AND P_CODTIPOPER <> 718 THEN
		SELECT DESCRLOCAL INTO P_LOCAL 
		FROM TGFLOC 
		WHERE CODLOCAL = P_CODLOCALORIG;
		
		:NEW.AD_CODLOCALDEST := P_CODLOCALORIG;
		:NEW.OBSERVACAO := 'Local Destino: ' || P_CODLOCALORIG;
	END IF;
    
    IF P_CODTIPOPER = 718 THEN
        :NEW.AD_CODLOCALDEST := 101;
        :NEW.OBSERVACAO := 'Movimentação de armazenamento de produção';
    END IF;

    BEGIN
		SELECT NUMPS INTO P_NUMPS
		FROM TPRIPROC 
		WHERE IDIPROC = :NEW.IDIPROC;
		EXCEPTION WHEN NO_DATA_FOUND THEN P_NUMPS := 0;
	END;

	IF :NEW.IDIPROC > 0 AND NVL(:NEW.AD_NUMPS,0) = 0 THEN
		:NEW.AD_NUMPS := P_NUMPS;
	END IF;
END;