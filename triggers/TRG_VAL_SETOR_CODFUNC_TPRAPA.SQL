CREATE OR REPLACE TRIGGER TRG_VAL_SETOR_CODFUNC_TPRAPA
BEFORE INSERT OR UPDATE ON TPRAPA
FOR EACH ROW
DECLARE
/*==============================================================================
  Nome do Script : TRG_VAL_SETOR_CODFUNC_TPRAPA
  Descrição      : Valida se o colaborador apontado (AD_CODFUNC) pertence ao
                   setor correspondente à etapa do apontamento (TPREFX).
                   O mapeamento entre departamento (TFPDEP.DESCRDEP) e etapa
                   (TPREFX.DESCRICAO) é mantido na tabela AD_MAP_SETOR_FUNC,
                   pois os nomes não são padronizados entre as duas origens.
                   Se a etapa não possui mapeamento, a validação é ignorada.
  Revisor        : Silvio Vieira | Analista de Sistemas Sênior | Spark Eletrônica
  Data Criação   : 31/03/2026
  Última Revisão : 31/03/2026
==============================================================================*/
    P_SETOR_APO   TPREFX.DESCRICAO%TYPE;
    P_SETOR_FUNC  TFPDEP.DESCRDEP%TYPE;
    P_NOMEFUNC    TFPFUN.NOMEFUNC%TYPE;
    P_TEM_MAPA    NUMBER;
    P_TEM_MATCH   NUMBER;
BEGIN
    -- Ignora validação se AD_CODFUNC não foi informado (outra trigger já valida)
    IF :NEW.AD_CODFUNC IS NULL OR :NEW.AD_CODFUNC = 0 THEN
        RETURN;
    END IF;

    -- Busca o setor da etapa vinculada ao apontamento
    BEGIN
        SELECT EFX.DESCRICAO
          INTO P_SETOR_APO
          FROM TPRAPO APO
         INNER JOIN TPRIATV IATV ON APO.IDIATV = IATV.IDIATV
         INNER JOIN TPREFX  EFX  ON IATV.IDEFX  = EFX.IDEFX
         WHERE APO.NUAPO = :NEW.NUAPO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN; -- Etapa não definida; sem como validar
    END;

    -- Verifica se existe mapeamento para essa etapa; se não houver, ignora
    SELECT COUNT(1)
      INTO P_TEM_MAPA
      FROM AD_MAP_SETOR_FUNC
     WHERE DESCIDEFX = P_SETOR_APO;

    IF P_TEM_MAPA = 0 THEN
        RETURN;
    END IF;

    -- Busca o departamento do colaborador e seu nome
    BEGIN
        SELECT DEP.DESCRDEP, FUN.NOMEFUNC
          INTO P_SETOR_FUNC, P_NOMEFUNC
          FROM TFPFUN FUN
         INNER JOIN TFPDEP DEP ON FUN.CODDEP = DEP.CODDEP
         WHERE FUN.CODFUNC = :NEW.AD_CODFUNC;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20110,
                'Colaborador ' || :NEW.AD_CODFUNC || ' não encontrado ou sem departamento cadastrado.');
    END;

    -- Verifica se o departamento do colaborador está mapeado para a etapa do apontamento
    SELECT COUNT(1)
      INTO P_TEM_MATCH
      FROM AD_MAP_SETOR_FUNC
     WHERE DESCDEP   = P_SETOR_FUNC
       AND DESCIDEFX = P_SETOR_APO;

    IF P_TEM_MATCH = 0 THEN
        RAISE_APPLICATION_ERROR(-20111,
            'O colaborador "' || P_NOMEFUNC || '" pertence ao setor "' || P_SETOR_FUNC ||
            '", que não está mapeado para a etapa "' || P_SETOR_APO || '". ' ||
            'Informe um colaborador do setor correto ou atualize AD_MAP_SETOR_FUNC.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE BETWEEN -20999 AND -20000 THEN
            RAISE;
        END IF;
END;
