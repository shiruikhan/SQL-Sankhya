/*==============================================================================
  Nome do Script : TRG_INC_TGFCAB_EC
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 04/04/2023 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT sobre TGFCAB.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 04/04/2023, última alteração em 26/06/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026 (recaptura em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('TRIGGER', 'TRG_INC_TGFCAB_EC', 'SPARKPRD').
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_TGFCAB_EC" BEFORE INSERT ON TGFCAB
FOR EACH ROW
 WHEN (NEW.CODPEDLV IS NOT NULL AND NEW.TIPMOV = 'P') DECLARE
 P_COUNT      INT;

 P_CODUSU     TGFCAB.CODUSU%TYPE;
 P_ATVENDPDEC TSIPAR.LOGICO%TYPE;

 P_CODCON TGFCTT.CODCONTATO%TYPE;
 P_CODEND TSIEND.CODEND%TYPE;
 P_CODBAI TSIBAI.CODBAI%TYPE;
 P_CODUF  TSIUFS.CODUF%TYPE;
 P_CODCID TSICID.CODCID%TYPE;
 P_CPF    TGFCTT.CPF%TYPE;
 P_CNPJ   TGFCTT.CNPJ%TYPE;

 P_EMAIL  TGFPAR.EMAIL%TYPE;
 P_END    TSIEND.NOMEEND%TYPE;
 P_NRO    TGFCTT.NUMEND%TYPE;
 P_COM    TGFCTT.COMPLEMENTO%TYPE;
 P_BAI    TSIBAI.NOMEBAI%TYPE;
 P_CID    TSICID.NOMECID%TYPE;
 P_UFS    TSIUFS.UF%TYPE;
 P_CEP    TGFCTT.CEP%TYPE;
 P_NENT   TGFCTT.NOMECONTATO%TYPE;
 P_TIPPESSOA TGFPAR.TIPPESSOA%TYPE;

 P_TEXTO  VARCHAR(500);

 CURSOR C_END IS SELECT TRIM(REGEXP_SUBSTR(RTRIM(REPLACE(:NEW.ENDENVIOLV, ';', '; ')),'[^;]+', 1, LEVEL)) AS DADOS FROM DUAL
                 CONNECT BY REGEXP_SUBSTR(RTRIM(:NEW.ENDENVIOLV), '[^;]+', 1, LEVEL) IS NOT NULL;
BEGIN

    BEGIN
        SELECT NVL(INTEIRO, -1) INTO P_CODUSU FROM TSIPAR WHERE CHAVE = 'CODUSUEC';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        P_CODUSU := -1;
    END;

    IF :NEW.CODUSU <> P_CODUSU OR :NEW.TIPMOV <> 'P' THEN
        :NEW.CODPEDLV := NULL;
        :NEW.STPEDLV  := NULL;
        :NEW.REFPEDLV := NULL;
    ELSE
        BEGIN
            SELECT LOGICO INTO P_ATVENDPDEC FROM TSIPAR WHERE CHAVE = 'ATVENDPDEC';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            P_ATVENDPDEC := 'N';
        END;

        IF P_ATVENDPDEC = 'S' THEN
            SELECT CODVEND INTO :NEW.CODVEND FROM TGFPAR WHERE CODPARC = :NEW.CODPARC;
        END IF;

        /* monta endereço de entrega - usa se existe, inclui se não existir */
        P_COUNT := 1;

        OPEN C_END;
            LOOP
                FETCH C_END INTO P_TEXTO;
                EXIT WHEN C_END%NOTFOUND;

                IF P_COUNT <> 1 THEN
                    P_TEXTO := TRANSLATE(UPPER(P_TEXTO),'ÃÄÊÍÕÚÂÉÁÀáéêôÔÇ?!@#$%&*Õõã', 'AAEIOUAEAAaeeoOC        Ooa');
                END IF;

                IF P_COUNT = 1 THEN
                    P_EMAIL := TRIM(P_TEXTO);
                ELSIF P_COUNT = 2 THEN
                    P_END :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 3 THEN
                    P_NRO :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 4 THEN
                    P_COM :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 5 THEN
                    P_BAI :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 6 THEN
                    P_CID :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 7 THEN
                    P_UFS :=  UPPER(TRIM(P_TEXTO));
                ELSIF P_COUNT = 8 THEN
                    P_CEP :=  TRIM(P_TEXTO);
                ELSIF P_COUNT = 9 THEN
                    P_NENT := UPPER(TRIM(P_TEXTO));
                END IF;

                P_COUNT := P_COUNT + 1;
            END LOOP;
        CLOSE C_END;

        /* obtem end, bai e cid - usa se existir, inclui se não existir */
        BEGIN  -- endereço
            SELECT CODEND INTO P_CODEND FROM TSIEND WHERE TRANSLATE(TRIM(UPPER(NOMEEND)),'ÃÄÊÍÕÚÂÉÁÀáéêôÔÇ?!@#$%&*Õõã', 'AAEIOUAEAAaeeoOC        Ooa') = P_END AND ROWNUM = 1 ORDER BY 1 DESC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            BEGIN
                UPDATE TGFNUM SET ULTCOD = ULTCOD + 1   WHERE  ARQUIVO = 'TSIEND';
                SELECT ULTCOD INTO P_CODEND FROM TGFNUM WHERE  ARQUIVO = 'TSIEND';

                INSERT INTO TSIEND(CODEND, NOMEEND, DESCRICAOCORREIO, DTALTER) VALUES(P_CODEND, P_END, P_END, SYSDATE);
            END;
        END;

        BEGIN  -- bairro
            SELECT CODBAI INTO P_CODBAI FROM TSIBAI WHERE TRANSLATE(TRIM(UPPER(NOMEBAI)),'ÃÄÊÍÕÚÂÉÁÀáéêôÔÇ?!@#$%&*Õõã', 'AAEIOUAEAAaeeoOC        Ooa') = P_BAI AND ROWNUM = 1 ORDER BY 1 DESC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            BEGIN
                UPDATE TGFNUM SET ULTCOD = ULTCOD + 1   WHERE  ARQUIVO = 'TSIBAI';
                SELECT ULTCOD INTO P_CODBAI FROM TGFNUM WHERE  ARQUIVO = 'TSIBAI';

                INSERT INTO TSIBAI(CODBAI, NOMEBAI, DESCRICAOCORREIO, DTALTER, CODREG) VALUES(P_CODBAI, P_BAI, P_BAI, SYSDATE, 0);
            END;
        END;

        BEGIN  -- UF
            SELECT CODUF INTO P_CODUF FROM TSIUFS WHERE TRANSLATE(TRIM(UPPER(UF)),'ÃÄÊÍÕÚÂÉÁÀáéêôÔÇ?!@#$%&*Õõã', 'AAEIOUAEAAaeeoOC        Ooa') = P_UFS
            AND ROWNUM = 1 ORDER BY 1 DESC;
        END;

        -- cidade não inclui, pois exige código de município fiscal, então deve ser inserido manualmente
        BEGIN
            SELECT CODCID INTO P_CODCID FROM TSICID WHERE TRANSLATE(TRIM(UPPER(NOMECID)),'ÃÄÊÍÕÚÂÉÁÀáéêôÔÇ?!@#$%&*Õõã', 'AAEIOUAEAAaeeoOC        Ooa') = P_CID AND UF = P_CODUF
            AND ROWNUM = 1 ORDER BY 1 DESC;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            BEGIN
                RAISE_APPLICATION_ERROR(-20101 ,'Cidade não localizada. Efetue o cadastro da cidade igual ao nome em destaque e preencha o código do IBGE para faturamento: >>' || P_CID ||'<<');
            END;
        END;

        -- trata inclusão ou não do contato
        BEGIN
            SELECT CODCONTATO INTO P_CODCON
            FROM TGFCTT
            WHERE CODPARC = :NEW.CODPARC
            AND CODEND = P_CODEND
            AND NUMEND = P_NRO
            AND COMPLEMENTO = P_COM
            AND CODBAI = P_CODBAI
            AND CODCID = P_CODCID
            AND CEP = P_CEP
            AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT (CASE WHEN TIPPESSOA = 'F' THEN CGC_CPF ELSE NULL END)
                     , (CASE WHEN TIPPESSOA = 'J' THEN CGC_CPF ELSE NULL END)
                INTO P_CPF, P_CNPJ
                FROM TGFPAR WHERE CODPARC = :NEW.CODPARC;

                SELECT NVL(MAX(CODCONTATO), 1)+1 INTO P_CODCON FROM TGFCTT WHERE CODPARC = :NEW.CODPARC;
                INSERT INTO TGFCTT(CODPARC, CODCONTATO, NOMECONTATO, EMAIL, CODEND, NUMEND, COMPLEMENTO, CODBAI, CODCID, CEP, CPF, CNPJ)
                VALUES(:NEW.CODPARC, P_CODCON, P_NENT, P_EMAIL, P_CODEND, P_NRO, P_COM, P_CODBAI, P_CODCID, P_CEP, P_CPF, P_CNPJ);
            END;
        END;

        -- vincula contato ao pedido
        :NEW.CODCONTATO        := P_CODCON;
        :NEW.CODCONTATOENTREGA := P_CODCON;

    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_TGFCAB_EC" ENABLE;
