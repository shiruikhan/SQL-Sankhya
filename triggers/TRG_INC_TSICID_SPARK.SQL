CREATE OR REPLACE TRIGGER TRG_INC_TSICID_SPARK
BEFORE INSERT ON TSICID
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TSICID_SPARK
  Tipo           : Trigger
  Descrição      : Valida preenchimento obrigatório de município fiscal e
                   controla unicidade de cidades por nome e UF.
                   Quando a API REST do Sankhya tenta inserir uma cidade já
                   existente, redireciona :NEW.CODCID para o CODCID já
                   cadastrado — forçando ORA-00001 que o Sankhya trata
                   internamente como "cidade já existe, usar o registro
                   existente". O redirecionamento ocorre quando CODMUNFIS
                   coincide OU quando o registro existente não tem CODMUNFIS
                   preenchido (cadastro legado/manual). Duplicatas com
                   CODMUNFIS ativamente divergente continuam bloqueadas.
  Tabela         : TSICID
  Evento         : BEFORE INSERT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Abril/2026
  Última Revisão : Maio/2026 — Removido PRECEDES (não suportado nesta versão
                               Oracle); removida verificação de igualdade de
                               CODMUNFIS — Sankhya não propaga codigolbge para
                               CODMUNFIS no INSERT via API, causando falsa
                               divergência; unicidade real já garantida pelo
                               índice AK_NOMECID_TSICID (NOMECID+UF)
==============================================================================*/
DECLARE
    V_CODCID_EX     TSICID.CODCID%TYPE;
    V_CODMUNFIS_EX  TSICID.CODMUNFIS%TYPE;

BEGIN

    ---------------------------------------------------------------------------
    -- 1. Município fiscal obrigatório
    ---------------------------------------------------------------------------
    IF :NEW.CODMUNFIS IS NULL THEN
        RAISE_APPLICATION_ERROR(-20101, 'É obrigatório preencher o campo Municipio Fiscal!');
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Unicidade por nome e UF
    --    Se já existe uma cidade com mesmo NOMECID e UF, verifica CODMUNFIS:
    --    - CODMUNFIS igual  → API re-criando cidade existente; redireciona
    --                         :NEW.CODCID para forçar ORA-00001 controlado.
    --    - CODMUNFIS diferente → duplicata manual; bloqueia com erro.
    ---------------------------------------------------------------------------
    BEGIN
        SELECT CODCID
              ,CODMUNFIS
          INTO V_CODCID_EX
              ,V_CODMUNFIS_EX
          FROM TSICID
         WHERE UPPER(NOMECID) = UPPER(:NEW.NOMECID)
           AND UF             = :NEW.UF
           AND CODCID        <> :NEW.CODCID
           AND ROWNUM         = 1;

        :NEW.CODCID := V_CODCID_EX;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

END TRG_INC_TSICID_SPARK;
