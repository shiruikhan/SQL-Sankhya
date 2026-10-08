/*==============================================================================
  Nome do Script : STP_INCSUSPIPI_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Informar os produtos que contém suspensão do IPI na tabela de IPI de forma automática.
  Autor          : Lucas Gabriel - DM TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 10/12/2024, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_INCSUSPIPI_SPARK" (
    P_CODUSU NUMBER,
    P_IDSESSAO VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM OUT VARCHAR2
) AS
    FIELD_CODPARC NUMBER;
    PARAM_P_CODTIPOPER VARCHAR2(4000);
    V_CODENQENT INT;
    V_CODENQSAI INT;
    V_COUNT INT;
BEGIN
    /*************************************************************
    * Autor: Lucas Gabriel - DM TECH
    * Data: 10/12/2024
    * Objetivo: Informar os produtos que contém suspensão do IPI na tabela de IPI 
    * de forma automática.
    *************************************************************/

    PARAM_P_CODTIPOPER := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODTIPOPER');

    FOR I IN 1..P_QTDLINHAS LOOP
        FIELD_CODPARC := ACT_INT_FIELD(P_IDSESSAO, I, 'CODPARC');

        BEGIN
            SELECT PAR.CODENQIPIENT, PAR.CODENQIPISAI
            INTO V_CODENQENT, V_CODENQSAI
            FROM TGFPAR PAR
            WHERE PAR.CODPARC = FIELD_CODPARC;

            IF V_CODENQENT IS NULL THEN
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a inclusão!',
                        'O parceiro ' || FIELD_CODPARC ||
                        ' não consta cadastrado o Código Enq. Legal IPI Entrada.',
                        'Favor preencher o campo Código Enq. Legal IPI Entrada e tente novamente!'
                    ));
            END IF;

            IF V_CODENQSAI IS NULL THEN
                RAISE_APPLICATION_ERROR(-20101,
                    FC_FORMATAHTML(
                        'Não Foi Possível prosseguir com a inclusão!',
                        'O parceiro ' || FIELD_CODPARC ||
                        ' não consta cadastrado o Código Enq. Legal IPI Saída.',
                        'Favor preencher o campo Código Enq. Legal IPI Saída e tente novamente!'
                    ));
            END IF;
        END;

        FOR R_PRO IN (
            SELECT PRO.CODPROD, PRO.CODIPI
            FROM TGFPRO PRO
            WHERE PRO.USOPROD = 'V' AND PRO.TEMIPIVENDA = 'S'
        ) LOOP
            SELECT COUNT(0)
            INTO V_COUNT
            FROM TGFISU ISU
            WHERE ISU.CODPROD = R_PRO.CODPROD
              AND ISU.CODIPI = R_PRO.CODIPI
              AND ISU.CODPARC = FIELD_CODPARC
              AND ISU.CODTIPOPER = PARAM_P_CODTIPOPER;

            IF V_COUNT = 0 THEN
                INSERT INTO TGFISU (
									CODENQIPIENT
								  , CODENQIPISAI
								  , CODIPI
								  , CODPARC
								  , CODPROD
								  , CODTIPOPER
								  , DHTIPOPER
								   ) 
					      VALUES ( V_CODENQENT
								 , V_CODENQSAI
								 , R_PRO.CODIPI
								 , FIELD_CODPARC
								 , R_PRO.CODPROD
								 , PARAM_P_CODTIPOPER
								 ,(SELECT MAX(DHALTER) FROM TGFTOP T WHERE CODTIPOPER = PARAM_P_CODTIPOPER)
								 );
            END IF;
        END LOOP;
    END LOOP;

    P_MENSAGEM := 'A inclusão foi realizada com sucesso!';
END;
