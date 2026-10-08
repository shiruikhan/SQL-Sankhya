/*==============================================================================
  Nome do Script : STP_BLOCOK200_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Corrigir a copia de estoque baseado na planilha externa apurada
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 14/01/2025, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_BLOCOK200_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
    FIELD_ID    NUMBER;
    V_CODPROD   AD_TGSEST.CODPROD%TYPE;
    V_DTCONTAGEM AD_TGSEST.DTCONTAGEM%TYPE;
    V_CODLOCAL  AD_TGSEST.CODLOCAL%TYPE;
    V_CODVOL    AD_TGSEST.CODVOL%TYPE;
    V_QTDEST    AD_TGSEST.QTDEST%TYPE;
/******************************************************************************
*Autor: Lucas Gabriel - DM TECH
*Data: 13/12/2024
*Objetivo: Corrigir a copia de estoque baseado na planilha externa apurada
******************************************************************************/
BEGIN
    FOR I IN 1..P_QTDLINHAS LOOP
        FIELD_ID := ACT_INT_FIELD(P_IDSESSAO, I, 'ID');

        SELECT
            CODPROD,
            DTCONTAGEM,
            CODLOCAL,
            CODVOL,
            QTDEST
        INTO
            V_CODPROD,
            V_DTCONTAGEM,
            V_CODLOCAL,
            V_CODVOL,
            V_QTDEST
        FROM AD_TGSEST
        WHERE ID = FIELD_ID;
		/*CORRIGO QUANTIDADE DE ESTOQUE CASO SEJA ALTERADA NA PLANILHA */
        FOR R_CTE IN (
            SELECT
                CTE.CODPROD,
                CTE.DTCONTAGEM,
                CTE.CODEMP,
                CTE.CODLOCAL,
                CTE.CONTROLE,
                CTE.CODVOL,
                CTE.CODPARC,
                CTE.TIPO,
                CTE.SEQUENCIA,
                EST.QTDEST AS EXTQTD,
                CTE.QTDEST AS INTQTD
            FROM AD_TGSEST EST
            INNER JOIN TGFCTE CTE
                ON CTE.CODPROD = EST.CODPROD
                AND CTE.CODLOCAL = EST.CODLOCAL
                AND CTE.CODVOL = EST.CODVOL
                AND CTE.DTCONTAGEM = EST.DTCONTAGEM
            WHERE
                EST.DTCONTAGEM = V_DTCONTAGEM AND
                EST.CODPROD = V_CODPROD AND
                EST.CODLOCAL = V_CODLOCAL AND
                EST.CODVOL = V_CODVOL AND
                CTE.CODEMP = 1 AND
                CTE.TIPO = 'P'
        ) LOOP
            IF R_CTE.EXTQTD <> R_CTE.INTQTD
				THEN
                UPDATE TGFCTE
                SET QTDEST = V_QTDEST,
                    QTDESTUNCAD = V_QTDEST
                WHERE
                    DTCONTAGEM = R_CTE.DTCONTAGEM AND
                    CODEMP = 1 AND
                    CODLOCAL = R_CTE.CODLOCAL AND
                    CODPROD = R_CTE.CODPROD AND
                    CODVOL = R_CTE.CODVOL AND
                    TIPO = 'P';
            END IF;
        END LOOP;
    END LOOP;
	/*EXCLUI CORRIGINDO OS PRODUTOS QUE FORAM DELETADOS MANUALMENTE*/
    FOR R_EXC IN (
        SELECT
             CTE.CODPROD
			,CTE.CODLOCAL
			,CTE.DTCONTAGEM
        FROM TGFCTE CTE
        WHERE  CTE.TIPO = 'P' 
			AND CTE.DTCONTAGEM = V_DTCONTAGEM 
			AND 
            NOT EXISTS (
                SELECT 1
                FROM AD_TGSEST EST
                WHERE
                    EST.CODPROD = CTE.CODPROD AND
                    EST.DTCONTAGEM = CTE.DTCONTAGEM AND
                    EST.CODLOCAL = CTE.CODLOCAL AND
                    EST.CODVOL = CTE.CODVOL
            )
    ) LOOP
        DELETE FROM TGFCTE
        WHERE CODPROD = R_EXC.CODPROD 
			AND DTCONTAGEM = V_DTCONTAGEM
			AND CODLOCAL = R_EXC.CODLOCAL
			AND TIPO = 'P' ;
    END LOOP;
	/* ACRESCENTADO A PARTE DO ESTOQUE DE TERCEIROS PARTE 1, AQUI EU DELETO O MIMO*/
	FOR R_ESTTER
		IN (SELECT 
				 DTCONTAGEM
				,CODEMP
				,CODLOCAL
				,CODPROD
				,CONTROLE
				,CODVOL
				,CODPARC
				,TIPO
				,SEQUENCIA
			 FROM TGFCTE  
			 WHERE DTCONTAGEM = V_DTCONTAGEM
			   AND CODEMP = 1
			   AND NVL(CODPARC,0) <> 0
			)   
		LOOP
			DELETE FROM TGFCTE 
			WHERE DTCONTAGEM = R_ESTTER.DTCONTAGEM
			  AND CODEMP     = R_ESTTER.CODEMP
			  AND CODLOCAL   = R_ESTTER.CODLOCAL
			  AND CODPROD    = R_ESTTER.CODPROD
			  AND CONTROLE   = R_ESTTER.CONTROLE
			  AND CODVOL     = R_ESTTER.CODVOL
			  AND CODPARC    = R_ESTTER.CODPARC
			  AND TIPO       = R_ESTTER.TIPO
			  AND SEQUENCIA  = R_ESTTER.SEQUENCIA;
		END LOOP;
	/*EU VOLTO AGORA O ESTOQUE DE TERCEIRO BASEADO NO RELATORIO DE CONFERENCIA, ONDE O MESMO JA ESTA VALIDADO SUA CONSULTA*/
	FOR R_TERCINC IN (
						SELECT DISTINCT 
							CAB.CODPARC,
							PAR.NOMEPARC,
							ITE.CODPROD,
							PRO.DESCRPROD,
							PRO.CODVOL,
							TO_NUMBER(SUBSTR(ITE.CODPROD, 1, 1)) AS TIPO,
							ROUND(SUM(CASE WHEN ITE.ATUALESTTERC IN ('P', 'T') AND CAB.NUNOTA = ITE.NUNOTA THEN ITE.QTDNEG ELSE 0 END) 
							- SUM(CASE WHEN ITE.ATUALESTTERC IN ('R', 'D') AND CAB.NUNOTA = ITE.NUNOTA THEN ITE.QTDNEG ELSE 0 END), 2) AS MOVTERC
						FROM TGFITE ITE
						INNER JOIN TGFCAB CAB ON ITE.NUNOTA = CAB.NUNOTA
						INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
						INNER JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD
						WHERE ITE.ATUALESTTERC IN ('P', 'T', 'R', 'D')
							AND CAB.DTENTSAI >= '01/01/2022'
							AND CAB.DTENTSAI <= V_DTCONTAGEM
						GROUP BY
							CAB.CODPARC,
							PAR.NOMEPARC,
							ITE.CODPROD,
							PRO.DESCRPROD,
							PRO.CODVOL
						HAVING ROUND(SUM(CASE WHEN ITE.ATUALESTTERC IN ('P', 'T') THEN ITE.QTDNEG ELSE 0 END) 
							- SUM(CASE WHEN ITE.ATUALESTTERC IN ('R', 'D') THEN ITE.QTDNEG ELSE 0 END), 2) > 0
						ORDER BY CAB.CODPARC, ITE.CODPROD
) LOOP
    INSERT INTO TGFCTE (
						DTCONTAGEM,
						CODEMP,
						CODLOCAL,
						CODPROD,
						QTDEST,
						CODVOL,
						CODPARC,
						TIPO,
						SEQUENCIA,
						QTDESTUNCAD
    )
				VALUES (
						V_DTCONTAGEM,
						1,
						113,
						R_TERCINC.CODPROD,
						R_TERCINC.MOVTERC,
						R_TERCINC.CODVOL,
						R_TERCINC.CODPARC,
						DECODE(R_TERCINC.TIPO, 1, 'P', 'T'),
						1,
						R_TERCINC.MOVTERC
						);
END LOOP;

    P_MENSAGEM := 'A correção da Cópia de Estoque foi realizada com sucesso!';
EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Ocorreu um erro: ' || SQLERRM;
END;
