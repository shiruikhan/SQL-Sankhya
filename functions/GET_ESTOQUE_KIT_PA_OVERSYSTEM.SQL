/*==============================================================================
  Nome do Script : GET_ESTOQUE_KIT_PA_OVERSYSTEM
  Tipo           : Function (customizacao -- fora do padrao _SPARK de autoria interna)
  Descricao      : Pipelined (TYPE_TABLE_KIT): estoque disponivel (estoque -
                  reservado, minimo 0) de um PA ou, se for kit (variacao 30000
                  em TGFICP), de cada materia-prima componente, por local
                  (P_CODLOCAL = 0 soma todos os locais).
  Assinatura     : GET_ESTOQUE_KIT_PA_OVERSYSTEM ( P_CODPROD IN INT,P_CODLOCAL
                  IN INT ) RETURN TYPE_TABLE_KIT
  Observacoes    : - Capturada do banco em 08/10/2026 (copia fiel do objeto
                    em producao, sem alteracoes), via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_ESTOQUE_KIT_PA_OVERSYSTEM', 'SPARKPRD') FROM dual;
                  - Origem nao confirmada: nome sem sufixo _SPARK, mas criada
                    apos a instalacao e com regras de negocio da Spark; tratada
                    como customizacao.
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_ESTOQUE_KIT_PA_OVERSYSTEM ( P_CODPROD IN INT,P_CODLOCAL IN INT )
   RETURN TYPE_TABLE_KIT PIPELINED AS
   V_COUNT   INT;
   V_COUNT2  INT;
   V_CODPROD INT;
   V_ESTOQUE FLOAT;
BEGIN

    SELECT COUNT(*)
    INTO V_COUNT
    FROM TGFICP 
    WHERE CODPROD = P_CODPROD AND VARIACAO = 30000;

    SELECT COUNT(*)
    INTO V_COUNT2
    FROM TGFEST
    WHERE CODPROD = P_CODPROD AND CODPARC = 0;

    IF V_COUNT = 0 AND V_COUNT2 = 0 THEN

        PIPE ROW(TYPE_TABLE_KIT_ROW(P_CODPROD,0));

    END IF;

    IF P_CODLOCAL != 0 THEN

            IF V_COUNT = 0 THEN

                SELECT CODPROD,CASE WHEN SUM(ESTOQUE-RESERVADO) < 0 THEN 0 ELSE SUM(ESTOQUE-RESERVADO) END
                INTO V_CODPROD,V_ESTOQUE
                FROM TGFEST E    
                WHERE TIPO = 'P' AND CODPARC = 0 AND CODPROD= P_CODPROD
                AND E.CODLOCAL = P_CODLOCAL
                GROUP BY CODPROD;

                PIPE ROW(TYPE_TABLE_KIT_ROW(V_CODPROD,V_ESTOQUE));
            END IF;

            IF V_COUNT > 0 THEN

                FOR ICP IN ( SELECT CODMATPRIMA FROM TGFICP WHERE CODPROD = P_CODPROD AND VARIACAO = 30000)  
                LOOP

                   SELECT CODPROD,CASE WHEN SUM(ESTOQUE-RESERVADO) < 0 THEN 0 ELSE SUM(ESTOQUE-RESERVADO) END
                   INTO V_CODPROD,V_ESTOQUE
                   FROM TGFEST E    
                   WHERE TIPO = 'P' AND CODPARC = 0 AND CODPROD= ICP.CODMATPRIMA
                   AND E.CODLOCAL = P_CODLOCAL
                   GROUP BY CODPROD;

                   PIPE ROW(TYPE_TABLE_KIT_ROW(V_CODPROD,V_ESTOQUE));

                END LOOP;

            END IF;
    END IF;

    IF P_CODLOCAL = 0 THEN

            IF V_COUNT = 0 THEN

                SELECT CODPROD,CASE WHEN SUM(ESTOQUE-RESERVADO) < 0 THEN 0 ELSE SUM(ESTOQUE-RESERVADO) END
                INTO V_CODPROD,V_ESTOQUE
                FROM TGFEST E    
                WHERE TIPO = 'P' AND CODPARC = 0 AND CODPROD= P_CODPROD
                GROUP BY CODPROD;

                PIPE ROW(TYPE_TABLE_KIT_ROW(V_CODPROD,V_ESTOQUE));
            END IF;

            IF V_COUNT > 0 THEN

                FOR ICP IN ( SELECT CODMATPRIMA FROM TGFICP WHERE CODPROD = P_CODPROD AND VARIACAO = 30000)  
                LOOP

                   SELECT CODPROD,CASE WHEN SUM(ESTOQUE-RESERVADO) < 0 THEN 0 ELSE SUM(ESTOQUE-RESERVADO) END
                   INTO V_CODPROD,V_ESTOQUE
                   FROM TGFEST E    
                   WHERE TIPO = 'P' AND CODPARC = 0 AND CODPROD= ICP.CODMATPRIMA
                   GROUP BY CODPROD;

                   PIPE ROW(TYPE_TABLE_KIT_ROW(V_CODPROD,V_ESTOQUE));

                END LOOP;

            END IF;
    END IF;

   RETURN;
END;
