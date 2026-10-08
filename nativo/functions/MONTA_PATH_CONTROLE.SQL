/*==============================================================================
  Nome do Script : MONTA_PATH_CONTROLE
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Monta o caminho hierarquico (pai > filho) de um controle da
                  estrutura TRDCON/TRDFCO.
  Assinatura     : MONTA_PATH_CONTROLE (P_NUCONTROLE IN INT, P_DESCRICAO IN
                  VARCHAR) RETURN VARCHAR
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'MONTA_PATH_CONTROLE', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION MONTA_PATH_CONTROLE (P_NUCONTROLE IN INT, P_DESCRICAO IN VARCHAR)
RETURN VARCHAR
IS
  P_NUCONTROLE_PAI INT;
  P_DESCRICAO_ATUAL VARCHAR(512);
  P_COUNT INT := 0;
BEGIN
    
    SELECT COUNT(1) INTO P_COUNT 
    FROM TRDFCO FCO 
    WHERE FCO.NUCONTROLEFILHO = P_NUCONTROLE
	AND FCO.NUCONTROLEFILHO <> FCO.NUCONTROLE;
    
    IF P_COUNT = 0 THEN
        SELECT NULL AS NUCONTROLE,
               CON.DESCRCONTROLE
        INTO P_NUCONTROLE_PAI, P_DESCRICAO_ATUAL
        FROM TRDCON CON
        WHERE CON.NUCONTROLE = P_NUCONTROLE
        AND CON.TIPOCONTROLE = 'FB';
    ELSE
        SELECT MAX(FCO.NUCONTROLE),
               CON.DESCRCONTROLE
        INTO P_NUCONTROLE_PAI, P_DESCRICAO_ATUAL
        FROM TRDFCO FCO
        INNER JOIN TRDCON CON ON (CON.NUCONTROLE = FCO.NUCONTROLEFILHO AND CON.TIPOCONTROLE IN ('MN','DS','FB'))
        WHERE FCO.NUCONTROLEFILHO = P_NUCONTROLE
		AND FCO.NUCONTROLEFILHO <> FCO.NUCONTROLE
        GROUP BY CON.DESCRCONTROLE; 
    END IF;
    
    IF(P_DESCRICAO IS NOT NULL) THEN
       P_DESCRICAO_ATUAL := P_DESCRICAO_ATUAL || '->' || P_DESCRICAO;    
    END IF;
    
    RETURN MONTA_PATH_CONTROLE(P_NUCONTROLE_PAI, P_DESCRICAO_ATUAL);

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        RETURN P_DESCRICAO;
END;
