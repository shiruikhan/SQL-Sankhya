create or replace NONEDITIONABLE PROCEDURE "EVP_CLASSIFICACTE_SPARK" (
       P_TIPOEVENTO INT,    -- Identifica o tipo de evento
       P_IDSESSAO VARCHAR2, -- Identificador da execução. Serve para buscar informações dos campos da execução.
       P_CODUSU INT         -- Código do usuário logado
) AS
/*==============================================================================
  Nome do Script : EVP_CLASSIFICACTE_SPARK
  Tipo           : Procedure de Visão Externa (Evento de Tela)
  Descrição      : Classifica automaticamente o CODTIPOPER de um CT-e com base
                   nos CODTIPOPERs das NF-e referenciadas no XML.

                   Dois pontos de disparo:
                   — AFTER_INSERT (TIPO='C'): tentativa imediata ao importar o CT-e.
                     Só aplica se o CT-e já foi processado (DHPROCAG preenchido) e
                     as NF-e já existem em TGFCAB.
                   — AFTER_UPDATE (TIPO='N'): quando uma NF-e é processada manualmente
                     e entra em TGFCAB, busca CT-es pendentes (CODTIPOPER = NULL) que
                     a referenciam e os classifica via UPDATE direto em TGFIXN.

                   Regras de mapeamento (por prioridade):
                     CODTIPOPER_NFE IN (214, 1125, 1211)                          → TOP 225
                     CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202)       → TOP 226
                     CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228,
                                        266, 233, 1119, 1108)                     → TOP 242
                     CODTIPOPER_NFE IN (201, 221, 209)                            → TOP 234

  Parâmetros     : P_TIPOEVENTO — tipo do evento (0=BEFORE_INSERT, 1=AFTER_INSERT, etc.)
                   P_IDSESSAO   — identificador da execução
                   P_CODUSU     — código do usuário logado

  Tabelas        : TGFIXN — portal de importação de XML (CT-e e NF-e)

  Dependências   : VW_CTE_AUTORIZADOS — lista CT-es autorizados com CODTIPOPER das NF-e
                                         referenciadas (via TGFCAB.CHAVENFE)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Reestruturação: função local de classificação,
                                correção de prioridade entre TOPs,
                                adição de AFTER_UPDATE para reclassificação via NF-e
==============================================================================*/

    BEFORE_INSERT INT;
    AFTER_INSERT  INT;
    BEFORE_DELETE INT;
    AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
    AFTER_UPDATE  INT;
    BEFORE_COMMIT INT;

    /*--------------------------------------------------------------------------
      FN_CLASSIFICA
      Retorna o CODTIPOPER correto para um CT-e dado seu NUNOTA, consultando
      VW_CTE_AUTORIZADOS. Aplica as regras em ordem de prioridade:
        1 → TOP 225  (prioridade máxima — retorno imediato ao encontrar)
        2 → TOP 226
        3 → TOP 242
        4 → TOP 234  (prioridade mínima)
      Retorna NULL se nenhuma NF-e referenciada estiver em TGFCAB ainda,
      ou se nenhum CODTIPOPER_NFE se enquadrar nas regras.
    --------------------------------------------------------------------------*/
    FUNCTION FN_CLASSIFICA(P_NUNOTA_CTE NUMBER) RETURN NUMBER IS
        V_TOP      NUMBER := NULL;
        V_PRIORITY NUMBER := 999;
    BEGIN
        FOR R IN (
            SELECT CODTIPOPER_NFE
            FROM   VW_CTE_AUTORIZADOS
            WHERE  NUNOTA           = P_NUNOTA_CTE
              AND  CODTIPOPER_NFE  IS NOT NULL
        ) LOOP
            IF R.CODTIPOPER_NFE IN (214, 1125, 1211) THEN
                RETURN 225; -- prioridade máxima, retorno imediato
            ELSIF R.CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202) AND V_PRIORITY > 2 THEN
                V_TOP := 226; V_PRIORITY := 2;
            ELSIF R.CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228, 266, 233, 1119, 1108) AND V_PRIORITY > 3 THEN
                V_TOP := 242; V_PRIORITY := 3;
            ELSIF R.CODTIPOPER_NFE IN (201, 221, 209) AND V_PRIORITY > 4 THEN
                V_TOP := 234; V_PRIORITY := 4;
            END IF;
        END LOOP;
        RETURN V_TOP;
    END FN_CLASSIFICA;

BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;

    /*==========================================================================
      AFTER_INSERT — CT-e recém-importado pelo agendador
      Tenta classificar imediatamente. Só aplica o TOP se:
        — o CT-e já foi processado (DHPROCAG preenchido pelo agendador), e
        — ao menos uma NF-e referenciada já existe em TGFCAB (FN_CLASSIFICA <> NULL).
      Se a NF-e ainda não existir, o CT-e fica com CODTIPOPER = NULL e será
      classificado pelo bloco AFTER_UPDATE quando a NF-e entrar no sistema.
    ==========================================================================*/
    IF P_TIPOEVENTO = AFTER_INSERT THEN
        DECLARE
            V_TIPO     VARCHAR2(1);
            V_NUNOTA   NUMBER;
            V_DHPROCAG DATE;
            V_NEW_TOP  NUMBER;
        BEGIN
            V_TIPO := EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'TIPO');

            IF V_TIPO = 'C' THEN
                V_NUNOTA := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA');

                BEGIN
                    SELECT DHPROCAG
                    INTO   V_DHPROCAG
                    FROM   TGFIXN
                    WHERE  NUNOTA  = V_NUNOTA
                      AND  ROWNUM  = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN V_DHPROCAG := NULL;
                END;

                V_NEW_TOP := FN_CLASSIFICA(V_NUNOTA);

                IF V_NEW_TOP IS NOT NULL AND V_DHPROCAG IS NOT NULL THEN
                    EVP_SET_CAMPO_INT(P_IDSESSAO, 'CODTIPOPER', V_NEW_TOP);
                END IF;
            END IF;
        END;
    END IF;

    /*==========================================================================
      AFTER_UPDATE — NF-e processada manualmente no portal
      Quando uma NF-e é processada e entra em TGFCAB (NUNOTA preenchido em TGFIXN),
      busca todos os CT-es pendentes (CODTIPOPER = NULL) que referenciam a chave
      desta NF-e e os classifica via UPDATE direto em TGFIXN.
      O UPDATE não dispara novo ciclo pois o bloco só reage a TIPO = 'N'.
    ==========================================================================*/
    IF P_TIPOEVENTO = AFTER_UPDATE THEN
        DECLARE
            V_NUARQUIVO NUMBER;
            V_TIPO      VARCHAR2(1);
            V_NUNOTA    NUMBER;
            V_CHAVE     VARCHAR2(50);
            V_NEW_TOP   NUMBER;
        BEGIN
            V_NUARQUIVO := EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUARQUIVO');

            BEGIN
                SELECT TIPO, NUNOTA, CHAVEACESSO
                INTO   V_TIPO, V_NUNOTA, V_CHAVE
                FROM   TGFIXN
                WHERE  NUARQUIVO = V_NUARQUIVO;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN V_TIPO := NULL;
            END;

            -- Só processa NF-e recém-processadas (NUNOTA agora preenchido)
            IF V_TIPO = 'N' AND V_NUNOTA IS NOT NULL AND V_CHAVE IS NOT NULL THEN

                FOR CTE_REC IN (
                    SELECT DISTINCT VW.NUNOTA AS NUNOTA_CTE
                    FROM   VW_CTE_AUTORIZADOS VW
                    INNER  JOIN TGFIXN IX ON IX.NUNOTA = VW.NUNOTA AND IX.TIPO = 'C'
                    WHERE  VW.CHAVEACESSO_REF = V_CHAVE
                      AND  IX.CODTIPOPER     IS NULL
                ) LOOP
                    V_NEW_TOP := FN_CLASSIFICA(CTE_REC.NUNOTA_CTE);

                    IF V_NEW_TOP IS NOT NULL THEN
                        UPDATE TGFIXN
                        SET    CODTIPOPER = V_NEW_TOP
                        WHERE  NUNOTA     = CTE_REC.NUNOTA_CTE;
                    END IF;
                END LOOP;

            END IF;
        END;
    END IF;

END;
