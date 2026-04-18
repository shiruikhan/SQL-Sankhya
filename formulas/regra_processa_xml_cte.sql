/*==============================================================================
  Nome do Script : regra_processa_xml_cte
  Tipo           : Complemento de Regra de Processamento (Fórmula Sankhya)
  Descrição      : Complementa a regra nativa do Sankhya para processamento
                   automático de CT-e via agendador.

                   O sistema fornece nativamente:
                     SELECT * FROM TGFIXN
                     WHERE STATUS = 0
                     AND [condições internas do Sankhya]
                     AND (VLRNOTA >= 5    OR CNPJPARC IN ('65849838004278','65849838002577'))
                     AND (VLRNOTA < 5000  OR CNPJPARC IN ('65849838004278','65849838002577'))
                     AND SUBSTRING(DOCSREF, 10, 12) = '<chaveAcesso'
                     AND TOMADORCTE = 'S'
                     AND [complemento abaixo]

                   Este complemento adiciona os filtros específicos da Spark:
                   — Apenas CT-e autorizados com tempo mínimo de emissão
                   — Apenas CT-e já classificados (CODTIPOPER preenchido pelo EVP)
                   — Apenas CT-e cujas NF-e referenciadas já estão todas em TGFCAB
                     (nenhum CODTIPOPER_NFE nulo na VW_CTE_AUTORIZADOS)

                   A condição NOT EXISTS é o gate central que garante que o CT-e
                   só seja processado quando todas as NF-e vinculadas estiverem
                   presentes no sistema — independente do tempo entre a emissão
                   do CT-e e a chegada das notas.

  Dependências   : VW_CTE_AUTORIZADOS — CT-es autorizados com CODTIPOPER das NF-e
                                         referenciadas (via TGFCAB.CHAVENFE)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: 2026
  Última Revisão : Abril/2026 — Reescrita completa: correção de alias, AND ausente,
                                gate NOT EXISTS para garantir todas as NF-e presentes
==============================================================================*/

TIPO = 'C'                                    -- apenas CT-e (não NF-e, MDF-e, etc.)
AND NVL(SITUACAOMDE, 0) <> 7                  -- exclui CT-e com evento de cancelamento
AND SITUACAOCTE         = 'A'                 -- apenas autorizados
AND (SYSDATE - DHEMISS) * 24 > 48            -- emitido há mais de 48 horas
AND DHIMPORT >= TO_DATE('01/01/2026', 'DD/MM/YYYY') -- importados a partir de 2026

-- CT-e classificado: o EVP preencheu CODTIPOPER com base nas NF-e referenciadas
AND CODTIPOPER IS NOT NULL

-- Todas as NF-e referenciadas pelo CT-e já estão em TGFCAB.
-- Enquanto qualquer NF-e ainda não existir no sistema, CODTIPOPER_NFE será NULL
-- na VW_CTE_AUTORIZADOS e o CT-e permanece bloqueado para processamento.
AND NOT EXISTS (
    SELECT 1
    FROM   VW_CTE_AUTORIZADOS VW
    WHERE  VW.NRARQUIVO      = NUARQUIVO   -- NRARQUIVO: alias de NUARQUIVO na view
      AND  VW.CODTIPOPER_NFE IS NULL
)
