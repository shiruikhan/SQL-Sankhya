CREATE OR REPLACE TRIGGER TRG_INC_TSICID_SPARK
BEFORE INSERT ON TSICID
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TSICID_SPARK
  Tipo           : Trigger
  Descrição      : Valida preenchimento obrigatório de município fiscal e
                   normaliza o nome da cidade para o valor canônico já
                   cadastrado em TSICID (comparação case-insensitive por
                   UPPER). O Sankhya sempre insere NOMECID em maiúsculas via
                   API; ao normalizar :NEW.NOMECID para o valor existente,
                   força ORA-00001 na AK_NOMECID_TSICID que o Sankhya trata
                   como "cidade já existe, usar o registro existente".
  Tabela         : TSICID
  Evento         : BEFORE INSERT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2026
  Última Revisão : Maio/2026 — Removido PRECEDES (não suportado nesta versão
                               Oracle); substituído redirect de CODCID por
                               normalização de NOMECID para valor canônico
                               existente — força AK_NOMECID_TSICID (tratado
                               graciosamente pelo Sankhya) em vez de PK
                               (não tratado); Sankhya sempre insere em
                               maiúsculas via API REST
==============================================================================*/
DECLARE
    V_NOMECID_EX  TSICID.NOMECID%TYPE;

BEGIN

    ---------------------------------------------------------------------------
    -- 1. Município fiscal obrigatório
    ---------------------------------------------------------------------------
    IF :NEW.CODMUNFIS IS NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 'É obrigatório preencher o campo Municipio Fiscal!');
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Normaliza NOMECID para o valor canônico já existente (case-insensitive)
    --    Sankhya insere cidades em maiúsculas via API; ao igualar :NEW.NOMECID
    --    ao valor exato do registro existente, a AK_NOMECID_TSICID dispara
    --    com match exato — o Sankhya trata esse ORA-00001 usando o CODCID
    --    já cadastrado, sem criar duplicata.
    ---------------------------------------------------------------------------
    BEGIN
        SELECT NOMECID
          INTO V_NOMECID_EX
          FROM TSICID
         WHERE UPPER(NOMECID) = UPPER(:NEW.NOMECID)
           AND UF             = :NEW.UF
           AND ROWNUM         = 1;

        :NEW.NOMECID := V_NOMECID_EX;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

END TRG_INC_TSICID_SPARK;
