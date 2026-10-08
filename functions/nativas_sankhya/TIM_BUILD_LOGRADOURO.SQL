/*==============================================================================
  Nome do Script : TIM_BUILD_LOGRADOURO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata 'tipo logradouro, numero' para endereco.
  Assinatura     : TIM_BUILD_LOGRADOURO (tipo VARCHAR, logradouro VARCHAR, nro
                  VARCHAR, codEnd INT) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_BUILD_LOGRADOURO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_BUILD_LOGRADOURO (tipo VARCHAR, logradouro VARCHAR, nro VARCHAR, codEnd INT)
RETURN VARCHAR
IS
	logradouroFormatado VARCHAR(4000);
BEGIN
	if length(trim(logradouro)) > 0 and codEnd != 0 then
    	if length(trim(tipo)) > 0 then
        	logradouroFormatado := logradouroFormatado || tipo || ' ';
        end if;
        logradouroFormatado := logradouroFormatado || logradouro;
        if length(trim(nro)) > 0 then
        	logradouroFormatado := logradouroFormatado || ', ' || nro;
        end if;
    end if;
    return logradouroFormatado;
END;
