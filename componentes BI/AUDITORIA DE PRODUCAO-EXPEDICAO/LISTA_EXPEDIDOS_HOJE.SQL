/*==============================================================================
  Nome do Script : LISTA_EXPEDIDOS_HOJE
  Tipo           : Componente BI — Tabela
  Dashboard      : AUDITORIA DE PRODUCAO-EXPEDICAO
  Componente     : LISTA_EXPEDIDOS_HOJE
  Descrição      : Lista os produtos que entraram na expedição/conferência
                   no dia de hoje, com quantidade apontada e conferente.

                   Regras de negócio:
                   - Somente apontamentos concluídos (APO.SITUACAO = 'C'),
                     mesmo padrão usado nos demais relatórios de produção.
                   - Data fixa em SYSDATE (não recebe parâmetro de data).

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TGFPRO, TSIUSU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Agosto/2026
  Última Revisão : Agosto/2026 — Criação inicial, baseado no P2
==============================================================================*/

SELECT  PRO.CODPROD
       ,PRO.DESCRPROD
       ,SUM(APA.QTDAPONTADA)                                              AS QTDEXPEDIDA
       ,APO.CODUSU || ' - ' || (SELECT NOMEUSU
                                   FROM TSIUSU
                                  WHERE CODUSU = APO.CODUSU)               AS CONFERENTE
  FROM  TPRAPA APA
        INNER JOIN TPRAPO  APO ON APA.NUAPO  = APO.NUAPO
        INNER JOIN TPRIATV TV  ON APO.IDIATV = TV.IDIATV
        INNER JOIN TPREFX  FX  ON TV.IDEFX   = FX.IDEFX
        INNER JOIN TGFPRO  PRO ON APA.CODPRODPA = PRO.CODPROD
 WHERE  APO.SITUACAO = 'C'
   AND  TRUNC(APO.DHAPO) = TRUNC(SYSDATE)
   AND  FX.DESCRICAO = 'EXPEDIÇÃO/CONFERENCIA'
 GROUP  BY
        PRO.CODPROD
       ,PRO.DESCRPROD
       ,APO.CODUSU
 ORDER  BY
        PRO.CODPROD
