/*==============================================================================
  Nome do Script : FWMS_BUSCA_MENOR_OC
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Busca a menor ordem de carga entre uma tarefa WMS e suas
                  tarefas dependentes (TGWSEP/TGWTDP).
  Assinatura     : FWMS_BUSCA_MENOR_OC ( P_NUTAREFA IN NUMBER, P_SEQUENCIA IN
                  NUMBER) RETURN NUMBER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'FWMS_BUSCA_MENOR_OC', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION FWMS_BUSCA_MENOR_OC ( P_NUTAREFA IN NUMBER, P_SEQUENCIA IN NUMBER) RETURN NUMBER
IS
 MIN_OC NUMBER;
 CUR_OC NUMBER;
 CURSOR C_DEP IS SELECT 
       TDP.NUTAREFADEP,
       TDP.SEQUENCIADEP
       FROM TGWTDP TDP
       WHERE
       TDP.NUTAREFA = P_NUTAREFA
       AND TDP.SEQUENCIA = P_SEQUENCIA;
 R_DEP C_DEP%ROWTYPE;
BEGIN
 MIN_OC := NULL;
 
 SELECT MIN(SEP.ORDEMCARGA) INTO MIN_OC FROM TGWSEP SEP WHERE SEP.NUTAREFA = P_NUTAREFA;
 
 IF( NVL(MIN_OC, 0) > 0) THEN
     RETURN MIN_OC;
 END IF;
 
 OPEN C_DEP;
 
 LOOP FETCH C_DEP INTO R_DEP;
   EXIT WHEN C_DEP%NOTFOUND;
   CUR_OC := Fwms_Busca_Menor_Oc( R_DEP.NUTAREFADEP, R_DEP.SEQUENCIADEP );

   IF NVL(CUR_OC,0) > 0 AND (NVL(MIN_OC,0) = 0 OR CUR_OC < MIN_OC) THEN
     MIN_OC := CUR_OC;
   END IF; 
 END LOOP;
 
 CLOSE C_DEP;
 
 RETURN MIN_OC;
END;
