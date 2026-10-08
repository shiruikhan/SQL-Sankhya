/*==============================================================================
  Nome do Script : STP_ITEPESOEXP_SPARK
  Tipo           : Procedure de visão externa (evento de tela)
  Descrição      : Validar informações do preenchimento da pesagem de exportação
  Autor          : Lucas Gabriel - ONTIME TECH (conforme comentário no fonte)
  Empresa        : Spark Eletrônica
  Observações    : - Objeto existente no banco e ausente do repositório até 08/10/2026 (descoberto no inventário scripts/inventario_2026-10-08/).
                   - No banco: criado em 09/04/2026, última alteração em 21/09/2026.
                   - Capturado do banco em 08/10/2026 via DBMS_METADATA.GET_DDL; fonte preservado sem alteração (removida só a qualificação "SPARKPRD".).
                   - Cabeçalho ainda não padronizado — revisar descrição/parâmetros.
==============================================================================*/
  CREATE OR REPLACE EDITIONABLE PROCEDURE "STP_ITEPESOEXP_SPARK" (
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
	   V_CODEMB      TGFPRO.AD_CODPRODEMB%TYPE;
	   V_PESOBRUTEMB TGFPRO.PESOBRUTO%TYPE;
BEGIN
       BEFORE_INSERT := 0;
       AFTER_INSERT  := 1;
       BEFORE_DELETE := 2;
       AFTER_DELETE  := 3;
       BEFORE_UPDATE := 4;
       AFTER_UPDATE  := 5;
       BEFORE_COMMIT := 10;
/*******************************************************************************
Autor: Lucas Gabriel - ONTIME TECH 
Data:09/04/2026
Objetivo: Validar informações do preenchimento da pesagem de exportação
********************************************************************************/
    IF P_TIPOEVENTO = BEFORE_INSERT 
       OR P_TIPOEVENTO = BEFORE_UPDATE
    THEN

        IF NVL(EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'USACXPROD'),'N') = 'S'
        THEN

            BEGIN
                SELECT AD_CODPRODEMB
                  INTO V_CODEMB 
                  FROM TGFPRO 
                 WHERE CODPROD = EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPROD');

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20191,
                        FC_FORMATAHTML(
                            'Ação não permitida!',
                            'Produto não encontrado.',
                            ''
                        )
                    );
            END;

            IF V_CODEMB IS NULL THEN 
                RAISE_APPLICATION_ERROR(-20191,
                    FC_FORMATAHTML(
                        'Ação não permitida!',
                        'Foi marcado para usar caixa coletiva do produto, porém o produto ' 
                        || EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODPROD') || 
                        ' não possui caixa coletiva informada no cadastro.',
                        ''
                    )
                );        
            END IF;

            BEGIN
                SELECT PESOBRUTO
                  INTO V_PESOBRUTEMB
                  FROM TGFPRO 
                 WHERE CODPROD = V_CODEMB;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20191,
                        FC_FORMATAHTML(
                            'Ação não permitida!',
                            'Produto da embalagem não encontrado.',
                            ''
                        )
                    );
            END;

            EVP_SET_CAMPO_DEC(P_IDSESSAO, 'PESOEMB', V_PESOBRUTEMB);
			EVP_SET_CAMPO_INT(P_IDSESSAO, 'CODCXPROD',V_CODEMB);
        END IF;

        IF NVL(EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'USACXPROD'),'N') = 'N'
           AND EVP_GET_CAMPO_INT(P_IDSESSAO, 'CODCXPROD') IS NULL
        THEN 
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'Foi marcado para não usar caixa coletiva do produto.',
                    'Informe a caixa coletiva manualmente.'
                )
            );            
        END IF;

        IF NVL(EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'USACXPROD'),'N') = 'N'
		   AND NVL(EVP_GET_CAMPO_TEXTO(P_IDSESSAO, 'CXUNIVPROD'),'N') = 'N'
           AND EVP_GET_CAMPO_DEC(P_IDSESSAO, 'PESOEMB') IS NULL 
        THEN 
            RAISE_APPLICATION_ERROR(-20191,
                FC_FORMATAHTML(
                    'Ação não permitida!',
                    'Foi marcado para não usar caixa coletiva do produto.',
                    'Informe o peso da caixa coletiva manualmente.'
                )
            );        
        END IF;

    END IF;

END;
