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

**Descrição:** Fórmula de cálculo de comissão padrão por vendedor. Considera:
- Tipo de operação (`CODTIPOPER`): se for TOP 11 (devolução de frete), utiliza valor de outros fretes
- Tipo de venda (`CODTIPVENDA`): determina a alíquota de comissão a partir de `TGFTPV`
- Desconto concedido: se houver desconto no item, aplica percentual de comissão com desconto (`AD_COMISDESC` ou `VAD_COMISDESC`)
- Tabela de comissão do vendedor: campo `COMVENDA` em `TSIUSU`
- Tipo de movimento: multiplica por `-1` em devoluções (`TIPMOV = 'D'`)

**Lógica resumida:**
```
comissao = (vlrTotalLiquidoItem) × (percentualComissao / 100) × sinal(tipmov)
```

Onde `percentualComissao` vem da tabela de tipos de venda (`TGFTPV`) se o vendedor usar tabela de comissão, ou do campo do vendedor (`COMVENDA`) caso contrário.

---

### `regra_processa_xml_cte.sql`

**Tipo:** Regra de processamento (SQL de condição/ação configurado no Sankhya)  
**Contexto:** Processamento automático de CT-e na importação de XML (`TGFIXN`)  

**Descrição:** Regra que identifica CT-e autorizados que ainda não foram processados e que possuem NF-e referenciada com tipo de operação `214` (importação/entrada). Utiliza a view `VW_CTE_AUTORIZADOS` para filtrar os documentos elegíveis.

**Critérios de ativação:**
- CT-e com status 0, 2 ou 4 (pendentes de processamento)
- Situação do CT-e: `'A'` (Autorizado)
- Emitidos há mais de 48 horas (`(SYSDATE - DHEMISS) * 24 > 48`)
- Emitidos a partir de 01/01/2026
- Com NF-e referenciada de `CODTIPOPER = 214`

**Integração:** Esta regra complementa o evento `EVP_CLASSIFICACTE_SPARK` — enquanto o evento classifica na importação, esta regra processa documentos que ficaram pendentes por qualquer motivo.

---

## Observações

- As fórmulas Sankhya (`comissaopadrao`) são mantidas aqui apenas como referência — a versão ativa está configurada no ERP em *Cadastros → Fórmulas*.
- O arquivo `comissaopadrao` não possui extensão pois é exportado diretamente do ERP como texto.
- Qualquer alteração na fórmula deve ser aplicada tanto aqui (para versionamento) quanto no ERP (para entrar em vigor).
