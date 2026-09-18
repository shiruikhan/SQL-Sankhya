/*==============================================================================
  Nome do Script : SNK_GET_CONTACONTABIL_EFD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a conta contabil para EFD ICMS/IPI ou Contribuicoes, delegando a
                  SNK_GET_DADOS_EFD ou SNK_GET_CTACTB_CADASTROS_EFD.
  Assinatura     : SNK_GET_CONTACONTABIL_EFD (P_TIPCTACTB VARCHAR2, P_REGISTRO VARCHAR2, P_CODEMP NUMBER, P_NUNICO NUMBER, P_SEQNOTA NUMBER, P_ORIGEM VARCHAR2, P_CODPROD NUMBER, P_CODNAT NUMBER, P_CODTIPOPER NUMBER, P_DHTIPOPER DATE, P_USOPROD VARCHAR2)
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CONTACONTABIL_EFD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CONTACONTABIL_EFD (P_TIPCTACTB   VARCHAR2,
                                                      P_REGISTRO    VARCHAR2,
                                                      P_CODEMP      NUMBER,
                                                      P_NUNICO      NUMBER, 
                                                      P_SEQNOTA     NUMBER, 
                                                      P_ORIGEM      VARCHAR2,
                                                      P_CODPROD     NUMBER,
                                                      P_CODNAT      NUMBER,
                                                      P_CODTIPOPER  NUMBER,
                                                      P_DHTIPOPER   DATE,                                                      
                                                      P_USOPROD     VARCHAR2)
RETURN VARCHAR2
AS
    P_RESULT                TCBPLA.CTACTB%TYPE := NULL;
    P_CODCENCUS             TSICUS.CODCENCUS%TYPE := NULL;
	
/* Nomenclatura sem o prefixo "F_" são as chamadas antigas feitas pelo "EFD Contribuições".
Novas chamadas para o "EFD Contribuições" devem começar a usar o prefixo "C_" para fazer uma boa distinção entre os EFDs.
Nomenclatura com o prefixo "F_" são as chamadas feitas pelo "EFD ICMS/IPI" de agora em diante.*/

BEGIN
    IF P_TIPCTACTB IS NULL AND SUBSTR(P_REGISTRO, 0, 2 ) = 'F_' THEN
        P_RESULT := NULL;
    ELSIF P_TIPCTACTB = 'T' THEN  --CONTABILIZAÇÃO TCBINT
        SNK_GET_DADOS_EFD(P_REGISTRO, P_CODEMP, P_NUNICO, P_SEQNOTA, P_ORIGEM, P_CODCENCUS, P_RESULT);
    ELSE --CADASTROS (SEM TCBINT)
        P_RESULT := SNK_GET_CTACTB_CADASTROS_EFD(P_REGISTRO, P_CODEMP, P_CODPROD, P_CODNAT, P_CODTIPOPER, P_DHTIPOPER, P_USOPROD);
    END IF;

    RETURN P_RESULT;
END;
