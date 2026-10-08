/*==============================================================================
  Nome do Script : STP_BOLJUROSMULTA_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Desmembrar o valor do juros e multa no momento da baixa pois o banco Itaú envia tudo consolidado e o Sankhya ainda não tem preparo na API para essa tratativa.
  Autor          : Lucas Gabriel - ONTIME TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 07/07/2025, última alteração em 08/07/2025.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_BOLJUROSMULTA_SPARK" (
    P_TIPOEVENTO   INT,    
    P_IDSESSAO     VARCHAR2, 
    P_CODUSU       INT         
) AS
    BEFORE_INSERT   INT := 0;
    AFTER_INSERT    INT := 1;
    BEFORE_DELETE   INT := 2;
    AFTER_DELETE    INT := 3;
    BEFORE_UPDATE   INT := 4;
    AFTER_UPDATE    INT := 5;
    BEFORE_COMMIT   INT := 10;

    V_CODTIPOPERBAIXA TGFFIN.CODTIPOPERBAIXA%TYPE;
    V_RECDESP         TGFFIN.RECDESP%TYPE;
    V_VLRJURO         TGFFIN.VLRJURO%TYPE;
    V_VLRMULTA        TGFFIN.VLRMULTA%TYPE;
    V_DHBAIXA         TGFFIN.DHBAIXA%TYPE;
    V_PROVISAO        TGFFIN.PROVISAO%TYPE;
    V_VLRDESDOB       TGFFIN.VLRDESDOB%TYPE;
    V_CODUSUBAIXA     TGFFIN.CODUSUBAIXA%TYPE;
    V_API             TGFFIN.BAIXAAPI%TYPE;
    V_VALORMULTA      NUMBER;
BEGIN
    /*******************************************************************************
    Autor: Lucas Gabriel - ONTIME TECH 
    Data: 02/07/2025
    Objetivo: Desmembrar o valor do juros e multa no momento da baixa pois o banco 
              Itaú envia tudo consolidado e o Sankhya ainda não tem preparo na API 
              para essa tratativa.
    ********************************************************************************/

    IF P_TIPOEVENTO = AFTER_UPDATE THEN
        SELECT 
            FIN.CODTIPOPERBAIXA,
            FIN.RECDESP,
            FIN.VLRJURO,
            FIN.VLRMULTA,
            FIN.DHBAIXA,
            FIN.PROVISAO,
            FIN.VLRDESDOB,
            FIN.CODUSUBAIXA,
            FIN.BAIXAAPI
        INTO 
            V_CODTIPOPERBAIXA,
            V_RECDESP,
            V_VLRJURO,
            V_VLRMULTA,
            V_DHBAIXA,
            V_PROVISAO,
            V_VLRDESDOB,
            V_CODUSUBAIXA,
            V_API
        FROM TGFFIN FIN 
        WHERE FIN.NUFIN = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN');

        IF V_PROVISAO = 'N' 
            AND V_RECDESP = 1
            AND V_CODUSUBAIXA = 0
            AND V_CODTIPOPERBAIXA = 1400
            AND V_VLRJURO > 0
            AND V_API IS NOT NULL
        THEN

            V_VALORMULTA := ROUND(V_VLRDESDOB * 0.02, 2);

            IF V_VALORMULTA < V_VLRJURO 
				THEN
                UPDATE TGFFIN 
                SET VLRMULTA = V_VALORMULTA,
                    VLRJURO  = ROUND(V_VLRJURO - V_VALORMULTA, 2)
                WHERE NUFIN = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUFIN');

            END IF;
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS
		THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro na procedure STP_BOLJUROSMULTA_SPARK: ' || SQLERRM);
END;
