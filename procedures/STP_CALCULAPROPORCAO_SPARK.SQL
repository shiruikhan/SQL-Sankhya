create or replace PROCEDURE STP_CALCULAPROPORCAO_SPARK AS 
    FIELD_RESULTADO NUMBER;
    FIELD_IDIMP NUMBER;
    FIELD_ANO NUMBER;
    FIELD_MES NUMBER;
/*==============================================================================
  Nome do Script : STP_CALCULAPROPORCAO_SPARK
  Descrição      : Realiza o cálculo da proporcionalidade do ICMS com base nas notas fiscais dos últimos 
  12 meses (excluindo o mês atual), agrupando por CFOP e registrando o índice calculado 
  na tabela AD_TGFPIM.
  Revisor        : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 02/10/2024
  Última Revisão : 23/04/2025 - Padronização e melhorias de legibilidade

  Observações:
* - Considera apenas empresas com CODEMP = 1.
* - Exclui notas com CODTIPOPER = 1114.
* - O cálculo é feito por: (SUM(BASEICMS) / (SUM(VLRNOTA) + SUM(BASEICMS))) * 100.
* - O ID do novo lançamento é obtido como MAX(IDIMP) + 1 da tabela AD_TGFPIM.
==============================================================================*/

BEGIN
    --REALIZA CALCULO DA PROPORCIONLIDADE
    SELECT (SUM(BASEICMS) / (SUM(VLRNOTA) + SUM(BASEICMS))) * 100 INTO FIELD_RESULTADO
    FROM (SELECT V.CODCFO,
                SUM(CASE WHEN CODCFO IN (7101,6109,7949) THEN V.VLRNOTA ELSE 0 END) AS VLRNOTA,
                SUM(CASE WHEN CODCFO IN (5101,5116,5151,5401,5910,6101,6107,6116,6118,6401,6910) THEN V.BASEICMS ELSE 0 END) AS BASEICMS  
            FROM (SELECT (SELECT MAX(I.CODCFO) FROM TGFITE I WHERE I.NUNOTA = CAB.NUNOTA) AS CODCFO,
                            CAB.BASEICMS AS BASEICMS,
                            CAB.VLRNOTA AS VLRNOTA
                        FROM TGFCAB CAB
                        WHERE CAB.DTNEG >= TRUNC(ADD_MONTHS(SYSDATE,-12 ), 'MM')
                            AND CAB.DTNEG <= LAST_DAY(ADD_MONTHS(SYSDATE,-1 ))
                            AND CAB.CODEMP = 1
                            AND CAB.CODTIPOPER <> 1114) V
        WHERE V.CODCFO IN (5101,5116,5151,5401,5910,6101,6107,6116,6118,6401,6910,7101,6109,7949)
        GROUP BY V.CODCFO);

    --CAPTURA DE INDICE PARA O NOVO LANÇAMENTO
    SELECT MAX(IDIMP) + 1 INTO FIELD_IDIMP
    FROM AD_TGFPIM;

    -- Captura ano e mês
    SELECT EXTRACT(YEAR FROM SYSDATE),
        EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE, -1))
    INTO FIELD_ANO,
        FIELD_MES
    FROM DUAL;

    --CRIAÇÃO DO NOVO INDICE DE PROPORCIONALIDADE NA TABELA
    INSERT INTO AD_TGFPIM (IDIMP,ANO,MES,ICMS) VALUES (FIELD_IDIMP,FIELD_ANO,FIELD_MES,FIELD_RESULTADO);

END;