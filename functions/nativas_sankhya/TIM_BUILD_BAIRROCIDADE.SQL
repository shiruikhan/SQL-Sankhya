/*==============================================================================
  Nome do Script : TIM_BUILD_BAIRROCIDADE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata 'bairro, cidade' para endereco.
  Assinatura     : TIM_BUILD_BAIRROCIDADE (bairro VARCHAR, cidade VARCHAR,
                  codBai INT, codCid INT) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_BUILD_BAIRROCIDADE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_BUILD_BAIRROCIDADE (bairro VARCHAR, cidade VARCHAR, codBai INT, codCid INT)
RETURN VARCHAR
IS
	bairroCidadeFormatado VARCHAR(4000);
BEGIN
	if length(trim(bairro)) > 0 and codBai != 0 then
    	bairroCidadeFormatado := bairroCidadeFormatado || bairro;
        if length(trim(cidade)) > 0 and codCid != 0 then
        	bairroCidadeFormatado := bairroCidadeFormatado || ', ';
        end if;
    end if;
    if length(trim(cidade)) > 0 and codCid != 0 then
    	bairroCidadeFormatado := bairroCidadeFormatado || cidade;
    end if;
    return bairroCidadeFormatado;
END;
