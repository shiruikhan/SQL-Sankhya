/*==============================================================================
  Nome do Script : F_WMS_GETESTOQUEDOCA_PARC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Variacao de F_WMS_GETESTOQUEDOCA que tambem filtra por
                  parceiro.
  Assinatura     : F_WMS_GETESTOQUEDOCA_PARC ( P_CODPROD IN NUMBER, P_CONTROLE
                  IN VARCHAR, P_CODEMP IN NUMBER, P_CODPARC IN NUMBER,
                  P_CODLOCAL IN NUMBER) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'F_WMS_GETESTOQUEDOCA_PARC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION F_WMS_GETESTOQUEDOCA_PARC (
  P_CODPROD IN NUMBER,
  P_CONTROLE IN VARCHAR,
  P_CODEMP IN NUMBER,
  P_CODPARC IN NUMBER,
  P_CODLOCAL IN NUMBER) RETURN FLOAT
IS
  R_ESTOQUE FLOAT;
BEGIN
  BEGIN
    SELECT SUM(ESTW.ESTOQUEVOLPAD) INTO R_ESTOQUE
    FROM TGWEST ESTW
    INNER JOIN TGWDCA DCA ON (DCA.CODEND = ESTW.CODEND)
    INNER JOIN TGFEMP EMP ON (EMP.CODEMP = P_CODEMP)
     INNER JOIN TGFEST EST ON (EST.CODEMP = ESTW.CODEMP AND ESTW.CODPROD = EST.CODPROD AND EST.CODPARC = ESTW.CODPARC AND ESTW.CONTROLE = EST.CONTROLE AND EST.CODLOCAL = P_CODLOCAL)
   WHERE DCA.TIPDOCA = 'E'
     AND ESTW.ESTOQUE > 0
     AND ESTW.CODPROD = P_CODPROD
     AND ESTW.CONTROLE = P_CONTROLE
     AND ESTW.CODEMP = P_CODEMP
     AND ESTW.CODPARC = P_CODPARC
     AND EST.CODLOCAL = NVL(EMP.WMSLOCALAJEST,0);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    R_ESTOQUE := 0;
  END;
  
  R_ESTOQUE := NVL(R_ESTOQUE,0);
  
  RETURN R_ESTOQUE;
END;
