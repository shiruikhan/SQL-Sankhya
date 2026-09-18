/*==============================================================================
  Nome do Script : SNK_GET_CONTACONTABIL_IMOB_EFD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna a conta contabil de lancamentos de imobilizado no EFD, delegando a
                  SNK_GET_DADOS_IMOB_EFD ou cadastros.
  Assinatura     : SNK_GET_CONTACONTABIL_IMOB_EFD (P_TIPCTACTB VARCHAR2, P_REGISTRO VARCHAR2, P_CODEMP NUMBER, P_CODPROD NUMBER, P_NUMLOTE NUMBER, P_NUMLANC NUMBER, P_REFERENCIA DATE )
                   RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CONTACONTABIL_IMOB_EFD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CONTACONTABIL_IMOB_EFD (P_TIPCTACTB   VARCHAR2,
                                                           P_REGISTRO    VARCHAR2,
                                                           P_CODEMP      NUMBER,
                                                           P_CODPROD     NUMBER,
                                                           P_NUMLOTE     NUMBER,
                                                           P_NUMLANC     NUMBER,
                                                           P_REFERENCIA  DATE   
                                                          )
RETURN VARCHAR2
AS
    P_GRUPO_NATUREZA        NUMBER(5) := 0;
    P_RESULT                TCBPLA.CTACTB%TYPE := NULL;
    P_CODCENCUS             TSICUS.CODCENCUS%TYPE := NULL;

/* Nomenclatura sem o prefixo "F_" são as chamadas antigas feitas pelo "EFD Contribuições".
Novas chamadas para o "EFD Contribuições" devem começar a usar o prefixo "C_" para fazer uma boa distinção entre os EFDs.
Nomenclatura com o prefixo "F_" são as chamadas feitas pelo "EFD ICMS/IPI" de agora em diante.*/	
	
BEGIN
    IF P_TIPCTACTB IS NULL AND SUBSTR(P_REGISTRO, 0, 2 ) = 'F_' THEN
        P_RESULT := NULL;
    ELSIF P_TIPCTACTB = 'T' THEN  --CONTABILIZAÇÃO IMOBILIZADO TCIMOV
        SNK_GET_DADOS_IMOB_EFD( P_REGISTRO, P_CODEMP, P_CODPROD, P_NUMLOTE, P_NUMLANC, P_REFERENCIA, P_CODCENCUS, P_RESULT);
    ELSE --CADASTROS (SEM TCBINT)
        P_RESULT := SNK_GET_CTACTB_CADASTROS_EFD(P_REGISTRO, P_CODEMP, P_CODPROD, NULL /*CODNAT*/, NULL /*CODTIPOPER*/, NULL /*P_DHTIPOPER*/, NULL /*P_USOPROD*/);
    END IF;

    RETURN P_RESULT;
END;
