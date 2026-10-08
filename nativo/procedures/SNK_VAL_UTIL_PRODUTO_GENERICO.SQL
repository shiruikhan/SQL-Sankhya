/*==============================================================================
  Nome do Script : SNK_VAL_UTIL_PRODUTO_GENERICO
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Bloqueia (ORA-20101) a movimentação de produto genérico (TGFGXE) em TOP que atualiza livros fiscais; chamada por TRG_INC_UPD_TGFITE_TGFGXE e TRG_INC_UPD_TGFCAB_TGFGXE. Usa PRAGMA AUTONOMOUS_TRANSACTION.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'SNK_VAL_UTIL_PRODUTO_GENERICO', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."SNK_VAL_UTIL_PRODUTO_GENERICO" (P_NUNOTA      NUMBER,  
                                                          P_CODPROD     NUMBER  := NULL)
AS
 P_CODTIPOPER    NUMBER(5);
 P_COUNT         NUMBER(10);
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF P_CODPROD IS NOT NULL THEN --VINDO DA TRG_INC_UPD_TGFITE_TGFGXE
        SELECT COUNT(1), MAX(C.CODTIPOPER)
        INTO P_COUNT, P_CODTIPOPER
        FROM TGFCAB C 
         INNER JOIN TGFTOP T ON(T.CODTIPOPER = C.CODTIPOPER AND T.DHALTER = C.DHTIPOPER)
        WHERE C.NUNOTA = P_NUNOTA
          AND T.ATUALLIVFIS <> 'N'
          AND EXISTS (SELECT 1 FROM TGFGXE E WHERE E.CODPROD = P_CODPROD);
     
        IF (P_COUNT > 0) THEN       
            RAISE_APPLICATION_ERROR(-20101, 'Não é permitido movimentação de produto genérico com TOP que atualiza Livros Fiscais. Produto: ' || TO_CHAR(P_CODPROD) || ', TOP: ' || P_CODTIPOPER || '.');
        END IF;
    ELSE --VINDO DA TRG_INC_UPD_TGFCAB_TGFGXE
        SELECT COUNT(1) INTO P_COUNT
        FROM TGFITE I 
        WHERE I.NUNOTA = P_NUNOTA
         AND EXISTS(SELECT 1 FROM TGFGXE E WHERE E.CODPROD = I.CODPROD);
                 
        IF (P_COUNT > 0) THEN
           RAISE_APPLICATION_ERROR(-20101, 'Não é permitido movimentação de produto genérico com TOP que atualiza Livros Fiscais. Nro. único: ' || P_NUNOTA || '.');
        END IF;        
    END IF;
    COMMIT;
END;
