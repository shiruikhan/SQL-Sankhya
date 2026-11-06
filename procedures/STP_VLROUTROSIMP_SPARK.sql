

CREATE OR REPLACE PROCEDURE STP_VLROUTROSIMP_SPARK (

    P_CODUSU    NUMBER,

    P_IDSESSAO  VARCHAR2,

    P_QTDLINHAS NUMBER,

    P_MENSAGEM  OUT VARCHAR2

) AS
 
    /*************************************************************************

    Autor: Lucas Gabel

    Data: 06/11/2026
 
    Objetivo:

        Preencher o campo VLROUTROS da TGFCAB com os gastos

        extras referentes a exportacao.
 
    Regras:

        1. Receber o parametro P_VLROUTOS da acao Sankhya.

        2. Validar o valor informado.

        3. Atualizar somente as notas selecionadas.

        4. Retornar a quantidade de registros atualizados.

    *************************************************************************/
 
    PARAM_P_VLROUTOS   TGFCAB.VLROUTROS%TYPE;

    FIELD_NUNOTA       TGFCAB.NUNOTA%TYPE;

    V_QTDATUALIZADAS   NUMBER := 0;
 
BEGIN
 
    /*---------------------------------------------------------

      1. Recuperar parametro informado na acao

    ---------------------------------------------------------*/

    PARAM_P_VLROUTOS := ACT_DEC_PARAM( P_IDSESSAO,'P_VLROUTOS');
 
    /*---------------------------------------------------------

      2. Validar parametro informado

    ---------------------------------------------------------*/

    IF PARAM_P_VLROUTOS IS NULL 

		THEN

        RAISE_APPLICATION_ERROR( -20001,'Informe o valor dos gastos extras de exportacao.' );

    END IF;
 
    IF PARAM_P_VLROUTOS < 0 

	THEN

        RAISE_APPLICATION_ERROR( -20002,'O valor dos gastos extras nao pode ser negativo.');

    END IF;
 
    /*---------------------------------------------------------

      3. Validar quantidade de linhas selecionadas

    ---------------------------------------------------------*/

    IF P_QTDLINHAS IS NULL OR P_QTDLINHAS <= 0

		THEN

        RAISE_APPLICATION_ERROR(-20003,'Nenhuma nota foi selecionada para atualizacao.');

    END IF;
 
    /*---------------------------------------------------------

      4. Percorrer notas selecionadas

    ---------------------------------------------------------*/

    FOR I IN 1 .. P_QTDLINHAS LOOP
 
        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO,I,'NUNOTA');
 
        /*-----------------------------------------------------

          5. Atualizar valor de gastos extras

        -----------------------------------------------------*/

        UPDATE TGFCAB

           SET VLROUTROS = PARAM_P_VLROUTOS

         WHERE NUNOTA = FIELD_NUNOTA;
 
        V_QTDATUALIZADAS :=V_QTDATUALIZADAS + SQL%ROWCOUNT;
 
    END LOOP;
 
    /*---------------------------------------------------------

      6. Mensagem de retorno

    ---------------------------------------------------------*/

    P_MENSAGEM :='Gastos extras de exportacao gravados com sucesso. ' ||'Quantidade de notas atualizadas: ' ||V_QTDATUALIZADAS ||'. Valor informado: R$ ' ||

        TO_CHAR(

            PARAM_P_VLROUTOS,

            'FM999G999G999G990D00',

            'NLS_NUMERIC_CHARACTERS='',.'''

        );
 
EXCEPTION
 
    WHEN OTHERS THEN

        RAISE_APPLICATION_ERROR(-20004, 'Erro ao atualizar os gastos extras de exportacao: ' ||SQLERRM);
 
END;

 