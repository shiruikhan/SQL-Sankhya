/*==============================================================================
  Nome do Script : SNK_VERIFICA_NOME_IDX
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Gera um nome de indice disponivel (sem colisao com USER_INDEXES),
                  incrementando um sufixo numerico.
  Assinatura     : SNK_VERIFICA_NOME_IDX (P_INDICE VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_VERIFICA_NOME_IDX', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_VERIFICA_NOME_IDX (P_INDICE VARCHAR2) 

RETURN VARCHAR2 

IS 

  P_COUNT INT; 

  P_QTD INT; 

  P_NOVONOME VARCHAR2(100); 

BEGIN 

  P_NOVONOME := P_INDICE; 

  SELECT COUNT(1) INTO P_COUNT FROM USER_INDEXES WHERE INDEX_NAME = P_INDICE;       

  IF P_COUNT <> 0 THEN 

    P_QTD := 1;         

    WHILE (P_COUNT <> 0) 

    LOOP 

      P_NOVONOME := P_INDICE || P_QTD; 

      SELECT COUNT(1) INTO P_COUNT FROM USER_INDEXES WHERE INDEX_NAME = P_INDICE || P_QTD;           

      P_QTD := P_QTD + 1; 

    END LOOP; 

  END IF;   

  RETURN P_NOVONOME; 

END; 

  

  

-- Verificar e gera os índices para FKs faltantes
