/*==============================================================================
  Nome do Script : TRG_UPD_TGFEST
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 21/09/2026 — referência)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFEST.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 21/09/2026, última alteração em 21/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFEST', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFEST" 
BEFORE UPDATE ON TGFEST 
FOR EACH ROW
DECLARE
    P_COUNT             INT;
    ERRMSG              VARCHAR2(4000);
    ERROR               EXCEPTION;
    P_VALIDAR           BOOLEAN;
	P_DISPONIVEL		TGFEST.ESTOQUE%TYPE := 0;
	P_VALEST			VARCHAR2(1);

BEGIN
  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  /*  sincronizacao de dados */
  P_VALIDAR := Fpodevalidar('TGFEST');

  IF (:NEW.ESTOQUE < 0) AND (:NEW.CODPARC <> 0) THEN 
     ERRMSG := 'Estoque com/de Terceiros não pode ficar negativo. Produto: ' || TO_CHAR(:NEW.CODPROD);
     RAISE ERROR;
  END IF; 

  IF (VARIAVEIS_PKG.V_VALIDA_EST_RESERVAR) THEN
	  SELECT VALEST INTO P_VALEST
	    FROM TGFGRU 
	   WHERE CODGRUPOPROD = (SELECT CODGRUPOPROD FROM TGFPRO WHERE CODPROD = :NEW.CODPROD); 
	  
	  /*S - Pelo Grupo de Empresas | G - Pela soma de todas as Empresas*/
	  IF(P_VALEST IN ('S', 'G')) THEN
		  P_DISPONIVEL := :NEW.RESERVADO;
	  ELSE 
	  P_DISPONIVEL := :NEW.ESTOQUE - :NEW.RESERVADO ;
	  
	  IF(VARIAVEIS_PKG.V_WMSDESCONESTBLQ) THEN
		P_DISPONIVEL := P_DISPONIVEL - NVL(:NEW.WMSBLOQUEADO, 0);
	  END IF;
	END IF;
	  
	  IF (P_DISPONIVEL < 0)  THEN
		 ERRMSG := 'Valor de estoque disponivel negativo(Estoque: ' || TO_CHAR(:NEW.ESTOQUE) || ',Reservado: ' || TO_CHAR(:NEW.RESERVADO) || ',WMSBLOQUEADO: ' || TO_CHAR(:NEW.WMSBLOQUEADO) || ',Disponivel: ' || TO_CHAR(P_DISPONIVEL) || ') para o produto: ' || TO_CHAR(:NEW.CODPROD);
		 RAISE ERROR;
	  END IF;
  END IF;
 

  IF (:NEW.TIPO <> :OLD.TIPO) AND (:NEW.ESTOQUE <> 0) THEN
     ERRMSG := 'Coluna Tipo não pode ser alterada quando o estoque for diferente de zero. Produto: ' || TO_CHAR(:NEW.CODPROD);
     RAISE ERROR;
  END IF;   
  
  IF (:NEW.RESERVADO <> 0 ) AND (:NEW.CODPARC <> 0) THEN 
     ERRMSG := 'Reservado não pode ser diferente de zero quando parceiro diferente de zero. Produto: ' || TO_CHAR(:NEW.CODPROD);
     RAISE ERROR;
  END IF;    

  /* QDO SUBSTITUINDO PRODUTO, NAO VALIDAR ESTOQUE */
  IF (VARIAVEIS_PKG.V_SBPRODUTO) THEN
    RETURN;
  END IF;
  
  SELECT COUNT(1) INTO P_COUNT
  FROM TSIPAR
  WHERE CHAVE = 'SBPRODUTO';

  IF (P_COUNT <> 0) THEN
    RETURN;
  END IF;
/*---------------------------------------------------------------*/

  IF (:NEW.CODEMP <> :OLD.CODEMP) THEN

    SELECT COUNT(1) INTO P_COUNT
    FROM TGFEMP
    WHERE CODEMP = :NEW.CODEMP
      AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
       ERRMSG := 'Empresa não está ativa: ' || TO_CHAR(:NEW.CODEMP);
       RAISE ERROR;
    END IF;

  END IF;

  IF (:NEW.CODPROD <> :OLD.CODPROD) THEN

    SELECT COUNT(1) INTO P_COUNT
    FROM TGFPRO
    WHERE CODPROD = :NEW.CODPROD
      AND ATIVO = 'S';

    IF (P_COUNT = 0) THEN
     ERRMSG := Erros_Pkg.ERRO_PRODUTO_NAOATIVO;
     RAISE ERROR;
    END IF;

  END IF;

  IF (:NEW.CODLOCAL <> :OLD.CODLOCAL) AND (:NEW.CODLOCAL <> 0) THEN

    SELECT COUNT(1) INTO P_COUNT
    FROM TGFLOC
    WHERE CODLOCAL = :NEW.CODLOCAL
      AND ATIVO = 'S'
      AND ANALITICO = 'S';

    IF (P_COUNT = 0) THEN
       Stp_Popula_Msg('TGFLOC');
    END IF;

  END IF;
  
  IF (:NEW.CODPARC = 0) AND
       ((:NEW.ESTOQUE < :OLD.ESTOQUE) OR 
         ((:NEW.ESTOQUE = 0) AND (:NEW.RESERVADO = 0) AND (:NEW.ESTMAX = 0) AND (:NEW.ESTMIN = 0) AND (TRIM(:NEW.CODBARRA) IS NULL))) THEN

    INSERT INTO TGFEST_UPD 
        (CODEMP, CODLOCAL, CONTROLE, CODPROD, ESTOQUEOLD, ESTOQUEOLDNEW, RESERVADONEW, STATUSLOTE, WMSBLOQUEADO)
    VALUES 
        (:NEW.CODEMP, :NEW.CODLOCAL, :NEW.CONTROLE, :NEW.CODPROD, :OLD.ESTOQUE, :NEW.ESTOQUE, :NEW.RESERVADO, NVL(:NEW.STATUSLOTE,'N'), NVL(:NEW.WMSBLOQUEADO,0));

  END IF;

  RETURN;
   
EXCEPTION
  WHEN OTHERS THEN
    /* Sincronizacao de dados nao faz validacoes */
	 VARIAVEIS_PKG.V_VALIDA_EST_RESERVAR := false;
     IF (P_VALIDAR) THEN
       IF SQLCODE <> 1 THEN
         ERRMSG := ERRMSG || '  ' || SQLERRM;
       END IF;
       RAISE_APPLICATION_ERROR(-20101, ERRMSG);       
     END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFEST" ENABLE;
