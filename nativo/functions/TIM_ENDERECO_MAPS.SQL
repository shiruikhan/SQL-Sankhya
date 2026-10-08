/*==============================================================================
  Nome do Script : TIM_ENDERECO_MAPS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta endereco formatado (logradouro, bairro/cidade, UF/CEP)
                  para mapas.
  Assinatura     : TIM_ENDERECO_MAPS ( tipo VARCHAR, endereco VARCHAR, nro
                  VARCHAR, bairro VARCHAR, cidade VARCHAR, uf VARCHAR, cep
                  VARCHAR, codEnd INT, codBai INT, codCid INT, codUF INT)
                  RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_ENDERECO_MAPS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_ENDERECO_MAPS (
	tipo VARCHAR, 
	endereco VARCHAR, 
	nro VARCHAR, 
	bairro VARCHAR, 
	cidade VARCHAR, 
	uf VARCHAR, 
	cep VARCHAR,
	codEnd INT,
	codBai INT,
	codCid INT,
	codUF INT)
RETURN VARCHAR
IS
	enderecoFormatado VARCHAR(4000);
    logradouro VARCHAR(4000);
    bairroCidade VARCHAR(4000);
    ufCep VARCHAR(4000);
BEGIN

	logradouro := TIM_BUILD_LOGRADOURO(tipo, endereco, nro, codEnd);
    bairroCidade := TIM_BUILD_BAIRROCIDADE(bairro, cidade, codBai, codCid);
    ufCep := TIM_BUILD_UFCEP(uf, cep, codUF);
	
    enderecoFormatado := enderecoFormatado || logradouro;

	if length(trim(bairroCidade)) > 0 then
    	enderecoFormatado := enderecoFormatado || ' - ';
    end if;

	enderecoFormatado := enderecoFormatado || bairroCidade;
    
    if length(trim(ufCep)) > 0 then
    	enderecoFormatado := enderecoFormatado || ' - ';
    end if;

    enderecoFormatado := enderecoFormatado || ufCep;

    return enderecoFormatado;
END;
