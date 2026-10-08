/*==============================================================================
  Nome do Script : STP_RASTREAMENTO_EST_ITENS
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Rotina de rastreamento de estoque por item de nota (criada em 05/2026): liga itens de saída às entradas de origem consumindo/devolvendo o saldo de TGFITS (P_TIPO: F = fazer NEW, D = desfazer OLD).
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 04/05/2026, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_RASTREAMENTO_EST_ITENS', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_RASTREAMENTO_EST_ITENS" (
   P_NUNOTA          INT,
   P_TIPMOV          CHAR,
   P_CODEMP          INT,
   P_DTENTSAI        DATE,
   P_CODTIPOPER      INT,
   P_DHTIPOPER       DATE,
   P_SEQUENCIA       INT,
   P_QTDNEG          FLOAT,
   P_CODPROD         INT,
   P_CODLOCALORIG    INT,
   P_CONTROLE        VARCHAR2,
   P_ATUALESTOQUE    INT,
   P_TIPO            CHAR                     --F - FAZER NEW D - DESFAZER OLD
                         )
AS
   P_COUNT           NUMBER (5);
   P_QTDDISP         FLOAT;
   P_NUNOTA_ITS      NUMBER (10);
   P_SEQUENCIA_ITS   NUMBER (10);
   P_SEQ             NUMBER (10);
   P_NUNOTAORIG      NUMBER (10);
   P_SEQUENCIAORIG   NUMBER (5);
   P_QTDATENDIDA     FLOAT;
   P_QTD             FLOAT;
   P_QTDITS          FLOAT;
   P_CRIOU_SBPROD    BOOLEAN;

   --BUSCA SALDO DA TGFITS PARA LIGACAO
   CURSOR CUR_TGFITS
   IS
        SELECT I.NUNOTA, I.SEQUENCIA, ROUND((I.QTDENT - NVL (I.QTDSAI, 0)), 10) AS QTDDISP
          FROM TGFITS I, TGFRASTEMP R
         WHERE     I.CODPROD = P_CODPROD
               AND R.CODPROD = I.CODPROD
               AND I.CODEMP = P_CODEMP
			   AND R.CODEMP = I.CODEMP
               AND ( (R.TIPORASTR NOT IN ('C', 'L'))
                    OR (I.CONTROLE = P_CONTROLE))
               AND ( (R.TIPORASTR NOT IN ('O', 'L'))
                    OR (I.CODLOCAL = P_CODLOCALORIG))
               AND ROUND((QTDENT - NVL (QTDSAI, 0)), 10) > 0
      ORDER BY I.DTENTSAI, NUNOTA;

   --BUSCA ITENS DA NOTA DE ORIGEM DA DEVOLUCAO
   CURSOR CUR_ITENS_DEVORIG
   IS
      SELECT VAR.NUNOTAORIG, VAR.SEQUENCIAORIG, VAR.QTDATENDIDA
        FROM TGFVAR VAR, TGFRASTEMP R
       WHERE     VAR.NUNOTA = P_NUNOTA
             AND VAR.SEQUENCIA = P_SEQUENCIA
             AND R.CODPROD = P_CODPROD
			 AND R.CODEMP = P_CODEMP
             AND R.TIPORASTR <> 'N';

   --VERIFICA SALDO DA TGFITS PARA CONSUMO
   FUNCTION TEM_SALDO
      RETURN BOOLEAN
   IS
   BEGIN
      SELECT ROUND(SUM (I.QTDENT - I.QTDSAI), 10)
        INTO P_QTDDISP
        FROM TGFITS I, TGFRASTEMP R
       WHERE     I.CODPROD = P_CODPROD
             AND R.CODPROD = I.CODPROD
             AND I.CODEMP = P_CODEMP
			 AND R.CODEMP = I.CODEMP
             AND ( (R.TIPORASTR NOT IN ('C', 'L'))
                  OR (CONTROLE = P_CONTROLE))
             AND ( (R.TIPORASTR NOT IN ('O', 'L'))
                  OR (I.CODLOCAL = P_CODLOCALORIG));

      RETURN (P_QTDDISP >= P_QTDNEG);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;
   
--VERIFICA SE EXISTE SALDO DA TGFITS PARA CONSUMO  
  FUNCTION TEM_ALGUM_SALDO
  RETURN BOOLEAN
  IS
  BEGIN
    SELECT SUM(I.QTDENT) INTO P_QTDDISP
    FROM TGFITS I
       , TGFPRO P 
    WHERE I.CODPROD  = P_CODPROD
      AND P.CODPROD = I.CODPROD
      AND I.CODEMP = P_CODEMP
      AND ((P.RASTRESTOQUE NOT IN ('C', 'L')) OR (CONTROLE = P_CONTROLE))
      AND ((P.RASTRESTOQUE  <> 'L') OR (I.CODLOCAL = P_CODLOCALORIG));  
    RETURN (P_QTDDISP >= 0);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN FALSE;  
  END;

   --CONSOME SALDO TGFITS
   PROCEDURE CONSOME_TGFITS
   IS
   BEGIN
      OPEN CUR_TGFITS;

      WHILE P_QTD > 0
      LOOP
         FETCH CUR_TGFITS
         INTO P_NUNOTA_ITS, P_SEQUENCIA_ITS, P_QTDDISP;


         IF P_QTD > P_QTDDISP
         THEN
            INSERT INTO TGFVAS (NUNOTA,
                                SEQUENCIA,
                                NUNOTAORIG,
                                SEQUENCIAORIG,
                                QTDSAI,
								ORIGCOMB)
                VALUES (P_NUNOTA,
                        P_SEQUENCIA,
                        P_NUNOTA_ITS,
                        P_SEQUENCIA_ITS,
                        P_QTDDISP,
						(SELECT ITS.ORIGCOMB
                        FROM TGFITS ITS
                       WHERE ITS.NUNOTA = P_NUNOTA_ITS
                         AND ITS.SEQUENCIA = P_SEQUENCIA_ITS));

            P_QTD := P_QTD - P_QTDDISP;
         ELSE
            INSERT INTO TGFVAS (NUNOTA,
                                SEQUENCIA,
                                NUNOTAORIG,
                                SEQUENCIAORIG,
                                QTDSAI,
								ORIGCOMB)
                VALUES (P_NUNOTA,
                        P_SEQUENCIA,
                        P_NUNOTA_ITS,
                        P_SEQUENCIA_ITS,
                        P_QTD,
						(SELECT ITS.ORIGCOMB
                        FROM TGFITS ITS
                       WHERE ITS.NUNOTA = P_NUNOTA_ITS
                         AND ITS.SEQUENCIA = P_SEQUENCIA_ITS));

            P_QTD := 0;
         END IF;
      END LOOP;

      CLOSE CUR_TGFITS;
   END;
BEGIN
   IF P_TIPO = 'D'
   THEN                                               -- DELECAO OU OLD UPDATE
      IF P_TIPMOV = 'C'
      THEN
         SELECT COUNT (1)
           INTO P_COUNT
           FROM TGFTOP TP
          WHERE     TP.CODTIPOPER = P_CODTIPOPER
                AND TP.DHALTER = P_DHTIPOPER
                AND COMPLEMENTO = 'S'
                AND EXISTS
                      (SELECT 1
                         FROM TGFVAR
                        WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = P_SEQUENCIA);

         IF P_COUNT > 0
         THEN --SE A NOTA E COMPLEMENTAR E TEM LIGACAO NA VAR AJUSTA OS VALORES
            UPDATE TGFITS
               SET QTDENT = QTDENT - P_QTDNEG
             WHERE EXISTS
                      (SELECT 1
                         FROM TGFVAR V
                        WHERE     V.NUNOTA = P_NUNOTA
                              AND V.SEQUENCIA = P_SEQUENCIA
                              AND TGFITS.NUNOTA = V.NUNOTAORIG
                              AND TGFITS.SEQUENCIA = V.SEQUENCIAORIG);

            RETURN;
         END IF;
      END IF;

      --OS864848 RETIRADO POIS JA EXISTE UMA FK COM ON DELETE CASCADE NA TABELA TGFITS PARA A TGFITE
      /*
      *OS:1311907 - Voltamos o comentario pois, instrucoes UPDATE tambem estavam caindo aqui
      *Entao, a tratativa precisa ser feita na trigger TRG_INC_UPD_DLT_TGFITE_RASTEST, para que quando seja DELETE
      *Ele NaO dispare esta TRG_INC_UPD_DLT_TGFITE_RASTEST com TIPO 'D', visto que a constraint fara o servico.
      */
      IF P_TIPMOV IN ('C', 'T', 'D')
      THEN
         DELETE FROM TGFITS
               WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = P_SEQUENCIA;
      END IF;

      IF P_TIPMOV IN ('T', 'V', 'E')
      THEN
         DELETE FROM TGFVAS
               WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = P_SEQUENCIA;
      END IF;
   --NOTAS DE COMPRA
   ELSIF P_TIPMOV = 'C'
   THEN
      -- INSERCAO OU NEW.UPDATE COMPRA
      SELECT COUNT (1)
        INTO P_COUNT
        FROM TGFTOP TP
       WHERE     TP.CODTIPOPER = P_CODTIPOPER
             AND TP.DHALTER = P_DHTIPOPER
             AND COMPLEMENTO = 'S'
             AND EXISTS
                   (SELECT 1
                      FROM TGFVAR
                     WHERE NUNOTA = P_NUNOTA AND SEQUENCIA = P_SEQUENCIA);

      IF P_COUNT > 0
      THEN                                 -- SE FOR COMPLEMENTAR E TEM ORIGEM
         UPDATE TGFITS
            SET QTDENT = QTDENT + P_QTDNEG
          WHERE EXISTS
                   (SELECT 1
                      FROM TGFVAR V
                     WHERE     V.NUNOTA = P_NUNOTA
                           AND V.SEQUENCIA = P_SEQUENCIA
                           AND TGFITS.NUNOTA = V.NUNOTAORIG
                           AND TGFITS.SEQUENCIA = V.SEQUENCIAORIG);
      ELSE
         INSERT INTO TGFITS (NUNOTA,
                             SEQUENCIA,
                             CODEMP,
                             CODPROD,
                             CODLOCAL,
                             CONTROLE,
                             DTENTSAI,
                             QTDENT,
                             QTDSAI,
							ORIGCOMB)
            SELECT P_NUNOTA,
                   P_SEQUENCIA,
                   P_CODEMP,
                   P_CODPROD,
                   (CASE
                       WHEN R.TIPORASTR IN ('O', 'L') THEN P_CODLOCALORIG
                       ELSE 0
                    END),
                   (CASE
                       WHEN R.TIPORASTR IN ('C', 'L') THEN P_CONTROLE
                       ELSE ' '
                    END),
                   P_DTENTSAI,
                   P_QTDNEG,
                   0,
			CASE
             WHEN EXISTS (SELECT 1
                            FROM TGFPRO PRO
                           WHERE PRO.CODPROD = P_CODPROD
                             AND PRO.CODANP IS NOT NULL)
             THEN (SELECT UFS.UF
                     FROM TGFCAB CAB
                     JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
                     JOIN TSICID CID ON CID.CODCID = PAR.CODCID
                     JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
                    WHERE CAB.NUNOTA = P_NUNOTA)
             ELSE NULL
          END
              FROM TGFRASTEMP R
             WHERE R.CODPROD = P_CODPROD
			 AND R.CODEMP = P_CODEMP;
      END IF;
   --DEVOLUCAO DE COMPRA
   ELSIF P_TIPMOV = 'E'
   THEN
      IF TEM_SALDO
      THEN
         --CASO DEVOLUCAO TENHA ORIGEM PEGA DA ORIGEM PRIMEIRO
         OPEN CUR_ITENS_DEVORIG;

         P_QTD := P_QTDNEG;

         LOOP
            EXIT WHEN P_QTD = 0;

            FETCH CUR_ITENS_DEVORIG
            INTO P_NUNOTAORIG, P_SEQUENCIAORIG, P_QTDATENDIDA;

            EXIT WHEN CUR_ITENS_DEVORIG%NOTFOUND;

            BEGIN
               SELECT (QTDENT - QTDSAI)
                 INTO P_QTDITS
                 FROM TGFITS
                WHERE NUNOTA = P_NUNOTAORIG AND SEQUENCIA = P_SEQUENCIAORIG;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  P_QTDITS := 0;
            END;

            IF P_QTDITS < P_QTDATENDIDA
            THEN
               P_QTDATENDIDA := P_QTDITS;
            END IF;

            IF P_QTDATENDIDA > 0
            THEN
               IF P_QTD > P_QTDATENDIDA
               THEN
                  INSERT INTO TGFVAS (NUNOTA,
                                      SEQUENCIA,
                                      NUNOTAORIG,
                                      SEQUENCIAORIG,
                                      QTDSAI,
										ORIGCOMB)
                      VALUES (P_NUNOTA,
                              P_SEQUENCIA,
                              P_NUNOTAORIG,
                              P_SEQUENCIAORIG,
                              P_QTDATENDIDA,
								(SELECT ITS.ORIGCOMB
					               FROM TGFITS ITS
					              WHERE ITS.NUNOTA = P_NUNOTAORIG
					                AND ITS.SEQUENCIA = P_SEQUENCIAORIG));

                  P_QTD := P_QTD - P_QTDATENDIDA;
               ELSE
                  INSERT INTO TGFVAS (NUNOTA,
                                      SEQUENCIA,
                                      NUNOTAORIG,
                                      SEQUENCIAORIG,
                                      QTDSAI,
										ORIGCOMB)
                      VALUES (P_NUNOTA,
                              P_SEQUENCIA,
                              P_NUNOTAORIG,
                              P_SEQUENCIAORIG,
                              P_QTD,
								(SELECT ITS.ORIGCOMB
               FROM TGFITS ITS
              WHERE ITS.NUNOTA = P_NUNOTAORIG
                AND ITS.SEQUENCIA = P_SEQUENCIAORIG));

                  P_QTD := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE CUR_ITENS_DEVORIG;

         IF P_QTD > 0
         THEN          --CASO TENHA ITEM DA DEVOLUCAO SEM ORIGEM PEGA VIA FIFO
            CONSOME_TGFITS;
         END IF;
      ELSE
         RAISE_APPLICATION_ERROR (
            -20101,
            'Nao existe quantidade disponivel para realizar o rastreamento. Produto: '
            || P_CODPROD
            || ' Qtd. Neg.: '
            || P_QTDNEG
            || 'Qtd. Disp.: '
            || P_QTDDISP
            || ' Falta(m): '
            || TO_CHAR (P_QTDNEG - P_QTDDISP)
            || ' Data: '
            || P_DTENTSAI);
      END IF;
   --NOTAS DE TRANSFERENCIA
   ELSIF P_TIPMOV = 'T'
   THEN
      IF P_ATUALESTOQUE = -1
      THEN                                            --SAIDA DA TRANSFERENCIA
         IF TEM_SALDO
         THEN
            P_QTD := P_QTDNEG;
            CONSOME_TGFITS;
         ELSE                                --SEM SALDO PARA SAIDA DO PRODUTO
            RAISE_APPLICATION_ERROR (
               -20101,
               'Nao existe quantidade disponivel para realizar o rastreamento. Produto: '
               || P_CODPROD
               || ' Qtd. Neg.: '
               || P_QTDNEG
               || 'Qtd. Disp.: '
               || P_QTDDISP
               || ' Falta(m): '
               || TO_CHAR (P_QTDNEG - P_QTDDISP)
               || ' Data: '
               || P_DTENTSAI);
         END IF;
      ELSE                                          --ENTRADA DA TRANSFERENCIA
         INSERT INTO TGFITS (NUNOTA,
                             SEQUENCIA,
                             CODEMP,
                             CODPROD,
                             CODLOCAL,
                             CONTROLE,
                             DTENTSAI,
                             QTDENT,
                             QTDSAI)
            SELECT P_NUNOTA,
                   P_SEQUENCIA,
                   P_CODEMP,
                   P_CODPROD,
                   (CASE
                       WHEN R.TIPORASTR IN ('O', 'L') THEN P_CODLOCALORIG
                       ELSE 0
                    END),
                   (CASE
                       WHEN R.TIPORASTR IN ('C', 'L') THEN P_CONTROLE
                       ELSE ' '
                    END),
                   P_DTENTSAI,
                   P_QTDNEG,
                   0
              FROM TGFRASTEMP R
             WHERE R.CODPROD = P_CODPROD
			 AND R.CODEMP = P_CODEMP;
      END IF;      
    --NOTAS NAO FISCAIS
   ELSIF P_TIPMOV = 'Q' AND SNK_IS_IN_PARAMLIST('TOPENTNFISRAST', P_CODTIPOPER, 'S') = 'S'
   THEN
      IF TEM_SALDO
      THEN
         P_QTD := P_QTDNEG;
         CONSOME_TGFITS;
      --SETA IMPOSTOS APURADOS NOS ITENS DA NOTA
      --SET_IMP_ACUMULADO;
      ELSE
         RAISE_APPLICATION_ERROR (
            -20101,
            'Nao existe quantidade disponivel para realizar o rastreamento. Produto: '
            || P_CODPROD
            || ' Qtd. Neg.: '
            || P_QTDNEG
            || 'Qtd. Disp.: '
            || P_QTDDISP
            || ' Falta(m): '
            || TO_CHAR (P_QTDNEG - P_QTDDISP)
            || ' Data: '
            || P_DTENTSAI);
      END IF;  
   --NOTAS DE VENDA
   ELSIF P_TIPMOV = 'V'
   THEN
      IF TEM_SALDO
      THEN
         P_QTD := P_QTDNEG;
         CONSOME_TGFITS;
      --SETA IMPOSTOS APURADOS NOS ITENS DA NOTA
      --SET_IMP_ACUMULADO;
      ELSE
		RAISE_APPLICATION_ERROR (
            -20101,
            'Nao existe quantidade disponivel para realizar o rastreamento. Produto: '
            || P_CODPROD
            || ' Qtd. Neg.: '
            || P_QTDNEG
            || 'Qtd. Disp.: '
            || P_QTDDISP
            || ' Falta(m): '
            || TO_CHAR (P_QTDNEG - P_QTDDISP)
            || ' Data: '
            || P_DTENTSAI);
  	 END IF; 
   --DEVOLUCOES DE VENDA
   ELSIF P_TIPMOV = 'D'
   THEN
      --GERA NOVO SALDO TGFITS
      INSERT INTO TGFITS (NUNOTA,
                          SEQUENCIA,
                          CODEMP,
                          CODPROD,
                          CODLOCAL,
                          CONTROLE,
                          DTENTSAI,
                          QTDENT,
                          QTDSAI,
							ORIGCOMB)
         SELECT P_NUNOTA,
                P_SEQUENCIA,
                P_CODEMP,
                P_CODPROD,
                (CASE
                    WHEN R.TIPORASTR IN ('O', 'L') THEN P_CODLOCALORIG
                    ELSE 0
                 END),
                (CASE
                    WHEN R.TIPORASTR IN ('C', 'L') THEN P_CONTROLE
                    ELSE ' '
                 END),
                P_DTENTSAI,
          		P_QTDNEG,
                0,
				CASE
             WHEN EXISTS (SELECT 1
                            FROM TGFPRO PRO
                           WHERE PRO.CODPROD = P_CODPROD
                             AND PRO.CODANP IS NOT NULL)
             THEN (SELECT MAX(VAS.ORIGCOMB)
                     FROM TGFVAR VAR
                     JOIN TGFVAS VAS
                       ON VAS.NUNOTA = VAR.NUNOTAORIG
                      AND VAS.SEQUENCIA = VAR.SEQUENCIAORIG
                    WHERE VAR.NUNOTA = P_NUNOTA
                      AND VAR.SEQUENCIA = P_SEQUENCIA)
             ELSE NULL
          END
           FROM TGFRASTEMP R
          WHERE R.CODPROD = P_CODPROD 
          AND R.CODEMP = P_CODEMP;
   END IF;
END;
