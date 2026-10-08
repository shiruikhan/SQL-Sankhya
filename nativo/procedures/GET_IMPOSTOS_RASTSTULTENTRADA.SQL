/*==============================================================================
  Nome do Script : GET_IMPOSTOS_RASTSTULTENTRADA
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Apura os impostos consumidos (ICMS, base e valor de ST, base/valor/percentual de FCP-ST de entrada anterior) proporcionalmente à quantidade de saída, para o rastreamento de estoque de um item de nota; usa TGFITE/TGFVAR/TGFDIN e o parâmetro UTILBASEREDRAST.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 07/12/2021, última alteração em 29/05/2026.
                   - Capturado do banco em 08/10/2026 (em pedaços — DDL completo, conferido pelo tamanho), via GET_DDL('PROCEDURE', 'GET_IMPOSTOS_RASTSTULTENTRADA', 'SPARKPRD').
                   - Descrição resumida a partir da leitura do código.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."GET_IMPOSTOS_RASTSTULTENTRADA" (P_NUNOTA           INT
                                                        , P_SEQUENCIA        INT
                                                        , P_QTDSAI           FLOAT
                                                        , P_VLRICMS          OUT FLOAT
                                                        , P_BASESUBST        OUT FLOAT
                                                        , P_VLRSUBST         OUT FLOAT 
                                                        , P_BASESTFCPINTANT  OUT FLOAT
                                                        , P_VLRSTFCPINTANT   OUT FLOAT
                                                        , P_PERCSTFCPINTANT  OUT FLOAT
                                                        , P_PERCSUBST         OUT FLOAT)
AS
    PRAGMA AUTONOMOUS_TRANSACTION;
    P_UTILBASEREDRAST       CHAR(1);
BEGIN
    P_UTILBASEREDRAST := GET_TSIPAR_LOGICO('UTILBASEREDRAST');

    --APURANDO IMPOSTOS CONSUMIDOS
    SELECT SUM(NVL(IMP.VLRICMS, 0) / ITE.QTDNEG * P_QTDSAI)
         , SUM(NVL(IMP.BASESUBST, 0) / ITE.QTDNEG * P_QTDSAI)
         , SUM(NVL(IMP.VLRSUBST, 0) / ITE.QTDNEG * P_QTDSAI)
         , SUM(NVL(IMP.BASESTFCPINTANT, 0) / ITE.QTDNEG * P_QTDSAI)
         , SUM(NVL(IMP.VLRSTFCPINTANT, 0) / ITE.QTDNEG * P_QTDSAI)
         , MAX(IMP.PERCSTFCPINTANT)
         , MAX(IMP.PERCSUBST)
         INTO P_VLRICMS, P_BASESUBST, P_VLRSUBST, P_BASESTFCPINTANT, P_VLRSTFCPINTANT, P_PERCSTFCPINTANT, P_PERCSUBST
    FROM  ( SELECT SUM(CASE WHEN DIN.CODIMP = 1 THEN DIN.VALOR ELSE 0 END) AS VLRICMS
                 , SUM(CASE WHEN DIN.CODIMP = 2 THEN CASE WHEN P_UTILBASEREDRAST = 'S' THEN DIN.BASERED ELSE DIN.BASE END ELSE 0 END) AS BASESUBST
                 , SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.VALOR ELSE 0 END) AS VLRSUBST
                 , SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.BASEFCPINT ELSE 0 END) AS BASESTFCPINTANT
                 , SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.VLRFCPINT ELSE 0 END) AS VLRSTFCPINTANT
                 , MAX(CASE WHEN DIN.CODIMP = 2 THEN DIN.PERCFCPINT ELSE 0 END) AS PERCSTFCPINTANT
                 , MAX(CASE WHEN DIN.CODIMP = 2 THEN DIN.ALIQUOTA ELSE 0 END)  AS PERCSUBST
                 , P_NUNOTA AS NUNOTA
                 , P_SEQUENCIA AS SEQUENCIA
            FROM TGFDIN DIN       
            WHERE DIN.NUNOTA = P_NUNOTA
                AND DIN.SEQUENCIA = P_SEQUENCIA
            UNION ALL --VALORES ANTERIORES DIGITADOS NO ITEM
            SELECT NVL(VLRICMSANT, 0) AS VLRICMS
                 , NVL(BASESUBSTITANT, 0) AS BASESUBST
                 , NVL(VLRSUBSTANT, 0) AS VLRSUBST
                 , NVL(BASESTFCPINTANT, 0) AS BASESTFCPINTANT
                 , NVL(VLRSTFCPINTANT, 0) AS VLRSTFCPINTANT
                 , NVL(PERCSTFCPINTANT, 0) AS PERCSTFCPINTANT
                 , NVL(ALIQSTFCPSTANT, 0) AS PERCSUBST
                 , P_NUNOTA AS NUNOTA
                 , P_SEQUENCIA AS SEQUENCIA      
            FROM TGFITE ITE
            WHERE ITE.NUNOTA = P_NUNOTA
                AND ITE.SEQUENCIA = P_SEQUENCIA   
            UNION ALL --NOTAS DE COMPLEMENTO
            SELECT NVL(SUM(CASE WHEN DIN.CODIMP = 1 THEN DIN.VALOR ELSE 0 END), 0) + NVL(ITE.VLRICMSANT, 0) AS VLRICMS
                 , NVL(SUM(CASE WHEN DIN.CODIMP = 2 THEN CASE WHEN P_UTILBASEREDRAST = 'S' THEN DIN.BASERED ELSE DIN.BASE END ELSE 0 END), 0) + NVL(ITE.BASESUBSTITANT, 0) AS BASESUBST
                 , NVL(SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.VALOR ELSE 0 END), 0) + NVL(ITE.VLRSUBSTANT, 0) AS VLRSUBST
                 , NVL(SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.BASEFCPINT ELSE 0 END), 0) + NVL(ITE.BASESTFCPINTANT, 0) AS BASESTFCPINTANT
                 , NVL(SUM(CASE WHEN DIN.CODIMP = 2 THEN DIN.VLRFCPINT ELSE 0 END), 0)  + NVL(ITE.VLRSTFCPINTANT, 0) AS VLRSTFCPINTANT
                 , NVL(MAX(CASE WHEN DIN.CODIMP = 2 THEN DIN.PERCFCPINT ELSE 0 END), 0) AS PERCSTFCPINTANT -- ITE.PERCSTFCPINTANT, POR ENQUANTO Nï¿½O VAMOS CONSIDERAR O PERCENTUAL DA ITE DIFERENTE, ATï¿½ TERMOS CASO DE USO
                 , NVL(MAX(CASE WHEN DIN.CODIMP = 2 THEN DIN.ALIQUOTA ELSE 0 END), 0) AS PERCSUBST
                 , P_NUNOTA AS NUNOTA
                 , P_SEQUENCIA AS SEQUENCIA        
            FROM TGFVAR VAR 
               , TGFCAB CAB
               , TGFTOP TP
               , TGFDIN DIN
               , TGFITE ITE
            WHERE VAR.NUNOTAORIG = P_NUNOTA
                AND VAR.SEQUENCIAORIG = P_SEQUENCIA
                AND CAB.NUNOTA = VAR.NUNOTA
                AND TP.CODTIPOPER = CAB.CODTIPOPER
                AND TP.DHALTER = CAB.DHTIPOPER
                AND TP.COMPLEMENTO = 'S'
                AND DIN.NUNOTA = VAR.NUNOTA
                AND DIN.SEQUENCIA = VAR.SEQUENCIA
                AND ITE.NUNOTA = DIN.NUNOTA
                AND ITE.SEQUENCIA = DIN.SEQUENCIA
            GROUP BY VAR.QTDATENDIDA, ITE.QTDNEG, ITE.VLRICMSANT, ITE.BASESUBSTITANT, ITE.VLRSUBSTANT, ITE.BASESTFCPINTANT, ITE.VLRSTFCPINTANT -- A TGFDIN pode ter vï¿½rias linas
        ) IMP       
        , TGFITE ITE
    WHERE ITE.NUNOTA = IMP.NUNOTA
        AND ITE.SEQUENCIA = IMP.SEQUENCIA;
  COMMIT;
END;
