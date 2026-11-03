CREATE OR REPLACE PROCEDURE EVP_GEROBRGDIFAL_SPARK (
    P_CODUSU    NUMBER
   ,P_IDSESSAO  VARCHAR2
   ,P_QTDLINHAS NUMBER
   ,P_MENSAGEM  OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : EVP_GEROBRGDIFAL_SPARK
  Tipo           : Procedure
  Descrição      : Gera as obrigações fiscais de DIFAL e FCP (destinatário) na
                   TGFOIR a partir das notas do período.

                   A seleção de notas segue exatamente o componente BI 26
                   (APURAÇÃO DIFAL), que é a referência validada de valores:
                   - TGFCAB.STATUSNOTA = 'L' (nota confirmada);
                   - TGFCAB.STATUSNFE  = 'A' (NF-e aprovada);
                   - período por TRUNC(TGFCAB.DTFATUR);
                   - TGFCAB.VLRICMSDIFALDEST > 0;
                   - UF pela cidade do parceiro (TGFPAR.CODCID).

                   TIPO = 1 - POR OPERAÇÃO (empresa sem IE na UF de destino):
                   - Uma obrigação por nota e imposto, AD_NUNOTA preenchido.
                   - Somente vendas (TIPMOV = 'V').
                   - Vencimento: data da negociação.

                   TIPO = 2 - POR APURAÇÃO (empresa com IE na UF de destino):
                   - Agrupa por empresa, UF e competência (mês de DTFATUR).
                   - DIFAL devido = Vendas - Devoluções.
                   - FCP devido   = Vendas - Devoluções.
                   - AD_NUNOTA = NULL.
                   - Vencimento: dia 9 do mês seguinte à competência.

                   OBRIGAÇÕES (TIPAPURACAO = 'D' em ambas as modalidades):
                   - DIFAL por operação: CODOBR = 90 / CODREC = 100102
                   - DIFAL por apuração: CODOBR = 90 / CODREC = 100110
                   - FCP:                CODOBR = 6  / CODREC = 100129

  Parâmetros     : P_CODUSU    — usuário que dispara a ação (gravado em CODUSU)
                   P_IDSESSAO  — sessão da tela, usada para ler os parâmetros:
                                 P_DATAINI (data inicial), P_DATAFIN (data
                                 final) e P_CODEMP (empresa)
                   P_QTDLINHAS — padrão de ação Sankhya (não utilizado)
                   P_MENSAGEM  — retorno com a quantidade gerada por modalidade

  Tabelas        : TGFCAB       -- cabeçalho de notas (leitura)
                   TGFPAR       -- parceiro (leitura)
                   TSICID       -- cidade do parceiro (leitura)
                   TSIUFS       -- UF (leitura)
                   TSIIUF       -- IE da empresa por UF (leitura)
                   TGFOIR       -- obrigações de ICMS a recolher (escrita)
  Tabela de Log  : AD_LOG_ERROS -- somente erros inesperados
  Dependencias   : ACT_DTA_PARAM, ACT_INT_PARAM
  Uso            : Ação da tela de obrigações fiscais.

  Autor          : Lucas Gabriel
  Empresa        : Spark Eletrônica
  Data de Criação: 22/10/2026
  Última Revisão : Out/2026 - Lucas Gabriel - modalidades por P_TIPO, vencimento
                   via ADD_MONTHS e CODREC 100110 na apuração.
                   Nov/2026 - Silvio Vieira - seleção de notas alinhada ao
                   componente BI 26: exige STATUSNOTA = 'L', STATUSNFE = 'A' e
                   VLRICMSDIFALDEST > 0; período e competência passam de DTNEG
                   para DTFATUR. Corrige obrigações geradas para UF sem DIFAL
                   válido (ex.: BA, empresa 1, 10/2026). Log de erro em
                   AD_LOG_ERROS e padronização de cabeçalho.

  Observações    : - Nota só com FCP (VLRICMSDIFALDEST = 0) não gera obrigação,
                     como no componente 26.
                   - Duplicidade validada por modalidade; rodar de novo no
                     mesmo período aborta com erro -20001.
                   - Sequência por empresa, referência e apuração.
                   - Rollback integral em caso de erro.
==============================================================================*/

    PARAM_P_DATAINI DATE;
    PARAM_P_DATAFIN DATE;
    PARAM_P_CODEMP  TGFCAB.CODEMP%TYPE;

    V_SEQUENCIA     TGFOIR.SEQUENCIA%TYPE;
    V_EXISTE        NUMBER;
    V_QTD_OPERACAO  NUMBER := 0;
    V_QTD_APURACAO  NUMBER := 0;

    ---------------------------------------------------------------------------
    -- Cursor 1 - Obrigações por operação (empresa sem IE na UF)
    ---------------------------------------------------------------------------
    CURSOR C_OPERACAO IS
        SELECT  CAB.NUNOTA
               ,CAB.CODEMP
               ,UFS.CODUF
               ,1                                  AS TIPO
               ,TRUNC(CAB.DTFATUR, 'MM')           AS DTREF
               ,TRUNC(CAB.DTNEG)                   AS DTVCTO
               ,NVL(CAB.VLRICMSDIFALDEST, 0)       AS DIFAL
               ,NVL(CAB.VLRICMSFCP, 0)             AS FCP
          FROM  TGFCAB CAB
         INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
         INNER JOIN TSICID CID ON CID.CODCID  = PAR.CODCID
         INNER JOIN TSIUFS UFS ON UFS.CODUF   = CID.UF
         WHERE  CAB.CODEMP     = PARAM_P_CODEMP
           AND  CAB.STATUSNOTA = 'L'
           AND  CAB.STATUSNFE  = 'A'
           AND  TRUNC(CAB.DTFATUR) >= TRUNC(PARAM_P_DATAINI)
           AND  TRUNC(CAB.DTFATUR) <= TRUNC(PARAM_P_DATAFIN)
           AND  CAB.TIPMOV     = 'V'
           AND  NVL(CAB.VLRICMSDIFALDEST, 0) > 0
           -- Empresa não possui IE na UF
           AND  NOT EXISTS (
                    SELECT 1
                      FROM TSIIUF IE
                     WHERE IE.CODEMP = CAB.CODEMP
                       AND IE.CODUF  = UFS.CODUF
                       AND TRIM(IE.INSCRICAO) IS NOT NULL
                )
         ORDER BY CAB.DTFATUR
                 ,CAB.NUNOTA;

    ---------------------------------------------------------------------------
    -- Cursor 2 - Obrigações por apuração (empresa com IE na UF)
    --            Vendas menos devoluções
    ---------------------------------------------------------------------------
    CURSOR C_APURACAO IS
        SELECT  CAB.CODEMP
               ,UFS.CODUF
               ,2                                                  AS TIPO
               ,TRUNC(CAB.DTFATUR, 'MM')                           AS DTREF
               ,ADD_MONTHS(TRUNC(CAB.DTFATUR, 'MM'), 1) + 8        AS DTVCTO
               ,SUM(CASE WHEN CAB.TIPMOV = 'V' THEN NVL(CAB.VLRICMSDIFALDEST, 0) ELSE 0 END) AS DIFAL_VENDAS
               ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN NVL(CAB.VLRICMSDIFALDEST, 0) ELSE 0 END) AS DIFAL_DEVOLUCOES
               ,SUM(CASE WHEN CAB.TIPMOV = 'V' THEN  NVL(CAB.VLRICMSDIFALDEST, 0)
                         WHEN CAB.TIPMOV = 'D' THEN -NVL(CAB.VLRICMSDIFALDEST, 0)
                         ELSE 0
                    END)                                                            AS DIFAL_DEVIDO
               ,SUM(CASE WHEN CAB.TIPMOV = 'V' THEN NVL(CAB.VLRICMSFCP, 0) ELSE 0 END)       AS FCP_VENDAS
               ,SUM(CASE WHEN CAB.TIPMOV = 'D' THEN NVL(CAB.VLRICMSFCP, 0) ELSE 0 END)       AS FCP_DEVOLUCOES
               ,SUM(CASE WHEN CAB.TIPMOV = 'V' THEN  NVL(CAB.VLRICMSFCP, 0)
                         WHEN CAB.TIPMOV = 'D' THEN -NVL(CAB.VLRICMSFCP, 0)
                         ELSE 0
                    END)                                                            AS FCP_DEVIDO
               ,COUNT(*)                                           AS QTD_NOTAS
          FROM  TGFCAB CAB
         INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
         INNER JOIN TSICID CID ON CID.CODCID  = PAR.CODCID
         INNER JOIN TSIUFS UFS ON UFS.CODUF   = CID.UF
         WHERE  CAB.CODEMP     = PARAM_P_CODEMP
           AND  CAB.STATUSNOTA = 'L'
           AND  CAB.STATUSNFE  = 'A'
           AND  TRUNC(CAB.DTFATUR) >= TRUNC(PARAM_P_DATAINI)
           AND  TRUNC(CAB.DTFATUR) <= TRUNC(PARAM_P_DATAFIN)
           AND  CAB.TIPMOV IN ('V', 'D')
           AND  NVL(CAB.VLRICMSDIFALDEST, 0) > 0
           -- Empresa possui IE na UF
           AND  EXISTS (
                    SELECT 1
                      FROM TSIIUF IE
                     WHERE IE.CODEMP = CAB.CODEMP
                       AND IE.CODUF  = UFS.CODUF
                       AND TRIM(IE.INSCRICAO) IS NOT NULL
                )
         GROUP BY CAB.CODEMP
                 ,UFS.CODUF
                 ,TRUNC(CAB.DTFATUR, 'MM')
         ORDER BY DTREF
                 ,CODUF;

    ---------------------------------------------------------------------------
    -- Registra erros em AD_LOG_ERROS com transacao autonoma
    ---------------------------------------------------------------------------
    PROCEDURE LOG_ERRO(
        P_OPERACAO      VARCHAR2
       ,P_NUNOTA        NUMBER
       ,P_ERR_CODE      NUMBER
       ,P_ERR_MSG       VARCHAR2
       ,P_ERR_BACKTRACE VARCHAR2
       ,P_CALL_STACK    VARCHAR2
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        V_IDLOG NUMBER;
    BEGIN
        SELECT NVL(MAX(IDLOG), 0) + 1 INTO V_IDLOG FROM AD_LOG_ERROS;

        INSERT INTO AD_LOG_ERROS (
             IDLOG, TRIGGER_NAME, OPERACAO, NUNOTA
            ,ERROR_CODE, ERROR_MESSAGE, ERROR_BACKTRACE, CALL_STACK
        ) VALUES (
             V_IDLOG, 'EVP_GEROBRGDIFAL_SPARK', P_OPERACAO, P_NUNOTA
            ,P_ERR_CODE, P_ERR_MSG, P_ERR_BACKTRACE, P_CALL_STACK
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END LOG_ERRO;

    ---------------------------------------------------------------------------
    -- Insere uma obrigação na TGFOIR
    ---------------------------------------------------------------------------
    PROCEDURE PRC_INSERIR (
        P_CODEMP      NUMBER
       ,P_CODUF       NUMBER
       ,P_DTREF       DATE
       ,P_DTVCTO      DATE
       ,P_TIPAPURACAO VARCHAR2
       ,P_CODOBR      NUMBER
       ,P_CODREC      NUMBER
       ,P_VALOR       NUMBER
       ,P_NUNOTA      NUMBER
       ,P_TIPO        NUMBER
    ) AS
    BEGIN
        -- Valida modalidade
        IF P_TIPO IS NULL
           OR P_TIPO NOT IN (1, 2)
        THEN
            RAISE_APPLICATION_ERROR(-20005, 'Tipo de geração inválido: ' || NVL(TO_CHAR(P_TIPO), 'NULL'));
        END IF;

        -- Não insere valores zero ou negativos
        IF NVL(P_VALOR, 0) <= 0 THEN
            RETURN;
        END IF;

        -- Valida vínculo com nota
        IF P_TIPO = 1
           AND P_NUNOTA IS NULL
        THEN
            RAISE_APPLICATION_ERROR(-20006, 'Obrigação por operação exige NUNOTA.');
        ELSIF P_TIPO = 2
              AND P_NUNOTA IS NOT NULL
        THEN
            RAISE_APPLICATION_ERROR(-20007, 'Obrigação por apuração não deve possuir NUNOTA.');
        END IF;

        -- Verifica duplicidade por modalidade
        SELECT COUNT(1)
          INTO V_EXISTE
          FROM TGFOIR OIR
         WHERE OIR.CODEMP      = P_CODEMP
           AND OIR.CODUF       = P_CODUF
           AND OIR.DTREF       = P_DTREF
           AND OIR.TIPAPURACAO = P_TIPAPURACAO
           AND OIR.CODOBR      = P_CODOBR
           AND (   (P_TIPO = 1 AND OIR.AD_NUNOTA = P_NUNOTA)
                OR (P_TIPO = 2 AND OIR.AD_NUNOTA IS NULL)
               );

        IF V_EXISTE > 0 THEN
            RAISE_APPLICATION_ERROR(
                 -20001
                ,'Obrigação fiscal já existente. '
                 || 'Tipo: '         || P_TIPO
                 || ' | Empresa: '   || P_CODEMP
                 || ' | UF: '        || P_CODUF
                 || ' | Referência: '|| TO_CHAR(P_DTREF, 'MM/YYYY')
                 || ' | Obrigação: ' || P_CODOBR
                 || ' | Nota: '      || NVL(TO_CHAR(P_NUNOTA), 'APURACAO')
            );
        END IF;

        -- Obtém próxima sequência
        SELECT NVL(MAX(OIR.SEQUENCIA), 0) + 1
          INTO V_SEQUENCIA
          FROM TGFOIR OIR
         WHERE OIR.CODEMP      = P_CODEMP
           AND OIR.DTREF       = P_DTREF
           AND OIR.TIPAPURACAO = P_TIPAPURACAO;

        INSERT INTO TGFOIR (
             CODEMP
            ,DTREF
            ,TIPAPURACAO
            ,CODUF
            ,CODOBR
            ,VALOR
            ,DTVCTO
            ,CODREC
            ,CODRECDIME
            ,CODCLSVENCDIME
            ,NUMPROCESSO
            ,ORIGPROCESSO
            ,DESCRPROCESSO
            ,INDSUBAPURACAO
            ,DESCRCOMPL
            ,CODUSU
            ,DTALTER
            ,SEQUENCIA
            ,AD_NUNOTA
        ) VALUES (
             P_CODEMP
            ,P_DTREF
            ,P_TIPAPURACAO
            ,P_CODUF
            ,P_CODOBR
            ,P_VALOR
            ,P_DTVCTO
            ,P_CODREC
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,NULL
            ,P_CODUSU
            ,SYSDATE
            ,V_SEQUENCIA
            ,P_NUNOTA
        );

        -- Contabiliza pela modalidade
        IF P_TIPO = 1 THEN
            V_QTD_OPERACAO := V_QTD_OPERACAO + 1;
        ELSIF P_TIPO = 2 THEN
            V_QTD_APURACAO := V_QTD_APURACAO + 1;
        END IF;
    END PRC_INSERIR;

BEGIN
    -- Antes de qualquer validação: o ROLLBACK TO do handler exige o savepoint
    SAVEPOINT SP_GEROBRGDIFAL;

    ---------------------------------------------------------------------------
    -- 1. Recupera e valida os parâmetros da tela
    ---------------------------------------------------------------------------
    PARAM_P_DATAINI := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAINI');
    PARAM_P_DATAFIN := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAFIN');
    PARAM_P_CODEMP  := ACT_INT_PARAM(P_IDSESSAO, 'P_CODEMP');

    IF PARAM_P_CODEMP IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Informe a empresa.');
    END IF;

    IF PARAM_P_DATAINI IS NULL
       OR PARAM_P_DATAFIN IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20003, 'Informe o período inicial e final.');
    END IF;

    IF TRUNC(PARAM_P_DATAINI) > TRUNC(PARAM_P_DATAFIN) THEN
        RAISE_APPLICATION_ERROR(-20004, 'A data inicial não pode ser maior que a final.');
    END IF;

    ---------------------------------------------------------------------------
    -- 2. Geração por operação (TIPO = 1)
    ---------------------------------------------------------------------------
    FOR R_OPE IN C_OPERACAO LOOP
        -- DIFAL por operação
        IF R_OPE.DIFAL > 0 THEN
            PRC_INSERIR(
                 R_OPE.CODEMP
                ,R_OPE.CODUF
                ,R_OPE.DTREF
                ,R_OPE.DTVCTO
                ,'D'
                ,90
                ,100102
                ,R_OPE.DIFAL
                ,R_OPE.NUNOTA
                ,R_OPE.TIPO
            );
        END IF;

        -- FCP por operação
        IF R_OPE.FCP > 0 THEN
            PRC_INSERIR(
                 R_OPE.CODEMP
                ,R_OPE.CODUF
                ,R_OPE.DTREF
                ,R_OPE.DTVCTO
                ,'D'
                ,6
                ,100129
                ,R_OPE.FCP
                ,R_OPE.NUNOTA
                ,R_OPE.TIPO
            );
        END IF;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 3. Geração por apuração (TIPO = 2) - vendas menos devoluções
    ---------------------------------------------------------------------------
    FOR R_APU IN C_APURACAO LOOP
        -- DIFAL devido
        IF R_APU.DIFAL_DEVIDO > 0 THEN
            PRC_INSERIR(
                 R_APU.CODEMP
                ,R_APU.CODUF
                ,R_APU.DTREF
                ,R_APU.DTVCTO
                ,'D'
                ,90
                ,100110
                ,R_APU.DIFAL_DEVIDO
                ,NULL
                ,R_APU.TIPO
            );
        END IF;

        -- FCP devido
        IF R_APU.FCP_DEVIDO > 0 THEN
            PRC_INSERIR(
                 R_APU.CODEMP
                ,R_APU.CODUF
                ,R_APU.DTREF
                ,R_APU.DTVCTO
                ,'D'
                ,6
                ,100129
                ,R_APU.FCP_DEVIDO
                ,NULL
                ,R_APU.TIPO
            );
        END IF;
    END LOOP;

    ---------------------------------------------------------------------------
    -- 4. Mensagem final
    ---------------------------------------------------------------------------
    P_MENSAGEM := 'Obrigações fiscais geradas com sucesso. '
                  || 'Por operação: '  || V_QTD_OPERACAO
                  || ' | Por apuração: ' || V_QTD_APURACAO
                  || ' | Total: '      || (V_QTD_OPERACAO + V_QTD_APURACAO);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SP_GEROBRGDIFAL;

        -- Erros de validação (-20001 a -20007) já trazem a mensagem ao usuário
        IF SQLCODE NOT BETWEEN -20007 AND -20001 THEN
            LOG_ERRO(
                 'GEROBRG'
                ,NULL
                ,SQLCODE
                ,SQLERRM
                ,DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                ,DBMS_UTILITY.FORMAT_CALL_STACK
            );
        END IF;

        RAISE;
END EVP_GEROBRGDIFAL_SPARK;
