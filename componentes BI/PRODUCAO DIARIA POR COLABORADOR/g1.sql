/*==============================================================================
  Nome do Script : G1
  Tipo           : Componente BI — Gráfico (resumo colaborador × setor)
  Dashboard      : [SPARK] - PRODUÇÃO DIÁRIA POR COLABORADOR
  Componente     : G1
  Descrição      : Mesma agregação do P2 (total produzido por colaborador em
                   cada setor, dentro do universo de processos filtrado por
                   período/status/processo/lote), servindo de fonte para a
                   versão em gráfico do resumo — P2 é a tabela equivalente.

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
  Data de Criação: Setembro/2026
  Última Revisão : Setembro/2026 — Correção de bug: parâmetro estava como
                   :P_IDIPROC (linha 16), divergente do nome real configurado
                   no gadget (:P_IDIPROD, confirmado na tela de parâmetros e
                   usado em P1/P2) — filtro de processo específico não
                   funcionava neste painel. Cabeçalho adicionado e formatação
                   padronizada (vírgula à esquerda, join ANSI).

  Observações    : Query igual ao P2, EXCETO a coluna CODFUNC — o P2 passou a
                   expor APA.AD_CODFUNC para alimentar o drill-down
                   :A_CODFUNC do novo P3; um gráfico não precisa dessa coluna,
                   então essa é a única divergência intencional entre os dois.
                   Qualquer outro ajuste de regra de negócio feito aqui deve
                   ser replicado no P2, e vice-versa.
==============================================================================*/

SELECT  FUN.NOMEFUNC                                            AS COLABORADOR
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
