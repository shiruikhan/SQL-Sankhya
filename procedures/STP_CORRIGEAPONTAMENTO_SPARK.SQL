CREATE OR REPLACE PROCEDURE STP_CORRIGEAPONTAMENTO_SPARK (
    P_DIAS    NUMBER   DEFAULT 120,  -- Janela de varredura (dias) das conferências finalizadas
    P_IDIPROC NUMBER   DEFAULT NULL, -- Restringe a uma OP específica (ignora a janela P_DIAS)
    P_SIMULA  VARCHAR2 DEFAULT 'N'   -- S = apenas lista (DBMS_OUTPUT), sem alterar nem auditar
) AS
/*==============================================================================
  Nome do Script : STP_CORRIGEAPONTAMENTO_SPARK
  Tipo           : Procedure
  Descrição      : Valida automaticamente os apontamentos de produção (TPRAPA)
                   de cada conferência finalizada (TPRCONF.STATUS = 'F') e
                   corrige os divergentes. O apontamento é localizado pelo
                   vínculo TPRCONF.NUAPO e o valor correto é o nº de séries
                   distintas do PA consolidadas em AD_TPRCOI pela conferência.
                   Substitui a conferência visual manual (script
                   scripts/DIAG_APONTAMENTO_VS_CONFERENCIA.SQL), que antes era
                   feita OP a OP a partir do IDIPROC informado pelo usuário.

                   Correção aplicada (idempotente, por apontamento):
                     UPDATE TPRAPA SET QTDAPONTADA = <séries>, QTDFAT = <séries>
                   somente quando QTDAPONTADA ou QTDFAT diferem do nº de séries.

                   Casos NÃO corrigidos automaticamente (registrados em
                   AD_CORRAPONTAMENTO como IGNORADO_*, uma única vez por
                   conferência, para análise manual):
                   - o mesmo NUAPO atende mais de uma conferência finalizada
                     (IGNORADO_MULTICONF);
                   - o NUAPO tem mais de uma linha em TPRAPA para o mesmo
                     produto (IGNORADO_MULTISEQ).
                   Conferências sem NUAPO vinculado, sem séries em AD_TPRCOI ou
                   sem linha em TPRAPA para o PA não geram ação (nada a corrigir).

                   Ordens canceladas ('C'), em cancelamento ('C2') e finalizadas
                   ('F') — TPRIPROC.STATUSPROC — são sempre ignoradas: a
                   procedure nunca altera o apontamento de uma OP encerrada,
                   mesmo quando P_IDIPROC é informado explicitamente.

  Parâmetros     : P_DIAS    — janela de varredura em dias, pela finalização da
                               conferência (default 120)
                   P_IDIPROC — verifica somente a OP informada; quando informado,
                               a janela P_DIAS NÃO é aplicada (opcional)
                   P_SIMULA  — S/N: com 'S' apenas lista no DBMS_OUTPUT o que
                               seria corrigido, sem UPDATE nem auditoria
  Tabelas        : TPRCONF, TPRIATV, TPRIPROC, AD_TPRCOI (leitura)
                   TPRAPA (leitura/escrita)
                   AD_CORRAPONTAMENTO (auditoria das correções)
  Tabela de Log  : AD_LOG_ERROS
  Dependencias   : AD_CORRAPONTAMENTO (tables/AD_CORRAPONTAMENTO.SQL);
                   AD_TPRCOI alimentada pela TRG_INC_UPD_TPRCONF_SPARK
  Uso            : Primeira execução (carga inicial, janela de 120 dias; cada
                   correção fica em AD_CORRAPONTAMENTO, TIPOCORR = 'AJUSTADO'):
                     BEGIN STP_CORRIGEAPONTAMENTO_SPARK(); END;
                   Execução recorrente por agendador externo (a cada 2 min):
                     BEGIN STP_CORRIGEAPONTAMENTO_SPARK(P_DIAS => 3); END;
                   ou manual, para uma OP específica / simulação:
                     BEGIN STP_CORRIGEAPONTAMENTO_SPARK(P_IDIPROC => 33743); END;
                     BEGIN STP_CORRIGEAPONTAMENTO_SPARK(P_SIMULA => 'S'); END;

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação da procedure
                   Outubro/2026 — Ordens finalizadas (STATUSPROC 'F') passam a
                   ser excluídas da varredura, além das canceladas ('C') e
                   em cancelamento ('C2')
                   Outubro/2026 — Janela padrão (P_DIAS) ampliada de 7 para 120
                   dias
                   Outubro/2026 — Erro de um apontamento passa a ser registrado
                   em AD_LOG_ERROS uma única vez (mesma mensagem não repete);
                   linha de TPRAPA lida com FOR UPDATE NOWAIT: se bloqueada por
                   outra sessão é pulada e retomada na próxima execução, e os
                   valores são relidos sob o bloqueio antes do UPDATE

  Observações    : - O UPDATE em TPRAPA dispara as triggers da tabela, inclusive
                     a TRG_INC_UPD_DLT_TPRAPA_SPARK (recria TPRSERPA da OP/PA e,
                     com QTDFAT > 0, insere séries em AD_TPRSERAPO usando
                     STP_GET_CODUSULOGADO()) e a TRG_VAL_AD_CODFUNC_TPRAPA
                     (exige AD_CODFUNC exceto na etapa de expedição/conferência).
                     É o mesmo efeito da correção manual; validar em
                     homologação como essas triggers se comportam fora de
                     uma sessão de usuário antes de agendar.
                   - Como a correção é idempotente (só atua em divergência), a
                     trigger não é disparada novamente nas execuções seguintes.
                   - Cada apontamento é confirmado (COMMIT) individualmente;
                     erro em um deles é registrado em AD_LOG_ERROS e não
                     interrompe os demais. Será tentado de novo a cada execução
                     enquanto estiver na janela de P_DIAS, mas o mesmo erro
                     (apontamento + código + mensagem) é gravado em
                     AD_LOG_ERROS uma única vez; se a mensagem mudar, grava de
                     novo. Para reavaliar um erro já logado, apague a linha do
                     log depois de corrigir a causa.
                   - Linha de TPRAPA bloqueada por outra sessão (ORA-00054) é
                     pulada em silêncio — situação transitória, retomada na
                     execução seguinte. Bloqueios em outras tabelas tocadas
                     pelas triggers do TPRAPA não são tratados e esperam.
                   - Na primeira execução, com a janela de 120 dias, todas as
                     divergências antigas ainda abertas serão corrigidas de
                     uma vez; rodar antes o dry-run
                     (scripts/DRYRUN_CORRIGEAPONTAMENTO.SQL) e conferir o volume.
                     Depois da carga inicial, agendar com P_DIAS => 3.
                   - Uma conferência finalizada cujo NUAPO ainda não foi
                     vinculado é simplesmente ignorada e reavaliada na próxima
                     execução; a cadência é responsabilidade do agendador.
==============================================================================*/

    V_NUCORR   NUMBER;
    V_QTDAPO   TPRAPA.QTDAPONTADA%TYPE;
    V_QTDFAT   TPRAPA.QTDFAT%TYPE;
    V_PULAR    BOOLEAN;
    V_ERRCODE  NUMBER;
    V_ERRMSG   VARCHAR2(4000);
    V_ERRBACK  VARCHAR2(4000);

    -- ORA-00054: linha de TPRAPA bloqueada por outra sessão (NOWAIT)
    E_LINHA_BLOQUEADA EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_LINHA_BLOQUEADA, -54);

    -- Conferências finalizadas cujo apontamento vinculado diverge do nº de séries
    CURSOR C_DIVERG IS
        SELECT  CNF.NUCONF
               ,ATV.IDIPROC
               ,CNF.NUAPO
               ,APA.SEQAPA
               ,APA.CODPRODPA
               ,SER.QTD_SERIES
               ,APA.QTDAPONTADA
               ,APA.QTDFAT
               ,(SELECT COUNT(*)
                   FROM TPRCONF C2
                  WHERE C2.NUAPO  = CNF.NUAPO
                    AND C2.STATUS = 'F')       AS QTD_CONF_APO
               ,(SELECT COUNT(*)
                   FROM TPRAPA A2
                  WHERE A2.NUAPO     = CNF.NUAPO
                    AND A2.CODPRODPA = SER.CODPROD) AS QTD_SEQ_APO
        FROM    TPRCONF CNF
                INNER JOIN TPRIATV  ATV  ON ATV.IDIATV   = CNF.IDIATV
                INNER JOIN TPRIPROC PROC ON PROC.IDIPROC = ATV.IDIPROC
                INNER JOIN (SELECT  COI.NUCONF
                                   ,COI.CODPROD
                                   ,COUNT(DISTINCT COI.CODBARRA) AS QTD_SERIES
                                   ,MAX(COI.DTINCLUSAO)          AS DHINC
                              FROM  AD_TPRCOI COI
                             GROUP BY COI.NUCONF
                                     ,COI.CODPROD) SER ON SER.NUCONF = CNF.NUCONF
                INNER JOIN TPRAPA   APA  ON APA.NUAPO     = CNF.NUAPO
                                        AND APA.CODPRODPA = SER.CODPROD
        WHERE   CNF.STATUS       = 'F'
        AND     PROC.STATUSPROC NOT IN ('C', 'C2', 'F')  -- cancelada, cancelando ou finalizada: não alterar
        AND     (   APA.QTDAPONTADA <> SER.QTD_SERIES
                 OR APA.QTDFAT      <> SER.QTD_SERIES)
        AND     (   ATV.IDIPROC = P_IDIPROC
                 OR (    P_IDIPROC IS NULL
                     AND COALESCE(CNF.DHFINCONF, SER.DHINC) >= TRUNC(SYSDATE) - P_DIAS))
        ORDER BY CNF.NUCONF;

    -- Cópia de trabalho da linha do cursor (recebe os valores atuais de TPRAPA
    -- lidos sob bloqueio, usados na auditoria)
    V_DIV C_DIVERG%ROWTYPE;

    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2,
        P_NUNOTA        NUMBER,
        P_ERR_CODE      NUMBER,
        P_ERR_MSG       VARCHAR2,
        P_ERR_BACKTRACE VARCHAR2,
        P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;
        -- Trunca nos tamanhos das colunas de AD_LOG_ERROS (OPERACAO é
        -- VARCHAR2(10)!) para o registro do log nunca falhar por ORA-12899
        INSERT INTO AD_LOG_ERROS (
            IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA,
            ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
            V_IDLOG, 'STP_CORRIGEAPONTAMENTO_SPARK', SUBSTR(P_OPERACAO, 1, 10), P_NUNOTA,
            P_ERR_CODE, SUBSTR(P_ERR_MSG, 1, 4000),
            SUBSTR(P_ERR_BACKTRACE, 1, 4000), SUBSTR(P_CALL_STACK, 1, 4000)
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

    -- Grava a auditoria em AD_CORRAPONTAMENTO (na mesma transação, para ser
    -- desfeita junto com a correção em caso de erro)
    PROCEDURE REGISTRA_CORRECAO(
        P_TIPO  VARCHAR2,
        R_DIV   C_DIVERG%ROWTYPE
    ) IS
    BEGIN
        SELECT NVL(MAX(NUCORR), 0) + 1 INTO V_NUCORR FROM AD_CORRAPONTAMENTO;
        INSERT INTO AD_CORRAPONTAMENTO (
            NUCORR, NUCONF, IDIPROC, NUAPO, SEQAPA, CODPRODPA,
            QTDSERIES, QTDAPO_ANT, QTDFAT_ANT, TIPOCORR, DHCORR
        ) VALUES (
            V_NUCORR, R_DIV.NUCONF, R_DIV.IDIPROC, R_DIV.NUAPO, R_DIV.SEQAPA, R_DIV.CODPRODPA,
            R_DIV.QTD_SERIES, R_DIV.QTDAPONTADA, R_DIV.QTDFAT, P_TIPO, SYSDATE
        );
    END REGISTRA_CORRECAO;

    -- Indica se o caso ignorado dessa conferência já foi registrado
    -- (evita repetir a mesma linha a cada execução do agendador)
    FUNCTION JA_REGISTRADO(
        P_TIPO  VARCHAR2,
        R_DIV   C_DIVERG%ROWTYPE
    ) RETURN BOOLEAN IS
        V_QTD NUMBER;
    BEGIN
        SELECT  COUNT(*)
        INTO    V_QTD
        FROM    AD_CORRAPONTAMENTO COR
        WHERE   COR.NUCONF   = R_DIV.NUCONF
        AND     COR.NUAPO    = R_DIV.NUAPO
        AND     COR.SEQAPA   = R_DIV.SEQAPA
        AND     COR.TIPOCORR = P_TIPO;

        RETURN V_QTD > 0;
    END JA_REGISTRADO;

    -- Indica se o mesmo erro (mesmo apontamento, código e mensagem) já consta em
    -- AD_LOG_ERROS — evita um novo registro a cada execução do agendador
    FUNCTION ERRO_JA_LOGADO(
        P_NUAPO    NUMBER,
        P_ERR_CODE NUMBER,
        P_ERR_MSG  VARCHAR2
    ) RETURN BOOLEAN IS
        V_QTD NUMBER;
    BEGIN
        SELECT  COUNT(*)
        INTO    V_QTD
        FROM    AD_LOG_ERROS LGE
        WHERE   LGE.TRIGGER_NAME  = 'STP_CORRIGEAPONTAMENTO_SPARK'
        AND     LGE.OPERACAO      = 'CORRIGEAPO'
        AND     LGE.NUNOTA        = P_NUAPO
        AND     LGE.ERROR_CODE    = P_ERR_CODE
        AND     LGE.ERROR_MESSAGE = SUBSTR(P_ERR_MSG, 1, 4000);

        RETURN V_QTD > 0;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END ERRO_JA_LOGADO;

BEGIN

    FOR R_DIV IN C_DIVERG LOOP
        BEGIN
            SAVEPOINT SP_APO;

            ---------------------------------------------------------------------------
            -- 1. Casos ambíguos: registra uma única vez e não altera o apontamento
            ---------------------------------------------------------------------------
            IF R_DIV.QTD_CONF_APO > 1 THEN

                IF P_SIMULA = 'S' THEN
                    DBMS_OUTPUT.PUT_LINE('IGNORADO_MULTICONF  NUCONF ' || R_DIV.NUCONF
                        || ' NUAPO ' || R_DIV.NUAPO);
                ELSIF NOT JA_REGISTRADO('IGNORADO_MULTICONF', R_DIV) THEN
                    REGISTRA_CORRECAO('IGNORADO_MULTICONF', R_DIV);
                END IF;

            ELSIF R_DIV.QTD_SEQ_APO > 1 THEN

                IF P_SIMULA = 'S' THEN
                    DBMS_OUTPUT.PUT_LINE('IGNORADO_MULTISEQ   NUCONF ' || R_DIV.NUCONF
                        || ' NUAPO ' || R_DIV.NUAPO);
                ELSIF NOT JA_REGISTRADO('IGNORADO_MULTISEQ', R_DIV) THEN
                    REGISTRA_CORRECAO('IGNORADO_MULTISEQ', R_DIV);
                END IF;

            ---------------------------------------------------------------------------
            -- 2. Caso comum: apontamento diverge das séries conferidas -> corrige
            ---------------------------------------------------------------------------
            ELSIF P_SIMULA = 'S' THEN

                DBMS_OUTPUT.PUT_LINE('AJUSTARIA  OP ' || R_DIV.IDIPROC
                    || ' NUCONF ' || R_DIV.NUCONF
                    || ' NUAPO ' || R_DIV.NUAPO || '/' || R_DIV.SEQAPA
                    || ' QTDAPONTADA ' || R_DIV.QTDAPONTADA
                    || ' QTDFAT ' || R_DIV.QTDFAT
                    || ' -> ' || R_DIV.QTD_SERIES);

            ELSE

                -- Bloqueia a linha sem esperar: se outra sessão a estiver usando
                -- (apontamento em andamento), pula e tenta na próxima execução.
                -- Relê os valores sob o bloqueio: se já foram corrigidos desde a
                -- leitura do cursor, não há nada a fazer.
                V_PULAR := FALSE;
                V_DIV   := R_DIV;

                BEGIN
                    SELECT  APA.QTDAPONTADA
                           ,APA.QTDFAT
                    INTO    V_QTDAPO
                           ,V_QTDFAT
                    FROM    TPRAPA APA
                    WHERE   APA.NUAPO  = R_DIV.NUAPO
                    AND     APA.SEQAPA = R_DIV.SEQAPA
                    FOR UPDATE NOWAIT;

                    V_DIV.QTDAPONTADA := V_QTDAPO;
                    V_DIV.QTDFAT      := V_QTDFAT;
                EXCEPTION
                    WHEN E_LINHA_BLOQUEADA OR NO_DATA_FOUND THEN
                        V_PULAR := TRUE;
                END;

                IF NOT V_PULAR
                   AND (   V_DIV.QTDAPONTADA <> R_DIV.QTD_SERIES
                        OR V_DIV.QTDFAT      <> R_DIV.QTD_SERIES) THEN

                    UPDATE  TPRAPA
                    SET     QTDAPONTADA = R_DIV.QTD_SERIES
                           ,QTDFAT      = R_DIV.QTD_SERIES
                    WHERE   NUAPO  = R_DIV.NUAPO
                    AND     SEQAPA = R_DIV.SEQAPA;

                    REGISTRA_CORRECAO('AJUSTADO', V_DIV);

                END IF;

            END IF;

            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                V_ERRCODE := SQLCODE;
                V_ERRMSG  := SUBSTR('Conferencia ' || R_DIV.NUCONF || ' / OP '
                                    || R_DIV.IDIPROC || ' / Apontamento ' || R_DIV.NUAPO
                                    || '-' || R_DIV.SEQAPA || ' - ' || SQLERRM, 1, 4000);
                V_ERRBACK := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 4000);

                ROLLBACK TO SP_APO;

                -- Registra o erro uma única vez por apontamento/mensagem
                IF NOT ERRO_JA_LOGADO(R_DIV.NUAPO, V_ERRCODE, V_ERRMSG) THEN
                    LOG_ERRO('CORRIGEAPO', R_DIV.NUAPO, V_ERRCODE, V_ERRMSG,
                             V_ERRBACK, DBMS_UTILITY.FORMAT_CALL_STACK);
                END IF;
        END;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        LOG_ERRO('GERAL', NULL,
                 SQLCODE, SQLERRM,
                 DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                 DBMS_UTILITY.FORMAT_CALL_STACK);
        RAISE_APPLICATION_ERROR(-20093,
            'STP_CORRIGEAPONTAMENTO_SPARK - Erro na verificação dos apontamentos: '
            || SQLERRM);
END STP_CORRIGEAPONTAMENTO_SPARK;
/
