/*==============================================================================
  Nome do Script : SNK_GET_CODLOTACAO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o codigo de lotacao (empresa ou terceiro) para o eSocial, prefixando
                  'SNK' quando parametrizado.
  Assinatura     : SNK_GET_CODLOTACAO (P_CODPARC NUMBER, P_EMP_CODPARC NUMBER, P_CODEMP NUMBER, P_FUN_CODEMP NUMBER)
                   RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CODLOTACAO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CODLOTACAO (P_CODPARC        NUMBER,
                                               P_EMP_CODPARC    NUMBER,
                                               P_CODEMP         NUMBER,
                                               P_FUN_CODEMP     NUMBER)
   RETURN VARCHAR
IS
   P_RESULT   VARCHAR (4000);
   P_VAL      VARCHAR2 (2);
BEGIN
    P_VAL := '0';
    P_RESULT := NULL;
    
    SELECT COUNT(1) INTO P_VAL 
        FROM TSIEMP E 
        WHERE E.CODPARC = P_CODPARC 
         AND E.CODEMPMATRIZ = P_CODEMP;
         
    IF (P_CODPARC = 0 OR P_EMP_CODPARC = P_CODPARC OR P_VAL >= 1) THEN
        P_RESULT := P_RESULT || 'E' || P_FUN_CODEMP;
    ELSE
        P_RESULT:= P_RESULT || 'T' || P_CODPARC;
    END IF;
    
    SELECT COUNT(1) INTO P_VAL
    FROM TSIPAR 
    WHERE CHAVE = 'FPCONCATEVE' 
     AND LOGICO = 'S';
    
    IF P_VAL > 0 THEN
        P_RESULT := 'SNK' || P_RESULT;
    END IF;
    
    RETURN P_RESULT;
END;
