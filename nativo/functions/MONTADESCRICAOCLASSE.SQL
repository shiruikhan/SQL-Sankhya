/*==============================================================================
  Nome do Script : MONTADESCRICAOCLASSE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Traduz a sigla de classe da conta bancaria (C, D, A, X, E,
                  G, S, O, Z) em descricao.
  Assinatura     : MONTADESCRICAOCLASSE (STRCLASSE VARCHAR) RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'MONTADESCRICAOCLASSE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION MONTADESCRICAOCLASSE (STRCLASSE VARCHAR)
RETURN VARCHAR2
IS
  P_RESULT VARCHAR2(50) := ' ';
BEGIN

  IF NVL(STRCLASSE, ' ') <> ' ' THEN
  
    P_RESULT := CASE SUBSTR(STRCLASSE, 0, 1) WHEN 'C' THEN 'Corrente'
                                             WHEN 'D' THEN 'Adiantamento'
                                             WHEN 'A' THEN 'Aplicação'
                                             WHEN 'X' THEN 'Caixa'
                                             WHEN 'E' THEN 'Empréstimo'
                                             WHEN 'G' THEN 'Garantida'
                                             WHEN 'S' THEN 'Sócios'
                                             WHEN 'O' THEN 'Outros'
                                             WHEN 'Z' THEN 'Não Selecionada'
                                             ELSE ' '
                END;  
    
  END IF;
  
  RETURN P_RESULT;  
END;
