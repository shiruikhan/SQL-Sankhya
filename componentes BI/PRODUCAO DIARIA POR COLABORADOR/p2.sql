/*==============================================================================
  Nome do Script : P2
  Tipo           : Componente BI — Tabela (resumo colaborador × setor)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : P2
  Descrição      : Total produzido por colaborador em cada setor, dentro dos
                   processos que atendem ao mesmo recorte do P1 (período,
                   status do processo, processo específico e código de
                   processo). Uma linha por colaborador × setor, ordenada da
                   maior para a menor produção. Complementa o G1, que exibe o
                   mesmo resumo em forma de gráfico.
                   Expõe CODFUNC para permitir drill-down: ao selecionar uma
                   linha, o gadget alimenta o parâmetro :A_CODFUNC, que filtra
                   o P3 (relação de apontamentos daquele colaborador).

  Parâmetros     : :P_PERIODO    — período do apontamento (INI/FIN), aplicado
                                   sobre APO.DHAPO
                   :P_FINAL      — 'N' considera apenas atividades não
                                   finalizadas (TV.DHFINAL IS NULL); 'S' inclui
                                   também as finalizadas
                   :P_STATUSPROC — status do processo (array)
                   :P_IDIPROD    — ID do processo de produção (opcional)
                   :P_CODPRC     — código do processo (array)

  Tabelas        : TPRAPA, TPRAPO, TPRIATV, TPREFX, TFPFUN, TPRIPROC, TPRPRC

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Junho/2026
  Última Revisão : Setembro/2026 — Pivô de escopo: painel deixa de ser o
                   resumo por colaborador com LISTAGG de setores (grão
                   colaborador × dia) e passa a agregar produção por
                   colaborador × setor dentro do universo de processos do P1,
                   com os mesmos filtros de status/processo/lote. Cabeçalho
                   adicionado (estava ausente após a reescrita) e formatação
                   padronizada (vírgula à esquerda, join ANSI).
                   Setembro/2026 — Coluna CODFUNC adicionada ao SELECT (já
                   fazia parte do GROUP BY) para servir de origem do
                   drill-down :A_CODFUNC usado pelo novo P3.

  Observações    : Colaborador via TPRAPA.AD_CODFUNC (LEFT JOIN) — nulos
                   aparecem com NOMEFUNC e CODFUNC nulos (sem tratamento de
                   'NAO IDENTIFICADO' neste painel). :P_IDIPROD é o nome real
                   do parâmetro configurado no gadget — não confundir com
                   PROC.IDIPROC, a coluna à qual ele é comparado. G1 não
                   recebe a coluna CODFUNC (não se aplica a um gráfico) — essa
                   é a única divergência intencional entre P2 e G1; qualquer
                   outro ajuste de regra de negócio continua valendo para os
                   dois.
==============================================================================*/

SELECT  FUN.NOMEFUNC                                            AS COLABORADOR
       ,APA.AD_CODFUNC                                          AS CODFUNC
       ,FX.DESCRICAO                                            AS SETOR
       ,SUM(APA.QTDAPONTADA)                                    AS PRODUCAO
  FROM TPRAPA APA
       INNER JOIN TPRAPO   APO  ON APA.NUAPO      = APO.NUAPO
       INNER JOIN TPRIATV  TV   ON APO.IDIATV     = TV.IDIATV
       INNER JOIN TPREFX   FX   ON TV.IDEFX       = FX.IDEFX
       LEFT  JOIN TFPFUN   FUN  ON APA.AD_CODFUNC = FUN.CODFUNC
       INNER JOIN TPRIPROC PROC ON TV.IDIPROC     = PROC.IDIPROC
       INNER JOIN TPRPRC   PRC  ON PROC.IDPROC    = PRC.IDPROC
 WHERE TRUNC(APO.DHAPO) BETWEEN :P_PERIODO.INI AND :P_PERIODO.FIN
   AND FX.DESCRICAO IN ('APONTAMENTO INSERSORA','APONTAMENTO REVISORA','INSERÇÃO','SOLDA','TESTE','DISSIPADOR','TAMPA/GABINETE','MONTAGEM FINAL','EXPEDIÇÃO/CONFERENCIA','DISPLAY','PRODUÇÃO KIT IBM')
   AND APO.SITUACAO = 'C'
   AND PROC.STATUSPROC IN :P_STATUSPROC
   AND (PROC.IDIPROC = :P_IDIPROD OR :P_IDIPROD IS NULL)
   AND NVL(TV.DHFINAL, TO_DATE('01/01/2099')) = CASE WHEN :P_FINAL = 'S'
                                                      THEN NVL(TV.DHFINAL, TO_DATE('01/01/2099'))
                                                      ELSE TO_DATE('01/01/2099')
                                                 END
   AND PRC.CODPRC IN :P_CODPRC
 GROUP BY
       FUN.NOMEFUNC
      ,APA.AD_CODFUNC
      ,FX.DESCRICAO
 ORDER BY PRODUCAO DESC
