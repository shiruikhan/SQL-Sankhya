create or replace TRIGGER TRG_VAL_AD_CODFUNC_TPRAPA
BEFORE UPDATE ON TPRAPA
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_VAL_AD_CODFUNC_TPRAPA
  Tipo           : Trigger
  Descrição      : Valida obrigatoriedade de funcionário em apontamento,
                   exceto para atividade de expedição/conferência
  Tabela         : TPRAPA
  Evento         : BEFORE UPDATE
  Escopo         : FOR EACH ROW / STATEMENT

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
DECLARE
    P_DESCRICAO VARCHAR2(100);
BEGIN
    -- Busca a descrição da etapa/atividade vinculada ao apontamento
    BEGIN
        SELECT EFX.DESCRICAO
        INTO P_DESCRICAO
        FROM TPRAPO APO 
        INNER JOIN TPRIATV IATV ON APO.IDIATV = IATV.IDIATV 
        INNER JOIN TPREFX EFX ON IATV.IDEFX = EFX.IDEFX
        WHERE APO.NUAPO = :NEW.NUAPO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            P_DESCRICAO := NULL;
    END TRG_VAL_AD_CODFUNC_TPRAPA;

    -- Valida se o campo AD_CODFUNC está preenchido, EXCETO se for 'EXPEDIÇÃO/CONFERENCIA'
    IF NVL(P_DESCRICAO, ' ') <> 'EXPEDIÇÃO/CONFERENCIA' AND NVL(P_DESCRICAO, ' ') <> 'EXPEDICAO/CONF' THEN
        IF :NEW.AD_CODFUNC IS NULL OR :NEW.AD_CODFUNC = 0 THEN
           RAISE_APPLICATION_ERROR(-20101, 'O campo Funcionário (AD_CODFUNC) é obrigatório e não pode ser zero.');
        END IF;
    END IF;
END;