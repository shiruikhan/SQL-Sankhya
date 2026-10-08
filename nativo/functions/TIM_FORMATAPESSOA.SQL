/*==============================================================================
  Nome do Script : TIM_FORMATAPESSOA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Qualifica uma pessoa em texto contratual (nome,
                  nacionalidade, estado civil, profissao, documentos,
                  endereco).
  Assinatura     : TIM_FORMATAPESSOA (razaoSocial IN VARCHAR2, nacionalidade IN
                  VARCHAR2, descEstCivil IN VARCHAR2, profissao IN VARCHAR2,
                  tipo IN CHAR, documento IN VARCHAR2, identidade IN VARCHAR2,
                  orgao IN VARCHAR2, endereco IN VARCHAR2, estCivil IN
                  VARCHAR2, conjuge IN VARCHAR2, responsavel IN VARCHAR2)
                  RETURN VARCHAR2
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em nativo/triggers/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'TIM_FORMATAPESSOA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION TIM_FORMATAPESSOA (razaoSocial IN VARCHAR2, nacionalidade IN VARCHAR2, descEstCivil IN VARCHAR2, profissao IN VARCHAR2, 
                                            tipo IN CHAR, documento IN VARCHAR2, identidade IN VARCHAR2, orgao IN VARCHAR2, endereco IN VARCHAR2,  
                                            estCivil IN VARCHAR2, conjuge IN VARCHAR2, responsavel IN VARCHAR2) RETURN VARCHAR2 IS
 --Autor: Bosco
 rsp VARCHAR2(4000);
 
 BEGIN
       
 IF razaoSocial IS NOT NULL THEN
  rsp := razaoSocial;
  IF tipo = 'F' THEN
   IF nacionalidade IS NOT NULL THEN
    rsp := rsp || ', ' || trim(nacionalidade);
   END IF;
   IF descEstCivil IS NOT NULL THEN
    rsp := rsp || ', ' || trim(descEstCivil);
   END IF;
   IF profissao IS NOT NULL THEN
    rsp := rsp || ', ' || trim(profissao);
   END IF;
   rsp := rsp || ', inscrito no Ministério da Fazenda sob o número (CPF) ' || Tim_Formatacpfcnpj(documento, tipo) ;
   IF identidade IS NOT NULL THEN
    rsp := rsp || ', portador da carteira de identidade número ' || identidade;
    IF orgao IS NOT NULL THEN
     rsp := rsp || ' - ' || orgao;
    END IF;
   END IF;
   IF endereco IS NOT NULL THEN
    rsp := rsp || ', residente e domiciliado à ' || endereco;
   END IF; 
   IF estCivil = 'CA' THEN
    if conjuge is not null then
     rsp := rsp || ', casado com ' || conjuge;
    end if; 
   END IF; 
  ELSE
   rsp := rsp || ', inscrito no Ministério da Fazenda sob o número (CNPJ) ' || Tim_Formatacpfcnpj(documento, tipo);
   IF identidade IS NOT NULL THEN
    IF UPPER(SUBSTR(identidade, 1,2)) <> 'IS' THEN 
     rsp := rsp || ', com Inscrição Estadual número ' || identidade;
    END IF; 
   END IF;
   IF profissao IS NOT NULL THEN
    rsp := rsp || ', atuando no ramo de ' || trim(profissao);
   END IF;
   rsp := rsp || ', com sede à ' || endereco;
  END IF; 
  IF responsavel IS NOT NULL THEN
   rsp := rsp || ', neste momento representado por ' || responsavel;
  END IF; 
 ELSE
  rsp := NULL;  
 END IF;

 RETURN rsp;

END;
