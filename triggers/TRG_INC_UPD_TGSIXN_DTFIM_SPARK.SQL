CREATE OR REPLACE TRIGGER TRG_INC_UPD_TGSIXN_DTFIM_SPARK
BEFORE INSERT OR UPDATE ON AD_TGSIXN
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_UPD_TGSIXN_DTFIM_SPARK
  Tipo           : Trigger
  Descrição      : Preenche DTFIM do apontamento de conferência a partir da
                   nota fiscal vinculada ao arquivo conferido. Localiza a chave
                   de acesso do arquivo (TGFIXN.CHAVEACESSO) pelo NUARQUIVO e,
                   a partir dela, busca a nota correspondente em TGFCAB
                   (CHAVENFE). Quando a nota está lançada (STATUSNOTA = 'L'),
                   DTFIM recebe a data de movimento (TGFCAB.DTMOV) da nota.
  Tabela         : AD_TGSIXN
  Evento         : BEFORE INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSIXN -- registro alterado via :NEW
                   TGFIXN    -- leitura de CHAVEACESSO a partir de NUARQUIVO
                   TGFCAB    -- leitura de DTMOV/STATUSNOTA a partir de CHAVENFE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/07/2026
  Última Revisão : Julho/2026 — Criação

  Observações    : - Só atualiza DTFIM quando a nota vinculada está com
                     STATUSNOTA = 'L'; caso contrário, DTFIM permanece
                     inalterado (apontamento continua em aberto).
                   - Deve ser executada antes de TRG_INC_UPD_AD_TGSIXN_SPARK,
                     que deriva STATUS a partir de DTFIM (ver cláusula FOLLOWS
                     naquela trigger).
                   - Nome do objeto sem o prefixo "AD_" (TGSIXN, não
                     AD_TGSIXN) propositalmente: com o prefixo o identificador
                     ultrapassa 30 caracteres e o Oracle rejeita a criação
                     (ORA-00972: identifier is too long). Não renomear de volta.
==============================================================================*/
DECLARE
    V_CHAVEACESSO TGFIXN.CHAVEACESSO%TYPE;
    V_DTMOV       TGFCAB.DTMOV%TYPE;
BEGIN
    ---------------------------------------------------------------------------
    -- 1. Busca a chave de acesso do arquivo conferido
    ---------------------------------------------------------------------------
    BEGIN
        SELECT IXN.CHAVEACESSO
          INTO V_CHAVEACESSO
          FROM TGFIXN IXN
         WHERE IXN.NUARQUIVO = :NEW.NUARQUIVO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_CHAVEACESSO := NULL;
    END;

    ---------------------------------------------------------------------------
    -- 2. Busca a data de movimento da nota lancada com essa chave
    ---------------------------------------------------------------------------
    IF V_CHAVEACESSO IS NOT NULL THEN
        BEGIN
            SELECT CAB.DTMOV
              INTO V_DTMOV
              FROM TGFCAB CAB
             WHERE CAB.CHAVENFE   = V_CHAVEACESSO
               AND CAB.STATUSNOTA = 'L';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DTMOV := NULL;
            WHEN TOO_MANY_ROWS THEN
                SELECT MAX(CAB.DTMOV)
                  INTO V_DTMOV
                  FROM TGFCAB CAB
                 WHERE CAB.CHAVENFE   = V_CHAVEACESSO
                   AND CAB.STATUSNOTA = 'L';
        END;

        IF V_DTMOV IS NOT NULL THEN
            :NEW.DTFIM := V_DTMOV;
        END IF;
    END IF;
END;
