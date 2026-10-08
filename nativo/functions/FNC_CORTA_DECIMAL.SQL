/*==============================================================================
  Nome do Script : FNC_CORTA_DECIMAL
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Trunca (corta) um valor para N casas decimais somando uma
                  unidade na ultima casa quando ha excedente.
  Assinatura     : FNC_CORTA_DECIMAL (P_VALOR FLOAT, P_CASAS NUMBER) RETURN
                  FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FNC_CORTA_DECIMAL', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FNC_CORTA_DECIMAL (P_VALOR FLOAT, P_CASAS NUMBER) RETURN FLOAT
AS
BEGIN
   IF ROUND(P_VALOR, P_CASAS) = P_VALOR THEN
      RETURN P_VALOR;
     END IF;

    RETURN TRUNC((P_VALOR * POWER(10.0,P_CASAS)) + 1 ) / POWER(10.0,P_CASAS); 
END;
