/*==============================================================================
  Nome do Script : STP_CORPISCOFINSIMP_SPARK
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Corrigir informações de PIS e COFINS de importação
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 07/10/2026, última alteração em 07/10/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_CORPISCOFINSIMP_SPARK" (

       P_CODUSU      NUMBER,

       P_IDSESSAO    VARCHAR2,

       P_QTDLINHAS   NUMBER,

       P_MENSAGEM    OUT VARCHAR2

) AS
 
    /********************************************************************

      Autor: Lucas Gabriel

      Objetivo: Corrigir informações de PIS e COFINS de importação

    ********************************************************************/

    PARAM_P_BASE          NUMBER;

    PARAM_P_VLRPISCOFINS  NUMBER;

    PARAM_P_CST           NUMBER;

    PARAM_P_ALIQPIS       NUMBER;

    PARAM_P_ALIQCOFINS    NUMBER;

    PARAM_P_CODINC        VARCHAR2(4000);

    FIELD_NUNOTA          NUMBER;

    FIELD_SEQUENCIA       NUMBER;

    V_CODINC              NUMBER;

BEGIN

    /* ================================================================

       PARÂMETROS DA AÇÃO

       ================================================================ */

    PARAM_P_BASE := ACT_DEC_PARAM(P_IDSESSAO, 'P_BASE');

    PARAM_P_VLRPISCOFINS := ACT_DEC_PARAM(P_IDSESSAO, 'P_VLRPISCOFINS');

    PARAM_P_CST := ACT_INT_PARAM(P_IDSESSAO, 'P_CST');

    PARAM_P_ALIQPIS := ACT_DEC_PARAM(P_IDSESSAO, 'P_ALIQPIS');

    PARAM_P_ALIQCOFINS :=ACT_DEC_PARAM(P_IDSESSAO, 'P_ALIQCOFINS');

    PARAM_P_CODINC := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODINC');


    /* ================================================================

       DEFINE O CODINC

       Caso P_CODINC = 1 -> CODINC = 3

       Caso contrário     -> CODINC = 0

       ================================================================ */

    V_CODINC :=

        CASE

            WHEN PARAM_P_CODINC = '1' THEN 3

            ELSE 0

        END;


    /* ================================================================

       PERCORRE OS ITENS SELECIONADOS

       ================================================================ */

    FOR I IN 1 .. P_QTDLINHAS

    LOOP

        FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');

        FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');


        /* ============================================================

           BASE DE CÁLCULO

           ============================================================ */

        IF PARAM_P_BASE IS NOT NULL THEN

            UPDATE TGFDIN

               SET BASE    = PARAM_P_BASE,

                   BASERED = PARAM_P_BASE

             WHERE NUNOTA    = FIELD_NUNOTA

               AND SEQUENCIA = FIELD_SEQUENCIA

               AND CODINC    = V_CODINC

               AND CODIMP IN (6, 7);

        END IF;


        /* ============================================================

           VALOR PIS / COFINS

           ============================================================ */

        IF PARAM_P_VLRPISCOFINS IS NOT NULL THEN

            UPDATE TGFDIN

               SET VALOR   = PARAM_P_VLRPISCOFINS,

                   VLRCRED = PARAM_P_VLRPISCOFINS

             WHERE NUNOTA    = FIELD_NUNOTA

               AND SEQUENCIA = FIELD_SEQUENCIA

               AND CODINC    = V_CODINC

               AND CODIMP IN (6, 7);

        END IF;


        /* ============================================================

           CST

           ============================================================ */

        IF PARAM_P_CST IS NOT NULL THEN

            UPDATE TGFDIN

               SET CST = PARAM_P_CST

             WHERE NUNOTA    = FIELD_NUNOTA

               AND SEQUENCIA = FIELD_SEQUENCIA

               AND CODINC    = V_CODINC

               AND CODIMP IN (6, 7);

        END IF;


        /* ============================================================

           ALÍQUOTA PIS

           CODIMP = 6

           ============================================================ */

        IF PARAM_P_ALIQPIS IS NOT NULL THEN

            UPDATE TGFDIN

               SET ALIQUOTA = PARAM_P_ALIQPIS

             WHERE NUNOTA    = FIELD_NUNOTA

               AND SEQUENCIA = FIELD_SEQUENCIA

               AND CODINC    = V_CODINC

               AND CODIMP    = 6;

        END IF;


        /* ============================================================

           ALÍQUOTA COFINS

           CODIMP = 7

           ============================================================ */

        IF PARAM_P_ALIQCOFINS IS NOT NULL THEN

            UPDATE TGFDIN

               SET ALIQUOTA = PARAM_P_ALIQCOFINS

             WHERE NUNOTA    = FIELD_NUNOTA

               AND SEQUENCIA = FIELD_SEQUENCIA

               AND CODINC    = V_CODINC

               AND CODIMP    = 7;

        END IF;

    END LOOP;


    P_MENSAGEM :='Os valores de PIS e COFINS da importação foram alterados com sucesso!';


EXCEPTION

    WHEN OTHERS THEN

        P_MENSAGEM :=

            'Erro ao alterar PIS/COFINS da importação: ' || SQLERRM;

        RAISE;

END;
