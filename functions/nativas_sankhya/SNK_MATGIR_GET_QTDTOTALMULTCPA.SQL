/*==============================================================================
  Nome do Script : SNK_MATGIR_GET_QTDTOTALMULTCPA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Ajusta a quantidade sugerida de compra para multiplos do lote de compra do
                  parceiro, conforme parametro de arredondamento (TIPARMULTCPGIRO).
  Assinatura     : SNK_MATGIR_GET_QTDTOTALMULTCPA (P_CODPROD NUMBER, P_CODPARC NUMBER, P_SUGCOMPRA FLOAT, P_UNIDADE VARCHAR2)
                   RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_MATGIR_GET_QTDTOTALMULTCPA', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_MATGIR_GET_QTDTOTALMULTCPA (P_CODPROD NUMBER,
                                                          P_CODPARC NUMBER,
                                                          P_SUGCOMPRA FLOAT,
                                                          P_UNIDADE VARCHAR2)
RETURN FLOAT
AS    
  MULT                  NUMBER;
  QTDMULT               FLOAT;
  PARAMTIPOARRECP       INT;
  QTDRESTOAGRUPAMENTO   FLOAT;
  PERCRESTOAGRUPAMENTO  FLOAT;
BEGIN
    MULT := SNK_MATGIR_GET_MULTCPA(P_CODPROD, P_CODPARC, P_UNIDADE);
    
    PARAMTIPOARRECP := GET_TSIPAR_INTEIRO('TIPARMULTCPGIRO');   
    
    
    IF  NVL(MULT, 0) <> 0 THEN
      
      QTDRESTOAGRUPAMENTO := MOD(P_SUGCOMPRA, MULT);      
      PERCRESTOAGRUPAMENTO := ((QTDRESTOAGRUPAMENTO * 100) / MULT);
      
      IF PARAMTIPOARRECP = 0 THEN
          QTDMULT := CEIL(P_SUGCOMPRA/MULT) * MULT;
      ELSIF PARAMTIPOARRECP = 1 OR PARAMTIPOARRECP = 2 THEN
          
          QTDMULT := P_SUGCOMPRA;
          
          IF PERCRESTOAGRUPAMENTO > 0 AND PERCRESTOAGRUPAMENTO < 50 AND PARAMTIPOARRECP = 1 THEN
                QTDMULT := (P_SUGCOMPRA - QTDRESTOAGRUPAMENTO);
          ELSIF PERCRESTOAGRUPAMENTO >= 50 AND PARAMTIPOARRECP = 1 THEN
            QTDMULT := (P_SUGCOMPRA + (MULT - QTDRESTOAGRUPAMENTO));   
          ELSIF PERCRESTOAGRUPAMENTO > 0 AND PERCRESTOAGRUPAMENTO <= 50 AND PARAMTIPOARRECP = 2 THEN
            QTDMULT := (P_SUGCOMPRA - QTDRESTOAGRUPAMENTO);
          ELSIF PERCRESTOAGRUPAMENTO > 50 AND PARAMTIPOARRECP = 2 THEN
             QTDMULT := (P_SUGCOMPRA + (MULT - QTDRESTOAGRUPAMENTO));         
          END IF;
                    
      ELSE
        IF QTDRESTOAGRUPAMENTO > 0 THEN  
            QTDMULT := (P_SUGCOMPRA - QTDRESTOAGRUPAMENTO);
        ELSE
            QTDMULT := P_SUGCOMPRA;
        END IF;
      END IF;           
    ELSE
      QTDMULT := P_SUGCOMPRA; 
    END IF;
    
    RETURN QTDMULT;
END;
