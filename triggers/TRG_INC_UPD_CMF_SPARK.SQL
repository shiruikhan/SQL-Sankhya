CREATE OR REPLACE TRIGGER TRG_INC_UPD_CMF_SPARK
BEFORE INSERT OR UPDATE OF NOMECID ON TSICID
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_CMF_SPARK
  Tipo           : Trigger
  Descrição      : Normaliza nome de cidade e busca correspondência em tabela de municípios fiscais
  Tabela         : TSICID
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
  v_sort_raw   RAW(2000);
  v_id_match   AD_TGSMDF.ID%TYPE;
BEGIN
  -- Executa somente em INSERT ou quando o campo NOMECID for alterado
  IF INSERTING OR (UPDATING('NOMECID') AND NVL(:NEW.NOMECID, '§') <> NVL(:OLD.NOMECID, '§')) THEN

    IF :NEW.NOMECID IS NOT NULL THEN
      -- Normaliza o NOMECID removendo caracteres não alfanuméricos e aplicando comparação accent-insensitive
      v_sort_raw := NLSSORT(REGEXP_REPLACE(:NEW.NOMECID, '[^[:alnum:]]', ''), 'NLS_SORT=BINARY_AI');

      -- Busca o ID em AD_TGSMDF cujo MUNICIPIO normalizado corresponde ao NOMECID normalizado (case-insensitive e accent-insensitive)
      SELECT MIN(ID)
        INTO v_id_match
        FROM AD_TGSMDF
       WHERE NLSSORT(REGEXP_REPLACE(MUNICIPIO, '[^[:alnum:]]', ''), 'NLS_SORT=BINARY_AI') = v_sort_raw;

      -- Se encontrou correspondência, atualiza o CODMUNFIS do registro atual
      IF v_id_match IS NOT NULL THEN
        :NEW.CODMUNFIS := v_id_match;
      END IF;
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- Em caso de erro inesperado, não impede a operação, mas registra a exceção via raise para manter integridade/transparência
    -- Ajuste este tratamento conforme a política de erros da sua instância
    RAISE;
END TRG_INC_UPD_CMF_SPARK;
/