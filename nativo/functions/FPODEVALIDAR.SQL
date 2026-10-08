/*==============================================================================
  Nome do Script : FPODEVALIDAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Decide se a validacao de uma tabela deve rodar, considerando
                  DataSync em andamento (variavel de pacote/TSIPAR) e uso do
                  Checkout.
  Assinatura     : FPODEVALIDAR (NOMEDATABELA IN CHAR) RETURN BOOLEAN
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FPODEVALIDAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FPODEVALIDAR (NOMEDATABELA IN CHAR)
RETURN BOOLEAN
IS 
  P_COUNT INT;
  P_LOGICO CHAR(1);
  P_TEM_CHECKOUT BOOLEAN;
BEGIN
    /* 
    Quando existe e é sim, é porque esta vindo do DataSync, quando termina  o DataSync modifica para não.
    Esse parametro é global, se não encontrar vai buscar pelo outro, por questão de compatibilidade de versão.
	
	Se o cliente utiliza o Sankhya Checkout, vai validar com base apenas no parametro.
    */
	P_TEM_CHECKOUT := FCheckout_Utiliza;
	
	IF (NOT P_TEM_CHECKOUT) THEN
	  SELECT COUNT(1)
		INTO P_COUNT
		FROM USER_OBJECTS
		WHERE OBJECT_NAME = 'SYNC_PKG';
		 
		IF P_COUNT > 0 THEN
			P_LOGICO := SYNC_PKG.DSUPD_GLOBAL;
			RETURN (P_LOGICO <> 'S');
		END IF;
	END IF;	
	
	
    -- SE NÃO ENCONTROU A PKG OU A VARIÁVEL = 'N', BUSCA NA TSIPAR
    BEGIN
        SELECT NVL(COUNT(1),0) 
        INTO P_COUNT 
        FROM TSIPAR
        WHERE ((CHAVE = 'DSUPD_GLOBAL') OR (CHAVE = TRIM('DSUPD_' || NOMEDATABELA)))
        AND LOGICO = 'S';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        P_COUNT:= 0;
    END;
    
    IF (P_COUNT > 0) THEN
        RETURN(FALSE);
    ELSE 
        RETURN(TRUE);
    END IF;
END;
