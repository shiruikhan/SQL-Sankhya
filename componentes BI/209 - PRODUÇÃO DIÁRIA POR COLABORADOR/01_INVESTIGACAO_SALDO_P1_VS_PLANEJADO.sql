/*==============================================================================
  Nome do Script : 01_INVESTIGACAO_SALDO_P1_VS_PLANEJADO
  Tipo           : Script de Diagnóstico / Investigação
  Descrição      : Investiga por que o saldo a produzir do p1.sql (Componente
                   BI "PRODUÇÃO DIÁRIA POR COLABORADOR") não bate com o total
                   de PLANEJADO_ESTOQUE do componente
                   "PLANEJAMENTO DE ESTOQUE DE PRODUCAO.SQL", antes de decidir
                   como incluir em p1.sql as atividades sem apontamento.

                   Duas hipóteses em jogo:
                   1) FAN-OUT: p1.sql liga TPRIPA e TPRIATV ao processo só por
                      IDIPROC, sem chave entre si — se um processo tem mais de
                      1 item de lote (IPA) ou mais de 1 atividade (TV), a
                      junção gera produto cartesiano e TAMLOTE é contado mais
                      de uma vez ao somar QTDPRODUZIR entre atividades.
                   2) FONTE DIFERENTE: p1.sql deduz o que "já foi produzido"
                      via apontamento de chão de fábrica (TPRAPO/TPRAPA,
                      recortado por :P_PERIODO); PLANEJADO_ESTOQUE deduz via
                      nota fiscal de fabricação já lançada em estoque
                      (TGFCAB/TGFITE, TIPMOV='F'), sem recorte de período —
                      são fatos e datas de corte diferentes, mesmo corrigindo
                      o fan-out.

                   Pronto para rodar direto em qualquer cliente Oracle
                   (SQL Developer, DBeaver etc.) — sem bind variables, todos
                   os parâmetros já vêm como literais de teste (BLOCO 0).
                   Execute cada bloco separadamente.

  Tabelas        : TPRIPROC, TPRPRC, TPRIPA, TPRIATV, TPREFX, TPRAPO, TPRAPA,
                   TGFCAB, TGFITE

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Setembro/2026
  Última Revisão : Setembro/2026 — Criação inicial e execução completa (ver
                   conclusão abaixo). Investigação encerrada — não perseguir
                   mais reconciliação entre estes dois totais.

  CONCLUSÃO (21/09/2026, valores reais de produção):
                   BLOCO 1 — Fan-out confirmado: >140 processos com
                   QTD_ITENS_LOTE=1 e várias atividades (até 14) por processo.
                   BLOCO 2 — Efeito do fan-out isolado: TAMLOTE somado sem
                   duplicação = 49.373; somado como o p1.sql faz hoje =
                   128.752 (~2,6x inflado).
                   BLOCO 3 — Apontamento (chão de fábrica) é sistematicamente
                   maior que entrega fiscal (NF de fabricação) por processo —
                   confirma que são fatos de negócio diferentes.
                   BLOCO 4 — Mesmo corrigindo o fan-out, o "saldo P1" via
                   apontamento deu -12.291 (negativo) contra 17.506 do
                   PLANEJADO_ESTOQUE — sinais opostos, não só escalas
                   diferentes.
                   CAUSA RAIZ: TPRIATV representa ETAPAS SEQUENCIAIS do mesmo
                   lote (inserção → solda → teste → ...), não quantidades
                   independentes. A mesma peça física é apontada uma vez por
                   etapa que já passou. Somar QTDPRODUZIR/apontamento entre
                   atividades do mesmo processo conta a mesma peça várias
                   vezes — não é bug de join, é a semântica do dado.
                   PLANEJADO_ESTOQUE não sofre disso porque deduz por entrega
                   fiscal (evento único por unidade), não por etapa.
                   DECISÃO: não reconciliar. Aceitar que p1.sql (progresso de
                   chão de fábrica por etapa) e PLANEJAMENTO DE ESTOQUE DE
                   PRODUCAO (saldo fiscal por lote) medem coisas
                   estruturalmente diferentes. Ver memória de projeto
                   "apontamento-por-etapa-nao-e-quantidade" para o mesmo
                   raciocínio aplicado a outros relatórios futuros.

  Observações    : Script de investigação pontual — não é componente BI, não
                   recebe bind variables do gadget; os parâmetros abaixo já
                   estão fixados como literais para permitir execução direta
                   via SGBD. Deliberadamente NÃO aplica o recorte de
                   :P_PERIODO do p1.sql (soma apontamento de todo o histórico)
                   para isolar os efeitos de FAN-OUT e FONTE DIFERENTE do
                   efeito da janela de período — se quiser reproduzir
                   exatamente o que aparece no gadget num período específico,
                   adicione o filtro de TRUNC(APO.DHAPO) BETWEEN ... nos
                   blocos 2, 3 e 4.
==============================================================================*/

--------------------------------------------------------------------------------
-- BLOCO 0 — PARÂMETROS DE TESTE USADOS NOS BLOCOS ABAIXO (já fixados)
--------------------------------------------------------------------------------

-- STATUSPROC  : ('A','P2')      -- mesmos status hardcoded no PLANEJAMENTO,
--                                  usado também no lado do p1 para a
--                                  comparação fazer sentido
-- DATAPRD     : TRUNC(SYSDATE)  -- data de referência do corte de
--                                  DTPREVENT no PLANEJAMENTO (hoje, 21/09/2026)
-- PERÍODO     : sem recorte     -- ver observação acima sobre :P_PERIODO

--------------------------------------------------------------------------------
-- BLOCO 1 — EXISTE FAN-OUT? Processos com mais de 1 item de lote (IPA) ou
-- mais de 1 atividade (TV) dentro do mesmo IDIPROC.
-- Se QTD_ITENS_LOTE > 1 E QTD_ATIVIDADES > 1 na mesma linha, o join de p1.sql
-- gera QTD_ITENS_LOTE x QTD_ATIVIDADES linhas para esse processo — cada uma
-- repetindo o TAMLOTE inteiro do item.
--------------------------------------------------------------------------------

SELECT
     PROC.IDIPROC
    ,PROC.NROLOTE
    ,COUNT(DISTINCT IPA.CODPRODPA)                              AS QTD_ITENS_LOTE
    ,COUNT(DISTINCT TV.IDIATV)                                  AS QTD_ATIVIDADES
    ,COUNT(DISTINCT IPA.CODPRODPA) * COUNT(DISTINCT TV.IDIATV)  AS LINHAS_GERADAS_NO_P1
FROM TPRIPROC PROC
    INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = PROC.IDIPROC
    INNER JOIN TPRIATV TV  ON TV.IDIPROC  = PROC.IDIPROC
    INNER JOIN TPREFX  EFX ON EFX.IDEFX   = TV.IDEFX
WHERE EFX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
  AND PROC.STATUSPROC IN ('A','P2')
GROUP BY PROC.IDIPROC, PROC.NROLOTE
HAVING COUNT(DISTINCT IPA.CODPRODPA) > 1
    OR COUNT(DISTINCT TV.IDIATV) > 1
ORDER BY LINHAS_GERADAS_NO_P1 DESC;

--------------------------------------------------------------------------------
-- BLOCO 2 — IMPACTO DO FAN-OUT NA SOMA DE TAMLOTE
-- Compara o total de TAMLOTE contado uma vez por lote/produto (correto) contra
-- o total contado uma vez por linha do p1.sql atual (com duplicação, se houver
-- fan-out). A diferença entre as duas colunas é o efeito isolado do fan-out.
--------------------------------------------------------------------------------

SELECT
     (SELECT SUM(QTDPRODUZIR) FROM (
          SELECT DISTINCT PROC.IDIPROC, IPA.CODPRODPA, IPA.QTDPRODUZIR
          FROM TPRIPROC PROC
              INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = PROC.IDIPROC
              INNER JOIN TPRIATV TV  ON TV.IDIPROC  = PROC.IDIPROC
              INNER JOIN TPREFX  EFX ON EFX.IDEFX   = TV.IDEFX
          WHERE EFX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
            AND PROC.STATUSPROC IN ('A','P2')
     ))                                                          AS TAMLOTE_SEM_DUPLICACAO
    ,(SELECT SUM(IPA.QTDPRODUZIR)
      FROM TPRIPROC PROC
          INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = PROC.IDIPROC
          INNER JOIN TPRIATV TV  ON TV.IDIPROC  = PROC.IDIPROC
          INNER JOIN TPREFX  EFX ON EFX.IDEFX   = TV.IDEFX
      WHERE EFX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
        AND PROC.STATUSPROC IN ('A','P2'))                       AS TAMLOTE_COMO_EM_P1_HOJE
FROM DUAL;

--------------------------------------------------------------------------------
-- BLOCO 3 — DUAS FONTES DE "JÁ PRODUZIDO" PARA O MESMO PROCESSO
-- Para cada IDIPROC, mostra lado a lado quanto foi apontado no chão de
-- fábrica (fonte do p1.sql) e quanto foi entregue por nota fiscal de
-- fabricação (fonte do PLANEJADO_ESTOQUE). Se os valores divergirem bastante
-- por processo, confirma que são fatos de negócio distintos — não apenas uma
-- questão de join.
--------------------------------------------------------------------------------

SELECT
     PROC.IDIPROC
    ,PROC.NROLOTE
    ,NVL(APT.QTDAPON, 0)        AS QTD_APONTADA_CHAO_FABRICA
    ,NVL(ENT.QTD_ENTREGUE, 0)   AS QTD_ENTREGUE_NF_FABRICACAO
    ,NVL(APT.QTDAPON, 0) - NVL(ENT.QTD_ENTREGUE, 0) AS DIFERENCA
FROM TPRIPROC PROC
    LEFT JOIN (
           SELECT TV.IDIPROC, SUM(APA.QTDAPONTADA) AS QTDAPON
             FROM TPRAPO APO
                  INNER JOIN TPRAPA  APA ON APA.NUAPO  = APO.NUAPO
                  INNER JOIN TPRIATV TV  ON APO.IDIATV = TV.IDIATV
            WHERE APO.SITUACAO = 'C'
            GROUP BY TV.IDIPROC
         ) APT ON APT.IDIPROC = PROC.IDIPROC
    LEFT JOIN (
           SELECT C.IDIPROC, SUM(I.QTDNEG) AS QTD_ENTREGUE
             FROM TGFCAB C
                  INNER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
            WHERE C.TIPMOV = 'F'
              AND I.ATUALESTOQUE = 1
              AND C.CODTIPOPER <> 900
            GROUP BY C.IDIPROC
         ) ENT ON ENT.IDIPROC = PROC.IDIPROC
WHERE PROC.STATUSPROC IN ('A','P2')
ORDER BY ABS(NVL(APT.QTDAPON, 0) - NVL(ENT.QTD_ENTREGUE, 0)) DESC;

--------------------------------------------------------------------------------
-- BLOCO 4 — TOTAL PLANEJADO_ESTOQUE (lógica original) x TOTAL "SALDO P1"
-- (mesma base de processos, dedução por apontamento em vez de entrega,
-- corrigindo o fan-out ao agregar por IDIPROC x CODPROD antes de somar).
-- Se ainda houver diferença relevante aqui, ela vem do BLOCO 3 (fonte do
-- "já produzido"), não do join.
--------------------------------------------------------------------------------

WITH PLANEJADO AS (
    SELECT SUM(P.QTD_PROD - COALESCE(E.QTD_ENTREGUE, 0)) AS TOTAL_PLANEJADO_ESTOQUE
    FROM (
             SELECT PROC.IDIPROC, IPA.CODPRODPA AS CODPROD, SUM(IPA.QTDPRODUZIR) AS QTD_PROD
             FROM TPRIPROC PROC
                  INNER JOIN TPRIPA IPA ON IPA.IDIPROC = PROC.IDIPROC
             WHERE PROC.STATUSPROC IN ('A','P2')
               AND COALESCE(PROC.DTPREVENT, TRUNC(PROC.DHINC) + 7) <= TRUNC(SYSDATE)
             GROUP BY PROC.IDIPROC, IPA.CODPRODPA
         ) P
         LEFT JOIN (
             SELECT C.IDIPROC, I.CODPROD, SUM(I.QTDNEG) AS QTD_ENTREGUE
             FROM TGFCAB C
                  INNER JOIN TGFITE I ON I.NUNOTA = C.NUNOTA
             WHERE C.TIPMOV = 'F'
               AND I.ATUALESTOQUE = 1
               AND C.CODTIPOPER <> 900
             GROUP BY C.IDIPROC, I.CODPROD
         ) E ON E.IDIPROC = P.IDIPROC AND E.CODPROD = P.CODPROD
)
,SALDO_P1_SEM_FANOUT AS (
    SELECT SUM(LOTE.QTDPRODUZIR - NVL(APT.QTDAPON, 0)) AS TOTAL_SALDO_P1
    FROM (
             SELECT DISTINCT PROC.IDIPROC, IPA.CODPRODPA, IPA.QTDPRODUZIR
             FROM TPRIPROC PROC
                  INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = PROC.IDIPROC
                  INNER JOIN TPRIATV TV  ON TV.IDIPROC  = PROC.IDIPROC
                  INNER JOIN TPREFX  EFX ON EFX.IDEFX   = TV.IDEFX
             WHERE EFX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
               AND PROC.STATUSPROC IN ('A','P2')
               AND COALESCE(PROC.DTPREVENT, TRUNC(PROC.DHINC) + 7) <= TRUNC(SYSDATE)
         ) LOTE
         LEFT JOIN (
             SELECT TV.IDIPROC, IPA.CODPRODPA, SUM(APA.QTDAPONTADA) AS QTDAPON
             FROM TPRAPO APO
                  INNER JOIN TPRAPA  APA ON APA.NUAPO   = APO.NUAPO
                  INNER JOIN TPRIATV TV  ON APO.IDIATV  = TV.IDIATV
                  INNER JOIN TPRIPA  IPA ON IPA.IDIPROC = TV.IDIPROC
             WHERE APO.SITUACAO = 'C'
             GROUP BY TV.IDIPROC, IPA.CODPRODPA
         ) APT ON APT.IDIPROC = LOTE.IDIPROC AND APT.CODPRODPA = LOTE.CODPRODPA
)
SELECT
     PLA.TOTAL_PLANEJADO_ESTOQUE
    ,SP1.TOTAL_SALDO_P1
    ,PLA.TOTAL_PLANEJADO_ESTOQUE - SP1.TOTAL_SALDO_P1 AS DIFERENCA_RESIDUAL
FROM PLANEJADO PLA, SALDO_P1_SEM_FANOUT SP1;
