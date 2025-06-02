create or replace TRIGGER TRG_INC_ATUALIZAATRIB_SPARK
BEFORE INSERT ON AD_MKTPMELIATRIB
FOR EACH ROW
DECLARE
    v_compldesc   varchar2(100);
    v_altura      varchar2(100);
    v_espessura   varchar2(100);
    v_largura     varchar2(100);
    v_pesobruto   varchar2(100);
    v_referencia  varchar2(100);
BEGIN
    -- Preenchimento fixo para BRAND
    IF :NEW.IDATRIBUTO = 'BRAND' THEN
        :NEW.VALUE_ID := 'Usina';
        :NEW.VALUE_NAME := 'Usina';
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para MODEL
    IF :NEW.IDATRIBUTO = 'MODEL' THEN
        SELECT COMPLDESC INTO v_compldesc FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_compldesc;
        :NEW.VALUE_NAME := v_compldesc;
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para HEIGHT
    IF :NEW.IDATRIBUTO = 'HEIGHT' THEN
        SELECT ALTURA || 'cm' INTO v_altura FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_altura;
        :NEW.VALUE_NAME := v_altura;
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para LENGTH
    IF :NEW.IDATRIBUTO = 'LENGTH' THEN
        SELECT ESPESSURA || 'cm' INTO v_espessura FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_espessura;
        :NEW.VALUE_NAME := v_espessura;
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para WIDTH
    IF :NEW.IDATRIBUTO = 'WIDTH' THEN
        SELECT ESPESSURA || 'cm' INTO v_largura FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_largura;
        :NEW.VALUE_NAME := v_largura;
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para WEIGHT
    IF :NEW.IDATRIBUTO = 'WEIGHT' THEN
        SELECT PESOBRUTO || 'Kg' INTO v_pesobruto FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_pesobruto;
        :NEW.VALUE_NAME := v_pesobruto;
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para SELLER_SKU
    IF :NEW.IDATRIBUTO = 'SELLER_SKU' THEN
        :NEW.VALUE_ID := TO_CHAR(:NEW.CODPROD);
        :NEW.VALUE_NAME := TO_CHAR(:NEW.CODPROD);
        :NEW.ACTIVE := 'S';
    END IF;

    -- Preenchimento para GTIN
    IF :NEW.IDATRIBUTO = 'GTIN' THEN
        SELECT REFERENCIA INTO v_referencia FROM TGFPRO WHERE CODPROD = :NEW.CODPROD;
        :NEW.VALUE_ID := v_referencia;
        :NEW.VALUE_NAME := v_referencia;
        :NEW.ACTIVE := 'S';
    END IF;
END;