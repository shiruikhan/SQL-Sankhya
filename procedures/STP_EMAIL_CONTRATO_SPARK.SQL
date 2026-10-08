/*==============================================================================
  Nome do Script : STP_EMAIL_CONTRATO_SPARK
  Tipo           : Stored Procedure
  Descrição      : Envio de E-mail avisando da proximidade do termino do contrato para o gestor do contrato, para que faça a gestão do contrato.
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 31/07/2025, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_EMAIL_CONTRATO_SPARK" 
AS 
    V_MENSAGEM VARCHAR2(4000);
    V_ASSUNTO  VARCHAR2(4000);
    V_MAXFILA  INT;

    /*******************************************************************************************************
     AUTOR: Lucas Gabriel - DM TECH 
     DATA: 31/07/2025	
     OBJETIVO: Envio de E-mail avisando da proximidade do termino do contrato para o gestor do contrato,
     para que faça a gestão do contrato.
    *******************************************************************************************************/
BEGIN 
    FOR R_CONTRATO IN (
        SELECT 
             CON.NUMCONTRATO
            ,CON.DTCONTRATO
            ,CON.DTTERMINO
            ,CON.CODEMP
            ,CON.CODPARC 
            ,PAR.NOMEPARC
            ,USU.EMAIL
            ,CON.CODMONSANKHYA
            ,USU.NOMEUSU
            ,CON.CLAUSCONTRATO
        FROM TCSCON CON 
        INNER JOIN TSIUSU USU 
			ON USU.CODUSU = CON.CODMONSANKHYA
        INNER JOIN TGFPAR PAR 
			ON PAR.CODPARC = CON.CODPARC 
        WHERE CON.NUMCONTRATO <> 0
         AND  NVL(CON.AD_NOTEMAIL,'N') = 'S'
		 AND (CON.DTTERMINO - TRUNC(SYSDATE)) <=30
    )
    LOOP
        IF (R_CONTRATO.DTTERMINO - TRUNC(SYSDATE)) <= 30
		  AND (R_CONTRATO.DTTERMINO - TRUNC(SYSDATE)) >0
   		THEN



            V_ASSUNTO := 'O contrato nº ' || R_CONTRATO.NUMCONTRATO || ' está próximo ao término';

            V_MENSAGEM := 
                '<div>Prezado ' || R_CONTRATO.NOMEUSU || ',</div>' ||
                '<div>Venho informar que o contrato de nº <b>' || R_CONTRATO.NUMCONTRATO || '</b> está prestes a chegar ao fim.</div>' ||
                '<div>Data de término: <b>' || TO_CHAR(R_CONTRATO.DTTERMINO, 'DD/MM/YYYY') || '</b></div>' ||
                '<div>Solicitamos que prossiga com a análise do contrato e verifique se haverá renovação com o parceiro <b>' || R_CONTRATO.NOMEPARC || '</b>.</div>' ||
                '<div>Cláusulas de cancelamento atuais:</div>' ||
                '<div><i>' || R_CONTRATO.CLAUSCONTRATO || '</i></div><br>' ||
                '<div>Atenciosamente,<br>Equipe de Controladoria</div>';

			SELECT NVL(MAX(CODFILA), 0) + 1
              INTO V_MAXFILA
              FROM TMDFMG;
			  
            STP_GRAVA_FILA_BI2(V_MAXFILA
							 , V_ASSUNTO
							 , V_MENSAGEM
							 , 'administrativo@spark.ind.br'
							 , NULL);
							 
			SELECT NVL(MAX(CODFILA), 0) + 1
              INTO V_MAXFILA
              FROM TMDFMG;		
			  
            STP_GRAVA_FILA_BI2(V_MAXFILA
							 , V_ASSUNTO
							 , V_MENSAGEM
							 , 'financeiro@spark.ind.br'
							 , NULL);


			SELECT NVL(MAX(CODFILA), 0) + 1
              INTO V_MAXFILA
              FROM TMDFMG;
			  
            STP_GRAVA_FILA_BI2(V_MAXFILA
							 , V_ASSUNTO
							 , V_MENSAGEM
							 , R_CONTRATO.EMAIL
							 , NULL);

        END IF;
    END LOOP;
END;
