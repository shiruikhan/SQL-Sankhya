/*==============================================================================
  Nome do Script : STP_VALIDA_VEICULO
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Valida que o veículo (TGFVEI) existe e está ativo; senão levanta ORA-20101 com ERROS_PKG.ERRO_VEICULO_NAOATIVO.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 03/07/2024.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'STP_VALIDA_VEICULO', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_VALIDA_VEICULO" ( P_VEICULO INT )
AS
BEGIN
  DECLARE
     P_COUNT                    INT := 0;
  BEGIN
    SELECT COUNT(1) INTO P_COUNT
    FROM TGFVEI V
    WHERE V.CODVEICULO = P_VEICULO 
	  AND V.ATIVO = 'S';
    IF P_COUNT = 0 THEN
       RAISE_APPLICATION_ERROR(-20101,ERROS_PKG.ERRO_VEICULO_NAOATIVO);
    END IF;
  END;
END;
