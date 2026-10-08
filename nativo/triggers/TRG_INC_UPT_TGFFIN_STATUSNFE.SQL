/*==============================================================================
  Nome do Script : TRG_INC_UPT_TGFFIN_STATUSNFE
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 15/01/2025)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFFIN.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 15/01/2025, última alteração em 20/04/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_INC_UPT_TGFFIN_STATUSNFE', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFFIN_STATUSNFE" 
   BEFORE INSERT OR UPDATE
   ON TGFFIN
   FOR EACH ROW
    WHEN (NEW.ORIGEM = 'E' AND NEW.PROVISAO = 'N' AND NVL (NEW.NUNOTA, 0) <> 0) DECLARE
   P_COUNT                  INT;
   ERROR EXCEPTION;
   ERRMSG                   VARCHAR2 (4000);
   P_VALIDAR                BOOLEAN;
   P_STATUSNFE              VARCHAR2 (1);
   P_TPEMISNFE              NUMBER (5);
   P_EMPNFE                 VARCHAR2 (1);
   P_TOPNFE                 VARCHAR2 (1);
   P_STATUSNFSE             VARCHAR2 (1);
   P_TPEMISNFSE             NUMBER (5);
   P_EMPNFSE                VARCHAR2 (1);
   P_TOPNFSE                VARCHAR2 (1);
   P_NUMREGDPEC             VARCHAR2 (15);
   P_EMPTPAMBCTE            VARCHAR2 (1);
   P_BAIXAFINPREEMISSNFCE   VARCHAR2 (1);
   P_TOPCTE                 VARCHAR2 (1);
   P_TPEMISCTE              NUMBER (5);
   P_STATUSCTE              VARCHAR2 (1);
   P_COUNT_PIX              INT := 0;
   P_COUNT_PIX_NSU          INT := 0;

   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   IF STP_GET_ATUALIZANDO
   THEN
      RETURN;
   END IF;

   /*
   sincronização de dados
   */
   P_VALIDAR := Fpodevalidar ('TGFFIN');

   BEGIN
      SELECT NVL (EMP.NFE, ' '),
             NVL (TPO.NFE, ' '),
             NVL (CAB.STATUSNFE, ' '),
             NVL (CAB.TPEMISNFE, 0),
             NVL (EMP.NFSE, ' '),
             NVL (TPO.NFSE, ' '),
             NVL (CAB.STATUSNFSE, ' '),
             NVL (CAB.TPEMISNFSE, 0),
             NVL (CAB.NUMREGDPEC, '*'),
             NVL (EMP.TPAMBCTE, ' '),
             NVL (EMP.BAIXAFINPREEMISSNFCE, 'N'),
             NVL (TPO.CTE, ' '),
             NVL (CAB.TPEMISCTE, 0),
             NVL (CAB.STATUSCTE, ' ')
        INTO P_EMPNFE,
             P_TOPNFE,
             P_STATUSNFE,
             P_TPEMISNFE,
             P_EMPNFSE,
             P_TOPNFSE,
             P_STATUSNFSE,
             P_TPEMISNFSE,
             P_NUMREGDPEC,
             P_EMPTPAMBCTE,
             P_BAIXAFINPREEMISSNFCE,
             P_TOPCTE,
             P_TPEMISCTE,
             P_STATUSCTE
        FROM TGFCAB CAB, TGFEMP EMP, TGFTOP TPO
       WHERE     CAB.NUNOTA = :NEW.NUNOTA
             AND EMP.CODEMP = CAB.CODEMP
             AND TPO.CODTIPOPER = CAB.CODTIPOPER
             AND TPO.DHALTER = CAB.DHTIPOPER
             AND CAB.MODRECEBPDVWEB IS NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
   END;

   IF (P_BAIXAFINPREEMISSNFCE = 'N')
   THEN
      IF (P_EMPNFE IN ('1', '2')) AND (P_TOPNFE IN ('N', 'C', 'A', 'D'))
      THEN
         IF NOT (   (P_TPEMISNFE IN (2, 9))
                 OR (P_STATUSNFE IN ('A', 'S'))
                 OR (P_TPEMISNFE = 4 AND P_NUMREGDPEC <> '*'))
         THEN --Acrescentamos exceção 9  - Conting.Off-Line NFC-e funciona como o DANF de segurança.

			SELECT COUNT(1) INTO P_COUNT_PIX
         	FROM TGFTIT 
         	WHERE CODTIPTIT = :NEW.CODTIPTIT
         	AND SUBTIPOVENDA IN (10, 11);
         
         	SELECT COUNT(1) INTO P_COUNT_PIX_NSU
			FROM (
				SELECT 1 
				FROM TGFPIX
				WHERE NUFIN = :NEW.NUFIN
			UNION ALL
				SELECT 1
				FROM TGFPIXTEF
				WHERE NUFIN = :NEW.NUFIN);

            IF (    (:OLD.DHBAIXA IS NULL)
                AND (:NEW.DHBAIXA IS NOT NULL)
                AND (VARIAVEIS_PKG.V_CODTIPTIT_TROCA <> :NEW.CODTIPTIT)
                AND (P_COUNT_PIX = 0)
                AND (P_COUNT_PIX_NSU = 0))
            THEN
               ERRMSG :=
                  'Ocorreu um erro na BAIXA: Os financeiros estão vinculados a uma NF-e: '
                  || :NEW.NUNOTA
                  || ' não autorizada pela Sefaz. Não é possível baixá-los';
               RAISE ERROR;
            END IF;

            IF ( (NVL (:OLD.NOSSONUM, 'X')) <> (NVL (:NEW.NOSSONUM, 'X')))
            THEN
               ERRMSG :=
                  'Não é possível gerar Nosso Número para uma nota ainda não confirmada pela SEFAZ. NUNOTA: '
                  || :NEW.NUNOTA;
               RAISE ERROR;
            END IF;

            IF ( (NVL (:OLD.NURENEG, 0)) <> (NVL (:NEW.NURENEG, 0)))
            THEN
               ERRMSG :=
                  'Não é possível RENEGOCIAR uma nota ainda não confirmada pela SEFAZ. NUNOTA: '
                  || :NEW.NUNOTA;
               RAISE ERROR;
            END IF;
         END IF;
      END IF;
   END IF;

   IF (P_EMPTPAMBCTE IN ('1', '2')) AND (P_TOPCTE = 'N')
   THEN
      IF NOT (   (P_TPEMISCTE = 5)
              OR (P_STATUSCTE IN ('A', 'S'))
              OR (P_TPEMISCTE = 4 AND P_NUMREGDPEC <> '*'))
      THEN                        --Acrescentamos exceção 5 - Conting. FSDA.
         IF (    (:OLD.DHBAIXA IS NULL)
             AND (:NEW.DHBAIXA IS NOT NULL)
             AND (VARIAVEIS_PKG.V_CODTIPTIT_TROCA <> :NEW.CODTIPTIT))
         THEN
            ERRMSG :=
               'Ocorreu um erro na BAIXA: Os financeiros estão vinculados a um CT-e: '
               || :NEW.NUNOTA
               || ' Não autorizada pela Sefaz. Não é possível baixá-los';
            RAISE ERROR;
         END IF;

         IF ( (NVL (:OLD.NOSSONUM, 'X')) <> (NVL (:NEW.NOSSONUM, 'X')))
         THEN
            ERRMSG :=
               'Não é possível gerar Nosso Número para um conhecimento ainda não confirmada pela SEFAZ. NUNOTA: '
               || :NEW.NUNOTA;
            RAISE ERROR;
         END IF;

         IF ( (NVL (:OLD.NURENEG, 0)) <> (NVL (:NEW.NURENEG, 0)))
         THEN
            ERRMSG :=
               'Não é possível RENEGOCIAR um conhecimento ainda não confirmada pela SEFAZ. NUNOTA: '
               || :NEW.NUNOTA;
            RAISE ERROR;
         END IF;
      END IF;
   END IF;

   IF (P_EMPNFSE IN ('1', '2')) AND (P_TOPNFSE = 'N')
   THEN
      IF NOT ( (P_TPEMISNFSE = 2) OR (P_STATUSNFSE = 'A'))
      THEN
         IF (    (:OLD.DHBAIXA IS NULL)
             AND (:NEW.DHBAIXA IS NOT NULL)
             AND (VARIAVEIS_PKG.V_CODTIPTIT_TROCA <> :NEW.CODTIPTIT))
         THEN
            ERRMSG :=
               'Ocorreu um erro na BAIXA: Os financeiros estão vinculados a uma NFS-e: '
               || :NEW.NUNOTA
               || ' não aprovada pela Prefeitura. Não é possível baixá-los.';
            RAISE ERROR;
         END IF;

         IF ( (NVL (:OLD.NOSSONUM, 'X')) <> (NVL (:NEW.NOSSONUM, 'X')))
         THEN
            ERRMSG :=
               'Não é possível gerar Nosso Número para uma nota ainda não aprovada pela Prefeitura. NUNOTA: '
               || :NEW.NUNOTA
               || '. Financeiro de Nro único: '
               || :NEW.NUFIN
               || '.';
            RAISE ERROR;
         END IF;

		IF ( (NVL (:OLD.NURENEG, 0)) <> (NVL (:NEW.NURENEG, 0)))
		THEN
		   ERRMSG :=
			  'Não é possível RENEGOCIAR uma nota ainda não confirmada pela Prefeitura. NUNOTA: '
			  || :NEW.NUNOTA
			  || '.';
		   RAISE ERROR;
		END IF;
      END IF;
   END IF;

   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      /*
      Sincronizção de dados não faz validações
      */
      IF (P_VALIDAR)
      THEN
         IF SQLCODE <> 1
         THEN
            ERRMSG := ERRMSG || '  ' || SQLERRM;
         END IF;

         RAISE_APPLICATION_ERROR (-20101, ERRMSG);
      END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPT_TGFFIN_STATUSNFE" ENABLE;
