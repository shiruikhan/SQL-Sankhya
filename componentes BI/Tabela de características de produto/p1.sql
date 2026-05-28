/*==============================================================================
  Nome do Script : Tabela de Características de Produto
  Tipo           : Componente BI
  Descrição      : Lista os produtos ativos e não obsoletos com suas principais
                   características: descrições, referência, NCM, peso líquido,
                   medidas do produto e da caixa, e grupo de produto.
                   Aceita filtro opcional por grupo (pai ou filho direto) via
                   parâmetro :P_CODGRUPOPROD. Quando o grupo informado for
                   sintético (ANALITICO = 'N'), retorna também seus filhos
                   diretos.
  Parâmetros     : P_CODGRUPOPROD — lista de códigos de grupo de produto
                   (multilist, obrigatório)
  Tabelas        : TGFPRO, TGFGRU
  Dependencias   : filtro.sql (popula o parâmetro P_CODGRUPOPROD)
  Uso            : Componente BI — Tabela de Características de Produto

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Maio/2026
  Última Revisão : Maio/2026 — parâmetro P_CODGRUPOPROD alterado para multilist

  Observações    : Produtos com AD_OBSOLETO = 'S' ou ATIVO <> 'S' são excluídos.
                   Eixos de medida não preenchidos exibem '0'.
==============================================================================*/
SELECT  P.CODPROD
       ,P.DESCRPROD
       ,P.COMPLDESC
       ,P.AD_DESCRPRODOED
       ,P.AD_QTDEMB
       ,P.REFERENCIA
       ,P.NCM
       ,P.AD_PESOLIQ_SPARK
       ,NVL(TRIM(TO_CHAR(P.AD_ESPESSURA_SPARK)), '0') || 'x'
            || NVL(TRIM(TO_CHAR(P.AD_LARGURA_SPARK)), '0') || 'x'
            || NVL(TRIM(TO_CHAR(P.AD_ALTURA_SPARK)),  '0') AS MEDIDA_PRODUTO
       ,P.PESOBRUTO
       ,NVL(TRIM(TO_CHAR(P.ESPESSURA)), '0') || 'x'
            || NVL(TRIM(TO_CHAR(P.LARGURA)), '0') || 'x'
            || NVL(TRIM(TO_CHAR(P.ALTURA)), '0')           AS MEDIDA_CAIXA
       ,G.CODGRUPOPROD
       ,G.DESCRGRUPOPROD
  FROM TGFPRO P
       INNER JOIN TGFGRU G ON G.CODGRUPOPROD = P.CODGRUPOPROD
 WHERE P.ATIVO = 'S'
   AND NVL(P.AD_OBSOLETO, 'N') <> 'S'
   AND (   P.CODGRUPOPROD IN :P_CODGRUPOPROD
        OR (    G.CODGRUPAI IN :P_CODGRUPOPROD
            AND EXISTS (
                    SELECT 1
                      FROM TGFGRU GP
                     WHERE GP.CODGRUPOPROD = G.CODGRUPAI
                       AND GP.ANALITICO = 'N'
                )
           )
       )
 ORDER BY P.DESCRPROD
