/*==============================================================================
  Nome do Script : EXISTS_STP
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna 'S' ou 'N' conforme a procedure informada existe em
                  USER_PROCEDURES.
  Assinatura     : EXISTS_STP (stp_name VARCHAR) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'EXISTS_STP', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION EXISTS_STP (stp_name VARCHAR)
RETURN VARCHAR
IS
    RESULT VARCHAR(255);
BEGIN  
    BEGIN    
        SELECT 
            OBJECT_NAME INTO RESULT
        FROM 
            USER_PROCEDURES
        WHERE
            OBJECT_NAME = stp_name;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'N';
    END;

    RETURN 'S';
END;
