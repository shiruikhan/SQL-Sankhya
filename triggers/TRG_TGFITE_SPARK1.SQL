create or replace TRIGGER "TRG_TGFITE_SPARK1" 
BEFORE INSERT OR UPDATE ON TGFITE 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_TGFITE_SPARK1
  Tipo           : Trigger
  Descrição      : Calcula valores complementares de volumes e preços baseado
                   em atualização de outros campos do item
  Tabela         : TGFITE
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2025
  Última Revisão : Setembro/2026 — Performance: unificados os dois SELECTs
                   idênticos (mesmo FROM/JOIN/WHERE em TGFPRO/TGFVOA) que
                   calculavam P_QTDNEG e P_VLRUNIT separadamente em uma única
                   consulta com dois retornos, eliminando uma varredura completa
                   por linha de item. Comportamento observável inalterado.
==============================================================================*/
DECLARE
P_ATUALVLR       VARCHAR2(10);
P_TIPMOV         VARCHAR2(10);
P_VLRCHEIO                  FLOAT;
P_PERC                      FLOAT;
P_QTDNEG                    FLOAT;
P_VLRUNIT                   FLOAT;

BEGIN

    BEGIN
    SELECT TPO.AD_ATUALOUTROS , NVL(TPV.TAXAJURO,0) , CAB.TIPMOV INTO P_ATUALVLR, P_PERC, P_TIPMOV
       FROM TGFCAB CAB, TGFTOP TPO, TGFTPV TPV
    WHERE CAB.CODTIPOPER = TPO.CODTIPOPER
        AND CAB.DHTIPOPER = TPO.DHALTER
        AND CAB.CODTIPVENDA = TPV.CODTIPVENDA
        AND CAB.DHTIPVENDA = TPV.DHALTER
        AND CAB.NUNOTA = :NEW.NUNOTA;
     EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN;
    END;

    IF P_ATUALVLR = 'S' AND :NEW.NUTAB > 0 THEN 

    BEGIN   
     SELECT AD_VLRTOT INTO P_VLRCHEIO
          FROM TGFEXC 
         WHERE NUTAB = :NEW.NUTAB
            AND CODPROD = :NEW.CODPROD;
             EXCEPTION WHEN NO_DATA_FOUND THEN

     P_VLRCHEIO:= 0;    
    END;    


            :NEW.AD_VLRCHEIO := P_VLRCHEIO;

    END IF;



    IF :NEW.AD_VLRCHEIO > 0 OR :NEW.AD_VLRCHEIOCOM > 0 THEN

      SELECT (CASE WHEN :NEW.CODVOL = PRO.CODVOL THEN :NEW.QTDNEG ELSE (CASE WHEN VOA.DIVIDEMULTIPLICA = 'M' THEN :NEW.QTDNEG / VOA.QUANTIDADE ELSE :NEW.QTDNEG * VOA.QUANTIDADE END) END) AS QTDNEG
            ,(CASE WHEN :NEW.CODVOL = PRO.CODVOL THEN :NEW.VLRUNIT ELSE (CASE WHEN VOA.DIVIDEMULTIPLICA = 'M' THEN :NEW.VLRUNIT * VOA.QUANTIDADE ELSE :NEW.VLRUNIT / VOA.QUANTIDADE END) END) AS VLRUNIT
        INTO P_QTDNEG, P_VLRUNIT
        FROM TGFPRO PRO
        LEFT JOIN TGFVOA VOA ON (PRO.CODPROD = VOA.CODPROD AND VOA.CODVOL = :NEW.CODVOL)
       WHERE PRO.CODPROD = :NEW.CODPROD;

    :NEW.AD_VLROUTROS := ROUND((((:NEW.AD_VLRCHEIO - :NEW.VLRUNIT) * P_QTDNEG /*:NEW.QTDNEG*/) - CASE WHEN P_TIPMOV IN ('P', 'V') THEN :NEW.AD_VLRCHEIO * P_PERC / 100 * P_QTDNEG/*:NEW.QTDNEG*/ ELSE 0 END),2);

    :NEW.AD_VLROUTROSBR := ROUND(((:NEW.AD_VLRCHEIO - :NEW.VLRUNIT) * P_QTDNEG/*:NEW.QTDNEG*/ - CASE WHEN P_TIPMOV IN ('P', 'V') THEN :NEW.AD_VLRCHEIO * P_PERC / 100 * P_QTDNEG/*:NEW.QTDNEG*/ ELSE 0 END),2);

    -- parte nova de compras 

    :NEW.AD_VLROUTROSCOMP := ROUND(((:NEW.AD_VLRCHEIOCOM - P_VLRUNIT) * P_QTDNEG/*:NEW.QTDNEG*/) ,6);

    :NEW.AD_VLROUTROSBRCOMP := ROUND(((:NEW.AD_VLRCHEIOCOM ) * P_QTDNEG/*:NEW.QTDNEG*/),6);

    -- fim parte nova


     IF P_TIPMOV  IN ( 'P','V', 'D') AND :NEW.VLRTOT > 0 THEN

     :NEW.AD_VLROUTROS := ROUND((:NEW.AD_VLROUTROSBR - (:NEW.AD_VLROUTROSBR *  (:NEW.VLRDESC/:NEW.VLRTOT)) ),2) ;

     END IF;

    END IF;

END;
