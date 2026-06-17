/*==============================================================================
  Nome do Script : P1
  Tipo           : Componente BI — Tabela
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P1
  Descrição      : Detalha os processos/atividades de produção que tiveram
                   apontamento dentro do período informado, exibindo a
                   quantidade apontada, perdas e saldo a produzir.
                   O período (sobre APO.DHAPO) define quais linhas aparecem, de
                   forma idêntica nos dois modos de :P_FINAL — garantindo
                   resultado consistente entre 'S' e 'N'. Só entram atividades
                   com apontamento confirmado (SITUACAO='C') no período.

  Parâmetros     : :P_PERIODO    — período do apontamento (INI/FIN), aplicado
                                   sobre APO.DHAPO
                   :P_FINAL      — 'N' lista apenas atividades não finalizadas
                                   (TV.DHFINAL IS NULL); 'S' inclui também as
                                   finalizadas (TV.DHFINAL IS NOT NULL)
                   :P_STATUSPROC — status do processo (array)
                   :P_IDIPROD    — ID do processo de produção (opcional)
                   :P_CODPRC     — código do processo (array)

  Tabelas        : TPRIPROC, TPRPRC, TPRIPA, TPRIATV, TPREFX, TPRAPO, TPRAPA,
                   TGFPRO, TGFGRU

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: A DEFINIR
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
                   Junho/2026 — Refatoração total: a produção do período é
                   agregada por atividade numa subconsulta (TPRAPO/TPRAPA) e
                   ligada por INNER JOIN, de modo que o período (APO.DHAPO)
                   filtra as linhas igualmente para :P_FINAL 'S' e 'N'. O
                   :P_FINAL passa a controlar apenas a inclusão das atividades
                   finalizadas (TV.DHFINAL), eliminando a inconsistência
==============================================================================*/

SELECT *
FROM (
    SELECT  PRC.CODPRC                                            AS CODIGO
           ,PRC.DESCRABREV                                        AS DESCRICAO
           ,PROC.IDIPROC                                          AS IDIPROC
           ,TV.DHINCLUSAO                                         AS DTINICO
           ,TV.DHFINAL                                            AS DHFINAL
           ,PROC.DTPREVENT
           ,PROC.NROLOTE
           ,IPA.QTDPRODUZIR                                       AS TAMLOTE
           ,IPA.QTDPRODUZIR - (APT.QTDAPON + APT.QTDPERDA)        AS QTDPRODUZIR
           ,APT.QTDAPON
           ,APT.QTDPERDA
           ,PRO.CODPROD
           ,PRO.DESCRPROD
           ,CASE WHEN PRO.AD_LINHA = 1 THEN 'Linha 1'
                 WHEN PRO.AD_LINHA = 2 THEN 'Linha 2'
                 ELSE 'Linha N/E'
            END                                                   AS LINHA
           ,(SELECT DISTINCT G.DESCRGRUPOPROD
               FROM TGFGRU G
              WHERE G.CODGRUPOPROD = PRO.CODGRUPOPROD)            AS DESCRGRUPOPROD
           ,OPTION_LABEL('TPRIPROC','STATUSPROC',PROC.STATUSPROC) AS STATUSPROD
           ,EFX.DESCRICAO                                         AS ATIVIDADE
      FROM TPRIPROC PROC
           INNER JOIN TPRPRC  PRC ON PRC.IDPROC = PROC.IDPROC
           INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = PROC.IDIPROC
           INNER JOIN TPRIATV TV  ON TV.IDIPROC = PROC.IDIPROC
           INNER JOIN TPREFX  EFX ON EFX.IDEFX = TV.IDEFX
           INNER JOIN TGFPRO  PRO ON PRO.CODPROD = IPA.CODPRODPA
           INNER JOIN (
                  SELECT  APO.IDIATV
                         ,NVL(SUM(APA.QTDAPONTADA),0) AS QTDAPON
                         ,NVL(SUM(APA.QTDPERDA),0)    AS QTDPERDA
                    FROM TPRAPO APO
                         INNER JOIN TPRAPA APA ON APA.NUAPO = APO.NUAPO
                   WHERE APO.SITUACAO = 'C'
                     AND TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
                   GROUP BY APO.IDIATV
                ) APT ON APT.IDIATV = TV.IDIATV
     WHERE EFX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
       AND PROC.STATUSPROC IN :P_STATUSPROC
       AND (PROC.IDIPROC = :P_IDIPROD OR :P_IDIPROD IS NULL)
       AND (TV.DHFINAL IS NULL OR :P_FINAL = 'S')
       AND PRC.CODPRC IN :P_CODPRC
     ORDER BY PROC.DTPREVENT, PROC.NROLOTE
)
