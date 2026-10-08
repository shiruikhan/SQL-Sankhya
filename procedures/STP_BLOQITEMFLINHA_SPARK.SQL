/*==============================================================================
  Nome do Script : STP_BLOQITEMFLINHA_SPARK
  Tipo           : Stored Procedure
  Descrição      : Evitar erros do comercial quando recebe o pedido com código antigo e acaba digitando o pedido mesmo assim
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 02/06/2025, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_BLOQITEMFLINHA_SPARK" (
    P_NUNOTA     IN  NUMBER,
    P_SEQUENCIA  IN  NUMBER,
    P_SUCESSO    OUT VARCHAR2,
    P_MENSAGEM   OUT VARCHAR2,
    P_CODUSULIB  OUT NUMBER
)
AS
/*******************************************************************
Autor: Lucas Gabriel 
Data: 02/06/2025
Objetivo: Evitar erros do comercial quando recebe o pedido com código 
antigo e acaba digitando o pedido mesmo assim 
*******************************************************************/
    V_FORALINHA TGFPRO.AD_OBSOLETO%TYPE;
BEGIN
    P_SUCESSO   := 'S';
    P_MENSAGEM  := NULL;
    P_CODUSULIB := NULL;

    BEGIN
        SELECT NVL(PRO.AD_OBSOLETO,'N')
          INTO V_FORALINHA
          FROM TGFITE ITE
        INNER JOIN TGFPRO PRO
			ON ITE.CODPROD = PRO.CODPROD
         WHERE ITE.NUNOTA = P_NUNOTA
           AND ITE.SEQUENCIA = P_SEQUENCIA;

        IF V_FORALINHA = 'S' 
		THEN
            P_SUCESSO := 'N';
            P_MENSAGEM := 'O produto não pode ser vendido, pois está fora de linha. Desmarque a opção e tente novamente.';
        END IF;
    END;
END;
