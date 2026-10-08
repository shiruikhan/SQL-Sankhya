/*==============================================================================
  Nome do Script : EVP_PISCOFINSSPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : corrigir o PIS e COFINS das notas fiscais de Devolução do Simples nacional pois não pode ser devolvido o ICMS em campos próprios e sim em ajuste.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 01/04/2025, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "EVP_PISCOFINSSPARK" (
    P_TIPOEVENTO INT,    
    P_IDSESSAO VARCHAR2, 
    P_CODUSU INT         
) AS
    BEFORE_INSERT INT;
    AFTER_INSERT  INT;
    BEFORE_DELETE INT;
    AFTER_DELETE  INT;
    BEFORE_UPDATE INT;
    AFTER_UPDATE  INT;
    BEFORE_COMMIT INT;
    V_SIMPLES TGFPAR.SIMPLES%TYPE;
    V_TIPMOV TGFCAB.TIPMOV%TYPE;
    V_CODIMP INT;
    V_NUNOTA INT;
    V_NEW_BASE NUMBER(18,2);
    V_NEW_PIS NUMBER(18,2);
    V_NEW_COFINS NUMBER(18,2);
BEGIN
    BEFORE_INSERT := 0;
    AFTER_INSERT  := 1;
    BEFORE_DELETE := 2;
    AFTER_DELETE  := 3;
    BEFORE_UPDATE := 4;
    AFTER_UPDATE  := 5;
    BEFORE_COMMIT := 10;
/*******************************************************************************
Autor: Lucas Gabriel 
Data: 01/04/2024
Objetivo: corrigir o PIS e COFINS das notas fiscais de Devolução do Simples nacional 
pois não pode ser devolvido o ICMS em campos próprios e sim em ajuste.
********************************************************************************/
    IF P_TIPOEVENTO = BEFORE_INSERT 
		OR P_TIPOEVENTO = BEFORE_UPDATE
	THEN
        SELECT 
            NVL(PAR.SIMPLES,'N'),
            CAB.TIPMOV,
            EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODIMP'),
            EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA')
        INTO 
            V_SIMPLES,
            V_TIPMOV,
            V_CODIMP,
            V_NUNOTA
        FROM TGFPAR PAR 
        INNER JOIN TGFCAB CAB ON CAB.CODPARC = PAR.CODPARC 
        WHERE CAB.NUNOTA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'NUNOTA'); 
        IF V_SIMPLES = 'S' AND V_TIPMOV = 'E' THEN 
            SELECT 
                ROUND(ITE.VLRTOT - NVL(ITE.AD_VLRICMSSP,0), 2),
                ROUND(ROUND(ITE.VLRTOT - NVL(ITE.AD_VLRICMSSP,0), 2) * 0.0165, 2),
                ROUND(ROUND(ITE.VLRTOT - NVL(ITE.AD_VLRICMSSP,0), 2) * 0.076, 2)
            INTO 
                V_NEW_BASE,
                V_NEW_PIS,
                V_NEW_COFINS
            FROM TGFITE ITE
            WHERE ITE.NUNOTA = V_NUNOTA
            AND ITE.SEQUENCIA = EVP_GET_CAMPO_INT(P_IDSESSAO, 'SEQUENCIA');

            IF V_CODIMP = 6 
				THEN 
                EVP_SET_CAMPO_DEC(P_IDSESSAO, 'BASERED', V_NEW_BASE);
                EVP_SET_CAMPO_DEC(P_IDSESSAO, 'VALOR', V_NEW_PIS);
            ELSIF V_CODIMP = 7 
				THEN
                EVP_SET_CAMPO_DEC(P_IDSESSAO, 'BASERED', V_NEW_BASE);
                EVP_SET_CAMPO_DEC(P_IDSESSAO, 'VALOR', V_NEW_COFINS);
            END IF;
        END IF;
    END IF;
END;
