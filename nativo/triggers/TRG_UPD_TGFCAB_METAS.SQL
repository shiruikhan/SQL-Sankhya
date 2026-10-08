/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_METAS
  Tipo           : Trigger — origem a confirmar (criada isoladamente em 12/12/2023)
  Descrição      : Trigger AFTER EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 12/12/2023, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_METAS', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_METAS" 
AFTER UPDATE ON TGFCAB FOR EACH ROW
    WHEN (
      TRUNC(OLD.DTNEG, 'MONTH') <> TRUNC(NEW.DTNEG, 'MONTH')
      ) DECLARE
  P_COUNT INT;
  P_PERIODO INT;
  P_NUMTRANSF         TGMTRA.NUMTRANSF%TYPE;
  P_NEWNUMTRANSF  	  TGMTRA.NUMTRANSF%TYPE;
  P_CODMETA             TGMTRA.CODMETA%TYPE;
  P_DTREF                  TGMTRA.DTREF%TYPE;
  P_CODEMP               TGMTRA.CODEMP%TYPE;
  P_CODPROD             TGMTRA.CODPROD%TYPE;
  P_CODGRUPOPROD  TGMTRA.CODGRUPOPROD%TYPE;
  P_CODLOCAL            TGMTRA.CODLOCAL%TYPE;
  P_CONTROLE            TGMTRA.CONTROLE%TYPE;
  P_MARCA                  TGMTRA.MARCA%TYPE;
  P_CODPROJ             TGMTRA.CODPROJ%TYPE;
  P_CODCENCUS        TGMTRA.CODCENCUS%TYPE;
  P_CODNAT               TGMTRA.CODNAT%TYPE;
  P_CODCTACTB        TGMTRA.CODCTACTB%TYPE;
  P_CODREG              TGMTRA.CODREG%TYPE;
  P_CODGER              TGMTRA.CODGER%TYPE;
  P_CODVEND            TGMTRA.CODVEND%TYPE;
  P_CODPARC            TGMTRA.CODPARC%TYPE;
  P_CODUF                TGMTRA.CODUF%TYPE;
  P_CODCID               TGMTRA.CODCID%TYPE;
  P_CODPAIS             TGMTRA.CODPAIS%TYPE;
  P_CODTIPPARC       TGMTRA.CODTIPPARC%TYPE;
  P_VALOR                 TGMTRA.VALOR%TYPE;
  P_CODUSU              TGMTRA.CODUSU%TYPE;
  P_NUFIN                  TGMTRA.NUFIN%TYPE;
  P_STATUS               TGMTRA.STATUS%TYPE;
  P_CODUSULIB          TGMTRA.CODUSULIB%TYPE;
  P_GRAU                   TGMTRA.GRAU%TYPE;
  P_TIPO                     TGMTRA.TIPO%TYPE;
  P_SINAL                   TGMTRA.SINAL%TYPE;
  P_DTNEG                 TGFCAB.DTNEG%TYPE;
  P_SEQUENCIA          TGMTRA.SEQUENCIA%TYPE;
  P_SEQUENCIAITE     TGMTRA.SEQUENCIAITE%TYPE;
  CURSOR CUR_TGMTRA1 IS
        SELECT
          TRA.NUMTRANSF,
          VAR.SEQUENCIA AS SEQUENCIAITE,
          TRA.CODMETA,
          TRA.DTREF,
          TRA.CODEMP,
          TRA.CODPROD, 
          TRA.CODGRUPOPROD,
          TRA.CODLOCAL,
          TRA.CONTROLE, 
          TRA.MARCA,
          TRA.CODPROJ,
          TRA.CODCENCUS,
          TRA.CODNAT,
          TRA.CODCTACTB,
          TRA.CODREG,
          TRA.CODGER,
          TRA.CODVEND,
          TRA.CODPARC,
          TRA.CODUF,
          TRA.CODCID,
          TRA.CODPAIS,
          TRA.CODTIPPARC,
          ROUND(TRA.VALOR_ORIG / ITE.QTDNEG * VAR.QTDATENDIDA,2),
          TRA.CODUSU,
          TRA.NUFIN,
          TRA.STATUS,
          TRA.CODUSULIB,
          TRA.GRAU
        FROM TGFVAR VAR,
        TGMTRA TRA,
        TGFITE ITE
        WHERE VAR.NUNOTA = :NEW.NUNOTA
        AND VAR.NUNOTAORIG <> VAR.NUNOTA
        AND VAR.QTDATENDIDA <> 0
        AND TRA.NUNOTA = VAR.NUNOTAORIG
        AND TRA.SEQUENCIAITE = VAR.SEQUENCIAORIG
        AND TRA.TIPO = 'C'    
        AND ITE.NUNOTA = VAR.NUNOTAORIG 
        AND ITE.SEQUENCIA = VAR.SEQUENCIAORIG
        AND ITE.QTDNEG <> 0;
BEGIN

  -- VERIFICANDO SE O CLIENTE UTILIZA ESTA FUNCIONALIDADE
  SELECT COUNT(*) INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_METAS = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  SELECT COUNT(1) INTO P_COUNT
    FROM TGFVAR VAR, 
       TGMTRA TRA
   WHERE VAR.NUNOTA = :NEW.NUNOTA
     AND VAR.NUNOTAORIG <> VAR.NUNOTA
     AND TRA.NUNOTA = VAR.NUNOTAORIG
     AND TRA.SEQUENCIAITE = VAR.SEQUENCIAORIG
     AND TRA.TIPO = 'C';
  
  IF P_COUNT > 0 THEN
    DELETE FROM TGMTRA
   WHERE NUNOTA = :NEW.NUNOTA
     AND TIPO = 'M';

      OPEN CUR_TGMTRA1;
      LOOP
        FETCH CUR_TGMTRA1 INTO
          P_NUMTRANSF,
          P_SEQUENCIAITE,
          P_CODMETA,
          P_DTREF,
          P_CODEMP,
          P_CODPROD,
          P_CODGRUPOPROD,
          P_CODLOCAL,
          P_CONTROLE,
          P_MARCA,
          P_CODPROJ,
          P_CODCENCUS, 
          P_CODNAT, 
          P_CODCTACTB,
          P_CODREG, 
          P_CODGER, 
          P_CODVEND,
          P_CODPARC, 
          P_CODUF, 
          P_CODCID, 
          P_CODPAIS, 
          P_CODTIPPARC,
          P_VALOR,
          P_CODUSU,
          P_NUFIN,
          P_STATUS,
          P_CODUSULIB,
          P_GRAU;
        EXIT WHEN CUR_TGMTRA1%NOTFOUND;

        P_SEQUENCIA := SNK_GET_PROX_SEQ_TGMTRA(P_NUMTRANSF, P_SEQUENCIAITE, 1000);
	    P_NEWNUMTRANSF := SNK_VERIFICA_PK_TGMTRA(P_NUMTRANSF, P_SEQUENCIA, P_SEQUENCIAITE);
	    
	    IF(P_NEWNUMTRANSF = P_NUMTRANSF) THEN
		    P_SEQUENCIA := SNK_GET_PROX_SEQ_TGMTRA(P_NUMTRANSF, P_SEQUENCIAITE, 2000);
		    P_NEWNUMTRANSF := SNK_VERIFICA_PK_TGMTRA(P_NUMTRANSF, P_SEQUENCIA, P_SEQUENCIAITE);
		END IF;
	   
	    IF(P_NEWNUMTRANSF <> P_NUMTRANSF) THEN
			STP_TROCA_NUMTRANSF(P_NUMTRANSF, P_NEWNUMTRANSF, :NEW.NUNOTA);
	   		P_NUMTRANSF := P_NEWNUMTRANSF;
	    END IF;
	   
	    P_SEQUENCIA := SNK_GET_PROX_SEQ_TGMTRA(P_NUMTRANSF, P_SEQUENCIAITE, 1000);

        INSERT INTO TGMTRA (
          NUMTRANSF,
          SEQUENCIA,
          NUNOTA,
          SEQUENCIAITE,
          CODMETA,
          DTREF,
          CODEMP,
          CODPROD,
          CODGRUPOPROD, 
          CODLOCAL, 
          CONTROLE, 
          MARCA,
          CODPROJ, 
          CODCENCUS, 
          CODNAT, 
          CODCTACTB,
          CODREG, 
          CODGER, 
          CODVEND,
          CODPARC, 
          CODUF, 
          CODCID, 
          CODPAIS, 
          CODTIPPARC,
          TIPO,
          SINAL,
          VALOR, 
          VALOR_ORIG,
          CODUSU, 
          DTALTER,
          NUFIN,
          STATUS, 
          CODUSULIB,
          GRAU)
        VALUES (
          P_NUMTRANSF,
          P_SEQUENCIA,
          :NEW.NUNOTA,
          P_SEQUENCIAITE,
          P_CODMETA,
          P_DTREF,
          P_CODEMP,
          P_CODPROD,
          P_CODGRUPOPROD,
          P_CODLOCAL,
          P_CONTROLE,
          P_MARCA,
          P_CODPROJ,
          P_CODCENCUS,
          P_CODNAT,
          P_CODCTACTB,
          P_CODREG,
          P_CODGER,
          P_CODVEND,
          P_CODPARC,
          P_CODUF,
          P_CODCID,
          P_CODPAIS,
          P_CODTIPPARC,
          'M',
          -1,
          P_VALOR,
          P_VALOR,
          P_CODUSU,
          TRUNC(SYSDATE, 'MI'),
          P_NUFIN,
          P_STATUS,
          P_CODUSULIB,
          P_GRAU);

        BEGIN
			SELECT PERIODO INTO P_PERIODO FROM TGMCFG WHERE CODMETA = P_CODMETA;
			EXCEPTION WHEN NO_DATA_FOUND THEN P_PERIODO := 4;
		END;
		
        IF P_PERIODO = 9  THEN 
       		P_DTNEG := TRUNC(:NEW.DTNEG, 'YEAR');
       	ELSE 
       		P_DTNEG := TRUNC(:NEW.DTNEG, 'MONTH'); 
       	END IF;

        P_SEQUENCIA := SNK_GET_PROX_SEQ_TGMTRA(P_NUMTRANSF, P_SEQUENCIAITE, 2000);
	    P_NEWNUMTRANSF := SNK_VERIFICA_PK_TGMTRA(P_NUMTRANSF, P_SEQUENCIA, P_SEQUENCIAITE);
	    
	    IF(P_NEWNUMTRANSF <> P_NUMTRANSF) THEN
			STP_TROCA_NUMTRANSF(P_NUMTRANSF, P_NEWNUMTRANSF, :NEW.NUNOTA);	
	   		P_NUMTRANSF := P_NEWNUMTRANSF;
	    	P_SEQUENCIA := SNK_GET_PROX_SEQ_TGMTRA(P_NUMTRANSF, P_SEQUENCIAITE, 2000);
	    END IF;

        INSERT INTO TGMTRA (
          NUMTRANSF,
          SEQUENCIA,
          NUNOTA,
          SEQUENCIAITE,
          CODMETA,
          DTREF,
          CODEMP,
          CODPROD,
          CODGRUPOPROD,
          CODLOCAL,
          CONTROLE,
          MARCA,
          CODPROJ,
          CODCENCUS,
          CODNAT,
          CODCTACTB,
          CODREG,
          CODGER,
          CODVEND,
          CODPARC,
          CODUF,
          CODCID,
          CODPAIS,
          CODTIPPARC,
          TIPO,
          SINAL,
          VALOR,
          VALOR_ORIG,
          CODUSU,
          DTALTER,
          NUFIN,
          STATUS, CODUSULIB, GRAU)
        VALUES (
          P_NUMTRANSF,
          P_SEQUENCIA,
          :NEW.NUNOTA,
          P_SEQUENCIAITE,
          P_CODMETA,
          P_DTNEG,
          P_CODEMP,
          P_CODPROD,
          P_CODGRUPOPROD,
          P_CODLOCAL,
          P_CONTROLE,
          P_MARCA,
          P_CODPROJ,
          P_CODCENCUS,
          P_CODNAT,
          P_CODCTACTB,
          P_CODREG,
          P_CODGER,
          P_CODVEND,
          P_CODPARC,
          P_CODUF,
          P_CODCID,
          P_CODPAIS,
          P_CODTIPPARC,
          'M',
          1,
          P_VALOR,
          P_VALOR,
          P_CODUSU,
         TRUNC(SYSDATE, 'MI'),
          P_NUFIN,
          P_STATUS,
          P_CODUSULIB,
          P_GRAU);

      END LOOP;
      CLOSE CUR_TGMTRA1;


  END IF;      
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_METAS" ENABLE;
