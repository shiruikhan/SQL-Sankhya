/*==============================================================================
  Nome do Script : GET_DEPEND
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Lista os dependentes de um funcionario (TFPDPD) separados
                  por virgula. INVALID no banco desde 2021.
  Assinatura     : GET_DEPEND ( P_CODFUNC INTEGER ) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_DEPEND', 'SPARKPRD') FROM dual;
                  - Objeto INVALID no banco desde 2021 (nunca recompilou); nao
                    utilizar.
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_DEPEND ( P_CODFUNC INTEGER ) RETURN VARCHAR IS
BEGIN
  DECLARE 
  P_RESULT VARCHAR(256);
  P_DEPEND VARCHAR(256);

  CURSOR C_DEPENDENTE IS 
   SELECT DISTINCT DPD.NOMEDEPEND FROM 
  TFPDPD DPD
  ,TFPFUN FUN 
  WHERE
  DPD.CODFUNC = FUN.CODFUNC
  AND DPD.CODFUNC = P_CODFUNC;
  
  BEGIN
    P_RESULT := '';
    /* ABRE CURSOR */
    OPEN C_DEPENDENTE;
    
    LOOP
        /* LE UM REGISTRO DO CURSOR */
        FETCH C_DEPENDENTE INTO P_DEPEND;
        
        /* ABANDONA O LOOP CASO SEJA O FINAL DO CURSOR */
        EXIT WHEN C_DEPENDENTE%NOTFOUND;
        
  IF P_RESULT = '' THEN
          P_RESULT := P_DEPEND;
  ELSE 
    P_RESULT := P_RESULT ||','||P_DEPEND;
  END IF; 
    
    END LOOP;
    
    /* FECHA O CURSOR */
    CLOSE C_DEPENDENTE;
 
 RETURN P_RESULT;
  
  END;

END;
