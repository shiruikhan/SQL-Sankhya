/*==============================================================================
  Nome do Script : QUEBRALINHACHAR
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Quebra um texto em linhas de N caracteres (CR+LF entre
                  elas).
  Assinatura     : QUEBRALINHACHAR ( P_TEXTO VARCHAR2, QTDCHAR NUMBER) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'QUEBRALINHACHAR', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION QUEBRALINHACHAR ( P_TEXTO VARCHAR2, QTDCHAR  NUMBER) RETURN VARCHAR2 IS
P_FIM     NUMBER;
P_COMECO  NUMBER;
P_RETORNO VARCHAR2(4000);
BEGIN
    P_COMECO := 0;
    P_RETORNO := '';
    P_FIM := FLOOR(LENGTH(P_TEXTO)/QTDCHAR);  
    FOR I IN 0..(P_FIM)
    LOOP
        P_RETORNO := P_RETORNO|| SUBSTR( P_TEXTO,P_COMECO+1,QTDCHAR );         
        IF(I <> P_FIM)THEN 
            P_RETORNO := P_RETORNO||CHR(13)||CHR(10);
        END IF;
        P_COMECO:= P_COMECO+QTDCHAR;
    END LOOP; 
  RETURN P_RETORNO ;
END;
