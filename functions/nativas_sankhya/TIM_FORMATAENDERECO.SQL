/*==============================================================================
  Nome do Script : TIM_FORMATAENDERECO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Formata o endereco de uma pessoa (tipo, numero, complemento,
                  bairro, cidade e estado).
  Assinatura     : TIM_FORMATAENDERECO (tipo IN VARCHAR2, endereco IN VARCHAR2,
                  numend IN VARCHAR2, complemento IN VARCHAR2, bairro IN
                  VARCHAR2, cidade IN VARCHAR2, estado IN VARCHAR2) RETURN
                  VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_FORMATAENDERECO', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_FORMATAENDERECO (tipo IN VARCHAR2, endereco IN VARCHAR2, numend IN VARCHAR2, complemento IN VARCHAR2, 
                                            bairro IN VARCHAR2, cidade IN VARCHAR2, estado IN VARCHAR2) RETURN VARCHAR2 IS
 --Autor: Bosco
 rsp VARCHAR2(400);
 
 BEGIN
       
 IF UPPER(SUBSTR(endereco, 1, LENGTH(trim(tipo)))) = UPPER(trim(tipo)) THEN
  rsp := endereco;
 ELSE
  rsp := trim(tipo) || ' ' || endereco;  
 END IF;
 IF numend IS NOT NULL THEN
  IF UPPER(SUBSTR(numend, 1, 1)) = 'S' THEN
   rsp := rsp || ', ' || trim(numend);
  ELSE
   rsp := rsp || ', nº ' || trim(numend);
  END IF; 
 END IF;
 IF complemento IS NOT NULL THEN
   rsp := rsp || ' - ' || trim(complemento);
 END IF;
 IF bairro IS NOT NULL THEN
  rsp := rsp || ', ' || bairro;
 END IF;
 IF cidade IS NOT NULL THEN
  rsp := rsp || ', ' || cidade;
 END IF;
 IF estado IS NOT NULL THEN
  rsp := rsp || ' - ' || estado;
 END IF;
       

 RETURN rsp;

END;
