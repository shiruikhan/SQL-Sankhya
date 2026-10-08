/*==============================================================================
  Nome do Script : TIM_GET_TSIPAR_INTEIRO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Parametro inteiro de TSIPAR (CODUSU = 0), busca case-
                  insensitive e com TRIM na chave; NULL se nao existir.
  Assinatura     : TIM_GET_TSIPAR_INTEIRO ( P_CHAVE VARCHAR ) RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_GET_TSIPAR_INTEIRO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_GET_TSIPAR_INTEIRO ( P_CHAVE VARCHAR )
RETURN INT
IS
   V_INTEIRO INT := NULL;
BEGIN

   BEGIN
    
    SELECT INTEIRO INTO V_INTEIRO
    FROM TSIPAR
    WHERE UPPER(TRIM(CHAVE)) = UPPER(TRIM(P_CHAVE))
    AND CODUSU = 0;
    
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         V_INTEIRO := NULL;
   END;

   RETURN V_INTEIRO;
END;
