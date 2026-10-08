/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGFPRO_EC
  Tipo           : Trigger de origem Sankhya (lote de atualização do ERP de 04/04/2023 — referência)
  Descrição      : Trigger BEFORE EACH ROW INSERT OR UPDATE sobre TGFPRO.
  Empresa        : Spark Eletrônica
  Observações    : - Estado no banco: ENABLED; criada em 04/04/2023, última alteração em 30/06/2026.
                   - Objeto do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_INC_UPD_TGFPRO_EC', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPRO_EC" BEFORE INSERT OR UPDATE ON TGFPRO FOR EACH ROW
DECLARE
 P_COUNT INT;

BEGIN
    /* barra desabilitar produtos já integrados */

    IF UPDATING ('USADOLV') THEN
        IF (:OLD.USADOLV = 'S' AND :NEW.USADOLV = 'N') THEN
            RAISE_APPLICATION_ERROR(-20101, 'Produto código ' || :NEW.CODPROD || ' - Não é possível voltar o campo "Usado no E-commerce" para NAO. Caso queira desativar o produto no site, altere o campo "Situação no E-commerce".');
        END IF;
    END IF;

    IF :NEW.USADOLV = 'S' THEN

        IF UPDATING ('ATIVO') THEN
            IF ((:OLD.ATIVO = 'S' AND :NEW.ATIVO = 'N') AND NVL(:NEW.SITUACAOLV,'') <> 'E')  THEN /* Linha que impede de desativar produto no ERP sem marcar ele como excluído na loja virtual. */
                RAISE_APPLICATION_ERROR(-20101, 'Produto código ' || :NEW.CODPROD || ' - Este produto é utilizado no E-commerce. Para desativa-lo é necessário alterar o campo "Situação no E-commerce" para "Excluído".');
            END IF;
        END IF;

        /* Valida quantidade máxima de produto a serem enviados ao E-commerce. Alterar a quantidade de acordo com o contrato do cliente */
        IF LENGTH(:NEW.DESCLONGALV) > 5000 THEN
            RAISE_APPLICATION_ERROR(-20101, 'Produto código ' || :NEW.CODPROD || ' - O vampo "Descrição longa (E-commerce)" não pode ter mais que 5.000 caracteres. Limite este campo a 5.000 caracteres para salvar o produto.');
        END IF;

        IF :NEW.NOMEPRDLV IS NULL OR TRIM(:NEW.NOMEPRDLV) = '' THEN
            RAISE_APPLICATION_ERROR(-20101, 'Produto código ' || :NEW.CODPROD || ' - O campo "Nome (E-commerce)" é obrigatório para produtos habilitados no E-commerce.');
        END IF;

        /* valida se o produto está sendo enviado pela primeira vez para Usado na Loja Virtual. Se for o caso, é necessario inserir o Preço e Estoque na integracao */
        INSERT INTO TECLOG (CODPROD, TIPO) SELECT :NEW.CODPROD, 'P' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'P' AND CODPROD = :NEW.CODPROD));
        INSERT INTO TECLOG (CODPROD, TIPO) SELECT :NEW.CODPROD, 'E' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'E' AND CODPROD = :NEW.CODPROD));
        INSERT INTO TECLOG (CODPROD, TIPO) SELECT :NEW.CODPROD, 'R' FROM DUAL WHERE NOT EXISTS ((SELECT 1 FROM TECLOG WHERE TIPO = 'R' AND CODPROD = :NEW.CODPROD));

        /* força atualização de preço e estoque no caso de edição do produto */
        UPDATE TECLOG SET INTEGRADO = 'N' WHERE TIPO IN ('P', 'R', 'E') AND INTEGRADO <> 'N' AND CODPROD = :NEW.CODPROD;

    END IF;
END;
/
ALTER TRIGGER "SPARKPRD"."TRG_INC_UPD_TGFPRO_EC" ENABLE;
