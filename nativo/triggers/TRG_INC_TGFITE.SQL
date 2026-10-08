CREATE OR REPLACE TRIGGER TRG_INC_TGFITE
BEFORE INSERT ON TGFITE FOR EACH ROW
/*==============================================================================
  Nome do Script : TRG_INC_TGFITE
  Descrição      : Trigger nativa do Sankhya — BEFORE INSERT na tabela de itens
                   de nota (TGFITE). Executa validações de integridade, controle
                   de estoque, agrupamento mínimo, CFOP, IPI e reserva antes de
                   persistir cada novo item.

                   ATENÇÃO: Este é um objeto nativo do Sankhya com customizações
                   adicionadas pela Spark Eletrônica. Deve ser revisado após
                   qualquer atualização de versão do ERP.

  Customizações  : - Validação de agrupamento mínimo
                   - Controle de atualização de estoque por TOP
                   - Verificação de CFOP para transferências
                   - Validação de IPI por tipo de movimento

  Autor Original : Sankhya Gestão de Negócios
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Última Revisão : Abril/2026 — Padronização de cabeçalho, encoding e comentários

  Referências de OS (Sankhya):
    OS 717072  — Arredondamento de QTDNEG para 9 casas decimais
    OS 748512  — Mantido argumento 9 (10 estoura o tamanho do tipo)
    OS 756293  — Arredondamento de QTDENTREGUE
    OS 823336  — Controle de validação de varejo (MANOEL)
    OS 902640  — Bloqueio de itens em notas já lançadas no Livro Fiscal
    OS 954116  — Condição para desmembramento de bem
==============================================================================*/
DECLARE
    -- Campos do grupo do produto
    P_VALEST                    TGFGRU.VALEST%TYPE;

    -- Controle de exceção local
    ERROR                       EXCEPTION;
    ERRMSG                      VARCHAR2(4000);

    -- Campos do cabeçalho da nota
    P_CODEMPCAB                 TGFCAB.CODEMP%TYPE;
    P_TIPMOV                    CHAR(1);
    P_CODEMPNEGOC               TGFITE.CODEMP%TYPE;
    P_CODTIPOPER                NUMBER(5);
    P_DHTIPOPER                 DATE;

    -- Controles gerais de validação e contagem
    P_INICIOCONTEST             INT;
    P_COUNT                     INT := 0;

    -- Campos do produto
    P_CODGRUPOPROD              INT;
    P_ATIVO                     CHAR(1);
    P_AGRUPMIN                  FLOAT;
    P_RESTO                     FLOAT;
    P_TEMIPIVENDA               CHAR;
    P_TEMIPICOMPRA              CHAR;
    P_TIPCONTEST                TGFPRO.TIPCONTEST%TYPE;

    -- Campos da TOP (Tipo de Operação)
    P_COMPLEMENTO               CHAR(1);
    P_ALES                      CHAR;            -- Atualização de estoque da TOP
    P_RESERVADO_TOP             CHAR;
    P_ATUALESTOQUE_TOP          INT;
    P_ATUALESTOQUEMP_TOP        INT;
    P_VALIDAAGRUPMIN            CHAR;
    P_PENDENTE_TOP              CHAR;
    P_CFOSAIDA                  TGFTOP.CODCFO_SAIDA%TYPE;
    P_CFOENTRADA                TGFTOP.CODCFO_ENTRADA%TYPE;
    P_CFO                       TGFTOP.CODCFO_ENTRADA%TYPE;
    P_CFOSAIDA_FORA             TGFTOP.CODCFO_SAIDA%TYPE;
    P_CFOENTRADA_FORA           TGFTOP.CODCFO_ENTRADA%TYPE;
    P_ADIARATUALEST             CHAR(1);
    P_CUPOMFISCAL               CHAR(1);
    P_VALIDA_EST_RESERVAR       TGFTOP.VALEST%TYPE;

    -- Campos auxiliares de estoque e reserva
    P_TIPRES                    CHAR;
    P_QTDNEG                    FLOAT;
    P_ATUALIZOU                 CHAR;
    P_ADIARATUALIZACAOESTOQUE   CHAR(1);

    -- Campos de FLV (Frete por Local de Venda)
    P_HABFLV                    CHAR(1);
    P_TEMFLV                    CHAR(1);

    -- Campos de IPI e CST
    P_CSTIPI                    TGFITE.CSTIPI%TYPE;
    P_CODENQIPI                 TGFITE.CODENQIPI%TYPE;

    -- Validação de varejo
    P_VALIDAVAREJO              INT;

    -- Nome do programa que está executando a sessão
    P_PROGRAMNAME               VARCHAR2(60);

    -- Flag de sincronização de dados (controla se deve validar)
    P_VALIDAR                   BOOLEAN;

BEGIN

    -- =========================================================================
    -- GUARDA RÁPIDA: se o Sankhya estiver em modo de atualização interna,
    -- ignora todas as validações para evitar conflito com processos do ERP.
    -- =========================================================================
    IF STP_GET_ATUALIZANDO THEN
        RETURN;
    END IF;

    -- =========================================================================
    -- INICIALIZAÇÃO: captura campos de IPI do item sendo inserido.
    -- =========================================================================
    P_CODENQIPI := :NEW.CODENQIPI;
    P_CSTIPI    := :NEW.CSTIPI;

    -- Define se as validações de integridade devem ser executadas
    -- (falso durante sincronização de dados — OS interna Sankhya).
    P_VALIDAR := Fpodevalidar('TGFITE');

    -- Verifica se a atualização de estoque está sendo adiada por controle de variável global.
    P_ADIARATUALIZACAOESTOQUE := NVL(VARIAVEIS_PKG.V_ADIARATUALIZACAOESTOQUE, 'N');

    -- =========================================================================
    -- VALIDAÇÃO DE IPI: enquadramento e CST devem estar consistentes.
    -- =========================================================================
    STP_VALIDA_ENQUADRAMENTO_IPI_2(P_CSTIPI, P_CODENQIPI);

    -- =========================================================================
    -- DEFAULT DE CAMPO: garante que GERAPRODUCAO seja preenchido caso o banco
    -- não aplique o default automaticamente (compatibilidade Produção/W).
    -- =========================================================================
    IF :NEW.GERAPRODUCAO IS NULL THEN
        :NEW.GERAPRODUCAO := 'S';
    END IF;

    -- =========================================================================
    -- BLOQUEIO — LIVRO FISCAL (OS 954116 / OS 902640):
    -- Impede inclusão de itens em notas que já foram geradas no Livro Fiscal,
    -- exceto quando o processo de desmembramento de bem está ativo.
    -- =========================================================================
    IF VARIAVEIS_PKG.V_DESMEMBRANDOBEM = 'N' THEN
        SELECT COUNT(1)
          INTO P_COUNT
          FROM TGFLIV
         WHERE NUNOTA = :NEW.NUNOTA
           AND ORIGEM = 'E';

        IF P_COUNT > 0 THEN
            ERRMSG := 'Nota já foi gerada no Livro Fiscal.';
            RAISE ERROR;
        END IF;
    END IF;

    -- =========================================================================
    -- VALIDAÇÃO DE VENDEDOR: alerta se o vendedor do item estiver inativo.
    -- =========================================================================
    SELECT COUNT(1)
      INTO P_COUNT
      FROM TGFVEN
     WHERE CODVEND = :NEW.CODVEND
       AND ATIVO   = 'N';

    IF P_COUNT <> 0 THEN
        Stp_Popula_Msg('TGFVEN');
    END IF;

    -- =========================================================================
    -- VALIDAÇÃO DE SÉRIE INICIAL E FINAL: devem conter apenas numerais.
    -- =========================================================================
    IF LENGTH(TRIM(TRANSLATE(:NEW.SERIEINICIAL, ' +-.0123456789', ' '))) IS NOT NULL THEN
        ERRMSG := 'A coluna "SERIEINICIAL" deve conter somente numerais.';
        RAISE ERROR;
    END IF;

    IF LENGTH(TRIM(TRANSLATE(:NEW.SERIEFINAL, ' +-.0123456789', ' '))) IS NOT NULL THEN
        ERRMSG := 'A coluna "SERIEFINAL" deve conter somente numerais.';
        RAISE ERROR;
    END IF;

    -- =========================================================================
    -- BUSCA DE DADOS DO CABEÇALHO DA NOTA (TGFCAB):
    -- Tipo de movimento, empresa, TOP e data/hora para uso nas validações.
    -- =========================================================================
    BEGIN
        SELECT C.TIPMOV, C.CODEMPNEGOC, C.CODTIPOPER, C.DHTIPOPER, C.CODEMP
          INTO P_TIPMOV, P_CODEMPNEGOC, P_CODTIPOPER, P_DHTIPOPER, P_CODEMPCAB
          FROM TGFCAB C
         WHERE NUNOTA = :NEW.NUNOTA;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ERRMSG := 'Nota não encontrada';
            RAISE ERROR;
    END;

    -- =========================================================================
    -- BUSCA DE DADOS DA TOP (TGFTOP):
    -- CFOPs de entrada/saída (dentro e fora do estado), atualização de
    -- estoque, agrupamento mínimo, pendência e controles de reserva.
    -- =========================================================================
    SELECT CODCFO_ENTRADA
         , CODCFO_SAIDA
         , ATUALEST
         , ATUALESTMP
         , VALIDAAGRUPMIN
         , PENDENTE
         , CODCFO_ENTRADA_FORA
         , CODCFO_SAIDA_FORA
         , ADIARATUALEST
         , COMPLEMENTO
         , CUPOMFISCAL
         , VALEST
      INTO P_CFOENTRADA
         , P_CFOSAIDA
         , P_ALES
         , P_ATUALESTOQUEMP_TOP
         , P_VALIDAAGRUPMIN
         , P_PENDENTE_TOP
         , P_CFOENTRADA_FORA
         , P_CFOSAIDA_FORA
         , P_ADIARATUALEST
         , P_COMPLEMENTO
         , P_CUPOMFISCAL
         , P_VALIDA_EST_RESERVAR
      FROM TGFTOP
     WHERE CODTIPOPER = P_CODTIPOPER
       AND DHALTER    = P_DHTIPOPER;

    -- =========================================================================
    -- VALIDAÇÃO DE TIPO DE CONTESTAÇÃO (LOTE):
    -- Se o item atualiza estoque e não está em reserva ou controle vazio,
    -- verifica se o produto exige informação de lote (TIPCONTEST = 'L').
    -- Nota: validação de lote obrigatório está comentada — manter para referência.
    -- =========================================================================
    IF (:NEW.ATUALESTOQUE <> 0) AND (:NEW.RESERVA <> 'S') AND (:NEW.CONTROLE = ' ') THEN
        SELECT CASE WHEN PEM.TIPCONTEST IS NOT NULL THEN PEM.TIPCONTEST ELSE P.TIPCONTEST END
          INTO P_TIPCONTEST
          FROM TGFPRO P
          LEFT JOIN TGFPEM PEM ON (P.CODPROD = PEM.CODPROD AND :NEW.CODEMP = PEM.CODEMP)
         WHERE P.CODPROD = :NEW.CODPROD;

        /*-- Descomentado para ativar validação de lote obrigatório:
        IF (P_TIPCONTEST = 'L') THEN
            ERRMSG := 'Lote do produto '||TO_CHAR(:NEW.CODPROD)||' deve ser informado na nota de número único '||TO_CHAR(:NEW.NUNOTA)||'.';
            RAISE ERROR;
        END IF;*/
    END IF;

    -- =========================================================================
    -- CONTROLE DE PENDÊNCIA DO ITEM:
    -- Ajusta o campo PENDENTE com base na quantidade entregue versus negociada
    -- e no parâmetro PENDENTE da TOP.
    -- =========================================================================
    IF P_VALIDAR THEN
        IF (:NEW.PENDENTE = 'S' AND ABS(:NEW.QTDNEG) <= ABS(:NEW.QTDENTREGUE)) THEN
            :NEW.PENDENTE := 'N';
        ELSE
            IF P_PENDENTE_TOP = 'N' THEN
                :NEW.PENDENTE := 'N';
            ELSIF (:NEW.PENDENTE = 'N') AND (ABS(:NEW.QTDNEG) > ABS(:NEW.QTDENTREGUE)) THEN
                :NEW.PENDENTE := 'S';
            END IF;
        END IF;
    END IF;

    -- =========================================================================
    -- BUSCA DE DADOS DO PRODUTO E DO GRUPO (TGFPRO / TGFGRU):
    -- Agrupamento mínimo, IPI por tipo de movimento, grupo, ativo, validação
    -- de estoque e FLV (Frete por Local de Venda).
    -- =========================================================================
    BEGIN
        SELECT P.AGRUPMIN
             , CASE WHEN PEM.TEMIPIVENDA  IS NULL OR PEM.TEMIPIVENDA  = 'C' THEN P.TEMIPIVENDA  ELSE PEM.TEMIPIVENDA  END
             , CASE WHEN PEM.TEMIPICOMPRA IS NULL OR PEM.TEMIPICOMPRA = 'C' THEN P.TEMIPICOMPRA ELSE PEM.TEMIPICOMPRA END
             , P.CODGRUPOPROD
             , P.ATIVO
             , G.VALEST
             , G.TEMFLV
          INTO P_AGRUPMIN, P_TEMIPIVENDA, P_TEMIPICOMPRA, P_CODGRUPOPROD, P_ATIVO, P_VALEST, P_TEMFLV
          FROM TGFPRO P
          LEFT JOIN TGFPEM PEM ON (P.CODPROD = PEM.CODPROD AND :NEW.CODEMP = PEM.CODEMP)
             , TGFGRU G
         WHERE P.CODPROD      = :NEW.CODPROD
           AND P.CODGRUPOPROD = G.CODGRUPOPROD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ERRMSG := 'Produto ' || TO_CHAR(:NEW.CODPROD) || ' não encontrado';
            RAISE ERROR;
    END;

    -- =========================================================================
    -- VALIDAÇÕES DE PRODUTO, EMPRESA E LOCAL (somente quando FATURAR <> 'F'):
    -- =========================================================================
    IF :NEW.FATURAR <> 'F' THEN

        -- Produto deve estar ativo, exceto para uso 'D' (devolução) ou 'M' (matéria-prima).
        IF (P_ATIVO = 'N') AND (:NEW.USOPROD <> 'D') AND (:NEW.USOPROD <> 'M') THEN
            ERRMSG := 'Produto ' || TO_CHAR(:NEW.CODPROD) || ' não esta ativo.';
            RAISE ERROR;
        END IF;

        -- Verifica se a empresa do item está ativa.
        BEGIN
            SELECT ATIVO
              INTO P_ATIVO
              FROM TGFEMP
             WHERE CODEMP = :NEW.CODEMP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ERRMSG := 'Empresa ' || TO_CHAR(:NEW.CODEMP) || ' não encontrada';
                RAISE ERROR;
        END;

        IF P_ATIVO = 'N' THEN
            Stp_Popula_Msg('TGFEMP');
        END IF;

        -- Valida se o local de origem existe, está ativo e é analítico.
        IF :NEW.CODLOCALORIG <> 0 THEN
            SELECT COUNT(1)
              INTO P_COUNT
              FROM TGFLOC
             WHERE CODLOCAL  = :NEW.CODLOCALORIG
               AND ATIVO     = 'S'
               AND ANALITICO = 'S';

            IF P_COUNT = 0 THEN
                ERRMSG := 'Local não Ativo ou não Analítico '
                          || TO_CHAR(:NEW.CODLOCALORIG, '999999')
                          || ' Prod' || TO_CHAR(:NEW.CODPROD, '999999999');
                RAISE ERROR;
            END IF;
        END IF;

        -- Valida agrupamento mínimo: quantidade deve ser múltipla do AGRUPMIN.
        IF (P_VALIDAAGRUPMIN = 'S')
           AND (P_AGRUPMIN <> 1)
           AND (P_AGRUPMIN <> 0)
           AND (:NEW.QTDNEG <> 0)
           AND (P_COMPLEMENTO <> 'S')
        THEN
            P_RESTO := ROUND(MOD(:NEW.QTDNEG, P_AGRUPMIN), 9);
            IF P_RESTO <> 0 THEN
                ERRMSG := 'Quantidade negociada não é múltipla do agrupamento mínimo ('
                          || P_AGRUPMIN || ') do produto ' || :NEW.CODPROD || '.';
                RAISE ERROR;
            END IF;
        END IF;

        -- Valida se o produto (ou seu grupo) está restrito para a TOP selecionada.
        SELECT MIN(R.TIPREST)
          INTO P_TIPRES
          FROM TGFREP R, TGFPRO P
         WHERE ( (R.TIPREST = 'G' AND R.CODCOLREST = P.CODGRUPOPROD)
              OR (R.TIPREST = 'P' AND R.CODCOLREST = :NEW.CODPROD) )
           AND R.CODTIPOPER = P_CODTIPOPER
           AND P.CODPROD    = :NEW.CODPROD
           AND R.RESTRICAO  = 'N';

        IF P_TIPRES IS NOT NULL THEN
            IF P_TIPRES = 'G' THEN
                ERRMSG := 'Este grupo de produto não pode ser usado com esta TOP.';
                RAISE ERROR;
            ELSIF P_TIPRES = 'P' THEN
                ERRMSG := 'Este produto não pode ser usado com esta TOP.';
                RAISE ERROR;
            END IF;
        END IF;

        -- Valida base e valor de IPI: devem ser zero quando o produto não tem IPI
        -- para o tipo de movimento em questão.
        IF ( ( (P_TEMIPIVENDA  = 'N') AND (P_TIPMOV IN ('P', 'V')) )
          OR ( (P_TEMIPICOMPRA = 'N') AND (P_TIPMOV IN ('O', 'C', 'E')) ) )
           AND ( (:NEW.BASEIPI <> 0) OR (:NEW.VLRIPI <> 0) )
        THEN
            ERRMSG := 'A base e o valor do IPI devem ser zero (0) para o PRODUTO: '
                      || TO_CHAR(:NEW.CODPROD)
                      || ' NOTA: '    || TO_CHAR(:NEW.NUNOTA)
                      || ' SEQUENCIA: ' || TO_CHAR(:NEW.SEQUENCIA);
            RAISE ERROR;
        END IF;

    END IF; -- fim IF FATURAR <> 'F'

    -- =========================================================================
    -- VALIDAÇÕES ESPECÍFICAS PARA TRANSFERÊNCIAS (TIPMOV = 'T'):
    -- Transferências não podem ter reserva, nem itens de serviço.
    -- =========================================================================
    IF P_TIPMOV = 'T' THEN
        IF :NEW.RESERVA = 'S' THEN
            ERRMSG := 'Transferência não pode reservar.';
            RAISE ERROR;
        END IF;

        /*-- Validações desabilitadas (mantidas para referência):
        IF :NEW.PENDENTE = 'S' THEN
            ERRMSG := 'Transferência não pode estar pendente.';
            RAISE ERROR;
        END IF;
        IF :NEW.QTDENTREGUE <> 0 THEN
            ERRMSG := 'Transferência não pode ter quantidade entregue diferente de zero.';
            RAISE ERROR;
        END IF;*/

        IF :NEW.USOPROD = 'S' THEN
            ERRMSG := 'Transferência não pode conter itens que são serviço.';
            RAISE ERROR;
        END IF;
    END IF;

    -- =========================================================================
    -- CONTROLE DE ATUALIZAÇÃO DE ESTOQUE E RESERVA:
    -- Determina os valores esperados de RESERVA e ATUALESTOQUE com base na TOP,
    -- verifica FLV e valida a consistência com o que foi informado no item.
    --
    -- Nota: para pedidos com STATUSNOTA = 'P', o item é inserido com
    -- ATUALESTOQUE = 0 para não movimentar estoque até a confirmação/faturamento,
    -- pois a quantidade ainda está reservada.
    -- =========================================================================
    IF :NEW.STATUSNOTA <> 'P' THEN

        -- Define comportamento esperado de reserva e atualização de estoque
        -- de acordo com a configuração ATUALEST da TOP.
        IF    P_ALES = 'N' THEN
            P_RESERVADO_TOP    := 'N';
            P_ATUALESTOQUE_TOP := 0;
        ELSIF P_ALES = 'E' THEN
            P_RESERVADO_TOP    := 'N';
            P_ATUALESTOQUE_TOP := 1;
        ELSIF P_ALES = 'B' THEN
            P_RESERVADO_TOP    := 'N';
            P_ATUALESTOQUE_TOP := -1;
        ELSIF P_ALES = 'R' THEN
            P_RESERVADO_TOP    := 'S';
            P_ATUALESTOQUE_TOP := 1;
        END IF;

        IF P_TIPMOV <> 'F' THEN
            -- Inverte sinal para sequências negativas (devolução/ajuste).
            IF :NEW.SEQUENCIA < 0 THEN
                P_ATUALESTOQUEMP_TOP := P_ATUALESTOQUEMP_TOP * -1;
                P_ATUALESTOQUE_TOP   := P_ATUALESTOQUE_TOP   * -1;
            END IF;

            -- Valida se a reserva do item é consistente com a TOP.
            -- Exceção: quando FLV está habilitado e o produto admite FLV.
            IF (P_RESERVADO_TOP <> :NEW.RESERVA)
               AND ((:NEW.USOPROD <> 'D') OR (:NEW.RESERVA <> 'N'))
            THEN
                SELECT LOGICO
                  INTO P_HABFLV
                  FROM TSIPAR
                 WHERE CHAVE = 'HABFLV';

                -- Permite divergência de reserva apenas quando FLV está habilitado
                -- e o produto tem FLV configurado e o uso não é matéria-prima.
                IF (P_HABFLV <> 'S' OR :NEW.USOPROD = 'M' OR P_TEMFLV <> 'S') THEN
                    ERRMSG := 'Reserva diferente da definição na TOP.';
                    RAISE ERROR;
                END IF;
            END IF;

            -- Valida atualização de estoque de matéria-prima versus PA.
            IF (:NEW.USOPROD = 'M') AND (:NEW.RESERVA = 'N') THEN
                IF (P_ATUALESTOQUEMP_TOP <> :NEW.ATUALESTOQUE)
                   AND NOT (P_ADIARATUALEST = 'S' AND :NEW.ATUALESTOQUE = 0 AND :NEW.STATUSNOTA <> 'L')
                THEN
                    ERRMSG := 'Atualização de estoque de Mat.Prima diferente da definição na TOP.';
                    RAISE ERROR;
                END IF;
            ELSIF (P_ATUALESTOQUE_TOP <> :NEW.ATUALESTOQUE) AND (:NEW.USOPROD <> 'D') THEN
                IF NOT (P_ADIARATUALEST = 'S' AND :NEW.ATUALESTOQUE = 0 AND :NEW.STATUSNOTA <> 'L') THEN
                    ERRMSG := 'Atualização de estoque diferente da definição na TOP.';
                    RAISE ERROR;
                END IF;
            ELSIF (:NEW.USOPROD = 'D')
               AND (P_ATUALESTOQUE_TOP   <> :NEW.ATUALESTOQUE)
               AND (P_ATUALESTOQUEMP_TOP <> :NEW.ATUALESTOQUE)
               AND (:NEW.ATUALESTOQUE    <> 0)
            THEN
                ERRMSG := 'Atualização de estoque diferente da definição na TOP.';
                RAISE ERROR;
            END IF;
        END IF;

    END IF; -- fim IF STATUSNOTA <> 'P'

    -- =========================================================================
    -- ATUALIZAÇÃO DE ESTOQUE FÍSICO (Stp_Atualiza_Tgfest):
    -- Executada apenas quando o tipo de movimento não é 'Z' (sem estoque),
    -- o item deve atualizar estoque, a nota está dentro do controle de contestação
    -- e a reserva ou pendência justificam a movimentação.
    -- =========================================================================
    IF P_TIPMOV <> 'Z' THEN
        BEGIN
            SELECT INTEIRO
              INTO P_INICIOCONTEST
              FROM TSIPAR
             WHERE CHAVE = 'INICIOCONTEST';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                P_INICIOCONTEST := 0;
        END;

        IF (:NEW.ATUALESTOQUE <> 0)
           AND (:NEW.NUNOTA   >= P_INICIOCONTEST)
           AND ((:NEW.RESERVA  = 'N') OR (:NEW.PENDENTE = 'S'))
        THEN
            IF :NEW.RESERVA = 'S' THEN
                P_QTDNEG := :NEW.QTDNEG - :NEW.QTDENTREGUE;
            ELSE
                P_QTDNEG := :NEW.QTDNEG;
            END IF;

            Estoque_Pkg.V_TRANSF := 'N';

            -- Identifica o programa que está abrindo a sessão Oracle.
            SELECT UPPER(PROGRAM)
              INTO P_PROGRAMNAME
              FROM V$SESSION
             WHERE AUDSID = USERENV('SESSIONID')
               AND ROWNUM = 1;

            -- MANOEL OS 823336: em modo varejo (FSTECF.EXE) com VALEST <> 'N',
            -- verifica o parâmetro VALIDAVAREJO para decidir se usa flag de transferência.
            IF P_VALEST <> 'N' AND P_PROGRAMNAME = 'FSTECF.EXE' THEN
                SELECT INTEIRO
                  INTO P_VALIDAVAREJO
                  FROM TSIPAR
                 WHERE CHAVE = 'VALIDAVAREJO';

                IF MOD(P_VALIDAVAREJO, 2) = 0 THEN
                    Estoque_Pkg.V_TRANSF := 'S';
                END IF;
            END IF;

            -- Para transferências (TIPMOV = 'T'), ativa flag de transferência de estoque
            -- quando a empresa é a mesma ou quando o grupo de estoque é global ('G').
            IF P_TIPMOV = 'T' AND P_VALEST IN ('G', 'S') THEN
                IF P_CODEMPCAB = P_CODEMPNEGOC OR P_VALEST = 'G' THEN
                    Estoque_Pkg.V_TRANSF := 'S';
                ELSIF P_VALEST = 'S' THEN
                    SELECT COUNT(DISTINCT NVL(EMPSOMA, CODEMP))
                      INTO P_COUNT
                      FROM TGFEMP
                     WHERE CODEMP IN (P_CODEMPCAB, P_CODEMPNEGOC);

                    IF P_COUNT = 1 THEN
                        Estoque_Pkg.V_TRANSF := 'S';
                    END IF;
                END IF;
            END IF;

            -- Define flag de re-validação de estoque em reserva.
            VARIAVEIS_PKG.V_VALIDA_EST_RESERVAR :=
                P_VALIDA_EST_RESERVAR = 'S'
                AND Get_Tsipar_Logico('REVALIDAESTRES') = 'S';

            -- Atualiza estoque físico (se atualização não estiver sendo adiada).
            IF P_ADIARATUALIZACAOESTOQUE <> 'S' THEN
                Stp_Atualiza_Tgfest(
                    :NEW.RESERVA,
                    :NEW.ATUALESTOQUE,
                    :NEW.CODEMP,
                    :NEW.CODPROD,
                    :NEW.CONTROLE,
                    :NEW.CODLOCALORIG,
                    P_QTDNEG,
                    :NEW.STATUSLOTE,
                    P_ATUALIZOU
                );
            END IF;

            Estoque_Pkg.V_TRANSF := 'N';

            -- Se a atualização de estoque retornar falha, interrompe a inserção.
            IF P_ATUALIZOU = 'N' THEN
                ERRMSG := '(000) Falha na atualização do estoque do produto: '
                          || TO_CHAR(:NEW.CODPROD, '999999999');
                RAISE ERROR;
            END IF;

        END IF;
    END IF; -- fim IF TIPMOV <> 'Z'

    -- =========================================================================
    -- REGISTRO EM TGFITE_INC E AJUSTE DE CFOP PARA TRANSFERÊNCIAS:
    -- Para itens com sequência positiva que devem ser validados, ajusta o CFOP
    -- de acordo com o sentido da transferência (entrada/saída, dentro/fora do estado)
    -- e registra o item na tabela de inclusão temporária TGFITE_INC.
    -- =========================================================================
    IF (:NEW.FATURAR <> 'F') AND (:NEW.SEQUENCIA > 0) AND P_VALIDAR THEN

        P_CFO := :NEW.CODCFO;

        -- Para transferências, ajusta o CFOP para o sentido oposto ao informado.
        IF P_TIPMOV = 'T' THEN
            IF    :NEW.CODCFO = P_CFOENTRADA      THEN P_CFO := P_CFOSAIDA;
            ELSIF :NEW.CODCFO = P_CFOSAIDA        THEN P_CFO := P_CFOENTRADA;
            ELSIF :NEW.CODCFO = P_CFOENTRADA_FORA THEN P_CFO := P_CFOSAIDA_FORA;
            ELSIF :NEW.CODCFO = P_CFOSAIDA_FORA   THEN P_CFO := P_CFOENTRADA_FORA;
            -- CFOPs 1000-3000 (entrada): converte para saída (+4000).
            ELSIF :NEW.CODCFO BETWEEN 1000 AND 3000 THEN
                P_CFO := :NEW.CODCFO + 4000;
            -- CFOPs 5000-7000 (saída): converte para entrada (-4000) com ajustes específicos.
            ELSIF :NEW.CODCFO BETWEEN 5000 AND 7000 THEN
                BEGIN
                    P_CFO := :NEW.CODCFO - 4000;
                    -- Ajuste de CFOP: 2404 não existe, usa 2403.
                    IF P_CFO = 2404 THEN
                        P_CFO := 2403;
                    END IF;
                    -- Ajuste para CFOPs 654-656: recua 3 posições.
                    IF SUBSTR(P_CFO, 2, 4) BETWEEN 654 AND 656 THEN
                        P_CFO := P_CFO - 3;
                    END IF;
                END;
            ELSE
                P_CFO := :NEW.CODCFO;
            END IF;
        END IF;

        -- Insere o item na tabela de controle de inclusão.
        INSERT INTO TGFITE_INC (
            NUNOTA, SEQUENCIA, CFO, CODEMPNEGOC, TIPMOV, RESERVA, ATUALESTOQUE,
            CODEMP, CODPROD, CONTROLE, CODLOCAL, QTDNEG, QTDENTREGUE, USOPROD,
            ATUALESTTERC, TERCEIROS, PERCPUREZA, PERCGERMIN, STATUSLOTE, PENDENTE
        ) VALUES (
            :NEW.NUNOTA, :NEW.SEQUENCIA, P_CFO, P_CODEMPNEGOC, P_TIPMOV,
            :NEW.RESERVA, :NEW.ATUALESTOQUE, :NEW.CODEMP, :NEW.CODPROD,
            :NEW.CONTROLE, :NEW.CODLOCALORIG, :NEW.QTDNEG, :NEW.QTDENTREGUE,
            :NEW.USOPROD, :NEW.ATUALESTTERC, :NEW.TERCEIROS,
            :NEW.PERCPUREZA, :NEW.PERCGERMIN, :NEW.STATUSLOTE, :NEW.PENDENTE
        );

    END IF;

    -- =========================================================================
    -- ARREDONDAMENTO FINAL DE QUANTIDADES (OS 717072 / OS 748512 / OS 756293):
    -- Limita as quantidades a 9 casas decimais para evitar estouro de tipo.
    -- =========================================================================
    :NEW.QTDNEG      := ROUND(:NEW.QTDNEG,      9);  -- OS 717072 / OS 748512
    :NEW.QTDENTREGUE := ROUND(:NEW.QTDENTREGUE, 9);  -- OS 756293

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        -- =====================================================================
        -- TRATAMENTO DE EXCEÇÃO GERAL:
        -- Durante sincronização de dados (P_VALIDAR = FALSE), exceções são
        -- suprimidas para não bloquear o processo interno do Sankhya.
        -- Quando P_VALIDAR = TRUE, o erro é propagado com a mensagem acumulada
        -- em ERRMSG mais o detalhe do SQLERRM.
        -- =====================================================================
        Estoque_Pkg.V_TRANSF              := 'N';
        VARIAVEIS_PKG.V_VALIDA_EST_RESERVAR := false;

        IF P_VALIDAR THEN
            -- SQLCODE = 1 indica erro de constraint (tratado separadamente).
            IF SQLCODE <> 1 THEN
                ERRMSG := ERRMSG || '  ' || SQLERRM;
            END IF;
            RAISE_APPLICATION_ERROR(-20101, ERRMSG);
        END IF;

END TRG_INC_TGFITE;
