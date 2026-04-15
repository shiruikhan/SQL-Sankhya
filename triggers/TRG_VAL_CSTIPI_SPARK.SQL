CREATE OR REPLACE TRIGGER TRG_VAL_CSTIPI_SPARK
BEFORE INSERT OR UPDATE ON TGFITE
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_VAL_CSTIPI_SPARK
  Tipo           : Trigger
  Descrição      : Valida obrigatoriedade de CST IPI para empresa 1 em
                   operações de compra
  Tabela         : TGFITE
  Evento         : BEFORE INSERT
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODEMP INT;
    P_TIPMOV VARCHAR2(1);
BEGIN
    -- Valida se o campo CSTIPI é 0 ou nulo
    IF :NEW.CSTIPI IS NULL OR :NEW.CSTIPI = 0 THEN
        BEGIN
            -- Busca CODEMP e TIPMOV na tabela pai TGFCAB
            SELECT CODEMP, TIPMOV
            INTO P_CODEMP, P_TIPMOV
            FROM TGFCAB
            WHERE NUNOTA = :NEW.NUNOTA;

            -- Verifica se é Empresa 1 e Tipo de Movimento 'C'
            IF P_CODEMP = 1 AND P_TIPMOV = 'C' THEN
                RAISE_APPLICATION_ERROR(-20101, 'O campo CST IPI não pode ser 0 ou nulo para esta operação (Empresa 1, Tipo Movimento C).');
            END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Caso não encontre a nota (ex: carga de dados inconsistente), não valida
                NULL;
        END TRG_VAL_CSTIPI_SPARK;
    END IF;
END;
