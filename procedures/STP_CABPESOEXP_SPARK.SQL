/*==============================================================================
  Nome do Script : STP_CABPESOEXP_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : informar o codigo de parceiro e realizar travas importantes para que tenha integridade do numero unico da pesagem com o numero unico do pedido.
  Autor          : Lucas Gabriel (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 09/04/2026, última alteração em 26/08/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_CABPESOEXP_SPARK" (
													P_TIPOEVENTO INT,    
													P_IDSESSAO VARCHAR2, 
													P_CODUSU INT         
													) AS
       BEFORE_INSERT INT;
       AFTER_INSERT  INT;
       BEFORE_DELETE INT;
       AFTER_DELETE  INT;
       BEFORE_UPDATE INT;
       AFTER_UPDATE  INT;
       BEFORE_COMMIT INT;
	   V_NUNOTA      AD_TGSPESOEXP.NUNOTA%TYPE;
	   V_CODPARC     TGFCAB.CODPARC%TYPE;
	   V_TIPOMOV     TGFCAB.TIPMOV%TYPE;
	   V_ID          INT;
	   V_COUNT       INT;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
/*******************************************************************************
Autor: Lucas Gabriel 
Data:09/04/2026
Objetivo: informar o codigo de parceiro e realizar travas importantes para que 
tenha integridade do numero unico da pesagem com o numero unico do pedido.
********************************************************************************/

  IF P_TIPOEVENTO = AFTER_INSERT
       OR P_TIPOEVENTO = AFTER_UPDATE
    THEN

        V_ID := EVP_GET_CAMPO_INT(P_IDSESSAO, 'ID');

        SELECT NUNOTA
          INTO V_NUNOTA
          FROM AD_TGSPESOEXP
         WHERE ID = V_ID;

        IF V_NUNOTA IS NULL THEN
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'Informe o número único do pedido. Campo vazio.',
                    ''
                )
            );
        END IF;
        SELECT COUNT(1)
          INTO V_COUNT
          FROM AD_TGSPESOEXP
         WHERE NUNOTA = V_NUNOTA
           AND ID <> V_ID;

        IF V_COUNT > 0 THEN
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'Número único já foi utilizado não pode ser usado novamente.',
                    ''
                )
            );
        END IF;

        BEGIN
            SELECT CODPARC
				 , TIPMOV
              INTO V_CODPARC
			     , V_TIPOMOV
              FROM TGFCAB
             WHERE NUNOTA = V_NUNOTA;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20191,
                    FC_FORMATAHTML(
                        'Ação não permitida!',
                        'Pedido não encontrado para o número informado.',
                        ''
                    )
                );

            WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(-20191,
                    FC_FORMATAHTML(
                        'Erro de integridade!',
                        'Mais de um registro encontrado para o mesmo NUNOTA.',
                        ''
                    )
                );
        END;

        IF V_TIPOMOV <> 'P' THEN
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'O número informado não corresponde a um pedido.',
                    ''
                )
            );
        END IF;

        UPDATE AD_TGSPESOEXP
           SET CODPARC = V_CODPARC
         WHERE ID = V_ID
           AND (CODPARC IS NULL OR CODPARC <> V_CODPARC);

    END IF;
	IF P_TIPOEVENTO = BEFORE_DELETE
	THEN 
	--Deletar as tabelas filhos quando deletar o PAE
	 V_ID := EVP_GET_CAMPO_INT(P_IDSESSAO, 'ID');
	 DELETE FROM AD_TGSPESOEXPPLT
		WHERE ID = V_ID;
	 DELETE FROM AD_TGSPESOEXPROD
		WHERE ID = V_ID;

	END IF;

END;
