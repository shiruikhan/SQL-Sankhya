CREATE OR REPLACE PROCEDURE STP_GARANTEESTOQUE_SPARK AS
/*==============================================================================
  Nome do Script : STP_GARANTEESTOQUE_SPARK
  Tipo           : Stored Procedure (Processamento de Dados)
  Descrição      : Atualiza grupos de agregação de estoque para modo de
                   valorização por estimativa garantida.

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
BEGIN
    UPDATE TGFGRU SET AGRUPALOCVALEST = 'S', VALEST = 'G';
END;