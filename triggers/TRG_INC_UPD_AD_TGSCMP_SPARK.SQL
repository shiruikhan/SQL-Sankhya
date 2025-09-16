create or replace TRIGGER TRG_INC_UPD_AD_TGSCMP_SPARK
BEFORE INSERT OR UPDATE ON AD_TGSCMP
FOR EACH ROW
DECLARE
    v_referencia   TGFPRO.REFERENCIA%TYPE;
    v_marca        TGFPRO.MARCA%TYPE;
    v_pesobruto    TGFPRO.PESOBRUTO%TYPE;
    v_altura       TGFPRO.ALTURA%TYPE;
    v_largura      TGFPRO.LARGURA%TYPE;
    v_espessura    TGFPRO.ESPESSURA%TYPE;
    v_unidade      TGFPRO.UNIDADE%TYPE;
BEGIN
    IF :NEW.CODPROD IS NOT NULL THEN
        BEGIN
            SELECT REFERENCIA, MARCA, PESOBRUTO, ALTURA, LARGURA, ESPESSURA, UNIDADE
              INTO v_referencia, v_marca, v_pesobruto, v_altura, v_largura, v_espessura, v_unidade
              FROM TGFPRO
             WHERE CODPROD = :NEW.CODPROD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_referencia := NULL;
                v_marca      := NULL;
                v_pesobruto  := NULL;
                v_altura     := NULL;
                v_largura    := NULL;
                v_espessura  := NULL;
                v_unidade    := NULL;
        END;

        :NEW.REFERENCIA := v_referencia;
        :NEW.MARCA      := v_marca;
        :NEW.PESOBRUTO  := v_pesobruto;
        :NEW.ALTURA     := v_altura;
        :NEW.LARGURA    := v_largura;
        :NEW.ESPESSURA  := v_espessura;
        :NEW.UNIDADE    := v_unidade;
    ELSE
        :NEW.REFERENCIA := NULL;
        :NEW.MARCA      := NULL;
        :NEW.PESOBRUTO  := NULL;
        :NEW.ALTURA     := NULL;
        :NEW.LARGURA    := NULL;
        :NEW.ESPESSURA  := NULL;
        :NEW.UNIDADE    := NULL;
    END IF;
END;