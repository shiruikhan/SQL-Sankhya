/*==============================================================================
  Nome do Script : FSP_RETURN_DATAS_UTEIS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna uma colecao (TSP_DATAS_UTEIS_TYPE) com cada data do
                  intervalo, indicador de dia util e numero sequencial de dia
                  util.
  Assinatura     : FSP_RETURN_DATAS_UTEIS ( P_DATAINI DATE, P_DATAFIM DATE )
                  RETURN TSP_DATAS_UTEIS_TYPE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FSP_RETURN_DATAS_UTEIS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FSP_RETURN_DATAS_UTEIS (
  P_DATAINI DATE, P_DATAFIM DATE
)
RETURN TSP_DATAS_UTEIS_TYPE AS
  v_ret  TSP_DATAS_UTEIS_TYPE;

  P_DATA    DATE;
  P_DIAUTIL    VARCHAR2(1);
  P_SEQ        NUMBER(5);
BEGIN


  P_DATA := P_DATAINI;
  v_ret  := TSP_DATAS_UTEIS_TYPE();
  P_SEQ := -1;

   WHILE P_DATA <= P_DATAFIM
   LOOP

  SELECT
  CASE FSP_DATA_DIA_UTIL(P_DATA,0) WHEN 1 THEN 'S' ELSE 'N' END INTO P_DIAUTIL
  FROM DUAL;

  IF P_DIAUTIL = 'S' THEN
       P_SEQ := P_SEQ + 1;
  END IF;

  IF P_DIAUTIL = 'N' AND P_DATA = P_DATAINI  THEN
       P_SEQ := 0;
  END IF;

  v_ret.EXTEND;
     v_ret(v_ret.COUNT) := TSP_DATAS_UTEIS(P_DATA, P_DIAUTIL,P_SEQ );


     P_DATA := P_DATA + 1;


   END LOOP;

  RETURN v_ret;

END;
