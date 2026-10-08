/*==============================================================================
  Nome do Script : GET_TSIPAR_TIPO_CT
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o valor de um parametro TSIPAR do tipo C (combo) ou
                  T (texto) como texto, conforme o tipo cadastrado.
  Assinatura     : GET_TSIPAR_TIPO_CT ( P_PARAMETRO IN VARCHAR ) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_TSIPAR_TIPO_CT', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_TSIPAR_TIPO_CT ( P_PARAMETRO IN VARCHAR )
RETURN VARCHAR IS
   V_INTEIRO NUMBER(10);
   V_TEXTO   VARCHAR2(4000);
   V_TIPO    VARCHAR2(1);
   V_RETORNO VARCHAR2(1000);
BEGIN
   BEGIN
      SELECT TIPO, NVL(INTEIRO, 0), TEXTO
      INTO V_TIPO, V_INTEIRO, V_TEXTO
      FROM TSIPAR
      WHERE CHAVE = P_PARAMETRO
        AND TIPO IN ('C','T');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         V_INTEIRO    := -1;
   END;
   
   IF V_INTEIRO = -1 THEN
     V_RETORNO := NULL;
   ELSE
     IF V_TIPO = 'T' THEN
       V_RETORNO := V_TEXTO;
     ELSE   
       IF INSTR(V_TEXTO,CHR(10),1,1) = 0 THEN
         V_RETORNO := V_TEXTO;
       ELSE
           V_INTEIRO := V_INTEIRO + 1;
           SELECT SUBSTR(V_TEXTO,
                         CASE WHEN V_INTEIRO = 1 
                         THEN 1 
                         ELSE INSTR(V_TEXTO,CHR(10),1,V_INTEIRO-1)+1 
                         END,
                         CASE WHEN V_INTEIRO = 1 
                         THEN INSTR(V_TEXTO,CHR(10),1,V_INTEIRO) 
                         ELSE CASE WHEN INSTR(V_TEXTO,CHR(10),1,V_INTEIRO) = 0 
                              THEN LENGTH(V_TEXTO) 
                              ELSE INSTR(V_TEXTO,CHR(10),1,V_INTEIRO) END  
                                        -INSTR(V_TEXTO,CHR(10),1,V_INTEIRO-1) 
                         END)
            INTO V_RETORNO
            FROM DUAL;
       END IF;  
     END IF;
   END IF;

   RETURN V_RETORNO;
END;
