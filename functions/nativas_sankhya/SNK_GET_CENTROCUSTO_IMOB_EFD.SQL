/*==============================================================================
  Nome do Script : SNK_GET_CENTROCUSTO_IMOB_EFD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o centro de custo para lancamento contabil de imobilizado no EFD,
                  delegando a SNK_GET_DADOS_IMOB_EFD.
  Assinatura     : SNK_GET_CENTROCUSTO_IMOB_EFD ( P_TIPCTACTB VARCHAR2, P_REGISTRO VARCHAR2, P_CODEMP NUMBER, P_CODPROD NUMBER, P_NUMLOTE NUMBER, P_NUMLANC NUMBER, P_REFERENCIA DATE)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CENTROCUSTO_IMOB_EFD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CENTROCUSTO_IMOB_EFD ( P_TIPCTACTB   VARCHAR2,
                                                         P_REGISTRO    VARCHAR2,
                                                         P_CODEMP      NUMBER,
                                                         P_CODPROD     NUMBER,
                                                         P_NUMLOTE     NUMBER,
                                                         P_NUMLANC     NUMBER,
                                                         P_REFERENCIA  DATE)
RETURN NUMBER
AS
    P_CTACTB                TCBPLA.CTACTB%TYPE := NULL;
    P_RESULT                TSICUS.CODCENCUS%TYPE := NULL;
BEGIN
    IF P_TIPCTACTB = 'T' THEN
        SNK_GET_DADOS_IMOB_EFD( P_REGISTRO, P_CODEMP, P_CODPROD, P_NUMLOTE, P_NUMLANC, P_REFERENCIA, P_RESULT, P_CTACTB);
    END IF;

    RETURN P_RESULT;
END;
