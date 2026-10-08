/*==============================================================================
  Nome do Script : OBTEMCUSTO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o custo do produto (TGFCUS) na data, por
                  empresa/local/controle, conforme o tipo (reposicao, medio,
                  variavel etc.).
  Assinatura     : OBTEMCUSTO ( P_CODPROD IN NUMBER, P_POREMP IN CHAR, P_CODEMP
                  IN NUMBER, P_PORLOCAL IN CHAR, P_CODLOCAL IN NUMBER,
                  P_PORCONTROLE IN CHAR, P_CONTROLE IN VARCHAR2, P_DATA IN
                  DATE, P_TIPO IN NUMBER) RETURN FLOAT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'OBTEMCUSTO', 'SPARKPRD') FROM dual;
                  - Acentos aparecem como ? no DDL exportado; nao foi verificado
                    se o caractere esta corrompido no proprio banco ou apenas
                    na exportacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION OBTEMCUSTO (
  P_CODPROD IN NUMBER,
  P_POREMP IN CHAR,
  P_CODEMP IN NUMBER,
  P_PORLOCAL IN CHAR,
  P_CODLOCAL IN NUMBER,
  P_PORCONTROLE IN CHAR,
  P_CONTROLE IN VARCHAR2,
  P_DATA IN DATE,
  P_TIPO IN NUMBER)
RETURN FLOAT
IS  P_CUSREP          TGFCUS.CUSREP%TYPE;
    P_CUSGER          TGFCUS.CUSGER%TYPE;
    P_CUSVARIAVEL     TGFCUS.CUSVARIAVEL%TYPE;
    P_CUSSEMICM       TGFCUS.CUSSEMICM%TYPE;
    P_CUSMEDICM       TGFCUS.CUSMEDICM%TYPE;
    P_ENTRADASEMICMS  TGFCUS.ENTRADASEMICMS%TYPE;
    P_ENTRADACOMICMS  TGFCUS.ENTRADACOMICMS%TYPE;
BEGIN
  BEGIN  
    SELECT NVL(CUSREP,0), 
           NVL(CUSGER,0), 
           NVL(CUSVARIAVEL,0), 
           NVL(CUSSEMICM,0), 
           NVL(CUSMEDICM,0), 
           NVL(ENTRADASEMICMS,0), 
           NVL(ENTRADACOMICMS,0)
      INTO P_CUSREP, 
           P_CUSGER, 
           P_CUSVARIAVEL, 
           P_CUSSEMICM, 
           P_CUSMEDICM, 
           P_ENTRADASEMICMS, 
           P_ENTRADACOMICMS
      FROM TGFCUS
     WHERE CODPROD = P_CODPROD
       AND (P_PORCONTROLE  = 'N' OR CONTROLE = P_CONTROLE)
       AND (P_PORLOCAL = 'N' OR CODLOCAL = P_CODLOCAL)
       AND (P_POREMP = 'N' OR CODEMP = P_CODEMP)
       AND DTATUAL = (SELECT MAX(DTATUAL) FROM TGFCUS CN
                       WHERE CODPROD = P_CODPROD
                         AND DTATUAL <= P_DATA
                         AND (P_PORCONTROLE  = 'N' OR CONTROLE = P_CONTROLE)
                         AND (P_PORLOCAL = 'N' OR CODLOCAL = P_CODLOCAL)
                         AND (P_POREMP = 'N' OR CODEMP = P_CODEMP)
                     );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN 
    RAISE_APPLICATION_ERROR(-20101, ' O parametro EXIBRENTNOTACAC (Exibe rentabilidade na CAC) esta ligado! ERRO: N?o encontramos custo para o Produto ' || p_codprod || ', Empresa ' || P_CODEMP || ', Controle ' || P_CONTROLE || 'e Local ' || P_CODLOCAL || ' anterior ou igual a ' || p_data || '. N?o sera possivel mostrar analise de rentabilidade sem o custo.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20101, ' O parametro EXIBRENTNOTACAC (Exibe rentabilidade na CAC) esta ligado! ERRO: ' || SUBSTR(SQLERRM,1,200));
  END;

  IF P_TIPO = 0 THEN
    RETURN(P_CUSREP);
  ELSIF P_TIPO = 1 THEN
    RETURN(P_CUSGER);
  ELSIF P_TIPO = 2 THEN
    RETURN(P_CUSVARIAVEL);
  ELSIF P_TIPO = 3 THEN
    RETURN(P_CUSSEMICM);
  ELSIF P_TIPO = 4 THEN
    RETURN(P_CUSMEDICM);
  ELSIF P_TIPO = 5 THEN
    RETURN(P_ENTRADASEMICMS);
  ELSIF P_TIPO = 6 THEN
    RETURN(P_ENTRADACOMICMS);
  ELSE
    RETURN (0);
  END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN (0);
END;
