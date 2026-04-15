CREATE OR REPLACE TRIGGER TRG_APOQLD_INS_SPARK
BEFORE INSERT OR UPDATE ON AD_APOQLD 
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_APOQLD_INS_SPARK
  Tipo           : Trigger
  Descrição      : Popula CODPROD em AD_APOQLD a partir de TPRIPROC.
                  Busca código de produto PA (iniciados com 2 ou 3) associado ao lote de processo.
  Tabela         : AD_APOQLD
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_CODPROD INTEGER;	
    P_FICPRO TPRIPROC.NROLOTE%TYPE;
BEGIN
    P_FICPRO := :NEW.FICPRO;

    BEGIN
        SELECT CODPRODPA
        INTO P_CODPROD
        FROM (
            SELECT DISTINCT IPA.CODPRODPA
            FROM TPRIPROC OP
            INNER JOIN TPRIPA IPA ON OP.IDIPROC = IPA.IDIPROC
            WHERE OP.NROLOTE = P_FICPRO
              AND SUBSTR(IPA.CODPRODPA,1,1) IN ('2','3')
        )
        WHERE ROWNUM = 1; -- Garante que só retorna 1 linha

        :NEW.CODPROD := P_CODPROD;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            :NEW.CODPROD := NULL; -- Ou um valor padrão, se aplicável
        WHEN TOO_MANY_ROWS THEN
            -- Alternativamente, esse bloco não será atingido pois usamos ROWNUM = 1
            NULL;
        WHEN OTHERS THEN
            -- Log ou tratamento adicional se necessário
            :NEW.CODPROD := NULL;
    END TRG_APOQLD_INS_SPARK;
END;
