create or replace TRIGGER TRG_COTAFRETE_EMB_SPARK
AFTER INSERT OR UPDATE ON AD_TGSCTF
FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_COTAFRETE_EMB_SPARK
  Tipo           : Trigger
  Descrição      : Insere dimensões e peso de embalagem em AD_TGSLCB após criar
                   cotação. Agrupa os itens de AD_EMBPED por embalagem
                   (CODPRODEMB) — ou por produto, em fallback, quando a
                   embalagem não tem medidas cadastradas — e grava um pacote
                   por grupo com:
                     - COMPRIMENTO/ALTURA/LARGURA: medidas de TGFPRO (cm/100)
                     - VOLTOT: quantidade de caixas do grupo
                     - PESOITEM: peso de UMA caixa do grupo (embalagem + itens
                       nela), usado como Packs[].Weight na cotação Rodonaves

                   O peso de cada grupo é calculado como peso da embalagem
                   (TGFPRO.PESOBRUTO x nº de caixas) + peso dos itens
                   (AD_EMBPED.PESOBRUTO). Esse peso-base só serve para ratear
                   proporcionalmente o peso oficial da cotação
                   (AD_TGSCTF.PESOTOT) entre os grupos. PESOITEM é sempre
                   arredondado para cima (CEIL) para Kg inteiro, pois a API da
                   Rodonaves exige peso em Kg sem casas decimais — por isso a
                   soma de PESOITEM x VOLTOT pode ficar levemente acima de
                   PESOTOT (nunca abaixo), o que é intencional.

  Tabela         : AD_TGSCTF
  Evento         : AFTER INSERT OR UPDATE
  Escopo         : FOR EACH ROW

  Tabelas        : AD_TGSCTF  -- cotação (:NEW.PESOTOT é a base do rateio)
                   AD_EMBPED  -- itens embalados (peso, caixa, embalagem)
                   TGFPRO     -- dimensões e peso bruto de produto/embalagem
                   AD_TGSLCB  -- destino: um pacote por linha

  Tabela de Log  : AD_LOG_ERROS

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Julho/2026 — Adicionado cálculo de PESOITEM (rateio de
                   AD_TGSCTF.PESOTOT por grupo, proporcional a embalagem +
                   itens); reestruturado para duas passagens (monta pacotes em
                   memória, depois grava) para permitir o rateio; adicionado
                   handler de erro padrão (LOG_ERRO + EXCEPTION WHEN OTHERS).
                   Julho/2026 — Corrigida ordem de limpeza em UPDATE: o DELETE
                   em AD_TGSLCB agora roda antes da checagem de existência em
                   AD_EMBPED, para não deixar pacotes órfãos quando a
                   embalagem da nota for totalmente removida numa atualização.
                   Julho/2026 — PESOITEM agora é arredondado para cima (CEIL)
                   em Kg inteiro, conforme exigência da API da Rodonaves.
==============================================================================*/
DECLARE
    -- Cursor: codprodemb e quantidade de caixas distintas para a nota
    CURSOR C_EMB IS
        SELECT CODPRODEMB,
               COUNT(DISTINCT IDCAIXA) AS QTD_CAIXAS
          FROM AD_EMBPED
         WHERE NUNOTA = :NEW.NUNOTA
         GROUP BY CODPRODEMB;

    -- Dimensões e peso obtidos de TGFPRO
    V_ESPESSURA TGFPRO.ESPESSURA%TYPE;
    V_ALTURA    TGFPRO.ALTURA%TYPE;
    V_LARGURA   TGFPRO.LARGURA%TYPE;
    V_PESOEMB   TGFPRO.PESOBRUTO%TYPE;

    -- Controle de índice incremental de embalagem
    V_NEXT_IDEMB NUMBER;
    -- Verificador de existência de registros em AD_EMBPED
    V_EXISTS NUMBER;
    -- Operação corrente, para log de erro
    V_OPERACAO VARCHAR2(10);

    -- Pacote montado em memória antes da gravação (permite ratear o peso
    -- total da cotação entre os grupos antes de gravar qualquer linha)
    TYPE T_PACOTE IS RECORD (
        COMPRIMENTO AD_TGSLCB.COMPRIMENTO%TYPE,
        ALTURA      AD_TGSLCB.ALTURA%TYPE,
        LARGURA     AD_TGSLCB.LARGURA%TYPE,
        VOLTOT      AD_TGSLCB.VOLTOT%TYPE,
        PESOBASE    NUMBER  -- peso calculado (embalagem + itens) do grupo
    );
    TYPE T_PACOTE_TAB IS TABLE OF T_PACOTE INDEX BY PLS_INTEGER;
    V_PACOTES         T_PACOTE_TAB;
    V_QTD_PACOTES     PLS_INTEGER := 0;
    V_PESOBASE_TOTAL  NUMBER := 0;
    V_CAIXAS_TOTAL    NUMBER := 0;
    V_PESOITEM        AD_TGSLCB.PESOITEM%TYPE;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'TRG_COTAFRETE_EMB_SPARK', P_OPERACAO, :NEW.NUNOTA,
            P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

BEGIN
    IF INSERTING THEN
        V_OPERACAO := 'INSERT';
    ELSIF UPDATING THEN
        V_OPERACAO := 'UPDATE';
    END IF;

    -- Em caso de UPDATE, limpa embalagem existente para evitar duplicatas —
    -- feito antes da checagem de AD_EMBPED para não deixar pacotes órfãos em
    -- AD_TGSLCB quando a embalagem da nota for totalmente removida
    IF UPDATING THEN
        DELETE FROM AD_TGSLCB
         WHERE NUCTF = :NEW.NUCTF;
    END IF;

    -- Não faz nada caso não haja informações em AD_EMBPED para a nota
    BEGIN
        SELECT 1 INTO V_EXISTS
          FROM AD_EMBPED
         WHERE NUNOTA = :NEW.NUNOTA
           AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN; -- Sai do trigger sem inserir
    END;

    ---------------------------------------------------------------------------
    -- 1. Monta os pacotes em memória (por embalagem ou, em fallback, por
    --    produto) e acumula o peso-base de cada grupo (embalagem + itens)
    ---------------------------------------------------------------------------
    FOR R IN C_EMB LOOP
        -- Busca dimensões e peso bruto no cadastro de produtos
        BEGIN
            SELECT ALTURA / 100, LARGURA / 100, ESPESSURA / 100, NVL(PESOBRUTO, 0)
              INTO V_ALTURA, V_LARGURA, V_ESPESSURA, V_PESOEMB
              FROM TGFPRO
             WHERE CODPROD = R.CODPRODEMB;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_ALTURA    := NULL;
                V_LARGURA   := NULL;
                V_ESPESSURA := NULL;
                V_PESOEMB   := 0;
        END;

        -- Caso a embalagem (CODPRODEMB) tenha medidas, monta um pacote por embalagem
        IF V_ALTURA IS NOT NULL AND V_LARGURA IS NOT NULL AND V_ESPESSURA IS NOT NULL THEN
            V_QTD_PACOTES := V_QTD_PACOTES + 1;
            V_PACOTES(V_QTD_PACOTES).COMPRIMENTO := V_ESPESSURA;
            V_PACOTES(V_QTD_PACOTES).ALTURA      := V_ALTURA;
            V_PACOTES(V_QTD_PACOTES).LARGURA     := V_LARGURA;
            V_PACOTES(V_QTD_PACOTES).VOLTOT      := R.QTD_CAIXAS;

            -- Peso-base do grupo: peso da embalagem (por caixa x nº de caixas) + peso dos itens
            SELECT V_PESOEMB * R.QTD_CAIXAS + NVL(SUM(PESOBRUTO), 0)
              INTO V_PACOTES(V_QTD_PACOTES).PESOBASE
              FROM AD_EMBPED
             WHERE NUNOTA    = :NEW.NUNOTA
               AND CODPRODEMB = R.CODPRODEMB;

            V_PESOBASE_TOTAL := V_PESOBASE_TOTAL + V_PACOTES(V_QTD_PACOTES).PESOBASE;
            V_CAIXAS_TOTAL   := V_CAIXAS_TOTAL + R.QTD_CAIXAS;
        ELSE
            -- Fallback: usar medidas do produto (CODPROD) quando CODPRODEMB não tiver medidas
            FOR P IN (
                SELECT CODPROD,
                       COUNT(DISTINCT IDCAIXA) AS QTD_CAIXAS
                  FROM AD_EMBPED
                 WHERE NUNOTA = :NEW.NUNOTA
                   AND (CODPRODEMB = R.CODPRODEMB OR R.CODPRODEMB IS NULL)
                 GROUP BY CODPROD
            ) LOOP
                BEGIN
                    SELECT ALTURA / 100, LARGURA / 100, ESPESSURA / 100
                      INTO V_ALTURA, V_LARGURA, V_ESPESSURA
                      FROM TGFPRO
                     WHERE CODPROD = P.CODPROD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_ALTURA    := NULL;
                        V_LARGURA   := NULL;
                        V_ESPESSURA := NULL;
                END;

                IF V_ALTURA IS NOT NULL AND V_LARGURA IS NOT NULL AND V_ESPESSURA IS NOT NULL THEN
                    V_QTD_PACOTES := V_QTD_PACOTES + 1;
                    V_PACOTES(V_QTD_PACOTES).COMPRIMENTO := V_ESPESSURA;
                    V_PACOTES(V_QTD_PACOTES).ALTURA      := V_ALTURA;
                    V_PACOTES(V_QTD_PACOTES).LARGURA     := V_LARGURA;
                    V_PACOTES(V_QTD_PACOTES).VOLTOT      := P.QTD_CAIXAS;

                    -- Sem embalagem própria com medidas: peso-base é só o peso dos itens
                    SELECT NVL(SUM(PESOBRUTO), 0)
                      INTO V_PACOTES(V_QTD_PACOTES).PESOBASE
                      FROM AD_EMBPED
                     WHERE NUNOTA  = :NEW.NUNOTA
                       AND CODPROD = P.CODPROD
                       AND (CODPRODEMB = R.CODPRODEMB OR R.CODPRODEMB IS NULL);

                    V_PESOBASE_TOTAL := V_PESOBASE_TOTAL + V_PACOTES(V_QTD_PACOTES).PESOBASE;
                    V_CAIXAS_TOTAL   := V_CAIXAS_TOTAL + P.QTD_CAIXAS;
                END IF;
            END LOOP;
        END IF;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 2. Grava os pacotes em AD_TGSLCB, rateando AD_TGSCTF.PESOTOT entre os
    --    grupos proporcionalmente ao peso-base, arredondando cada PESOITEM
    --    para cima em Kg inteiro (exigência da API) — a soma de
    --    PESOITEM x VOLTOT fica igual ou levemente acima de PESOTOT
    ---------------------------------------------------------------------------
    SELECT NVL(MAX(IDEMB), 0) + 1
      INTO V_NEXT_IDEMB
      FROM AD_TGSLCB
     WHERE NUCTF = :NEW.NUCTF;

    FOR I IN 1 .. V_QTD_PACOTES LOOP
        IF V_PESOBASE_TOTAL > 0 THEN
            -- CEIL: API exige peso em Kg inteiro, sempre arredondado para cima
            -- (nunca declarar menos peso do que a caixa realmente tem)
            V_PESOITEM := CEIL((NVL(:NEW.PESOTOT, 0) * V_PACOTES(I).PESOBASE / V_PESOBASE_TOTAL)
                                / V_PACOTES(I).VOLTOT);
        ELSIF V_CAIXAS_TOTAL > 0 THEN
            -- Nenhum peso-base calculável (embalagem e itens sem PESOBRUTO): distribui
            -- o peso total igualmente entre todas as caixas da cotação
            V_PESOITEM := CEIL(NVL(:NEW.PESOTOT, 0) / V_CAIXAS_TOTAL);
        ELSE
            V_PESOITEM := NULL;
        END IF;

        INSERT INTO AD_TGSLCB (
            NUCTF,
            IDEMB,
            COMPRIMENTO,
            ALTURA,
            LARGURA,
            VOLTOT,
            PESOITEM
        ) VALUES (
            :NEW.NUCTF,
            V_NEXT_IDEMB,
            V_PACOTES(I).COMPRIMENTO,
            V_PACOTES(I).ALTURA,
            V_PACOTES(I).LARGURA,
            V_PACOTES(I).VOLTOT,
            V_PESOITEM
        );

        -- Incrementa o índice de embalagem para o próximo pacote
        V_NEXT_IDEMB := V_NEXT_IDEMB + 1;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO(V_OPERACAO, SQLCODE, SQLERRM,
                 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                 DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20101, 'Erro na trigger TRG_COTAFRETE_EMB_SPARK (NUCTF: '
                                 || :NEW.NUCTF || '): ' || SQLERRM);
END TRG_COTAFRETE_EMB_SPARK;
