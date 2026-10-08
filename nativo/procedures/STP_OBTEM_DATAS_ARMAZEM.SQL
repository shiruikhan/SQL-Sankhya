/*==============================================================================
  Nome do Script : STP_OBTEM_DATAS_ARMAZEM
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Calcula as datas de referência de entrada e de cobrança de armazenagem (por quinzena, conforme a isenção do contrato em TCSPSC) para o módulo de armazém/contratos.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 19/09/2025.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_OBTEM_DATAS_ARMAZEM', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_OBTEM_DATAS_ARMAZEM" (P_TIPMOV CHAR, P_DTNEG DATE, P_NUMCONTRATO INT, P_DTREFENT OUT DATE , P_DTREFCOB OUT DATE  ) AS
BEGIN
  DECLARE
  P_QTDISENCAO INT;
  P_DIA     INT;
  BEGIN
     /* 
	  Módulo agricola e sementes não tem obrigatoriedade do uso de contratos, conforme visto com o manoel para esses casos
	  as duas datas devem ser iguais.
    */
     IF (P_NUMCONTRATO=0) THEN
          P_DTREFENT := TRUNC(P_DTNEG, 'month');
          P_DTREFCOB := P_DTREFENT;
          RETURN;
     END IF;
  
     BEGIN
       SELECT QTDISENCAO
       INTO P_QTDISENCAO
       FROM TCSPSC
       WHERE NUMCONTRATO = P_NUMCONTRATO;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR(-20101, 'Contrato '||TO_CHAR(P_NUMCONTRATO)||' não foi encontrado.' );
     END;
     IF P_QTDISENCAO > 24 THEN
       RAISE_APPLICATION_ERROR(-20101, 'Quantidade de quinzenas de isenção não pode ser maior que 24.' );
     END IF;

     P_DIA := TO_CHAR(P_DTNEG, 'DD');
     P_DTREFENT := TRUNC(P_DTNEG, 'month');

     IF P_TIPMOV IN ('3','4') THEN
       IF P_DIA > 15 THEN
        P_DTREFENT := ADD_MONTHS(P_DTREFENT, 1);
       ELSE
        P_DTREFENT := P_DTREFENT + 15;
       END IF;
       P_DTREFCOB := P_DTREFENT;
     ELSE
      IF P_DIA > 15 THEN
        P_DIA := 16;
        P_DTREFENT := P_DTREFENT + 15;
      ELSE
        P_DIA := 1;
      END IF;

      P_DTREFCOB := P_DTREFENT;
	  
      IF (NVL(P_QTDISENCAO, 0) = 0)  THEN
        RETURN;
      END IF;

      IF MOD( P_QTDISENCAO, 2 ) > 0 THEN -- NRO DE QUINZENAS IMPAR
        IF P_DIA = 1 THEN
          P_DTREFCOB := P_DTREFENT + 15;
        ELSE
          P_DIA := 1;
          P_DTREFCOB := ADD_MONTHS(trunc(P_DTREFENT, 'month'),1);
        END IF;
        P_QTDISENCAO := P_QTDISENCAO - 1; -- FIZEMOS UMA QUINZENA MANUAL P/SOBRAR NRO QUINZENAS PAR
      END IF;
      P_DTREFCOB := ADD_MONTHS(P_DTREFCOB, TRUNC(P_QTDISENCAO/2));
     END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
END ;
