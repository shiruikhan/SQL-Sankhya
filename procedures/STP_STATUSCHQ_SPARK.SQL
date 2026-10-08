/*==============================================================================
  Nome do Script : STP_STATUSCHQ_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 24/02/2026, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_STATUSCHQ_SPARK" (
    P_CODUSU     NUMBER,
    P_IDSESSAO   VARCHAR2,
    P_QTDLINHAS  NUMBER,
    P_MENSAGEM   OUT VARCHAR2
) AS
    PARAM_P_STATUS VARCHAR2(10);
	PARAM_P_HISTORICO VARCHAR2(255);
    FIELD_NUFIN    NUMBER;

BEGIN


    PARAM_P_STATUS := ACT_TXT_PARAM(P_IDSESSAO, 'P_STATUS');
    PARAM_P_HISTORICO := ACT_TXT_PARAM(P_IDSESSAO, 'P_HISTORICO');
    FOR I IN 1 .. P_QTDLINHAS
    LOOP

        FIELD_NUFIN := ACT_INT_FIELD(P_IDSESSAO, I, 'NUFIN');

        IF PARAM_P_STATUS = '1' THEN

            UPDATE TGFFIN
               SET AD_CHEQUECOM = 'S'
             WHERE NUFIN = FIELD_NUFIN;

        ELSIF PARAM_P_STATUS = '2' THEN

            UPDATE TGFFIN
               SET AD_CHEQUECLI = 'S'
             WHERE NUFIN = FIELD_NUFIN;

        ELSIF PARAM_P_STATUS = '3' THEN

            UPDATE TGFFIN
               SET AD_CHEQUEFIN = 'S'
             WHERE NUFIN = FIELD_NUFIN;

        ELSIF PARAM_P_STATUS = '4' THEN

            UPDATE TGFFIN
               SET AD_CHEQUECOM = 'N'
             WHERE NUFIN = FIELD_NUFIN;

        ELSIF PARAM_P_STATUS = '5' THEN

            UPDATE TGFFIN
               SET AD_CHEQUECLI = 'N'
             WHERE NUFIN = FIELD_NUFIN;

        ELSIF PARAM_P_STATUS = '6' THEN

            UPDATE TGFFIN
               SET AD_CHEQUEFIN = 'N'
             WHERE NUFIN = FIELD_NUFIN;			

        END IF;
		IF PARAM_P_HISTORICO IS NOT NULL 
		THEN 
            UPDATE TGFFIN
               SET HISTORICO = PARAM_P_HISTORICO
             WHERE NUFIN = FIELD_NUFIN;		
		END IF;

    END LOOP;

    P_MENSAGEM := 'A gestão do Cheque foi realizada com sucesso!';

END;
