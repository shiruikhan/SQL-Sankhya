create or replace PROCEDURE STP_VERCORCUSTO_SPARK (
    P_CODUSU NUMBER,
    P_IDSESSAO VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_VERCORCUSTO_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Verifica e corrige custos de produtos comparando custo
                   bloqueado com custo calculado pela função OBTEMCUSTO,
                   atualizando ou inserindo registros na tabela TGFCUS.

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
    FIELD_ID NUMBER;
    V_CODPROD NUMBER;
    V_CUSTO AD_TGSCUSBLOCOH.VLRCUS%TYPE;
    V_VLRCUSTO NUMBER;
    V_EXISTE NUMBER;
    V_DTREF AD_TGSCUSBLOCOH.DTREF%TYPE;
BEGIN
    FOR I IN 1..P_QTDLINHAS LOOP

        FIELD_ID := ACT_INT_FIELD(P_IDSESSAO, I, 'ID');

        BEGIN
            SELECT CODPROD
				 , VLRCUS
				 , DTREF 
            INTO V_CODPROD
			   , V_CUSTO
			   , V_DTREF 
            FROM AD_TGSCUSBLOCOH 
            WHERE ID = FIELD_ID;


            BEGIN
                SELECT OBTEMCUSTO_SPARK(V_CODPROD, 'S', 1, 'N', NULL, 'N', NULL, V_DTREF, 3)
                INTO V_VLRCUSTO 
                FROM DUAL;
            EXCEPTION 
                WHEN NO_DATA_FOUND 
					THEN 
                    V_VLRCUSTO := 0;
            END;


            IF V_VLRCUSTO <> V_CUSTO 
				THEN
                SELECT COUNT(0) 
                INTO V_EXISTE 
                FROM TGFCUS 
                WHERE CODPROD = V_CODPROD 
                  AND DTATUAL = V_DTREF 
                  AND AD_MANUAL = 'S';

                IF V_EXISTE > 0 THEN
                    UPDATE TGFCUS 
                    SET CUSMEDICM = V_CUSTO,
                        CUSSEMICM = V_CUSTO,
                        CUSMED = V_CUSTO,
                        AD_MANUAL = 'S'
                    WHERE CODPROD = V_CODPROD 
                      AND DTATUAL = V_DTREF 
                      AND AD_MANUAL = 'S';
                ELSE
                    INSERT INTO TGFCUS (
										CODPROD
									  , CODEMP
									  , DTATUAL
									  , CODLOCAL
									  , CONTROLE
									  , CUSMEDICM
									  , CUSSEMICM
									  , CUSREP
									  , CUSVARIAVEL
									  , CUSGER
									  , CUSMED
									  , VLRVENDAFIXO
									  , ENTRADACOMICMS
									  , ENTRADASEMICMS
									  , QTDNEG
									  , AUTOMATICO
									  , ALTPRECO
									  , NUNOTA
									  , SEQUENCIA
									  , TOTALCOMICMS
									  , TOTALSEMICMS
									  , TOTALCOMICMSANT
									  , TOTALSEMICMSANT
									  , CUSMEDCALC
									  , RECARGA
									  , QTDNEGGER
									  , TIPO
									  , AD_MANUAL
                    ) VALUES (
								V_CODPROD
								, '1'
								, V_DTREF
								, '0'
								, '0'
								, V_CUSTO
								, V_CUSTO
								, '0'
								, '0'
								, '0'
								, V_CUSTO
								, '0'
								, '0'
								, '0'
								, '0'
								, 'S'
								, ''
								,  '0'
								, '0'
								, '0'
								, '0'
								, ''
								,  ''
								, 'S'
								, 'N'
								, '0'
								, ''
								, 'S'
                    );
                END IF;
            END IF;
        END;
    END LOOP;
    P_MENSAGEM := 'Processo de custos concluído com sucesso!';
EXCEPTION
    WHEN OTHERS THEN
        P_MENSAGEM := 'Erro ao processar os custos: ' || SQLERRM;
END;