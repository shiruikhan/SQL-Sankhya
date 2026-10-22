CREATE OR REPLACE PROCEDURE EVP_GEROBRGDIFAL_SPARK (
    P_CODUSU    NUMBER,
    P_IDSESSAO  VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM  OUT VARCHAR2
) AS

    PARAM_P_DATAINI DATE;
    PARAM_P_DATAFIN DATE;
    PARAM_P_CODEMP  NUMBER;

    V_SEQUENCIA TGFOIR.SEQUENCIA%TYPE;
    V_EXISTE    NUMBER;

    V_QTD_OPERACAO NUMBER := 0;
    V_QTD_APURACAO NUMBER := 0;

    /****************************************************
    AUTOR: Lucas Gabriel
    DATA: 22/10/2026

    OBJETIVO:
    Gerar obrigações fiscais DIFAL e FCP na TGFOIR.

    PARÂMETROS:
    P_DATAINI - Data inicial
    P_DATAFIN - Data final
    P_CODEMP  - Empresa

    TIPO = 1 - POR OPERAÇÃO:
    - Empresa sem IE na UF de destino.
    - Uma obrigação por nota e imposto.
    - AD_NUNOTA preenchido.
    - Vencimento: data da negociação.

    TIPO = 2 - POR APURAÇÃO:
    - Empresa com IE na UF de destino.
    - Agrupa por empresa, UF e competência.
    - DIFAL devido = Vendas - Devoluções.
    - FCP devido = Vendas - Devoluções.
    - AD_NUNOTA = NULL.
    - Vencimento: primeiro dia do mês + 8 dias.

    OBRIGAÇÕES:
    DIFAL: CODOBR = 90 / CODREC = 100102
    FCP:   CODOBR = 6  / CODREC = 100129

    TIPAPURACAO = 'D' EM AMBAS AS MODALIDADES.

    CONTROLES:
    - Duplicidade por modalidade.
    - Sequência por empresa, referência e apuração.
    - Rollback integral em caso de erro.
    ****************************************************/


    /****************************************************
    CURSOR 1 - OBRIGAÇÕES POR OPERAÇÃO
    ****************************************************/

    CURSOR C_OPERACAO IS

        SELECT
             CAB.NUNOTA
            ,CAB.CODEMP
            ,UFS.CODUF
            ,1 AS TIPO
            ,TRUNC(CAB.DTNEG, 'MM') AS DTREF
            ,TRUNC(CAB.DTNEG) AS DTVCTO
            ,NVL(CAB.VLRICMSDIFALDEST, 0) AS DIFAL
            ,NVL(CAB.VLRICMSFCP, 0) AS FCP

        FROM TGFCAB CAB

        INNER JOIN TGFPAR PAR
            ON PAR.CODPARC = CAB.CODPARC

        INNER JOIN TSICID CID
            ON CID.CODCID = PAR.CODCID

        INNER JOIN TSIUFS UFS
            ON UFS.CODUF = CID.UF

        WHERE CAB.CODEMP = PARAM_P_CODEMP
          AND CAB.DTNEG >= PARAM_P_DATAINI
          AND CAB.DTNEG <= PARAM_P_DATAFIN
          AND CAB.TIPMOV = 'V'
          AND (
                 NVL(CAB.VLRICMSDIFALDEST, 0) > 0
              OR NVL(CAB.VLRICMSFCP, 0) > 0
               )
          /* EMPRESA NÃO POSSUI IE NA UF */
          AND NOT EXISTS (
              SELECT 1
                FROM TSIIUF IE
               WHERE IE.CODEMP = CAB.CODEMP
                 AND IE.CODUF = UFS.CODUF
                 AND TRIM(IE.INSCRICAO) IS NOT NULL
          )
        ORDER BY
             CAB.DTNEG
            ,CAB.NUNOTA;


    /****************************************************
    CURSOR 2 - OBRIGAÇÕES POR APURAÇÃO
    VENDAS MENOS DEVOLUÇÕES
    ****************************************************/

    CURSOR C_APURACAO IS

        SELECT
             CAB.CODEMP
            ,UFS.CODUF
            ,2 AS TIPO
            ,TRUNC(CAB.DTNEG, 'MM') AS DTREF
            ,TRUNC(CAB.DTNEG, 'MM') + 8 AS DTVCTO

            /* DIFAL DAS VENDAS */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'V'
                    THEN NVL(CAB.VLRICMSDIFALDEST, 0)
                    ELSE 0
                END
            ) AS DIFAL_VENDAS

            /* DIFAL DAS DEVOLUÇÕES */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'D'
                    THEN NVL(CAB.VLRICMSDIFALDEST, 0)
                    ELSE 0
                END
            ) AS DIFAL_DEVOLUCOES

            /* DIFAL DEVIDO */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'V'
                    THEN NVL(CAB.VLRICMSDIFALDEST, 0)

                    WHEN CAB.TIPMOV = 'D'
                    THEN -NVL(CAB.VLRICMSDIFALDEST, 0)

                    ELSE 0
                END
            ) AS DIFAL_DEVIDO

            /* FCP DAS VENDAS */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'V'
                    THEN NVL(CAB.VLRICMSFCP, 0)
                    ELSE 0
                END
            ) AS FCP_VENDAS

            /* FCP DAS DEVOLUÇÕES */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'D'
                    THEN NVL(CAB.VLRICMSFCP, 0)
                    ELSE 0
                END
            ) AS FCP_DEVOLUCOES

            /* FCP DEVIDO */

            ,SUM(
                CASE
                    WHEN CAB.TIPMOV = 'V'
                    THEN NVL(CAB.VLRICMSFCP, 0)

                    WHEN CAB.TIPMOV = 'D'
                    THEN -NVL(CAB.VLRICMSFCP, 0)

                    ELSE 0
                END
            ) AS FCP_DEVIDO

            ,COUNT(*) AS QTD_NOTAS

        FROM TGFCAB CAB

        INNER JOIN TGFPAR PAR
            ON PAR.CODPARC = CAB.CODPARC

        INNER JOIN TSICID CID
            ON CID.CODCID = PAR.CODCID

        INNER JOIN TSIUFS UFS
            ON UFS.CODUF = CID.UF

        WHERE CAB.CODEMP = PARAM_P_CODEMP
          AND CAB.DTNEG >= PARAM_P_DATAINI
          AND CAB.DTNEG <= PARAM_P_DATAFIN
          AND CAB.TIPMOV IN ('V', 'D')
          AND (
                 NVL(CAB.VLRICMSDIFALDEST, 0) <> 0
              OR NVL(CAB.VLRICMSFCP, 0) <> 0
          )
          /* EMPRESA POSSUI IE NA UF */
          AND EXISTS (
              SELECT 1
                FROM TSIIUF IE
               WHERE IE.CODEMP = CAB.CODEMP
                 AND IE.CODUF = UFS.CODUF
                 AND TRIM(IE.INSCRICAO) IS NOT NULL
          )
        GROUP BY
             CAB.CODEMP
            ,UFS.CODUF
            ,TRUNC(CAB.DTNEG, 'MM')

        ORDER BY
             DTREF
            ,CODUF;


    /****************************************************
    PROCEDURE INTERNA - INSERIR OBRIGAÇÃO
    ****************************************************/

    PROCEDURE PRC_INSERIR (
        P_CODEMP      NUMBER,
        P_CODUF       NUMBER,
        P_DTREF       DATE,
        P_DTVCTO      DATE,
        P_TIPAPURACAO VARCHAR2,
        P_CODOBR      NUMBER,
        P_CODREC      NUMBER,
        P_VALOR       NUMBER,
        P_NUNOTA      NUMBER,
        P_TIPO        NUMBER
    ) AS

    BEGIN

        /* VALIDA MODALIDADE */

        IF P_TIPO NOT IN (1, 2)
		   OR P_TIPO IS NULL
		   THEN
            RAISE_APPLICATION_ERROR(-20005,'Tipo de geração inválido: ' || NVL(TO_CHAR(P_TIPO), 'NULL'));
        END IF;

        /* NÃO INSERE VALORES ZERO OU NEGATIVOS */

        IF NVL(P_VALOR, 0) <= 0
		THEN
            RETURN;
        END IF;

        /* VALIDA VÍNCULO COM NOTA */

        IF P_TIPO = 1
		   AND P_NUNOTA IS NULL
		  THEN
            RAISE_APPLICATION_ERROR(-20006,'Obrigação por operação exige NUNOTA.');
        ELSIF P_TIPO = 2
		    AND P_NUNOTA IS NOT NULL
		THEN

            RAISE_APPLICATION_ERROR( -20007,'Obrigação por apuração não deve possuir NUNOTA.' );

        END IF;

        /************************************************
        VERIFICA DUPLICIDADE POR MODALIDADE
        ************************************************/

        SELECT COUNT(1)
          INTO V_EXISTE
          FROM TGFOIR OIR
         WHERE OIR.CODEMP = P_CODEMP
           AND OIR.CODUF = P_CODUF
           AND OIR.DTREF = P_DTREF
           AND OIR.TIPAPURACAO = P_TIPAPURACAO
           AND OIR.CODOBR = P_CODOBR

           AND (
                (
                    P_TIPO = 1
                    AND OIR.AD_NUNOTA = P_NUNOTA
                )
                OR
                (
                    P_TIPO = 2
                    AND OIR.AD_NUNOTA IS NULL
                )
           );

        IF V_EXISTE > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20001,
                'Obrigação fiscal já existente. ' ||
                'Tipo: ' || P_TIPO ||
                ' | Empresa: ' || P_CODEMP ||
                ' | UF: ' || P_CODUF ||
                ' | Referência: ' ||
                TO_CHAR(P_DTREF, 'MM/YYYY') ||
                ' | Obrigação: ' || P_CODOBR ||
                ' | Nota: ' ||
                NVL(TO_CHAR(P_NUNOTA), 'APURACAO')
            );

        END IF;

        /************************************************
        OBTÉM PRÓXIMA SEQUÊNCIA
        ************************************************/

        SELECT NVL(MAX(OIR.SEQUENCIA), 0) + 1
          INTO V_SEQUENCIA
          FROM TGFOIR OIR
         WHERE OIR.CODEMP = P_CODEMP
           AND OIR.DTREF = P_DTREF
           AND OIR.TIPAPURACAO = P_TIPAPURACAO;

        /************************************************
        INSERE OBRIGAÇÃO NA TGFOIR
        ************************************************/

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
        )
        VALUES (
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

        /************************************************
        CONTABILIZA MODALIDADE PELO TIPO
        ************************************************/

        IF P_TIPO = 1 THEN

            V_QTD_OPERACAO := V_QTD_OPERACAO + 1;

        ELSIF P_TIPO = 2 THEN

            V_QTD_APURACAO := V_QTD_APURACAO + 1;

        END IF;

    END PRC_INSERIR;


BEGIN

    /****************************************************
    RECUPERA PARÂMETROS DA TELA
    ****************************************************/

    PARAM_P_DATAINI := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAINI');
    PARAM_P_DATAFIN := ACT_DTA_PARAM(P_IDSESSAO, 'P_DATAFIN');
    PARAM_P_CODEMP  := ACT_INT_PARAM(P_IDSESSAO, 'P_CODEMP');


    /****************************************************
    VALIDA PARÂMETROS
    ****************************************************/

    IF PARAM_P_CODEMP IS NULL
		THEN
        RAISE_APPLICATION_ERROR(-20002,'Informe a empresa.');
    END IF;

    IF PARAM_P_DATAINI IS NULL
       OR PARAM_P_DATAFIN IS NULL
	   THEN
        RAISE_APPLICATION_ERROR(-20003,'Informe o período inicial e final.' );
    END IF;

    IF TRUNC(PARAM_P_DATAINI) >
       TRUNC(PARAM_P_DATAFIN) THEN

        RAISE_APPLICATION_ERROR(-20004,'A data inicial não pode ser maior que a final.');

    END IF;

    SAVEPOINT SP_GEROBRGDIFAL;


    /****************************************************
    ETAPA 1 - GERAÇÃO POR OPERAÇÃO
    TIPO = 1
    ****************************************************/

    FOR R IN C_OPERACAO LOOP

        /* DIFAL POR OPERAÇÃO */

        IF R.DIFAL > 0 THEN

            PRC_INSERIR(
                 R.CODEMP
                ,R.CODUF
                ,R.DTREF
                ,R.DTVCTO
                ,'D'
                ,90
                ,100102
                ,R.DIFAL
                ,R.NUNOTA
                ,R.TIPO
            );

        END IF;

        /* FCP POR OPERAÇÃO */

        IF R.FCP > 0 THEN

            PRC_INSERIR(
                 R.CODEMP
                ,R.CODUF
                ,R.DTREF
                ,R.DTVCTO
                ,'D'
                ,6
                ,100129
                ,R.FCP
                ,R.NUNOTA
                ,R.TIPO
            );

        END IF;

    END LOOP;


    /****************************************************
    ETAPA 2 - GERAÇÃO POR APURAÇÃO
    TIPO = 2
    ****************************************************/

    FOR R IN C_APURACAO LOOP

        /* DIFAL DEVIDO = VENDAS - DEVOLUÇÕES */

        IF R.DIFAL_DEVIDO > 0
			THEN

            PRC_INSERIR(
                 R.CODEMP
                ,R.CODUF
                ,R.DTREF
                ,R.DTVCTO
                ,'D'
                ,90
                ,100102
                ,R.DIFAL_DEVIDO
                ,NULL
                ,R.TIPO
            );

        END IF;

        /* FCP DEVIDO = VENDAS - DEVOLUÇÕES */

        IF R.FCP_DEVIDO > 0
			THEN

            PRC_INSERIR(
                 R.CODEMP
                ,R.CODUF
                ,R.DTREF
                ,R.DTVCTO
                ,'D'
                ,6
                ,100129
                ,R.FCP_DEVIDO
                ,NULL
                ,R.TIPO
            );

        END IF;

    END LOOP;


    /****************************************************
    MENSAGEM FINAL
    ****************************************************/

    P_MENSAGEM :=
        'Obrigações fiscais geradas com sucesso. ' ||
        'Por operação: ' || V_QTD_OPERACAO ||
        ' | Por apuração: ' || V_QTD_APURACAO ||
        ' | Total: ' ||
        (V_QTD_OPERACAO + V_QTD_APURACAO);


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK TO SP_GEROBRGDIFAL;
        RAISE;

END;
