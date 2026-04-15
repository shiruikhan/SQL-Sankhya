create or replace TRIGGER TRG_INC_UPD_INTEGRA
BEFORE INSERT OR UPDATE ON AD_TGSPAR
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_INTEGRA
  Tipo           : Trigger
  Descrição      : Normaliza dados de entrada, busca parceiro existente e cria automaticamente registros de bairro, endereço e parceiro se necessário.
  Tabela         : AD_TGSPAR
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    v_codparc TGFPAR.CODPARC%TYPE;
    v_codbai  TSIBAI.CODBAI%TYPE;
    v_codend  TSIEND.CODEND%TYPE;
    v_coduf   TSIUFS.CODUF%TYPE;
    v_bairro_normalizado TSIBAI.NOMEBAI%TYPE;
    v_endereco_normalizado TSIEND.NOMEEND%TYPE;

BEGIN
    -- Normaliza entradas de bairro e endereço
    v_bairro_normalizado := UPPER(TRIM(:NEW.BAIRRO));
    v_endereco_normalizado := UPPER(TRIM(:NEW.ENDERECO));
    :NEW.BAIRRO := v_bairro_normalizado;
    :NEW.ENDERECO := v_endereco_normalizado;

    -- Busca UF pela sigla (trata ausência)
    BEGIN
        SELECT CODUF INTO v_coduf 
          FROM TSIUFS 
         WHERE UF = TRIM(:NEW.SIGLA);
        :NEW.CODUF := v_coduf;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            :NEW.CODUF := NULL;
    END TRG_INC_UPD_INTEGRA;
    
    -- Busca parceiro existente com o mesmo documento (ignorando máscara)
    BEGIN
        SELECT CODPARC, CODBAI, CODEND
          INTO v_codparc, v_codbai, v_codend
          FROM (
                SELECT CODPARC, CODBAI, CODEND
                  FROM TGFPAR
                 WHERE REGEXP_REPLACE(CGC_CPF, '[^0-9]', '') = REGEXP_REPLACE(:NEW.DOCUMENTO, '[^0-9]', '')
                 FETCH FIRST 1 ROWS ONLY
               );
        
        :NEW.CODPARC := v_codparc;
        :NEW.CODBAI := v_codbai;
        :NEW.CODEND := v_codend;
        :NEW.TIPOCAD := 'E';
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            :NEW.TIPOCAD := 'N'; -- Nenhum parceiro encontrado
    END;

    -- Se não encontrou parceiro, cria bairro, endereço e parceiro
    IF :NEW.CODPARC IS NULL THEN
        -- Bairro
        BEGIN
            SELECT CODBAI
              INTO v_codbai
              FROM (
                    SELECT CODBAI
                      FROM TSIBAI
                     WHERE NOMEBAI = v_bairro_normalizado
                     FETCH FIRST 1 ROWS ONLY
                   );
            :NEW.CODBAI := v_codbai;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Bairro não existe, cria um novo
                SELECT NVL(MAX(CODBAI), 0) + 1 INTO v_codbai FROM TSIBAI;
                INSERT INTO TSIBAI (CODBAI, NOMEBAI, CODREG, DTALTER)
                VALUES (v_codbai, v_bairro_normalizado, 0, SYSDATE);
                :NEW.CODBAI := v_codbai;
        END;
        
        -- Endereço
        BEGIN
            SELECT CODEND
              INTO v_codend
              FROM (
                    SELECT CODEND
                      FROM TSIEND
                     WHERE NOMEEND = v_endereco_normalizado
                     FETCH FIRST 1 ROWS ONLY
                   );
            :NEW.CODEND := v_codend;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Endereço não existe, cria um novo
                SELECT NVL(MAX(CODEND), 0) + 1 INTO v_codend FROM TSIEND;
                INSERT INTO TSIEND (CODEND, NOMEEND, DTALTER)
                VALUES (v_codend, v_endereco_normalizado, SYSDATE);
                :NEW.CODEND := v_codend;
        END;
        
        -- Parceiro
        BEGIN            
            SELECT NVL(MAX(CODPARC), 0) + 1 INTO v_codparc FROM TGFPAR;
            
            INSERT INTO TGFPAR (
                CODPARC, TIPPESSOA, IDENTINSCESTAD, NOMEPARC, CGC_CPF, ATIVO, CLIENTE, CEP, CODEND, NUMEND, COMPLEMENTO, CODVEND,
                CODBAI, CODCID, EMAIL, EMAILNFE, RAZAOSOCIAL, CLASSIFICMS, TEMIPI, TIPANEXONFE, EMAILDANFE, IPIINCICMS, DTCAD, DTALTER, APLICLEITRANSP, RETSTVENDA
            )
            VALUES (
                v_codparc, SUBSTR(:NEW.TIPPESSOA, 1, 1), :NEW.IDENTINSCESTAD, UPPER(:NEW.RAZAOSOCIAL), :NEW.DOCUMENTO, 'S', 'S', :NEW.CEP, :NEW.CODEND, :NEW.NUMERO, :NEW.COMPLEMENTO, 6,
                :NEW.CODBAI, :NEW.CODCID, :NEW.EMAIL, :NEW.EMAIL || ';pedidos02@spark.ind.br', UPPER(:NEW.RAZAOSOCIAL), CASE WHEN TRIM(:NEW.TIPPESSOA) = 'JC' THEN 'X' ELSE 'C' END, 'S', 'X', 'S', 'S', SYSDATE, SYSDATE, 'S', CASE WHEN SUBSTR(TRIM(:NEW.TIPPESSOA), 1, 1) = 'F' THEN 'N' ELSE 'A' END
            );
                
            :NEW.CODPARC := v_codparc;
        END;
    END IF;
END;