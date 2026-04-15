create or replace PROCEDURE          STP_PCP_SPARK (
    P_CODPROD NUMBER,         -- Código do PA.
  P_CONTROLE VARCHAR2,     -- Controle adicional do PA.
  P_DATA_INICIAL DATE,     -- Data inicial do período do MPS.
  P_DATA_FINAL DATE,         -- Data final do período do MPS.
  P_QTDDEMBRUTA OUT FLOAT, -- Valor da demanda bruta do PA que será calculada pela procedure.
  P_NUMPS OUT NUMBER	     -- Número do MPS que está sendo gerado
) AS
/*==============================================================================
  Nome do Script : STP_PCP_SPARK
  Tipo           : Stored Procedure (Cálculo de Demanda - PCP/MRP)
  Descrição      : Procedure para cálculo de necessidade de produção em MPS.
                   Considera giro mensal, estoque e lote padrão de produtos.

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
  P_COUNT            INT;
  P_TAMLOTEPAD       TPRLPA.TAMLOTEPAD%TYPE;
  P_ESTOQUESTART     NUMBER;
  P_QTDPEDVENDASTART NUMBER;
  P_GIROMENSAL       NUMBER;
  P_GIROMENSALBIOTEC NUMBER;
  P_ESTOQUEBIOTEC    NUMBER;
  P_NECESSIDADE      NUMBER;
  P_QTDBATELADA      NUMBER;
  P_QTDPRODUZIRAD    NUMBER;
  P_ESTOQUE          TGFEST.ESTOQUE%TYPE;
  P_QTDDIAS          NUMBER;
  P_MULTIPLICADOR    NUMBER;
  P_QTDPREV          FLOAT;
  P_QTDPRODUZIR     FLOAT;
BEGIN
  -- Encontrando a quantidade de dias que está sendo planejado
  SELECT P_DATA_FINAL-P_DATA_INICIAL
  INTO P_QTDDIAS
  FROM DUAL;

  SELECT COUNT(*) 
    INTO P_COUNT
  FROM TGFPRO
  WHERE CODPROD = P_CODPROD
  AND USOPROD='V';

 /* IF P_COUNT = 1 THEN
  RAISE_APPLICATION_ERROR(-20101,'P_COUNT: ' ||P_COUNT||'P_CODPROD:'||P_CODPROD);
  END IF; */


-- SÓ CALCULA NECESSIDADE PARA PA - VENDA FABRICAÇÃO PRÓPRIA, NÃO CONSIDERA PI PQ DEVE SER CALCUALADO EM FUNÇÃO DO PA PELA PRÓPRIA ROTINA
  IF P_COUNT = 1 THEN
    -- ACHA O TAMNHO DO LOTE IDEAL CONFIGURADO NO PROCESSO PRODUTIVO DO ULTIMO PROCESSO PRODUTIVO
    BEGIN
      SELECT NVL(TAMLOTEPAD,1) INTO P_TAMLOTEPAD 
      FROM TPRLPA WHERE CODPRODPA = P_CODPROD 
      AND IDPROC IN (SELECT MAX(LPA.IDPROC) 
      FROM TPRLPA LPA INNER JOIN TPRPRC RC ON (LPA.IDPROC = RC.IDPROC)
      WHERE LPA.CODPRODPA = P_CODPROD
      AND NVL(RC.PADRAO,'N') = 'S');
    EXCEPTION WHEN NO_DATA_FOUND THEN
      P_TAMLOTEPAD :=1;
    END;

    /* VERIFICA A QUANTIDADE DA META SIMPLIFICADA DE VENDAS POR QUANTIDADE PRODUTO */     
    BEGIN
         SELECT NVL(QTDPREV,0) INTO P_QTDPREV FROM TGFMET 
         WHERE CODMETA = 3 
           AND CODPROD = P_CODPROD 
             AND  DTREF = TRUNC(P_DATA_FINAL,'MM');
    EXCEPTION WHEN NO_DATA_FOUND THEN 
    P_QTDPREV :=0;
    END;

  /* VERIFICA A QUANTIDADE EM PRODUÇÃO DENTRO DO MÊS MRP */       
       BEGIN   
        SELECT SUM(QTDPRODUZIR) INTO P_QTDPRODUZIR 
         FROM TPRIPROC PROC INNER JOIN TPRIPA PA ON (PROC.IDIPROC=PA.IDIPROC) 
         WHERE STATUSPROC IN ('A','F','R','P2')
         AND PA.CODPRODPA = P_CODPROD
         AND TRUNC(PROC.DHINST,'MM') = TRUNC(P_DATA_FINAL,'MM') ;
          EXCEPTION WHEN NO_DATA_FOUND THEN 
            P_QTDPRODUZIR :=0;
            END;

            --RAISE_APPLICATION_ERROR(-20101,'P_QTDPREV: ' ||P_QTDPREV||'P_CODPROD:'||P_CODPROD);

   /*RENAN IRÁ ADICIONAR A QUANTIDADE A PRODUZIR ADICIONAL CONFORME PROGRAMAÇÃO, 
   PORÉM SE JÁ PRODUZIU A META NÃO SUGERE PRODUÇÃO */
   P_QTDDEMBRUTA :=0 ; --CASE WHEN P_QTDPREV > P_QTDPRODUZIR THEN 10 ELSE 0 END;
    --P_QTDPRODUZIRAD := 0;

    -- QUANDO INFORMA A QTDE ADICIONAL O SISTEMA ABATE O ESTOQUE E PRODUÇÕES EM ABERTO, PORÉM NESSE CASO DEVE RESPEITAR A QTDE DIGITADA E POR ISSO PRECISA SOMAR O ESTOQU
        -- Calculado o multiplicador, que irá incidir sobre o cálculo da quantidade de bateladas
   /* P_MULTIPLICADOR := 1 + (P_QTDDIAS/30);

    --QTDE LOTE IDEAL NECESSÁRIO PARA MANTER O GIRO MENSAL, RETIREI O ESTOQUE DA BIOTEC PQ A ROTINA DE MRP1 JÁ FAZ A CONTA A PRODUZIR CONSIDERANDO ESTOQUE
    --P_QTDBATELADA := (((P_GIROMENSAL+P_GIROMENSALBIOTEC)-(P_ESTOQUESTART-P_QTDPEDVENDASTART))/P_TAMLOTEPAD);
    P_QTDBATELADA := (((P_MULTIPLICADOR * (P_GIROMENSAL+P_GIROMENSALBIOTEC))-(P_ESTOQUESTART+P_ESTOQUE))/P_TAMLOTEPAD);

    P_QTDDEMBRUTA := CASE WHEN P_QTDPRODUZIRAD > 0 THEN P_ESTOQUE+P_QTDPRODUZIRAD ELSE 0 END +
                     CASE WHEN P_QTDBATELADA > 0.4 AND P_QTDBATELADA <= 1 THEN P_TAMLOTEPAD WHEN P_QTDBATELADA > 1 THEN ROUND(P_QTDBATELADA) * P_TAMLOTEPAD ELSE 0 END;      

    --RAISE_APPLICATION_ERROR(-20101,'P_ESTOQUE: ' ||P_ESTOQUE||'P_QTDDEMBRUTA:'||P_QTDDEMBRUTA);
    */
  END IF;
END;