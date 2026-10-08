/*==============================================================================
  Nome do Script : GET_QTD_FOTOS_IMV
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a quantidade de fotos de um imovel (colecao
                  T_FOTOS_IMOVEIS_TABLE).
  Assinatura     : GET_QTD_FOTOS_IMV (P_IMVCODIGO NUMBER) RETURN
                  T_FOTOS_IMOVEIS_TABLE
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_QTD_FOTOS_IMV', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_QTD_FOTOS_IMV (P_IMVCODIGO NUMBER)
       RETURN T_FOTOS_IMOVEIS_TABLE
    AS
       V_RET         T_FOTOS_IMOVEIS_TABLE;
       P_SEQUENCIA   NUMBER(10);
       P_QTDFOTOS    NUMBER(10);
    BEGIN
       V_RET := T_FOTOS_IMOVEIS_TABLE ();
       P_SEQUENCIA := 0;
        
       BEGIN 
           SELECT TIMQTDFOTOS INTO  P_QTDFOTOS
           FROM TGFPEV WHERE NUPEV = (SELECT NUPEV FROM TIMIMV WHERE IMVCODIGO = P_IMVCODIGO);
       EXCEPTION WHEN NO_DATA_FOUND THEN 
           P_QTDFOTOS := 0;
       END;
       
       WHILE P_SEQUENCIA < P_QTDFOTOS
       LOOP
          V_RET.EXTEND;
          V_RET (V_RET.COUNT) := T_FOTOS_IMOVEIS(P_IMVCODIGO,P_SEQUENCIA);
          P_SEQUENCIA := P_SEQUENCIA + 1;
       END LOOP;

       RETURN V_RET;
    END;
