/*==============================================================================
  Nome do Script : STP_GET_VARIAVEIS
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna uma variavel de VARIAVEIS_PKG pelo nome (insercao
                  automatica, imposto retido, custo por
                  empresa/local/controle).
  Assinatura     : STP_GET_VARIAVEIS ( NOMEVAR VARCHAR2 ) RETURN CHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'STP_GET_VARIAVEIS', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION STP_GET_VARIAVEIS ( NOMEVAR VARCHAR2 )
RETURN CHAR
AS
BEGIN
  RETURN(
    CASE UPPER(NOMEVAR)
      WHEN 'INSERCAOAUTOMATICA' 		 THEN Variaveis_Pkg.V_InsercaoAutomatica
      WHEN 'CONSIDERARIMPOSTORETIDONOTA' THEN Variaveis_Pkg.V_ConsiderarImpostoRetidoNota
      WHEN 'CUSTOPOREMPRESA' 			 THEN Variaveis_Pkg.V_CustoPorEmpresa
      WHEN 'CUSTOPORLOCAL' 				 THEN Variaveis_Pkg.V_CustoPorLocal
      WHEN 'CUSTOPORCONTROLE' 			 THEN Variaveis_Pkg.V_CustoPorControle
    END
  );
END;
