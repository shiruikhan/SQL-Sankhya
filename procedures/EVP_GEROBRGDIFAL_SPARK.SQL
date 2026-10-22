CREATE OR REPLACE PROCEDURE EVP_GEROBRGDIFAL_SPARK (
    P_CODUSU    NUMBER,
    P_IDSESSAO  VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM  OUT VARCHAR2
) AS

    FIELD_NUNOTA NUMBER;

    V_DIFALDEST  TGFCAB.VLRICMSDIFALDEST%TYPE;
    V_VLRFCP     TGFCAB.VLRICMSFCP%TYPE;
    V_UFS        TSIUFS.CODUF%TYPE;
    V_CODEMP     TGFCAB.CODEMP%TYPE;
    V_DTREF      TGFCAB.DTNEG%TYPE;
    V_DTVENC     TGFCAB.DTNEG%TYPE;

    V_SEQUENCIA  TGFOIR.SEQUENCIA%TYPE;
    V_EXISTE     NUMBER;
    V_QTDGERADOS NUMBER := 0;

    /****************************************************
    AUTOR: Lucas Gabriel
    DATA: 22/10/2026

    OBJETIVO:
    Gerar obrigações fiscais de DIFAL e FCP na TGFOIR.

    REGRAS:
    - DIFAL: CODOBR = 90 / CODREC = 100102
    - FCP:   CODOBR = 6  / CODREC = 100129
    - Referência: primeiro dia do mês da negociação.
    - Vencimento: data da negociação.
    - Sequência por CODEMP, DTREF e TIPAPURACAO.
    - Impedir duplicidade por nota e obrigação.
    - Interromper processamento em caso de erro.
    ****************************************************/

    PROCEDURE PRC_INSERIR_OBRIGACAO (
        P_CODOBR NUMBER,
        P_CODREC NUMBER,
        P_VALOR  NUMBER,
        P_DTVENC DATE
    ) AS

    BEGIN

        /* VERIFICA SE A OBRIGAÇÃO JÁ EXISTE */

        SELECT COUNT(1)
          INTO V_EXISTE
          FROM TGFOIR OIR
         WHERE OIR.CODEMP      = V_CODEMP
           AND OIR.DTREF       = V_DTREF
           AND OIR.TIPAPURACAO = 'D'
           AND OIR.CODOBR      = P_CODOBR
           AND OIR.AD_NUNOTA   = FIELD_NUNOTA;

        IF V_EXISTE > 0 THEN

            RAISE_APPLICATION_ERROR(
                -20001,
                'Não é possível gerar a obrigação fiscal. ' ||
                'A nota de número único ' ||
                FIELD_NUNOTA ||
                ' já possui lançamento para a obrigação ' ||
                P_CODOBR ||
                ' na referência ' ||
                TO_CHAR(V_DTREF, 'MM/YYYY') || '.'
            );

        END IF;

        /* LOCALIZA A PRÓXIMA SEQUÊNCIA */

        SELECT NVL(MAX(OIR.SEQUENCIA), 0) + 1
          INTO V_SEQUENCIA
          FROM TGFOIR OIR
         WHERE OIR.CODEMP      = V_CODEMP
           AND OIR.DTREF       = V_DTREF
           AND OIR.TIPAPURACAO = 'D';

        /* INSERE A OBRIGAÇÃO FISCAL */

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
             V_CODEMP
            ,V_DTREF
            ,'D'
            ,V_UFS
            ,P_CODOBR
            ,P_VALOR
            ,P_DTVENC
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
            ,FIELD_NUNOTA
        );

        V_QTDGERADOS := V_QTDGERADOS + 1;

    END PRC_INSERIR_OBRIGACAO;

BEGIN

    SAVEPOINT SP_GEROBRGDIFAL;

    FOR I IN 1..P_QTDLINHAS LOOP

        FIELD_NUNOTA := ACT_INT_FIELD(
            P_IDSESSAO,
            I,
            'NUNOTA'
        );

        /* CONSULTA OS VALORES DA NOTA */

        SELECT
             NVL(CAB.VLRICMSDIFALDEST, 0)
            ,NVL(CAB.VLRICMSFCP, 0)
            ,CAB.CODEMP
            ,TRUNC(CAB.DTNEG)
            ,TRUNC(CAB.DTNEG, 'MM')
            ,UFS.CODUF
        INTO
             V_DIFALDEST
            ,V_VLRFCP
            ,V_CODEMP
            ,V_DTVENC
            ,V_DTREF
            ,V_UFS
        FROM TGFCAB CAB

        INNER JOIN TGFPAR PAR
            ON PAR.CODPARC = CAB.CODPARC

        INNER JOIN TSICID CID
            ON CID.CODCID = PAR.CODCID

        INNER JOIN TSIUFS UFS
            ON UFS.CODUF = CID.UF

        WHERE CAB.NUNOTA = FIELD_NUNOTA;

        /* GERA A OBRIGAÇÃO DO DIFAL */

        IF V_DIFALDEST > 0 THEN
            PRC_INSERIR_OBRIGACAO(
                                   90
                                  ,100102
                                  ,V_DIFALDEST
                                  ,V_DTVENC
                                  );

        END IF;

        /* GERA A OBRIGAÇÃO DO FCP */
        IF V_VLRFCP > 0
			THEN

            PRC_INSERIR_OBRIGACAO(
                                   6
                                  ,100129
                                  ,V_VLRFCP
                                  ,V_DTVENC
                                   );

        END IF;

    END LOOP;

    P_MENSAGEM :='Processamento concluído com sucesso. ' ||'Total de obrigações fiscais geradas: ' || V_QTDGERADOS;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO SP_GEROBRGDIFAL;
        RAISE;

END;
