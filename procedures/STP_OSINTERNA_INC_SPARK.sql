create or replace PROCEDURE "STP_OSINTERNA_INC_SPARK" (
    P_CODUSU NUMBER,
    P_IDSESSAO VARCHAR2,
    P_QTDLINHAS NUMBER,
    P_MENSAGEM OUT VARCHAR2
) AS

    PARAM_P_SETOR VARCHAR2(4000);
    PARAM_P_PROBAPONTADO VARCHAR2(4000);
    PARAM_P_CODUSUCRI VARCHAR2(4000);
    M_NUMOS NUMBER;
BEGIN
    -- Obtenção dos parâmetros da sessão
    PARAM_P_SETOR := ACT_TXT_PARAM(P_IDSESSAO, 'P_SETOR');
    PARAM_P_PROBAPONTADO := ACT_TXT_PARAM(P_IDSESSAO, 'P_PROBAPONTADO');
    PARAM_P_CODUSUCRI := ACT_TXT_PARAM(P_IDSESSAO, 'P_CODUSUCRI');

    -- Geração do próximo número de OS
    SELECT MAX(NUMOS) + 1 INTO M_NUMOS FROM AD_OSINTERNA;

    IF M_NUMOS IS NULL THEN
        M_NUMOS := 1;
    END IF;
    
    -- Inserção na tabela AD_OSINTERNA
    BEGIN
        INSERT INTO AD_OSINTERNA (
            NUMOS,
            DHCRIACAO,
            SETOR,
            PROBAPONTADO,
            CODUSUCRI,
            PRIORIDADE,
        ) VALUES (
            M_NUMOS,                                    -- Número sequencial da OS
            SYSDATE,                                    -- Data/hora atual para criação
            PARAM_P_SETOR,                              -- Setor informado pelo usuário
            PARAM_P_PROBAPONTADO,                       -- Problema apontado
            PARAM_P_CODUSUCRI,                           -- Código do usuário criador
            1
        );
        
        -- Log de sucesso
        P_MENSAGEM := NVL(P_MENSAGEM, '') || 'OS Interna ' || M_NUMOS || ' criada com sucesso. ';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            -- Caso a OS já exista na tabela
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'ERRO: OS Interna ' || M_NUMOS || ' já existe na tabela. ';
        WHEN OTHERS THEN
            -- Outros erros
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'ERRO ao criar OS Interna ' || M_NUMOS || ': ' || SQLERRM || '. ';
    END;
    
    -- Controle de transação e finalização
    BEGIN
        -- Verificação de erros antes do commit
        IF P_MENSAGEM IS NULL OR INSTR(P_MENSAGEM, 'ERRO') = 0 THEN
            -- Commit apenas se não houve erros
            COMMIT;
            P_MENSAGEM := NVL(P_MENSAGEM, '') || 'Processo concluído com sucesso! 1 OS Interna foi processada.';
        ELSE
            -- Se houve erros, fazer rollback
            ROLLBACK;
            P_MENSAGEM := 'Processo finalizado com erros. Transações foram desfeitas. ' || P_MENSAGEM;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_MENSAGEM := 'ERRO CRÍTICO durante a finalização: ' || SQLERRM;
    END;

END;
