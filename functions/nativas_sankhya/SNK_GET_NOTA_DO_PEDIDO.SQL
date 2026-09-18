/*==============================================================================
  Nome do Script : SNK_GET_NOTA_DO_PEDIDO
  Tipo           : Function Nativa Sankhya (referencia -- nao customizada)
  Descricao      : Localiza recursivamente a nota de venda vinculada a um pedido, percorrendo
                  ligacoes em TGFVAR.
  Assinatura     : SNK_GET_NOTA_DO_PEDIDO ( P_NUNOTA INT )
                   RETURN INT
  Observacoes    : - Objeto nativo do ERP -- atualizacoes do Sankhya podem
                     sobrescrever esta function. Revisar apos cada upgrade
                     (mesmo cuidado descrito em trigger_nativa/README.md).
                   - Capturado do banco em 18/09/2026, via:
                     SELECT DBMS_METADATA.GET_DDL('FUNCTION', 'SNK_GET_NOTA_DO_PEDIDO', 'SPARKPRD') FROM dual;
==============================================================================*/
  create or replace FUNCTION SNK_GET_NOTA_DO_PEDIDO ( P_NUNOTA INT )
   RETURN INT AS
   /* funcao recebe o NUNOTA do pedido e procura a nota recursivamente 
      se n?o encontrar NOTA retorna ZERO */  
  V_RESULT INT;
  V_TIPMOV CHAR(1);
BEGIN
   V_RESULT := 0;

   --percorrendo as liga??es pela TGFVAR
   FOR LIGACAO IN ( SELECT DISTINCT V.NUNOTA
                     FROM TGFVAR V
                    WHERE V.NUNOTAORIG <> V.NUNOTA AND V.NUNOTAORIG = P_NUNOTA ) LOOP

      --obtendo o TIPMOV da liga??o 
      SELECT MAX(TIPMOV)
      INTO V_TIPMOV
      FROM TGFCAB
      WHERE NUNOTA = LIGACAO.NUNOTA;


      --se ligado com nota, seta o NUNOTA
      IF V_TIPMOV = 'V' THEN 
        V_RESULT := LIGACAO.NUNOTA;
      -- se ligado com pedido, chama novamente recursivamente 
      ELSIF V_TIPMOV = 'P' THEN 
        V_RESULT := SNK_GET_NOTA_DO_PEDIDO( LIGACAO.NUNOTA );
      END IF;

      --se achou a nota, retorna
      IF V_RESULT <> 0 THEN
        RETURN V_RESULT;
      END IF;


   END LOOP;

   RETURN V_RESULT;

END;
