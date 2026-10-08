/*==============================================================================
  Nome do Script : TIM_ENDERECO_IMOVEL_MAPS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o endereco completo de um imovel para
                  geocodificacao/mapas.
  Assinatura     : TIM_ENDERECO_IMOVEL_MAPS (P_IMVCODIGO INT) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_ENDERECO_IMOVEL_MAPS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_ENDERECO_IMOVEL_MAPS (P_IMVCODIGO INT)
RETURN VARCHAR
IS
	R_IMOVEL TIMIMV%ROWTYPE;
    tipoEnd VARCHAR(4000);
    codEnd INT;
    endTectum VARCHAR(4000);
    Bairro_NOMEBAI VARCHAR(4000);
    Cidade_NOMECID VARCHAR(4000);
    Cidade_UnidadeFederativa_UF VARCHAR(4000);
    Cidade_UnidadeFederativa_CODUF VARCHAR(4000);
    enderecoFormatado VARCHAR(4000);
    IMVENDFINAL VARCHAR(4000);
BEGIN

	SELECT * INTO R_IMOVEL
    FROM TIMIMV
    WHERE IMVCODIGO = P_IMVCODIGO;
    
    BEGIN
    	SELECT 
        	C.NOMECID,
            U.UF,
            U.CODUF
            INTO
            Cidade_NOMECID,
            Cidade_UnidadeFederativa_UF,
            Cidade_UnidadeFederativa_CODUF
		FROM TSICID C
        LEFT JOIN TSIUFS U ON U.CODUF = C.UF
        WHERE C.CODCID = R_IMOVEL.IMVCIDADE; 
    EXCEPTION 
    	WHEN NO_DATA_FOUND THEN
        	Cidade_NOMECID := NULL;
            Cidade_UnidadeFederativa_UF := NULL;
            Cidade_UnidadeFederativa_CODUF := NULL;
    END;
    
    BEGIN
    	SELECT 
        	NOMEBAI
            INTO
            Bairro_NOMEBAI
        FROM TSIBAI
        WHERE CODBAI = R_IMOVEL.IMVBAIRRO;
    EXCEPTION 
    	WHEN NO_DATA_FOUND THEN
        	Bairro_NOMEBAI := NULL;
    END;

    IMVENDFINAL := R_IMOVEL.IMVENDERECO;

    if R_IMOVEL.IMVCODEND != 0 then
    
    	BEGIN
        	SELECT 
                NOMEEND
                INTO
                IMVENDFINAL
            FROM TSIEND
            WHERE CODEND = R_IMOVEL.IMVCODEND;
        EXCEPTION
        	WHEN NO_DATA_FOUND THEN
            	NULL;
        END;
      
    end if;
    
    codEnd := NVL(R_IMOVEL.IMVCODEND,0);
    endTectum := R_IMOVEL.IMVENDERECO;
    
    if codEnd != 0 then
        
        BEGIN
            SELECT 
            	TRIM(T.DESCRICAO)
                INTO
                tipoEnd
            FROM TSIEND E
            LEFT JOIN TSITEND T ON TRIM(UPPER(T.TIPO)) = TRIM(UPPER(E.TIPO))
            WHERE E.CODEND = codEnd
            AND ROWNUM = 1;
        EXCEPTION
        	WHEN NO_DATA_FOUND THEN
            	tipoEnd := null;
        END;
        
    elsif length(trim(endTectum)) > 0 then
        codEnd := 1; --forçado para formatar o endereço
    end if;
    
    enderecoFormatado := TIM_ENDERECO_MAPS(tipoEnd, 
				IMVENDFINAL,
				R_IMOVEL.IMVNUMERO,
				Bairro_NOMEBAI,
				Cidade_NOMECID,
				Cidade_UnidadeFederativa_UF,
				R_IMOVEL.IMVCEP,
				codEnd,
				R_IMOVEL.IMVBAIRRO,
				R_IMOVEL.IMVCIDADE,
				Cidade_UnidadeFederativa_CODUF);
    
    RETURN enderecoFormatado;
    
    EXCEPTION 
    	WHEN NO_DATA_FOUND THEN
        	RETURN NULL;
END;
