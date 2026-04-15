create or replace PROCEDURE "STP_MARCAEFD08_TGFITE" (
    P_CODUSU NUMBER,
    P_IDSESSAO VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM OUT VARCHAR2
) AS
/*==============================================================================
  Nome do Script : STP_MARCAEFD08_TGFITE
  Tipo           : Stored Procedure (Botão de Ação)
  Descrição      : Marca ou desmarca itens de nota como EFD situação 08,
                   alternando entre S (marcado) e N (desmarcado).

  Parâmetros     : P_CODUSU     — código do usuário logado
                   P_IDSESSAO   — identificador da execução
                   P_QTDLINHAS  — quantidade de registros selecionados
                   P_MENSAGEM   — mensagem de retorno ao usuário (OUT)

  Autor          : Silvio Vieira
  Cargo          : Analista de Sistemas Sênior
  Empresa        : Spark Eletrônica
  Data de Criação: [A DEFINIR]
  Última Revisão : Abril/2026 — Padronização de cabeçalho e comentários
==============================================================================*/
    FIELD_NUNOTA NUMBER;
    FIELD_SEQUENCIA NUMBER;
    FIELD_CODSIT08EFD VARCHAR2(50); -- Variável para armazenar o conteúdo do campo CODSIT08EFD
BEGIN
    FOR I IN 1..P_QTDLINHAS
        LOOP
            FIELD_NUNOTA := ACT_INT_FIELD(P_IDSESSAO, I, 'NUNOTA');
            FIELD_SEQUENCIA := ACT_INT_FIELD(P_IDSESSAO, I, 'SEQUENCIA');
            
            -- Lendo o conteúdo atual do campo CODSIT08EFD direto da tabela TGFITE
            SELECT CODSIT08EFD 
            INTO FIELD_CODSIT08EFD 
            FROM TGFITE 
            WHERE NUNOTA = FIELD_NUNOTA 
              AND SEQUENCIA = FIELD_SEQUENCIA;
              
            -- Atualiza o campo 
            IF FIELD_CODSIT08EFD IS NULL THEN
                UPDATE TGFITE 
                SET CODSIT08EFD = 'S' 
                WHERE NUNOTA = FIELD_NUNOTA 
                  AND SEQUENCIA = FIELD_SEQUENCIA;
            ELSIF FIELD_CODSIT08EFD = 'S' THEN
                UPDATE TGFITE 
                SET CODSIT08EFD = 'N' 
                WHERE NUNOTA = FIELD_NUNOTA 
                  AND SEQUENCIA = FIELD_SEQUENCIA;
            END IF;
              
        END LOOP;
        
    P_MENSAGEM := 'Registros atualizados com sucesso!';
END;