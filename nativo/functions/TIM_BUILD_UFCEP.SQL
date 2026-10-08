/*==============================================================================
  Nome do Script : TIM_BUILD_UFCEP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata 'UF, CEP' para endereco.
  Assinatura     : TIM_BUILD_UFCEP (uf VARCHAR, cep VARCHAR, codUF INT) RETURN
                  VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_BUILD_UFCEP', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_BUILD_UFCEP (uf VARCHAR, cep VARCHAR, codUF INT)
RETURN VARCHAR
IS 
	UFCEPFormatado VARCHAR(4000);
BEGIN
	if length(trim(uf)) > 0 and codUF != 0 then
    	UFCEPFormatado := UFCEPFormatado || uf;
        if length(trim(cep)) > 0 then
        	UFCEPFormatado := UFCEPFormatado || ', ';
        end if;
    end if;
    if length(trim(cep)) > 0 then
    	UFCEPFormatado := UFCEPFormatado || cep;
    end if;
    return UFCEPFormatado;
END;
