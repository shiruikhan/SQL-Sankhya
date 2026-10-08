/*==============================================================================
  Nome do Script : F_WMS_NIVEL_VALIDO_ENDERECO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Valida se os niveis de origem/destino de um endereco WMS sao
                  atendidos pelo equipamento (nivel minimo/maximo, conexao,
                  picking).
  Assinatura     : F_WMS_NIVEL_VALIDO_ENDERECO (CONEXAO_ORIGEM VARCHAR2 ,
                  CONEXAO_DESTINO VARCHAR2 , PICKING_ORIGEM VARCHAR2 ,
                  NIVEL_ORIGEM NUMBER , NIVEL_DESTINO NUMBER , NIVEL_MAX IN
                  NUMBER , NIVEL_MIN IN NUMBER) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_WMS_NIVEL_VALIDO_ENDERECO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_WMS_NIVEL_VALIDO_ENDERECO (CONEXAO_ORIGEM VARCHAR2
                                                     , CONEXAO_DESTINO VARCHAR2
                                                     , PICKING_ORIGEM VARCHAR2
                                                     , NIVEL_ORIGEM NUMBER
                                                     , NIVEL_DESTINO NUMBER
                                                     , NIVEL_MAX IN NUMBER
                                                     , NIVEL_MIN IN NUMBER)
RETURN CHAR IS
BEGIN
  IF CONEXAO_DESTINO = 'S' THEN  
      IF CONEXAO_ORIGEM = 'S' THEN
        IF (NIVEL_ORIGEM BETWEEN NIVEL_MIN AND NIVEL_MAX) AND 
           (NIVEL_DESTINO BETWEEN NIVEL_MIN AND NIVEL_MAX) THEN
          RETURN 'S';
		    ELSE
		      RETURN 'N';
		    END IF;
	    END IF;
	  
      IF NIVEL_ORIGEM BETWEEN NIVEL_MIN AND NIVEL_MAX THEN
        RETURN 'S';
      ELSE
        RETURN 'N';
      END IF;  
      
  ELSIF CONEXAO_ORIGEM = 'S' THEN
      IF NIVEL_DESTINO BETWEEN NIVEL_MIN AND NIVEL_MAX THEN
        RETURN 'S';
      ELSE
        RETURN 'N';
      END IF; 
    
  ELSIF NIVEL_ORIGEM > 0 THEN  --não há conexão envolvida na movimentação --vou pegar em um local alto ?
      IF PICKING_ORIGEM = 'S' THEN
        --no caso de picking validamos apenas o destino, pois se o equipamento não for capaz de soltar no destino então ele não pode pegar
        --esse caso só será executado caso o picking não use conexão, pois para casos de conexão já está tratado no caso anterior
        IF NIVEL_DESTINO BETWEEN NIVEL_MIN AND NIVEL_MAX THEN
            RETURN 'S';
          ELSE
            RETURN 'N';
          END IF;
      END IF;
	  
	  IF  GET_TSIPAR_LOGICO('WMSVALNVMINMAX') = 'S' THEN
		IF (NIVEL_ORIGEM BETWEEN NIVEL_MIN AND NIVEL_MAX) AND (NIVEL_DESTINO BETWEEN NIVEL_MIN AND NIVEL_MAX) THEN
			RETURN 'S';
		ELSE
			RETURN 'N';
		END IF;
	  ELSE   
		IF NIVEL_ORIGEM <= NIVEL_MAX AND NIVEL_DESTINO <= NIVEL_MAX THEN --consigo pegar e consigo soltar ?
			RETURN 'S';
		ELSE
			RETURN 'N';
		END IF;
	  END IF;
        
  ELSE
      IF (NIVEL_ORIGEM BETWEEN NIVEL_MIN AND NIVEL_MAX) AND (NIVEL_DESTINO BETWEEN NIVEL_MIN AND NIVEL_MAX) THEN
        RETURN 'S';
      ELSE
        RETURN 'N';
      END IF;
  END IF;  
END;
