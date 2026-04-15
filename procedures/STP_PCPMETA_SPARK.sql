create or replace PROCEDURE "STP_PCPMETA_SPARK" (
    P_CODPROD NUMBER,         -- Código do PA.
    P_CONTROLE VARCHAR2,     -- Controle adicional do PA.
    P_DATA_INICIAL DATE,     -- Data inicial do período do MPS.
    P_DATA_FINAL DATE,         -- Data final do período do MPS.
    P_QTDDEMBRUTA OUT FLOAT, -- Valor da demanda bruta do PA que será calculada pela procedure.
    P_NUMPS OUT NUMBER	     -- Número do MPS que está sendo gerado
) AS
/*==============================================================================
  Nome do Script : STP_PCPMETA_SPARK
  Tipo           : Stored Procedure (Cálculo de Demanda - PCP/MRP)
  Descrição      : Procedure para cálculo de demanda bruta em MPS (Master Planning Schedule).
                   Considera meta de vendas, previsões e MPS para produtos acabados.

  Parâmetros     : P_CODPROD      — código do produto acabado (PA)
                   P_CONTROLE     — controle adicional do PA
                   P_DATA_INICIAL — data inicial do período de planejamento
                   P_DATA_FINAL   — data final do período de planejamento
                   P_QTDDEMBRUTA  — demanda bruta calculada (OUT)
                   P_NUMPS        — número do MPS gerado (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
P_COUNT INT;
P_QTDPREV FLOAT;
V_NUMPS NUMBER;

BEGIN
	SELECT COUNT(*) INTO P_COUNT
	FROM TGFPRO
	WHERE CODPROD = P_CODPROD
		AND USOPROD='V';
	--FORÇA OS PIS A FICAREM COMO SUB-ORDEM PARA O MRP CONSIDERAR NA COMPOSIÇÃO DE MPS POIS SÓ CONSIDERA SE FO PI OR SUB-ORDEM SE FOR ESTOQUE NÃO GERA NECESSIDADE DE MP
	UPDATE TPRLPI 
	SET TIPOPI='O' 
	WHERE CODPRODPA = P_CODPROD 
		AND IDPROC IN (SELECT MAX(PI.IDPROC) FROM TPRPRC PRC INNER JOIN TPRLPI PI ON (PRC.IDPROC = PI.IDPROC) WHERE PI.CODPRODPA = P_CODPROD AND PRC.PADRAO='S')
		AND TIPOPI NOT IN ('O');
	
	BEGIN
		SELECT NVL(QTDPREV,0) -NVL(QTDREDMET,0) INTO P_QTDPREV 
		FROM AD_TGFMET 
		WHERE CODMETA = 3 
			AND CODPROD = P_CODPROD 
			AND  DTREF = TRUNC(P_DATA_INICIAL,'MM');
		EXCEPTION WHEN NO_DATA_FOUND THEN P_QTDPREV := 0;
	END;
	
	BEGIN
		SELECT NUMPS INTO V_NUMPS 
		FROM TPRMPS 
		WHERE DTINICMPS = P_DATA_INICIAL 
			AND DTFINMPS = P_DATA_FINAL;
		EXCEPTION WHEN NO_DATA_FOUND THEN 
    V_NUMPS := 0;
    END;    
	
	/*VOLTA A MARCAÇÃO ORIGINAL DE TIPO DE PI
	UPDATE TPRLPI SET TIPOPI=AD_TIPOPI WHERE CODPRODPA=P_CODPROD AND IDPROC IN (SELECT MAX(PI.IDPROC) FROM TPRPRC PRC INNER JOIN TPRLPI PI ON (PRC.IDPROC = PI.IDPROC) WHERE PI.CODPRODPA = P_CODPROD AND PRC.PADRAO='S');*/
  
	IF P_COUNT > 0 THEN --SE FOR PRODUTO(PA) USOPROD 'V' - DANIEL CAMPOS = 18/05/2022
		P_QTDDEMBRUTA := P_QTDPREV + OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S'); /*CASE WHEN OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S')  < 0 THEN 0 ELSE OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S') END;*/
	ELSE    
		P_QTDDEMBRUTA := P_QTDPREV + /*OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S')*/CASE WHEN OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S')  < 0 THEN 0 ELSE OBTEM_TOTAIS_MRP(V_NUMPS,P_CODPROD,0,'S') END;
	END IF;
END;