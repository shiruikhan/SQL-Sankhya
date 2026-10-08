/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFPAR_EC
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 04/04/2023 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPAR.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 04/04/2023, última alteração em 28/09/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFPAR_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPAR_EC" BEFORE INSERT OR UPDATE
ON TGFPAR FOR EACH ROW
DECLARE
PRAGMA AUTONOMOUS_TRANSACTION;
 P_COUNT INT;

BEGIN
    IF (:NEW.USADOLV = 'S') THEN
        /* seta classificacao fiscal padrao */
        IF (:NEW.CLASSIFICMS IS NULL) THEN
            :NEW.CLASSIFICMS := (CASE WHEN :NEW.TIPPESSOA = 'F' THEN 'C' ELSE 'R' END);
        END IF;
        /* validando condicoes para integrar o parceiro */
        IF (:NEW.EMAIL IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Cliente com o campo E-mail em branco ou inválido. Favor verificar!');
        END IF;
        IF (:NEW.CLIENTE <> 'S') THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Parceiro não esta marcado como Cliente. Favor verificar!');
        END IF;
        IF (:NEW.CGC_CPF IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Campo CPF ou CNPJ está vazio. Favor verificar!');
        END IF;
        IF (:NEW.TIPPESSOA = 'J' AND (:NEW.IDENTINSCESTAD IS NULL AND UPPER(:NEW.IDENTINSCESTAD) <> 'ISENTO')) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Campo Inscrição Estadual esta Vazio. Caso o cliente seja isento, favor preencher o campo com a palavra ISENTO. Favor verificar!');
        END IF;
        IF (:NEW.CEP IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Campo CEP do cliente esta vazio. Favor verificar!');
        END IF;
        IF (:NEW.NUMEND IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Campo Numero do Endereço esta vazio. Favor verificar!');
        END IF;
        IF (:NEW.TIPPESSOA IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: Campo tipo de parceiro (Fisica ou Juridica) não esta preenchido. Favor verificar!');
        END IF;
        IF NOT REGEXP_LIKE(:NEW.EMAIL, '^[A-Za-z0-9+._-]+@[A-Za-z0-9._-]+\.[A-Za-z]{2,10}$') AND NOT :NEW.EMAIL LIKE '%mercadolivre%' THEN
            RAISE_APPLICATION_ERROR(-20101 ,'Não é permitido enviar o parceiro ' || :NEW.CODPARC || ' para o E-commerce, Motivo: O e-mail (' || :NEW.EMAIL || ') não é um e-mail válido. Favor verificar!');
        END IF;

        INSERT INTO TECLOG (CODPARC, TIPO)
        SELECT :NEW.CODPARC, 'C' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'C' AND CODPARC = :NEW.CODPARC));
        /* força atualização de preço e estoque no caso de edição do produto */
        UPDATE TECLOG SET INTEGRADO = 'N'
        WHERE TIPO IN ('C')
        AND INTEGRADO <> 'N'
        AND CODPARC = :NEW.CODPARC;

        COMMIT;
    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPAR_EC" ENABLE;
