/*==============================================================================
  Nome do Script : CARD - APONTAMENTOS DE CONFERENCIA - DETALHE
  Tipo           : Componente BI — Tabela
  Dashboard      : Conferência de Arquivos (AD_TGSIXN)
  Descrição      : Lista os apontamentos de conferência ainda em andamento
                   (STATUS = 1), com os dados da nota conferida, quem é o
                   conferente e a duração da conferência em dias úteis
                   (DTINI até SYSDATE, sem contar sábados e domingos).

  Parâmetros     : Sem parâmetros

  Tabelas        : AD_TGSIXN, TGFIXN, TFPFUN

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 03/07/2026
  Última Revisão : Julho/2026 — DURACAO_DIAS_UTEIS passou a vir da coluna
                   persistida em AD_TGSIXN (calculada por
                   TRG_DURACAO_AD_TGSIXN_SPARK), em vez de recalculada aqui

  Observações    : - CONFERENTE aparece em branco enquanto o apontamento
                     ainda não teve o conferente informado (CODFUNC nulo).
                   - Sem filtro de mês: lista todos os apontamentos em
                     andamento, de qualquer período.
==============================================================================*/

SELECT
    IXN.DHEMISS,
    IXN.VLRNOTA,
    IXN.NATUREZAOPER,
    IXN.XNOMEEMIT,
    IXN.NUMNOTA,
    FUN.NOMEFUNC                                        AS CONFERENTE,
    TGN.DTINI,
    TGN.DURACAO_DIAS_UTEIS
FROM AD_TGSIXN TGN
    LEFT  JOIN TGFIXN IXN ON IXN.NUARQUIVO = TGN.NUARQUIVO
    LEFT  JOIN TFPFUN FUN ON FUN.CODEMP = TGN.CODEMP AND FUN.CODFUNC = TGN.CODFUNC
WHERE TGN.STATUS = '1'
ORDER BY TGN.DTINI DESC
