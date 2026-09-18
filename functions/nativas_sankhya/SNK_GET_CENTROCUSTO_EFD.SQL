/*==============================================================================
  Nome do Script : SNK_GET_CENTROCUSTO_EFD
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o centro de custo para lancamento contabil de EFD (ICMS/IPI ou
                  Contribuicoes), delegando a SNK_GET_DADOS_EFD.
  Assinatura     : SNK_GET_CENTROCUSTO_EFD ( P_TIPCTACTB VARCHAR2, P_REGISTRO VARCHAR2, P_CODEMP NUMBER, P_NUNICO NUMBER, P_SEQNOTA NUMBER, P_ORIGEM VARCHAR2)
                   RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_CENTROCUSTO_EFD', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_CENTROCUSTO_EFD (  P_TIPCTACTB   VARCHAR2,
                                                     P_REGISTRO    VARCHAR2,
                                                     P_CODEMP      NUMBER,
                                                     P_NUNICO      NUMBER, 
                                                     P_SEQNOTA     NUMBER, 
                                                     P_ORIGEM      VARCHAR2)
RETURN NUMBER
AS
    P_CTACTB                TCBPLA.CTACTB%TYPE := NULL;
    P_RESULT                TSICUS.CODCENCUS%TYPE := NULL;
BEGIN
    IF P_TIPCTACTB = 'T' THEN
        SNK_GET_DADOS_EFD(P_REGISTRO, P_CODEMP, P_NUNICO, P_SEQNOTA, P_ORIGEM, P_RESULT, P_CTACTB);
    END IF;

    RETURN P_RESULT;
END;
