/*==============================================================================
  Nome do Script : STP_AJUSTEC197DEV_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Automatizar o preenchimento do registro C197, pois hoje ta sendo feito manualmente, sendo assim o usuario vai utilizar o dashboard para analisar as notas e dentro do dashboard vai rodar o botão de ação para automatizar o passo de preenchimento.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 13/03/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_AJUSTEC197DEV_SPARK" (
    P_CODUSU    NUMBER,
    P_IDSESSAO  VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM  OUT VARCHAR2
) AS
    FIELD_NUNOTA NUMBER;
/******************************************************************
Autor: Lucas Gabriel 
Data: 13/03/2025
Objetivo: Automatizar o preenchimento do registro C197, pois hoje ta 
sendo feito manualmente, sendo assim o usuario vai utilizar o dashboard
para analisar as notas e dentro do dashboard vai rodar o botão de ação 
para automatizar o passo de preenchimento.

Editado por: Lucas Gabriel 
Data:02/06/2025
Objetivo: Incluir os case when para atender as devolução do simples nacional
******************************************************************/
BEGIN
    FOR I IN 1..P_QTDLINHAS 
    LOOP                  
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        BEGIN 
            FOR R_DADOS IN (
                SELECT 
                    TAB.NOTADEV,
                    TAB.SEQUENCIA,
                    TAB.NUNOTA,
                    ROUND(TAB.BASEATUAL * (TAB.PROPOR / 100), 2) AS BASENOVA,
                    ROUND((TAB.BASEATUAL * (TAB.PROPOR / 100)) * (TAB.ALIQICMS / 100), 2) AS ICMSNOVO,
                    TAB.ALIQICMS
                FROM (
                    SELECT 
                        CAB1.NUMNOTA AS NOTADEV,
                        CAB.NUNOTA,
                        LIV.SEQUENCIA,
                        CASE WHEN LIV.ALIQICMS = 0 THEN ITE.AD_ALIQICMSSP ELSE LIV.ALIQICMS END AS ALIQICMS,
                        CASE WHEN LIV.BASEICMS = 0 THEN ITE.AD_BASEICMSSP ELSE LIV.BASEICMS END  AS BASEATUAL,
                        CASE 
                            WHEN TRUNC(CAB1.DTENTSAI, 'MM') <> TRUNC(CAB.DTENTSAI, 'MM')
                            THEN (
                                SELECT MAX(I.ICMS) 
                                FROM AD_TGFPIM I 
                                WHERE I.ANO = EXTRACT(YEAR FROM CAB1.DTENTSAI) 
                                AND I.MES = EXTRACT(MONTH FROM CAB1.DTENTSAI)
                            )
                            ELSE 0 
                        END AS PROPOR
                    FROM TGFCAB CAB
                    INNER JOIN TGFITE ITE 
                        ON CAB.NUNOTA = ITE.NUNOTA
                    LEFT JOIN TGFVAR VAR 
                        ON VAR.NUNOTA = CAB.NUNOTA
                        AND VAR.SEQUENCIA = ITE.SEQUENCIA
                    INNER JOIN TGFPRO PRO 
                        ON ITE.CODPROD = PRO.CODPROD
                    INNER JOIN TGFLIV LIV 
                        ON LIV.NUNOTA = CAB.NUNOTA
                        AND LIV.SEQUENCIA = ITE.SEQUENCIA
                    RIGHT JOIN TGFCAB CAB1
                        ON CAB1.NUNOTA = VAR.NUNOTAORIG
                    WHERE CAB.CODTIPOPER = 305
                        AND CAB.NUNOTA = FIELD_NUNOTA
                        AND CAB.STATUSNOTA = 'L'
                        AND CAB.CODEMP = 1
                        AND TRUNC(CAB1.DTENTSAI, 'MM') <> TRUNC(CAB.DTENTSAI, 'MM')
                ) TAB
                ORDER BY TAB.NUNOTA, TAB.SEQUENCIA ASC
            ) 
            LOOP
                IF R_DADOS.ICMSNOVO > 0
					THEN 
                    MERGE INTO TGFAJD TGT
                    USING (SELECT 1 FROM DUAL) D
							ON (TGT.NUNOTA = R_DADOS.NUNOTA 
									AND TGT.SEQUENCIA = R_DADOS.SEQUENCIA 
										AND TGT.CODAJUSTE = '20000999')
                    WHEN MATCHED THEN
                        UPDATE SET 
                            BASEICMS  = R_DADOS.BASENOVA,
                            ALIQICMS  = R_DADOS.ALIQICMS,
                            VLRICMS   = R_DADOS.ICMSNOVO,
                            DHALTER   = SYSDATE
                    WHEN NOT MATCHED THEN
                        INSERT (
								NUNOTA
							  , ORIGEM
							  , SEQUENCIA
							  , CODEMP
							  , CODOBSPADRAO
							  , CODAJUSTE
							  , COMPOBSPADRAO
							  , COMPAJUSTE
							  , BASEICMS
							  , ALIQICMS
							  , VLRICMS
							  , VLROUTROS
							  , CODUSU
							  , DHALTER
							  , AGRUPAR
							  ) 
					VALUES (
                            R_DADOS.NUNOTA
						   , 'E'
						   , R_DADOS.SEQUENCIA
						   , 1
						   , 24
						   , '20000999'
						   , NULL
						   , 'ESTORNO DE DÉBITO REF. DEVOLUÇÃO DE COMPRA, CRÉDITO ESTORNADO NA ENTRADA DA NF ORIGEM ' || R_DADOS.NOTADEV
						   , R_DADOS.BASENOVA
						   , R_DADOS.ALIQICMS
						   , R_DADOS.ICMSNOVO
						   ,0
						   , P_CODUSU
						   , SYSDATE
						   , 'N'
                        );
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                P_MENSAGEM := 'Erro ao processar os ajustes: ' || SQLERRM;
                RETURN;
        END;
    END LOOP;
    P_MENSAGEM := 'Os ajustes foram inseridos ou atualizados com sucesso. Gere novamente a apuração de ICMS para verificação.';
END;
