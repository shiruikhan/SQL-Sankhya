/*==============================================================================
  Nome do Script : TRG_UPD_TGFCAB_FLEX
  Tipo           : Trigger Nativa Sankhya (instalação do ERP, 12/2021 — referência, não customizada)
  Descrição      : Trigger BEFORE EACH ROW UPDATE sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 07/12/2021, última alteração em 03/07/2024.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_UPD_TGFCAB_FLEX', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_FLEX" 
BEFORE UPDATE ON TGFCAB FOR EACH ROW
    WHEN (
      (NEW.CODVEND <> OLD.CODVEND) OR 
      (NEW.CODTIPOPER <> OLD.CODTIPOPER) OR
      (NEW.DHTIPOPER <> OLD.DHTIPOPER) OR
      (NEW.CODPARC <> OLD.CODPARC) OR    
      (NEW.CODTIPVENDA <> OLD.CODTIPVENDA) OR
      (NEW.DHTIPVENDA <> OLD.DHTIPVENDA) OR      
      (NEW.CODEMP <> OLD.CODEMP)
      ) DECLARE
  P_ATUALACDC         TGFTOP.ATUALACDC%TYPE;
  P_ATUALACDC_D       TGFTOP.ATUALACDC%TYPE;
  P_GRUPORETENCAO     TGFVEN.GRUPORETENCAO%TYPE; 
  P_GRUPORETENCAO_D   TGFVEN.GRUPORETENCAO%TYPE;
  P_RETDESCDEV        CHAR(1);
  P_FLEXNEW           CHAR(1);
  P_FLEXOLD           CHAR(1);
  ERROR               EXCEPTION;
  ERRMSG              VARCHAR2(255);
  P_VALIDAR           BOOLEAN;
  P_COUNT             NUMBER(10);
BEGIN

  IF STP_GET_ATUALIZANDO THEN
    RETURN;
  END IF;

  SELECT COUNT(*) 
  INTO P_COUNT
  FROM TSIVARBD
  WHERE UTILIZA_FLEX = 'N';
  IF P_COUNT > 0 THEN 
    RETURN;
  END IF;

  IF :NEW.TIPMOV = 'D' THEN
    BEGIN
      SELECT LOGICO 
      INTO P_RETDESCDEV
      FROM TSIPAR 
      WHERE CHAVE = 'RETDESCDEV';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      P_RETDESCDEV := 'S';
    END;
    IF P_RETDESCDEV = 'S' THEN
      RETURN;
    END IF;
  END IF;
  
  SELECT COUNT(1) 
  INTO P_COUNT
  FROM TGFITE I 
  WHERE I.NUNOTA = :NEW.NUNOTA 
  AND NVL(I.VLRACRESCDESC,0) <> 0;
  IF P_COUNT = 0 THEN
    RETURN;
  END IF;
  
  BEGIN
    SELECT EMP.FLEX FLEXNEW, EMPD.FLEX FLEXOLD
    INTO P_FLEXNEW, P_FLEXOLD
    FROM TGFEMP EMP
    , TGFEMP EMPD
    WHERE EMP.CODEMP = :NEW.CODEMP
    AND EMPD.CODEMP = :OLD.CODEMP;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ERRMSG := 'Não foi possível encontrar os dados da empresa para validar a alteração do saldo FLEX. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END;
  IF P_FLEXNEW = 'N' AND P_FLEXOLD = 'N' THEN
    RETURN;
  END IF;
  
  BEGIN
    SELECT PAR.FLEX FLEXNEW, PARD.FLEX FLEXOLD
    INTO P_FLEXNEW, P_FLEXOLD
    FROM TGFPAR PAR
    , TGFPAR PARD
    WHERE PAR.CODPARC = :NEW.CODPARC
    AND PARD.CODPARC = :OLD.CODPARC;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ERRMSG := 'Não foi possível encontrar os dados do parceiro para validar a alteração do saldo FLEX. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END;
  IF P_FLEXNEW = 'N' AND P_FLEXOLD = 'N' THEN
    RETURN;
  END IF;
  
  BEGIN
    SELECT TPV.FLEX FLEXNEW, TPVD.FLEX FLEXOLD
    INTO P_FLEXNEW, P_FLEXOLD
    FROM TGFTPV TPV
    , TGFTPV TPVD
    WHERE TPV.CODTIPVENDA = :NEW.CODTIPVENDA
    AND TPV.DHALTER = :NEW.DHTIPVENDA
    AND TPVD.CODTIPVENDA = :OLD.CODTIPVENDA
    AND TPVD.DHALTER = :OLD.DHTIPVENDA;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ERRMSG := 'Não foi possível encontrar os dados do tipo de negociação para validar a alteração do saldo FLEX. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END;
  IF P_FLEXNEW = 'N' AND P_FLEXOLD = 'N' THEN
    RETURN;
  END IF;
  
  BEGIN
    SELECT NVL(ATUALACDC,'N') 
    INTO P_ATUALACDC
    FROM TGFTOP
    WHERE CODTIPOPER = :NEW.CODTIPOPER
    AND DHALTER = :NEW.DHTIPOPER;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ERRMSG := 'Não foi encontrada a TOP ' || TO_CHAR(:NEW.CODTIPOPER) || ' com data de alteração igual a ' || TO_CHAR(:NEW.DHTIPOPER) || '. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END;   

  IF (:NEW.CODTIPOPER = :OLD.CODTIPOPER) AND
     (:NEW.DHTIPOPER = :OLD.DHTIPOPER) THEN
    P_ATUALACDC_D := P_ATUALACDC;
  ELSE
    BEGIN
      SELECT NVL(ATUALACDC,'N')  
      INTO P_ATUALACDC_D
      FROM TGFTOP
      WHERE CODTIPOPER = :OLD.CODTIPOPER
      AND DHALTER = :OLD.DHTIPOPER;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      ERRMSG := 'Não foi encontrada a TOP ' || TO_CHAR(:OLD.CODTIPOPER) || ' com data de alteração igual a ' || TO_CHAR(:OLD.DHTIPOPER) || '. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
      RAISE ERROR;
    END;      
  END IF;
   
  IF P_ATUALACDC = 'N' AND P_ATUALACDC_D = 'N' THEN
    RETURN;
  END IF;
  
  BEGIN
    SELECT GRUPORETENCAO 
    INTO P_GRUPORETENCAO
    FROM TGFVEN
    WHERE CODVEND = :NEW.CODVEND;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    ERRMSG := 'Não foi encontrado o vendedor ' || TO_CHAR(:NEW.CODVEND) || '. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END;   

  IF :OLD.CODVEND = :NEW.CODVEND THEN
    P_GRUPORETENCAO_D := P_GRUPORETENCAO;
  ELSE
    BEGIN
      SELECT GRUPORETENCAO 
      INTO P_GRUPORETENCAO_D
      FROM TGFVEN
      WHERE CODVEND = :OLD.CODVEND;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      ERRMSG := 'Não foi encontrado o vendedor ' || TO_CHAR(:OLD.CODVEND) || '. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
      RAISE ERROR;
    END;   
  END IF;
  
  IF P_GRUPORETENCAO IS NULL AND P_GRUPORETENCAO_D IS NULL THEN
    RETURN;        
  END IF;
       
  IF :NEW.TIPMOV = 'D' AND NVL(P_GRUPORETENCAO,'.') <> 'PARCEIRO' AND NVL(P_GRUPORETENCAO_D,'.') <> 'PARCEIRO' THEN
    RETURN;
  END IF;
  
  IF P_GRUPORETENCAO_D IS NOT NULL AND P_GRUPORETENCAO_D <> NVL(P_GRUPORETENCAO,',.;+-[]') THEN
    ERRMSG := 'Divergência na configuração do FLEX dos vendedores antigo e novo. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END IF;
  
  IF :NEW.CODVEND <> :OLD.CODVEND AND 
     (NVL(P_GRUPORETENCAO,P_GRUPORETENCAO_D) <> 'PARCEIRO' OR
      NVL(P_GRUPORETENCAO_D,P_GRUPORETENCAO) <> 'PARCEIRO')
  THEN
    ERRMSG := 'Em operações com FLEX por vendedor, o vendedor não pode ser alterado. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END IF;
  
  IF :NEW.CODPARC <> :OLD.CODPARC AND 
     (NVL(P_GRUPORETENCAO, P_GRUPORETENCAO_D) = 'PARCEIRO' OR
      NVL(P_GRUPORETENCAO_D, P_GRUPORETENCAO) = 'PARCEIRO')
  THEN
    ERRMSG := 'Em operações com FLEX por parceiro, o parceiro não pode ser alterado. Nota de Nro Único: '|| TO_CHAR(:NEW.NUNOTA) ||'.';
    RAISE ERROR;
  END IF;
  
/* --Quando altera informações do cabeçalho, na aplicação, o flex é recalculado e atualizado saldo pela trigger da TGFITE.  
  INSERT INTO TGFCAB_UPD_FLEX(NUNOTA, ATUALACDC, ATUALACDC_D, 
                              CODVEND, CODVEND_D,
                              CODPARC, CODPARC_D,
                              GRUPORETENCAO, GRUPORETENCAO_D,
                              TIPMOV)
                      VALUES (:NEW.NUNOTA, P_ATUALACDC, P_ATUALACDC_D,
                              :NEW.CODVEND, :OLD.CODVEND,
                              :NEW.CODPARC, :OLD.CODPARC,
                              P_GRUPORETENCAO, P_GRUPORETENCAO_D,
                              :NEW.TIPMOV);
*/
  
EXCEPTION WHEN ERROR THEN

  IF Fpodevalidar('TGFCAB') THEN
    RAISE_APPLICATION_ERROR(-20101, ERRMSG);
  END IF;
  
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_UPD_TGFCAB_FLEX" ENABLE;
