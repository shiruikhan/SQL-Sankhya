/*==============================================================================
  Nome do Script : SNK_GET_CTACTB_CADASTROS_EFD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Resolve a conta contabil do EFD a partir de cadastros (produto/empresa,
                  natureza, TOP) quando nao ha lancamento contabil (TCBINT), filtrando por
                  grupo de natureza do registro SPED.
  Assinatura     : SNK_GET_CTACTB_CADASTROS_EFD ( P_REGISTRO VARCHAR2, P_CODEMP NUMBER, P_CODPROD NUMBER, P_CODNAT NUMBER, P_CODTIPOPER NUMBER, P_DHTIPOPER DATE, P_USOPROD VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CTACTB_CADASTROS_EFD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CTACTB_CADASTROS_EFD (
   P_REGISTRO      VARCHAR2,
   P_CODEMP        NUMBER,
   P_CODPROD       NUMBER,
   P_CODNAT        NUMBER,
   P_CODTIPOPER    NUMBER,
   P_DHTIPOPER     DATE,
   P_USOPROD       VARCHAR2)
   RETURN VARCHAR2
AS
   P_CODCTACTB        TCBPLA.CODCTACTB%TYPE := NULL;
   P_RESULT           TCBPLA.CTACTB%TYPE := NULL;
   P_GRUPO_NATUREZA   VARCHAR2 (100) := ' ';

/* Nomenclatura sem o prefixo "F_" são as chamadas antigas feitas pelo "EFD Contribuições".
Novas chamadas para o "EFD Contribuições" devem começar a usar o prefixo "C_" para fazer uma boa distinção entre os EFDs.
Nomenclatura com o prefixo "F_" são as chamadas feitas pelo "EFD ICMS/IPI" de agora em diante.*/

BEGIN
   IF P_REGISTRO IN
            ('A170',
             'C170',
             'C191',
             'C195',
             'C396',
             'C481',
             'C485',
             'C501',
             'C505',
             'F100_NOTA',
             'F100_FINANCEIRO',
             'F_C170',
             'F_C500')
   THEN
      P_GRUPO_NATUREZA := ',1,2,3,4,6,7,8,9,';

	 IF P_REGISTRO = 'F100_FINANCEIRO' AND NVL (P_CODNAT, 0) <> 0 THEN
		BEGIN
			SELECT NAT.CODCTACTBEFD
			INTO P_CODCTACTB 
			FROM TGFNAT NAT
			WHERE NAT.CODNAT = P_CODNAT
				AND NVL(NAT.CODCTACTBEFD, 0) <> 0
				AND EXISTS (
					SELECT 1
					FROM TGFTOP
					WHERE CODTIPOPER = P_CODTIPOPER AND DHALTER = P_DHTIPOPER
					AND USAALIQNATRATF100 = 'S');
		EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
        END;

	 END IF;

   ELSIF P_REGISTRO IN
               ('C175',
                'C181',
                'C185',
                'C381',
                'C385',
                'C491',
                'C495',
                'C810',
                'C870',
                'F_C350',
                'F_C370')
   THEN
      P_GRUPO_NATUREZA := ',1,2,';
   ELSIF P_REGISTRO IN ('D100', 'D101', 'D105', 'F_D100', 'F_D110')
   THEN
      P_GRUPO_NATUREZA := ',3,5,6,7,8,9,11,';
   ELSIF P_REGISTRO IN ('D201', 'D205', 'D601', 'D605')
   THEN
      P_GRUPO_NATUREZA := ',3,';
   ELSIF P_REGISTRO IN ('D501', 'D505','F_D500', 'F_D510')
   THEN
      P_GRUPO_NATUREZA := ',6,7,';
   ELSIF P_REGISTRO IN ('F500', 'F510', 'F525', 'F550', 'F560', '1900')
   THEN
      P_GRUPO_NATUREZA := ',1,2,3,';
   ELSIF P_REGISTRO IN ('F100_MULTA', 'F100_JURO', 'F100_DESCONTO', 'F100_VARCAMB')
   THEN
      P_GRUPO_NATUREZA := ',1,2,6,7,12,13,';

      SELECT 
		CASE 
			WHEN P_REGISTRO = 'F100_MULTA' AND EMP.TRIBPISCFMULT = 'S' THEN EMP.CODCTACTBMULT 
			WHEN P_REGISTRO = 'F100_JURO' AND EMP.TRIBPISCFJUROS = 'S' THEN EMP.CODCTACTBJUROS
			WHEN P_REGISTRO ='F100_DESCONTO' AND EMP.TRIBPISCFDESC = 'S' THEN EMP.CODCTACTBDESC
			WHEN P_REGISTRO = 'F100_VARCAMB' AND EMP.TRIBPISCFCAMB = 'S' THEN EMP.CODCTACTBCAMB
		END 
		INTO P_CODCTACTB 
		FROM TGFEMP EMP where EMP.CODEMP = P_CODEMP;
		P_CODCTACTB := CASE WHEN NVL(P_CODCTACTB, 0) = 0 THEN NULL ELSE P_CODCTACTB END; 
   ELSIF P_REGISTRO = 'F120'
   THEN 
      P_GRUPO_NATUREZA := ',10,';
   ELSIF P_REGISTRO IN ('F130', 'F_0300')
   THEN
      P_GRUPO_NATUREZA := ',11,';
   ELSE
      P_GRUPO_NATUREZA := ' ';
   END IF;

   IF P_CODCTACTB IS NULL AND NVL (P_CODPROD, 0) <> 0
   THEN
      IF NVL (P_USOPROD, 'R') = 'S'
      THEN
         BEGIN
            SELECT CODCTACTBEFD
              INTO P_CODCTACTB
              FROM TGFSEM PEM
             WHERE CODPROD = P_CODPROD AND CODEMP = P_CODEMP
                   AND EXISTS
                         (SELECT 1
                            FROM TCBPLA PLA
                           WHERE PLA.CODCTACTB = CODCTACTBEFD
                                 AND INSTR (P_GRUPO_NATUREZA,
                                            ',' || PLA.NATUREZAEFD || ',') >
                                       0);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
         END;
      ELSE
         BEGIN
            SELECT CODCTACTBEFD
              INTO P_CODCTACTB
              FROM TGFPEM PEM
             WHERE CODPROD = P_CODPROD AND CODEMP = P_CODEMP
                   AND EXISTS
                         (SELECT 1
                            FROM TCBPLA PLA
                           WHERE PLA.CODCTACTB = CODCTACTBEFD
                                 AND INSTR (P_GRUPO_NATUREZA,
                                            ',' || PLA.NATUREZAEFD || ',') >
                                       0);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
         END;
      END IF;

      IF P_CODCTACTB IS NULL
      THEN
         BEGIN
            SELECT CODCTACTBEFD
              INTO P_CODCTACTB
              FROM TGFPRO
             WHERE CODPROD = P_CODPROD
                   AND EXISTS
                         (SELECT 1
                            FROM TCBPLA PLA
                           WHERE PLA.CODCTACTB = CODCTACTBEFD
                                 AND INSTR (P_GRUPO_NATUREZA,
                                            ',' || PLA.NATUREZAEFD || ',') >
                                       0);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
         END;
      END IF;

      IF P_CODCTACTB IS NULL
      THEN
         BEGIN
            SELECT GEM.CODCTACTBEFD
              INTO P_CODCTACTB
              FROM TGFPRO PRO INNER JOIN TGFGEM GEM
                      ON GEM.CODGRUPOPROD = PRO.CODGRUPOPROD
             WHERE PRO.CODPROD = P_CODPROD AND GEM.CODEMP = P_CODEMP
                   AND EXISTS
                         (SELECT 1
                            FROM TCBPLA PLA
                           WHERE PLA.CODCTACTB = GEM.CODCTACTBEFD
                                 AND INSTR (P_GRUPO_NATUREZA,
                                            ',' || PLA.NATUREZAEFD || ',') >
                                       0);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
         END;
      END IF;

      IF P_CODCTACTB IS NULL
      THEN
         BEGIN
            SELECT GRU.CODCTACTBEFD
              INTO P_CODCTACTB
              FROM TGFPRO PRO INNER JOIN TGFGRU GRU
                      ON GRU.CODGRUPOPROD = PRO.CODGRUPOPROD
             WHERE PRO.CODPROD = P_CODPROD
                   AND EXISTS
                         (SELECT 1
                            FROM TCBPLA PLA
                           WHERE PLA.CODCTACTB = GRU.CODCTACTBEFD
                                 AND INSTR (P_GRUPO_NATUREZA,
                                            ',' || PLA.NATUREZAEFD || ',') >
                                       0);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               P_CODCTACTB := NULL;
         END;
      END IF;
   END IF;


   IF P_CODCTACTB IS NULL AND NVL (P_CODNAT, 0) <> 0
   THEN
      BEGIN
         SELECT CODCTACTBEFD
           INTO P_CODCTACTB
           FROM TGFNAT
          WHERE CODNAT = P_CODNAT
                AND EXISTS
                      (SELECT 1
                         FROM TCBPLA PLA
                        WHERE PLA.CODCTACTB = CODCTACTBEFD
                              AND INSTR (P_GRUPO_NATUREZA,
                                         ',' || PLA.NATUREZAEFD || ',') > 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            P_CODCTACTB := NULL;
      END;
   END IF;

   IF P_CODCTACTB IS NULL AND NVL (P_CODTIPOPER, 0) <> 0
   THEN
      BEGIN
         SELECT CODCTACTBEFD
           INTO P_CODCTACTB
           FROM TGFTOP
          WHERE CODTIPOPER = P_CODTIPOPER AND DHALTER = P_DHTIPOPER
                AND EXISTS
                      (SELECT 1
                         FROM TCBPLA PLA
                        WHERE PLA.CODCTACTB = CODCTACTBEFD
                              AND INSTR (P_GRUPO_NATUREZA,
                                         ',' || PLA.NATUREZAEFD || ',') > 0);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            P_CODCTACTB := NULL;
      END;
   END IF;

   IF P_CODCTACTB IS NOT NULL
   THEN
      BEGIN
         SELECT CTACTB
           INTO P_RESULT
           FROM TCBPLA
          WHERE CODCTACTB = P_CODCTACTB;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            P_RESULT := NULL;
      END;
   END IF;

   RETURN P_RESULT;
END;
