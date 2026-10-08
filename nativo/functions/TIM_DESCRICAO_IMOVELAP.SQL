/*==============================================================================
  Nome do Script : TIM_DESCRICAO_IMOVELAP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a descricao atual do imovel
                  (TIMIMV.IMVDESCRICAOATUAL).
  Assinatura     : TIM_DESCRICAO_IMOVELAP (IMOVEL IN NUMBER) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_DESCRICAO_IMOVELAP', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_DESCRICAO_IMOVELAP (IMOVEL IN NUMBER) RETURN VARCHAR2 IS
  P_DESCRICAO VARCHAR2(4000);
 BEGIN
  SELECT IMVDESCRICAOATUAL INTO P_DESCRICAO FROM TIMIMV WHERE IMVCODIGO = IMOVEL;
       
 RETURN P_DESCRICAO;

END;
