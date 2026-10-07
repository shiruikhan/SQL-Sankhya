CREATE OR REPLACE PROCEDURE STP_CORRIGEAPONTAMENTO_SPARK AS
/*==============================================================================
  Nome do Script : STP_CORRIGEAPONTAMENTO_SPARK
  Tipo           : Procedure (agendada, sem parâmetros)
  Descrição      : Validação e correção automática dos apontamentos de produção
                   (TPRAPA) das conferências finalizadas nos últimos 3 dias:
                   ajusta QTDAPONTADA e QTDFAT para o nº de séries conferidas
                   em AD_TPRCOI, apenas em apontamentos da expedição e em OPs
                   em andamento.

                   Não recebe parâmetros: o agendador do Sankhya invoca a
                   procedure sem enviar argumentos. A janela de 3 dias é uma
                   constante interna (V_DIAS). Toda a lógica está na
                   STP_CORRIGEAPO_PERIODO_SPARK, que esta procedure
                   apenas aciona; para cargas maiores, uma OP específica ou
                   simulação, use aquela diretamente.

  Parâmetros     : (nenhum)
  Tabelas        : ver STP_CORRIGEAPO_PERIODO_SPARK
  Tabela de Log  : AD_LOG_ERROS (gravado pela procedure chamada)
  Dependencias   : STP_CORRIGEAPO_PERIODO_SPARK (deve ser compilada antes)
  Uso            : Execução recorrente por agendador (a cada 2 min):
                     BEGIN STP_CORRIGEAPONTAMENTO_SPARK; END;

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: Outubro/2026
  Última Revisão : Outubro/2026 — Criação da procedure
                   Outubro/2026 — Passou a ser apenas o agendável sem parâmetros,
                   com a janela fixa de 3 dias; a lógica foi para a
                   STP_CORRIGEAPO_PERIODO_SPARK

  Observações    : - Mudar a janela exige recompilar esta procedure (V_DIAS).
                   - A cadência de execução é responsabilidade do agendador.
==============================================================================*/

    -- Janela fixa de varredura: conferências finalizadas nos últimos N dias
    V_DIAS CONSTANT NUMBER := 3;

BEGIN

    STP_CORRIGEAPO_PERIODO_SPARK(P_DTINI => TRUNC(SYSDATE) - V_DIAS);

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20095,
            'STP_CORRIGEAPONTAMENTO_SPARK - ' || SQLERRM);
END STP_CORRIGEAPONTAMENTO_SPARK;
/
