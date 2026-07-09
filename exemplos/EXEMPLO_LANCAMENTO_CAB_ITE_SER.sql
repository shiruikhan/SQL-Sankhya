/*==============================================================================
  Nome do Script : EXEMPLO_LANCAMENTO_CAB_ITE_SER
  Tipo           : Script de Consulta (extração de exemplo para documentação)
  Descrição      : Localiza um lançamento (NUNOTA) anterior a 01/07/2026 que
                   possua registros simultâneos em TGFCAB (cabeçalho),
                   TGFITE (itens) e TGFSER (controle de série/lote), e
                   extrai o conteúdo completo das três tabelas para esse
                   lançamento. O resultado serve como exemplo de referência
                   real da estrutura cabeçalho + itens + série a ser anexado
                   ao repositório.
  Tabelas        : TGFCAB, TGFITE, TGFSER
  Uso            : Execução manual (SQL Developer/Toad) para documentação.
                   Não é objeto implantado no ERP — script de consulta avulso.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 09/07/2026

  Observações    : Passo 1 localiza o NUNOTA de exemplo mais recente antes do
                   corte de data. Passo 2 extrai os três conjuntos de dados
                   completos desse NUNOTA — substitua :P_NUNOTA pelo valor
                   retornado no passo 1 antes de executar.
==============================================================================*/

---------------------------------------------------------------------------
-- 1. Localiza um NUNOTA de exemplo (mais recente antes de 01/07/2026,
--    com pelo menos um item e uma série vinculados)
---------------------------------------------------------------------------
SELECT  *
FROM    (
            SELECT  CAB.NUNOTA
                   ,CAB.DTNEG
                   ,CAB.NUMNOTA
                   ,CAB.CODTIPOPER
                   ,CAB.TIPMOV
                   ,(SELECT COUNT(*) FROM TGFITE ITE WHERE ITE.NUNOTA = CAB.NUNOTA) AS QTD_ITENS
                   ,(SELECT COUNT(*) FROM TGFSER SER WHERE SER.NUNOTA = CAB.NUNOTA) AS QTD_SERIES
            FROM    TGFCAB CAB
            WHERE   CAB.DTNEG < TO_DATE('01/07/2026', 'DD/MM/YYYY')
            AND     EXISTS (SELECT 1 FROM TGFITE ITE WHERE ITE.NUNOTA = CAB.NUNOTA)
            AND     EXISTS (SELECT 1 FROM TGFSER SER WHERE SER.NUNOTA = CAB.NUNOTA)
            ORDER BY CAB.DTNEG DESC
        )
WHERE   ROWNUM = 1;

---------------------------------------------------------------------------
-- 2. Extrai o exemplo completo do lançamento encontrado no passo 1
--    Substitua :P_NUNOTA pelo NUNOTA retornado acima antes de executar
--    cada bloco (ou defina uma variável de bind no seu client SQL).
---------------------------------------------------------------------------

-- 2.1 Cabeçalho da nota
SELECT  *
FROM    TGFCAB CAB
WHERE   CAB.NUNOTA = :P_NUNOTA;

-- 2.2 Itens da nota
SELECT  *
FROM    TGFITE ITE
WHERE   ITE.NUNOTA = :P_NUNOTA
ORDER BY ITE.SEQUENCIA;

-- 2.3 Séries/lotes vinculados aos itens
SELECT  *
FROM    TGFSER SER
WHERE   SER.NUNOTA = :P_NUNOTA
ORDER BY SER.SEQUENCIA
        ,SER.CODPROD;
