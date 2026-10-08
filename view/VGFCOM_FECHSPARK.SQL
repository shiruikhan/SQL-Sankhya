/*==============================================================================
  Nome do Script : VGFCOM_FECHSPARK
  Tipo           : View
  Descrição      : [A DOCUMENTAR]
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 14/03/2022, última alteração em 28/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "VGFCOM_FECHSPARK" ("CODEMP", "NUNOTAORIG", "FINNUFIN", "CODFORM", "DESCRFORM", "VLRCOM", "COMLIQ", "AD_COMBASE", "CODVEND", "TIPO", "CODPARC", "NOMEPARC", "NUNOTA", "NUMNOTA", "DESDOBRAMENTO", "DTVENC", "DHBAIXA", "VLRDESDOB", "VLRBAIXA", "NOSSONUM", "CODPARCVEN", "TIPCALC", "CODTIPTIT", "DHCONCILIACAO", "DTNEG", "DTMOV", "DTFATUR", "APELIDO", "CODCENCUSPAD", "COMISSAO", "CODTIPVENDA", "NUFINORIG", "DESCRNAT", "VLRDESC", "TAXA", "PERCCOM", "NUMOSORIG", "NUMITEMORIG", "POSICAO_QUERY", "DESCROPER", "TIPMOV", "CODEVENTO", "TIPINTEGRA", "TIPFATSERV", "INICEXEC", "NUFECHAMENTO") AS 
  SELECT                              /* comiss?o por negociac?o pela nota */
         CAB.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            0.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM,
            COM.VLRCOM AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            CAB.SERIENOTA AS DESDOBRAMENTO,
            CAB.DTNEG AS DTVENC,
            CAB.DTNEG AS DHBAIXA,
            (CAB.VLRNOTA
             + CASE
                  WHEN (SELECT   LOGICO
                          FROM   TSIPAR
                         WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                  THEN
                     CAB.VLROUTROS
                  ELSE
                     0
               END)
               AS VLRDESDOB,
            (CAB.VLRNOTA
             + CASE
                  WHEN (SELECT   LOGICO
                          FROM   TSIPAR
                         WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                  THEN
                     CAB.VLROUTROS
                  ELSE
                     0
               END)
               AS VLRBAIXA,
            CAST ('   ' AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            0.0 AS CODTIPTIT,
            CAB.DTNEG AS DHCONCILIACAO,
            CAB.DTNEG AS DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NAT.DESCRNAT,
            0.00 AS VLRDESC,
            0.00 AS TAXA,
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CAB.VLRNOTA
               + CASE
                    WHEN (SELECT   LOGICO
                            FROM   TSIPAR
                           WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                    THEN
                       CAB.VLROUTROS
                    ELSE
                       0
                 END)
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '1' AS POSICAO_QUERY,
            NULL AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            '' AS TIPFATSERV,
            SYSDATE AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB CAB,
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT
    WHERE       EXISTS (SELECT   1
                          FROM   TGFVEN
                         WHERE   TIPCALC = 'N')
            AND COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = 0
            AND COM.NUNOTAORIG = CAB.NUNOTA
            AND CAB.CODPARC = PAR.CODPARC
            AND VEN.TIPCALC = 'N'
            AND VEN.CODPARC <> 0
            AND CAB.CODNAT = NAT.CODNAT
            AND COM.TIPO <> 'S'
   UNION ALL
   SELECT                        /* comiss?o por negociac?o pelo financeiro */
         FIN.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            FIN.NUFIN * 1.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM,
            COM.VLRCOM AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            FIN.NUNOTA * 1.0 AS NUNOTA,
            FIN.NUMNOTA * 1.0 AS NUMNOTA,
            FIN.DESDOBRAMENTO,
            FIN.DTVENC,
            FIN.DHBAIXA AS DHBAIXA,
            FIN.VLRDESDOB,
            FIN.VLRBAIXA,
            CAST (FIN.NOSSONUM AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC AS TIPCALC,
            FIN.CODTIPTIT * 1.0 AS CODTIPTIT,
            MBC.DHCONCILIACAO,
            FIN.DTNEG AS DTNEG,
            FIN.DHMOV AS DTMOV,
            FIN.DTNEG AS DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            0.0 AS COMISSAO,
            0.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NAT.DESCRNAT,
            FIN.VLRDESC,
            FIN.CARTAODESC AS TAXA,
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / FIN.VLRDESDOB
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '2' AS POSICAO_QUERY,
            NULL AS DESCROPER,
            'F' AS TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            '' AS TIPFATSERV,
            SYSDATE AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
               TGFFIN FIN
            LEFT JOIN
               TGFMBC MBC
            ON (FIN.NUBCO = MBC.NUBCO),
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = FIN.NUFIN
            AND COM.NUNOTAORIG = 0
            AND FIN.CODPARC = PAR.CODPARC
            AND VEN.CODPARC <> 0
            AND FIN.RECDESP <> 0
            AND FIN.CODNAT = NAT.CODNAT
            AND COM.TIPO <> 'S'
   UNION ALL
   SELECT                             /* comiss?o por Baixa N?O Renegociada */
         FIN.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            FIN.NUFIN * 1.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM * 1.0 AS VLRCOM,
            CASE
               WHEN FIN.CODTIPOPER = 11
               THEN
                  NVL (FIN.AD_VLRCOMIMP, 0)
               ELSE
                  (SELECT   SUM (C1.VLRCOM)
                     FROM   TGFCOM C1
                    WHERE       C1.CODVEND = COM.CODVEND
                            --AND C1.CODEMP = COM.CODEMP
                            AND C1.NUNOTAORIG = COM.NUNOTAORIG
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO
                            AND C1.CODFORM = COM.CODFORM)
            END
            * CASE
                 WHEN FIN.CODTIPOPER = 11
                 THEN
                    1
                 ELSE
                    ( (FIN.VLRDESDOB
                       - CASE
                            WHEN FIN.CODEMP = 501
                                 AND FIN.DESDOBRAMENTO IN ('0', '1')
                            THEN
                               NVL (CAB.AD_VLROUTROSFRETE, 0)
                            ELSE
                               0
                         END
                       - CASE
                            WHEN FIN.CODEMP = 1
                                 AND FIN.DESDOBRAMENTO IN ('0', '1')
                            THEN
                               CAB.VLRIPI + CAB.VLRSUBST
                               + CASE
                                    WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE
                                    ELSE 0
                                 END
                            ELSE
                               0
                         END)
                     / (CAB.VLRNOTA + NVL (CAB.VLROUTROS, 0)
                        - (CAB.VLRSUBST + CAB.VLRIPI
                           + CASE
                                WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE
                                ELSE 0
                             END)))
              END
               AS COMLIQ,
            (CAB.VLRNOTA + NVL (CAB.VLROUTROS, 0)
             - (  CAB.VLRSUBST
                + CAB.VLRIPI
                + CASE WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE ELSE 0 END))
               AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            FIN.DESDOBRAMENTO,
            FIN.DTVENC,
            FIN.DHBAIXA AS DHBAIXA,
            FIN.VLRDESDOB,
            FIN.VLRBAIXA,
            CAST (FIN.NOSSONUM AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            FIN.CODTIPTIT * 1.0 AS CODTIPTIT,
            MBC.DHCONCILIACAO,
            CAB.DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFIN * 1.0 AS NUFINORIG,--PERSONALIZEI PARA PEGAR O  TÍTULO DESPESA AGRUPADO A PAGAR COMISSÃO
            NAT.DESCRNAT,
            FIN.VLRDESC,
            FIN.CARTAODESC AS TAXA,
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CASE
                  WHEN FIN.CODTIPOPER = 11 THEN FIN.VLRDESDOB
                  ELSE CAB.VLRNOTA
               END
               - (  CAB.VLRIPI
                  + VLRSUBST
                  + CASE WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE ELSE 0 END)
               + CAB.VLROUTROS)
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '3' AS POSICAO_QUERY,
            TPO.DESCROPER AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            TPO.TIPFATSERV AS TIPFATSERV,
            SYSDATE AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB CAB,
               TGFFIN FIN
            LEFT JOIN
               TGFMBC MBC
            ON (FIN.NUBCO = MBC.NUBCO),
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT,
            TGFTOP TPO
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            -- AND COM.NUFINORIG > 0
            -- AND COM.NUFIN > 0
            AND COM.NUFINORIG > 0 -- DIONE, COLOQUEI PARA FICAR COMO ESTAVA NO PADRÃO 07/03/2022
            AND COM.NUFIN > 0 --DIONE, COLOQUEI PARA FICAR COMO ESTAVA NO PADRÃO 07/03/2022
            -- AND COM.REFERENCIA IS NOT NULL
            -- AND COM.NUFECHAMENTO > 0
            AND COM.REFERENCIA IS NOT NULL
            AND COM.NUFECHAMENTO >  0 --DIONE, COLOQUEI PARA FICAR COMO ESTAVA NO PADRÃO 07/03/2022
            AND COM.NUNOTAORIG = CAB.NUNOTA
            AND COM.NUNOTAORIG = FIN.NUNOTA
            AND (FIN.DESDOBDUPL IS NULL
                 OR FIN.DESDOBDUPL NOT IN ('M', 'V', 'K', 'F', 'T'))
          /*  AND NOT EXISTS ---- TRECHO COMENTADO POR JOÃO AMARAL EM 02/03/2022: OBJETIVO É PERMITIR QUE OS REGISTROS DE COMISSÃO FECHADOS APAREÇAM NA VIEW E CONSEQUENTEMENTE NO RELATÓRIO.
                  (SELECT   1
                     FROM   TGFCOM C1
                    WHERE       C1.CODVEND = COM.CODVEND
                            AND C1.NUFINORIG = FIN.NUFIN
                            AND C1.NUNOTAORIG = CAB.NUNOTA
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO) */
            AND CAB.CODPARC = PAR.CODPARC
            AND (CAB.VLRNOTA
                 + CASE
                      WHEN (SELECT   LOGICO
                              FROM   TSIPAR
                             WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                      THEN
                         CAB.VLROUTROS
                      ELSE
                         0
                   END) <> 0
            AND VEN.CODPARC <> 0
            AND (VEN.TIPCALC = 'B')
            AND FIN.RECDESP <> 0
            AND FIN.NURENEG IS NULL
            AND FIN.CODNAT = NAT.CODNAT
            AND CAB.CODTIPOPER = TPO.CODTIPOPER
            AND CAB.DHTIPOPER = TPO.DHALTER
            AND COM.TIPO <> 'S'
            AND COM.CODFORM > 0 -- ESTAVA DUPLICANDO NA COM, TRAZENDO FORMULA ZERO
   UNION ALL
   SELECT                                 /* comiss?o por Baixa Renegociada */
         CAB.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            FIN.NUFIN * 1.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM,
           /* ( (SELECT   SUM (C1.VLRCOM)
                 FROM   TGFCOM C1
                WHERE       C1.CODVEND = COM.CODVEND
                        AND C1.NUNOTAORIG = COM.NUNOTAORIG
                        AND C1.NUMOSORIG = COM.NUMOSORIG
                        AND C1.NUMITEMORIG = COM.NUMITEMORIG
                        AND C1.TIPO = COM.TIPO
                        AND C1.CODFORM = COM.CODFORM)
             * (TMP.VLRDESDOB
                / (CAB.VLRNOTA
                   + CASE
                        WHEN (SELECT   LOGICO
                                FROM   TSIPAR
                               WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                        THEN
                           CAB.VLROUTROS
                        ELSE
                           0
                     END))) */
                     CASE
               WHEN FIN.CODTIPOPER = 11
               THEN
                  NVL (FIN.AD_VLRCOMIMP, 0)
               ELSE
                  (SELECT   SUM (C1.VLRCOM)
                     FROM   TGFCOM C1
                    WHERE       C1.CODVEND = COM.CODVEND
                            --AND C1.CODEMP = COM.CODEMP
                            AND C1.NUNOTAORIG = COM.NUNOTAORIG
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO
                            AND C1.CODFORM = COM.CODFORM)
            END
            * CASE
                 WHEN FIN.CODTIPOPER = 11
                 THEN
                    1
                 ELSE
                    ( (FIN.VLRDESDOB
                       - CASE
                            WHEN FIN.CODEMP = 501
                                 AND FIN.DESDOBRAMENTO IN ('0', '1')
                            THEN
                               NVL (CAB.AD_VLROUTROSFRETE, 0)
                            ELSE
                               0
                         END
                       - CASE
                            WHEN FIN.CODEMP = 1
                                 AND FIN.DESDOBRAMENTO IN ('0', '1')
                            THEN
                               CAB.VLRIPI + CAB.VLRSUBST
                               + CASE
                                    WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE
                                    ELSE 0
                                 END
                            ELSE
                               0
                         END)
                     / (CAB.VLRNOTA + NVL (CAB.VLROUTROS, 0)
                        - (CAB.VLRSUBST + CAB.VLRIPI
                           + CASE
                                WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE
                                ELSE 0
                             END)))
              END                     
               AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            FIN.DESDOBRAMENTO,
            FIN.DTVENC,
            FIN.DHBAIXA AS DHBAIXA,
            TMP.VLRDESDOB,
            TMP.VLRDESDOB / FIN.VLRDESDOB * FIN.VLRBAIXA AS VLRBAIXA,
            CAST (FIN.NOSSONUM AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            FIN.CODTIPTIT * 1.0 AS CODTIPTIT,
            MBC.DHCONCILIACAO AS DHCONCILIACAO,
            CAB.DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFIN * 1.0 AS NUFINORIG, --PERSONALIZEI PARA PEGAR FINANCEIRO DESPESA GRUPADO COMISSÃO 
            NAT.DESCRNAT,
            TMP.VLRDESDOB / FIN.VLRDESDOB * FIN.VLRDESC AS VLRDESC,
            TMP.VLRDESDOB / FIN.VLRDESDOB * FIN.CARTAODESC AS TAXA,
            /*(SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CAB.VLRNOTA
               + CASE
                    WHEN (SELECT   LOGICO
                            FROM   TSIPAR
                           WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                    THEN
                       CAB.VLROUTROS
                    ELSE
                       0
                 END)
            * 100.0 */
            
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CASE
                  WHEN FIN.CODTIPOPER = 11 THEN FIN.VLRDESDOB
                  ELSE CAB.VLRNOTA
               END
               - (  CAB.VLRIPI
                  + VLRSUBST
                  + CASE WHEN CAB.TIPFRETE = 'S' THEN CAB.VLRFRETE ELSE 0 END)
               + CAB.VLROUTROS)
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '4' AS POSICAO_QUERY,
            TPO.DESCROPER AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            TPO.TIPFATSERV AS TIPFATSERV,
            SYSDATE AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB CAB,
            TGFREN_TEMP TMP,
               TGFFIN FIN
            LEFT JOIN
               TGFMBC MBC
            ON FIN.NUBCO = MBC.NUBCO,
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT,
            TGFTOP TPO
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN > 0
            AND COM.REFERENCIA IS NOT NULL
            AND COM.NUFECHAMENTO > 0
            AND COM.NUFINORIG > 0
            AND COM.NUNOTAORIG = CAB.NUNOTA
            AND COM.NUNOTAORIG = TMP.NUNOTA
            AND TMP.NUFIN = FIN.NUFIN
            /*AND NOT EXISTS
                  (SELECT   1
                     FROM   TGFCOM C1
                    WHERE       C1.CODVEND = COM.CODVEND
                            AND C1.NUFINORIG = FIN.NUFIN
                            AND C1.NUNOTAORIG = CAB.NUNOTA
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO) */
            AND CAB.CODPARC = PAR.CODPARC
            AND (CAB.VLRNOTA
                 + CASE
                      WHEN (SELECT   LOGICO
                              FROM   TSIPAR
                             WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                      THEN
                         CAB.VLROUTROS
                      ELSE
                         0
                   END) <> 0
            AND VEN.CODPARC <> 0
            AND (VEN.TIPCALC = 'B')
            AND FIN.RECDESP <> 0
            AND FIN.NURENEG IS NOT NULL
            AND FIN.CODNAT = NAT.CODNAT
            AND CAB.CODTIPOPER = TPO.CODTIPOPER
            AND CAB.DHTIPOPER = TPO.DHALTER
            AND COM.TIPO <> 'S'
   UNION ALL
   SELECT                                 /* comissao por Negociac?o por OS */
         CAB.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            0.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM,
            COM.VLRCOM AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            CAB.SERIENOTA AS DESDOBRAMENTO,
            ITE.INICEXEC AS DTVENC,
            ITE.INICEXEC AS DHBAIXA,
            (CAB.VLRNOTA
             + CASE
                  WHEN (SELECT   LOGICO
                          FROM   TSIPAR
                         WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                  THEN
                     CAB.VLROUTROS
                  ELSE
                     0
               END)
               AS VLRDESDOB,
            (CAB.VLRNOTA
             + CASE
                  WHEN (SELECT   LOGICO
                          FROM   TSIPAR
                         WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                  THEN
                     CAB.VLROUTROS
                  ELSE
                     0
               END)
               AS VLRBAIXA,
            CAST ('   ' AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            0.0 AS CODTIPTIT,
            ITE.INICEXEC AS DHCONCILIACAO,
            CAB.DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NAT.DESCRNAT,
            0.00 AS VLRDESC,
            0.00 AS TAXA,
            CASE
               WHEN CAB.VLRNOTA = 0
               THEN
                  100
               ELSE
                  (SELECT   SUM (C1.VLRCOM)
                     FROM   TGFCOM C1
                    WHERE       C1.CODVEND = COM.CODVEND
                            AND C1.NUNOTAORIG = COM.NUNOTAORIG
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO
                            AND C1.CODFORM = COM.CODFORM)
                  / (CAB.VLRNOTA
                     + CASE
                          WHEN (SELECT   LOGICO
                                  FROM   TSIPAR
                                 WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                          THEN
                             CAB.VLROUTROS
                          ELSE
                             0
                       END)
            END
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '5' AS POSICAO_QUERY,
            TPO.DESCROPER AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            TPO.TIPFATSERV AS TIPFATSERV,
            ITE.INICEXEC AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB CAB,
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT,
            TCSITE ITE,
            TGFTOP TPO
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = 0
            AND COM.NUNOTAORIG = CAB.NUNOTA
            AND CAB.CODPARC = PAR.CODPARC
            AND ( (VEN.TIPCALC = 'N')
                 OR (TPO.TIPFATSERV IN ('N', 'P') AND TPO.ATUALCOMOS = 'S'))
            AND VEN.CODPARC <> 0
            AND CAB.CODNAT = NAT.CODNAT
            AND COM.TIPO = 'S'
            AND COM.NUMOSORIG = ITE.NUMOS
            AND COM.NUMITEMORIG = ITE.NUMITEM
            AND CAB.CODTIPOPER = TPO.CODTIPOPER
            AND CAB.DHTIPOPER = TPO.DHALTER
   UNION ALL
   SELECT                                          /* comiss?o por Contrato */
         0.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            0.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM,
            COM.VLRCOM AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            0.0 AS NUNOTA,
            0.0 AS NUMNOTA,
            NULL AS DESDOBRAMENTO,
            ITE.INICEXEC AS DTVENC,
            ITE.INICEXEC AS DHBAIXA,
            0.0 AS VLRDESDOB,
            0.0 AS VLRBAIXA,
            CAST ('   ' AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            'N' AS TIPCALC,
            0.0 AS CODTIPTIT,
            ITE.INICEXEC AS DHCONCILIACAO,
            ITE.INICEXEC AS DTNEG,
            ITE.INICEXEC AS DTMOV,
            ITE.INICEXEC AS DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            0.0 AS COMISSAO,
            0.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NULL AS DESCRNAT,
            0.00 AS VLRDESC,
            0.00 AS TAXA,
            100.0 AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '6' AS POSICAO_QUERY,
            'CONTRATO' AS DESCROPER,
            'X',
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            '' AS TIPFATSERV,
            ITE.INICEXEC AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFPAR PAR,
            TGFVEN VEN,
            TCSITE ITE,
            TCSOSE OSE
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = 0
            AND COM.NUNOTAORIG = 0
            AND COM.NUMOSORIG = ITE.NUMOS
            AND COM.NUMITEMORIG = ITE.NUMITEM
            AND COM.NUMOSORIG = OSE.NUMOS
            AND OSE.CODPARC = PAR.CODPARC
            AND VEN.CODPARC <> 0
            AND COM.TIPO = 'S'
   UNION ALL
   SELECT                      /* comiss?o por Baixa N?O Renegociada por OS */
         CAB.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            FIN.NUFIN * 1.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM * 1.0 AS VLRCOM,
            ( (SELECT   SUM (C1.VLRCOM)
                 FROM   TGFCOM C1
                WHERE       C1.CODVEND = COM.CODVEND
                        AND C1.NUNOTAORIG = COM.NUNOTAORIG
                        AND C1.NUMOSORIG = COM.NUMOSORIG
                        AND C1.NUMITEMORIG = COM.NUMITEMORIG
                        AND C1.TIPO = COM.TIPO
                        AND C1.CODFORM = COM.CODFORM)
             * (FIN.VLRDESDOB
                / (CAB.VLRNOTA
                   + CASE
                        WHEN (SELECT   LOGICO
                                FROM   TSIPAR
                               WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                        THEN
                           CAB.VLROUTROS
                        ELSE
                           0
                     END)))
               AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            FIN.DESDOBRAMENTO,
            FIN.DTVENC,
            FIN.DHBAIXA AS DHBAIXA,
            FIN.VLRDESDOB,
            FIN.VLRBAIXA,
            CAST (FIN.NOSSONUM AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            FIN.CODTIPTIT * 1.0 AS CODTIPTIT,
            MBC.DHCONCILIACAO,
            CAB.DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NAT.DESCRNAT,
            FIN.VLRDESC,
            FIN.CARTAODESC AS TAXA,
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CAB.VLRNOTA
               + CASE
                    WHEN (SELECT   LOGICO
                            FROM   TSIPAR
                           WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                    THEN
                       CAB.VLROUTROS
                    ELSE
                       0
                 END)
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '7' AS POSICAO_QUERY,
            TPO.DESCROPER AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            TPO.TIPFATSERV AS TIPFATSERV,
            ITE.INICEXEC AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB PED,
            TGFCAB CAB,
               TGFFIN FIN
            LEFT JOIN
               TGFMBC MBC
            ON (FIN.NUBCO = MBC.NUBCO),
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT,
            TGFTOP TPO,
            VGFVARDIF VAR,
            TCSITE ITE
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = 0
            AND COM.NUNOTAORIG = PED.NUNOTA
            AND VAR.NUNOTAORIG = PED.NUNOTA
            AND VAR.NUNOTA <> VAR.NUNOTAORIG
            AND VAR.NUNOTA = FIN.NUNOTA
            AND VAR.NUNOTA = CAB.NUNOTA
            AND NOT EXISTS
                  (SELECT   1
                     FROM   TGFCOM C1
                    WHERE   C1.CODVEND = COM.CODVEND
                            AND C1.NUFINORIG = FIN.NUFIN
                            AND (C1.NUNOTAORIG = PED.NUNOTA
                                 OR C1.NUNOTAORIG = CAB.NUNOTA)
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO)
            AND CAB.CODPARC = PAR.CODPARC
            AND (CAB.VLRNOTA
                 + CASE
                      WHEN (SELECT   LOGICO
                              FROM   TSIPAR
                             WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                      THEN
                         CAB.VLROUTROS
                      ELSE
                         0
                   END) <> 0
            AND PED.CODTIPOPER = TPO.CODTIPOPER
            AND PED.DHTIPOPER = TPO.DHALTER
            AND VEN.CODPARC <> 0
            AND COM.TIPO = 'S'
            AND TPO.ATUALCOMOS = 'S'
            AND FIN.RECDESP <> 0
            AND FIN.NURENEG IS NULL
            AND FIN.CODNAT = NAT.CODNAT
            AND TPO.TIPFATSERV IN ('A', 'F', 'S', 'U')
            AND (TPO.TIPFATSERV <> 'A'
                 OR EXISTS
                      (SELECT   1
                         FROM   TCSFAT FAT
                        WHERE       FAT.NUMOS = COM.NUMOSORIG
                                AND FAT.NUMITEM = COM.NUMITEMORIG
                                AND FAT.NUNOTA = CAB.NUNOTA
                                AND (FAT.ORIGEM IS NULL OR FAT.ORIGEM <> 'C')))
            AND COM.NUMOSORIG = ITE.NUMOS
            AND COM.NUMITEMORIG = ITE.NUMITEM
            AND VEN.TIPCALC = 'B'
   UNION ALL
   SELECT                          /* comiss?o por Baixa Renegociada por OS */
         CAB.CODEMP * 1.0 AS CODEMP,
            COM.NUNOTAORIG * 1.0 AS NUNOTAORIG,
            FIN.NUFIN * 1.0 AS FINNUFIN,
            COM.CODFORM * 1.0 AS CODFORM,
            FOC.DESCRFORM,
            COM.VLRCOM * 1.0 AS VLRCOM,
            ( (SELECT   SUM (C1.VLRCOM)
                 FROM   TGFCOM C1
                WHERE       C1.CODVEND = COM.CODVEND
                        AND C1.NUNOTAORIG = COM.NUNOTAORIG
                        AND C1.NUMOSORIG = COM.NUMOSORIG
                        AND C1.NUMITEMORIG = COM.NUMITEMORIG
                        AND C1.TIPO = COM.TIPO
                        AND C1.CODFORM = COM.CODFORM)
             * (FIN.VLRDESDOB
                / (CAB.VLRNOTA
                   + CASE
                        WHEN (SELECT   LOGICO
                                FROM   TSIPAR
                               WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                        THEN
                           CAB.VLROUTROS
                        ELSE
                           0
                     END)))
               AS COMLIQ,
            0 AS COMBASE,
            COM.CODVEND * 1.0 AS CODVEND,
            COM.TIPO,
            PAR.CODPARC * 1.0 AS CODPARC,
            PAR.NOMEPARC,
            CAB.NUNOTA * 1.0 AS NUNOTA,
            CAB.NUMNOTA * 1.0 AS NUMNOTA,
            FIN.DESDOBRAMENTO,
            FIN.DTVENC,
            FIN.DHBAIXA,
            FIN.VLRDESDOB,
            FIN.VLRBAIXA,
            CAST (FIN.NOSSONUM AS VARCHAR (12)) AS NOSSONUM,
            VEN.CODPARC * 1.0 AS CODPARCVEN,
            VEN.TIPCALC,
            FIN.CODTIPTIT * 1.0 AS CODTIPTIT,
            MBC.DHCONCILIACAO,
            CAB.DTNEG,
            CAB.DTMOV,
            CAB.DTFATUR,
            VEN.APELIDO,
            VEN.CODCENCUSPAD * 1.0 AS CODCENCUSPAD,
            CAB.COMISSAO * 1.0 AS COMISSAO,
            CAB.CODTIPVENDA * 1.0 AS CODTIPVENDA,
            COM.NUFINORIG * 1.0 AS NUFINORIG,
            NAT.DESCRNAT,
            FIN.VLRDESC,
            FIN.CARTAODESC AS TAXA,
            (SELECT   SUM (C1.VLRCOM)
               FROM   TGFCOM C1
              WHERE       C1.CODVEND = COM.CODVEND
                      AND C1.NUNOTAORIG = COM.NUNOTAORIG
                      AND C1.NUMOSORIG = COM.NUMOSORIG
                      AND C1.NUMITEMORIG = COM.NUMITEMORIG
                      AND C1.TIPO = COM.TIPO
                      AND C1.CODFORM = COM.CODFORM)
            / (CAB.VLRNOTA
               + CASE
                    WHEN (SELECT   LOGICO
                            FROM   TSIPAR
                           WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                    THEN
                       CAB.VLROUTROS
                    ELSE
                       0
                 END)
            * 100.0
               AS PERCCOM,
            COM.NUMOSORIG * 1.0 AS NUMOSORIG,
            COM.NUMITEMORIG * 1.0 AS NUMITEMORIG,
            '8' AS POSICAO_QUERY,
            TPO.DESCROPER AS DESCROPER,
            CAB.TIPMOV,
            FOC.CODEVENTO * 1.0 AS CODEVENTO,
            FOC.TIPINTEGRA,
            TPO.TIPFATSERV AS TIPFATSERV,
            ITE.INICEXEC AS INICEXEC,
            COM.NUFECHAMENTO
     FROM   TGFCOM COM,
            TGFFOC FOC,
            TGFCAB PED,
            TGFCAB CAB,
            TGFREN_TEMP TMP,
            TGFFIN FIN,
            TGFMBC MBC,
            TGFPAR PAR,
            TGFVEN VEN,
            TGFNAT NAT,
            TGFTOP TPO,
            VGFVARDIF VAR,
            TCSITE ITE
    WHERE       COM.CODVEND = VEN.CODVEND
            AND COM.CODFORM = FOC.CODFORM
            AND COM.NUFIN = 0
            AND COM.REFERENCIA IS NULL
            AND COM.NUFECHAMENTO = 0
            AND COM.NUFINORIG = 0
            AND COM.NUNOTAORIG = PED.NUNOTA
            AND VAR.NUNOTAORIG = PED.NUNOTA
            AND VAR.NUNOTA <> VAR.NUNOTAORIG
            AND VAR.NUNOTA = TMP.NUNOTA
            AND VAR.NUNOTA = CAB.NUNOTA
            AND TMP.NUFIN = FIN.NUFIN
            AND NOT EXISTS
                  (SELECT   1
                     FROM   TGFCOM C1
                    WHERE   C1.CODVEND = COM.CODVEND
                            AND C1.NUFINORIG = FIN.NUFIN
                            AND (C1.NUNOTAORIG = PED.NUNOTA
                                 OR C1.NUNOTAORIG = CAB.NUNOTA)
                            AND C1.NUMOSORIG = COM.NUMOSORIG
                            AND C1.NUMITEMORIG = COM.NUMITEMORIG
                            AND C1.TIPO = COM.TIPO)
            AND CAB.CODPARC = PAR.CODPARC
            AND (CAB.VLRNOTA
                 + CASE
                      WHEN (SELECT   LOGICO
                              FROM   TSIPAR
                             WHERE   CHAVE = 'GOL-SOMAOUTROS') = 'S'
                      THEN
                         CAB.VLROUTROS
                      ELSE
                         0
                   END) <> 0
            AND PED.CODTIPOPER = TPO.CODTIPOPER
            AND PED.DHTIPOPER = TPO.DHALTER
            AND VEN.CODPARC <> 0
            AND COM.TIPO = 'S'
            AND TPO.ATUALCOMOS = 'S'
            AND FIN.RECDESP <> 0
            AND FIN.NURENEG IS NOT NULL
            AND FIN.CODNAT = NAT.CODNAT
            AND FIN.NUBCO = MBC.NUBCO
            AND TPO.TIPFATSERV IN ('A', 'F', 'S', 'U')
            AND (TPO.TIPFATSERV <> 'A'
                 OR EXISTS
                      (SELECT   1
                         FROM   TCSFAT FAT
                        WHERE       FAT.NUMOS = COM.NUMOSORIG
                                AND FAT.NUMITEM = COM.NUMITEMORIG
                                AND FAT.NUNOTA = CAB.NUNOTA
                                AND (FAT.ORIGEM IS NULL OR FAT.ORIGEM <> 'C')))
            AND COM.NUMOSORIG = ITE.NUMOS
            AND COM.NUMITEMORIG = ITE.NUMITEM
            AND VEN.TIPCALC = 'B';
