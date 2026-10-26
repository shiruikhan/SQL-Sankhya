# Catálogo de Fórmulas e Regras

**Empresa:** Spark Eletrônica  
**Responsável:** Silvio Vieira — Analista de Sistemas Sênior  

---

## Visão Geral

Esta pasta contém fórmulas configuradas diretamente no ERP Sankhya e regras de processamento automático. As fórmulas são expressões avaliadas pelo motor do ERP — não são scripts SQL executados no banco, mas sim lógicas interpretadas pelo Sankhya em tempo de execução.

---

## Catálogo

### `comissaopadrao`

**Tipo:** Fórmula do ERP Sankhya (campo calculado)  
**Contexto:** Calculada no item da nota de venda  

**Descrição:** Fórmula de cálculo de comissão padrão por vendedor, avaliada por item (`queItens`) com dados do cabeçalho (`queCab`) e do vendedor (`queVend`). Considera:
- Tipo de operação (`CODTIPOPER`): na TOP 11 a base é zero e, na empresa 1, a comissão passa a ser o valor de `AD_VLROUTROSFRETE` do cabeçalho; na TOP 1190 a base também é zero
- Origem do percentual: se o vendedor usa tabela de comissão (`VAD_COMISSAOTAB = 'S'`), o percentual vem de `TGFTPV` (versão mais recente do `CODTIPVENDA`) — `COMISSAO`, ou `AD_COMISDESC` quando o item tem desconto; caso contrário vem do próprio vendedor — `COMVENDA`, ou `VAD_COMISDESC` quando o item tem desconto
- Tipo de movimento: multiplica por `-1` em devoluções (`TIPMOV = 'D'`)

**Lógica resumida:**
```
comissao = [AD_VLROUTROSFRETE se TOP 11 e empresa 1]
         + VLRTOTLIQ do item (0 nas TOPs 11 e 1190) × (percentualComissao / 100)
         × (-1 se TIPMOV = 'D')
```

---

### `regra_processa_xml_cte.sql`

**Tipo:** Regra de processamento (SQL de condição/ação configurado no Sankhya)  
**Contexto:** Processamento automático de CT-e na importação de XML (`TGFIXN`)  

**Descrição:** Regra que identifica CT-e autorizados elegíveis para processamento automático, garantindo que todas as NF-e referenciadas já estejam em `TGFCAB` e que o `CODTIPOPER` atual bata com o tipo de operação recalculado. Utiliza a view `VW_CTE_AUTORIZADOS` para filtrar os documentos elegíveis.

**Domínio oficial de `TGFIXN.STATUS` (Portal de Importação de XML):**

| Código | Descrição |
|---|---|
| 0 | Pendente |
| 1 | Cancelado |
| 2 | Importado |
| 3 | Inválido |
| 4 | Com divergência |
| 5 | Confirmado |

**Critérios de ativação (complemento Spark):**
- Apenas CT-e (`TIPO = 'C'`), situação `'A'` (Autorizado), sem evento de cancelamento
- Emitidos há mais de 48 horas (`(SYSDATE - DHEMISS) * 24 > 48`)
- Importados a partir de 01/01/2026
- Todas as NF-e referenciadas presentes em `TGFCAB` e `CODTIPOPER` igual ao TOP recalculado (gate central)

**Integração:** Esta regra complementa a procedure agendada `STP_CLASSIFICACTE_SPARK` (sucessora do evento `EVP_CLASSIFICACTE_SPARK`) — a procedure classifica o `CODTIPOPER` a cada 5 minutos; a regra libera o documento para o agendador nativo somente quando a classificação está completa e consistente.

---

### `Observação_Venda_Spark.txt`

**Tipo:** Fórmula do ERP Sankhya (texto de observação da nota)  
**Contexto:** Observação impressa/enviada na NF-e de venda  

**Descrição:** Monta o texto de observação da nota concatenando blocos condicionais:
- **Empresa 2, venda (`TIPMOV = 'V'`):** texto de operação de comércio eletrônico/telemarketing — para pessoa jurídica, a vedação de crédito (art. 70, III do RICMS); para pessoa física, o benefício do RET E-PTA 45.000015167-79
- Observações vindas de views por `NUNOTA`: `VGF_OBSNOTAS_SPARK` (devolução, via `NUNOTA_DEV`), `VGF_OBSRICMS_SPARK`, `VGF_OBSIPI_SPARK`, `VGF_OBSNOTASSIMPLES_SPARK`, `VGF_OBSRSUFRAMA_SPARK`, `VGF_OBSPISCOFINS_SPARK`, `VGF_OBSNOTASRED_SPARK`
- Recolhimento de FCP (ICMS e ICMS-ST, `TGFDIN.CODIMP` 1 e 2, `VLRFCPINT > 0`) com o valor somado
- `&tottributosnfe` (total aproximado de tributos)

O arquivo começa com o marcador `*** SIADE ***`.

> As views `VGF_OBS*_SPARK` citadas aqui **não estão versionadas** no repositório (em `view/` existem apenas `VGF_OBSNOTAS2_SPARK` e `VGF_OBSNOTASDEV2_SPARK`). O bloco `VGF_OBSPISCOFINS_SPARK` reaproveita o alias de coluna `V.OBSSUFRAMA` — confirmar se é intencional.

---

## Observações

- As fórmulas Sankhya (`comissaopadrao`, `Observação_Venda_Spark.txt`) são mantidas aqui apenas como referência — a versão ativa está configurada no ERP em *Cadastros → Fórmulas*.
- O arquivo `comissaopadrao` não possui extensão pois é exportado diretamente do ERP como texto.
- Qualquer alteração na fórmula deve ser aplicada tanto aqui (para versionamento) quanto no ERP (para entrar em vigor).
