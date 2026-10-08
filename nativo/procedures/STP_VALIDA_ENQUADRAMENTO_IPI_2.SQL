/*==============================================================================
  Nome do Script : STP_VALIDA_ENQUADRAMENTO_IPI_2
  Tipo           : Procedure Nativa Sankhya (referência — não customizada)
  Descrição      : Mesma validação de CST x enquadramento do IPI, mas só quando o enquadramento está preenchido (CODENQIPI <> 0). Versão chamada por TRG_INC_TGFITE.
  Empresa        : Spark Eletrônica
  Observações    : - Objeto nativo do ERP — atualizações do Sankhya podem sobrescrever; revisar após cada upgrade (nativo/README.md).
                   - No banco: criada em 01/07/2022, última alteração em 01/07/2022.
                   - Capturado do banco em 08/10/2026, via: SELECT DBMS_METADATA.GET_DDL('PROCEDURE', 'STP_VALIDA_ENQUADRAMENTO_IPI_2', 'SPARKPRD') FROM dual;
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "SPARKPRD"."STP_VALIDA_ENQUADRAMENTO_IPI_2" (P_CSTIPI     NUMBER, P_CODENQIPI     NUMBER)
AS
    P_ERRMSG    VARCHAR2(4000);
    ERROR       EXCEPTION;
BEGIN
    P_ERRMSG := ' ';
    IF NVL(P_CODENQIPI, 0) <> 0 THEN
        IF (P_CODENQIPI < 1 OR P_CODENQIPI > 999) THEN
            P_ERRMSG := 'Código de Enquadramento Legal do IPI deve ser vazio ou estar entre 1 e 999. ';
            RAISE ERROR;
        ELSIF NVL(P_CSTIPI, 0) IN (2, 52) AND (P_CODENQIPI IS NULL OR P_CODENQIPI < 301 OR P_CODENQIPI > 399) THEN
            P_ERRMSG := 'Código de Situação Tributária do IPI incompatível com o Código de Enquadramento Legal do IPI, '||
                                 'CST 02 (entrada) ou 52 (saída) deve possuir enquadramento de 301 a 399, para maiores '||
                                 'informações consulte a tabela de Código de Enquadramento Legal do IPI disponível na NT 2015 002 da NF-e.';
            RAISE ERROR;                     
        ELSIF NVL(P_CSTIPI, 0) IN (4, 54) AND (P_CODENQIPI IS NULL OR P_CODENQIPI < 1 OR P_CODENQIPI > 99) THEN
            P_ERRMSG := 'Código de Situação Tributária do IPI incompatível com o Código de Enquadramento Legal do IPI, '||
                                 'CST 04 (entrada) ou 54 (saída) deve possuir enquadramento de 001 a 099, para maiores '||
                                 'informações consulte a tabela de Código de Enquadramento Legal do IPI disponível na NT 2015 002 da NF-e.';
            RAISE ERROR;
        ELSIF NVL(P_CSTIPI, 0) IN (5, 55) AND (P_CODENQIPI IS NULL OR P_CODENQIPI < 101 OR P_CODENQIPI > 199) THEN
            P_ERRMSG := 'Código de Situação Tributária do IPI incompatível com o Código de Enquadramento Legal do IPI, '||
                                 'CST 05 (entrada) ou 55 (saída) deve possuir enquadramento de 101 a 199, para maiores '||
                                 'informações consulte a tabela de Código de Enquadramento Legal do IPI disponível na NT 2015 002 da NF-e.';
           RAISE ERROR;
        END IF;
    END IF;
EXCEPTION  WHEN ERROR THEN     
      RAISE_APPLICATION_ERROR(-20101, P_ERRMSG);    
END;
