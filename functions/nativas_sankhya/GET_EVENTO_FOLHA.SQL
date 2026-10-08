/*==============================================================================
  Nome do Script : GET_EVENTO_FOLHA
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Retorna o codigo do evento de folha ativo para uma
                  caracteristica; -1 se nao houver.
  Assinatura     : GET_EVENTO_FOLHA ( P_CARACTERISTICA IN VARCHAR ) RETURN
                  INTEGER
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                    sobrescrever esta function. Revisar apos cada upgrade
                    (mesmo cuidado descrito em trigger_nativa/README.md).
                  - Capturado do banco em 08/10/2026, via:
                    SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'GET_EVENTO_FOLHA', 'SPARKPRD') FROM dual;
==============================================================================*/
CREATE OR REPLACE FUNCTION GET_EVENTO_FOLHA ( P_CARACTERISTICA IN VARCHAR )
   RETURN INTEGER IS
   V_INTEIRO   INTEGER;
BEGIN
   BEGIN
     -- Não pode haver mais de um evento ativo para a mesma característica.
      SELECT CODEVENTO
        INTO V_INTEIRO
        FROM TFPEVE
       WHERE CARACTERISTICA = P_CARACTERISTICA
         AND ATIVO = 'S';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         V_INTEIRO    := -1;
   END;
   
   IF V_INTEIRO = -1 THEN
      SELECT CODEVENTO
        INTO V_INTEIRO
        FROM VGF_EVENTO_FOLHA
       WHERE CARACTERISTICA = P_CARACTERISTICA;
   END IF;

   RETURN V_INTEIRO;
END;
