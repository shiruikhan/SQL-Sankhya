create or replace TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFCAB_PROD_SPARK"
BEFORE INSERT OR UPDATE ON TGFCAB
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFCAB_PROD_SPARK
  Tipo           : Trigger
  Descrição      : Define local destino e número PS baseado em atividade vinculada à ordem de produção
  Tabela         : TGFCAB
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Setembro/2026 — Performance: os dois SELECTs (TPRROPE/TPROEST
                   e TPRIPROC) só executam quando a nota está de fato vinculada a
                   processo de produção (IDIPROC > 0), evitando consultas
                   desnecessárias na imensa maioria das notas de TGFCAB, que não
                   são de produção. Comportamento observável inalterado.
==============================================================================*/
DECLARE
	P_CODLOCALORIG TGFITE.CODLOCALORIG%TYPE := 0;
	P_LOCAL        TGFLOC.DESCRLOCAL%TYPE;
	P_NUMPS        TPRIPROC.NUMPS%TYPE := 0;
    P_CODTIPOPER   TGFCAB.CODTIPOPER%TYPE;
BEGIN
    P_CODTIPOPER := :NEW.CODTIPOPER;

	---------------------------------------------------------------------------
	-- 1. Local de baixa da atividade — só é usado pelo bloco abaixo quando a
	--    nota é de produção (IDIPROC > 0) e não é movimentação de armazenamento
	---------------------------------------------------------------------------
	IF :NEW.IDIPROC > 0 AND P_CODTIPOPER <> 718 THEN
		BEGIN
			SELECT EST.CODLOCALBAIXAMP INTO P_CODLOCALORIG
			FROM TPRROPE OPE
	            INNER JOIN TPROEST EST ON (OPE.IDEFX = EST.IDEFX)
			WHERE NUNOTA = :NEW.NUNOTA
				AND EST.TIPOITENS = 'PA';
			EXCEPTION WHEN NO_DATA_FOUND THEN P_CODLOCALORIG := 0;
		END;
	END IF;

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

	---------------------------------------------------------------------------
	-- 2. Número PS do processo — só é usado pelo bloco abaixo quando a nota é
	--    de produção (IDIPROC > 0)
	---------------------------------------------------------------------------
	IF :NEW.IDIPROC > 0 THEN
		BEGIN
			SELECT NUMPS INTO P_NUMPS
			FROM TPRIPROC
			WHERE IDIPROC = :NEW.IDIPROC;
			EXCEPTION WHEN NO_DATA_FOUND THEN P_NUMPS := 0;
		END;

		IF NVL(:NEW.AD_NUMPS,0) = 0 THEN
			:NEW.AD_NUMPS := P_NUMPS;
		END IF;
	END IF;
END;