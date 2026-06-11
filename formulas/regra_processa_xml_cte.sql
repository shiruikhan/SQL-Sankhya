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
                   Junho/2026 — Documentação: TOP padrão corrigido (1301, não 225);
                                domínio oficial de TGFIXN.STATUS registrado

  Observações    : Domínio oficial de TGFIXN.STATUS (Portal de Importação XML):
                     0 = Pendente          3 = Inválido
                     1 = Cancelado         4 = Com divergência
                     2 = Importado         5 = Confirmado
                   O filtro nativo do agendador (STATUS = 0, transcrito acima)
                   NÃO inclui o status 5 (Confirmado), que é documento válido
                   para a operação. Como este complemento é apenas ANDado à
                   consulta nativa, ele não consegue AMPLIAR o filtro de status
                   — CT-es Confirmados só entram no fluxo automático retornando
                   a Pendente pela tela do portal, ou ajustando o filtro nativo
                   na configuração do agendador (se a tela permitir).
==============================================================================*/

TIPO = 'C'                                    -- apenas CT-e (não NF-e, MDF-e, etc.)
AND NVL(SITUACAOMDE, 0) <> 7                  -- exclui CT-e com evento de cancelamento
AND SITUACAOCTE         = 'A'                 -- apenas autorizados
AND (SYSDATE - DHEMISS) * 24 > 48            -- emitido há mais de 48 horas
AND DHIMPORT >= TO_DATE('01/01/2026', 'DD/MM/YYYY') -- importados a partir de 2026

-- Gate central de classificação:
-- Substitui as condições anteriores (CODTIPOPER IS NOT NULL + NOT EXISTS) por uma
-- única subquery que verifica simultaneamente:
--   1. Todas as NF-e referenciadas já estão em TGFCAB (nenhum CODTIPOPER_NFE nulo)
--   2. O CODTIPOPER atual bate exatamente com o que as regras de classificação produzem
--
-- O Sankhya preenche CODTIPOPER = 1301 por padrão em todo CT-e importado
-- (confirmado em produção via AD_LOG_ERROS em Jun/2026).
-- Sem esta verificação, um CT-e ainda no TOP padrão mas que deveria ser 226 ou 242
-- seria processado incorretamente assim que todas as NF-e chegassem.
--
-- Comportamento da subquery:
--   — NF-e ausente (CODTIPOPER_NFE = NULL)   → retorna NULL → bloqueia
--   — Todas as NF-e presentes, mas CODTIPOPER ≠ esperado → condição falsa → bloqueia
--   — Todas as NF-e presentes e CODTIPOPER = esperado    → libera para processamento
--
-- Prioridade das regras (mesma lógica do EVP):
--   TOP 225 → CODTIPOPER_NFE IN (214, 1125, 1211)
--   TOP 226 → CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202)
--   TOP 242 → CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228, 266, 233, 1119, 1108)
--   TOP 234 → CODTIPOPER_NFE IN (201, 221, 209)
AND CODTIPOPER = (
    SELECT
        CASE
            WHEN COUNT(CASE WHEN VW.CODTIPOPER_NFE IS NULL THEN 1 END) > 0
                THEN NULL  -- NF-e ainda ausente; bloqueia
            WHEN MAX(CASE WHEN VW.CODTIPOPER_NFE IN (214, 1125, 1211) THEN 1 END) = 1
                THEN 225
            WHEN MAX(CASE WHEN VW.CODTIPOPER_NFE IN (1100, 1117, 1143, 1142, 2200, 2202) THEN 1 END) = 1
                THEN 226
            WHEN MAX(CASE WHEN VW.CODTIPOPER_NFE IN (267, 231, 1267, 1327, 215, 1227, 228, 266, 233, 1119, 1108) THEN 1 END) = 1
                THEN 242
            WHEN MAX(CASE WHEN VW.CODTIPOPER_NFE IN (201, 221, 209) THEN 1 END) = 1
                THEN 234
            ELSE NULL
        END
    FROM VW_CTE_AUTORIZADOS VW
    WHERE VW.NRARQUIVO = NUARQUIVO
)
