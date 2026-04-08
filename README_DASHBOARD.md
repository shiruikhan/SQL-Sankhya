# Dashboard Fichas de Produção

Este script SQL cria um dashboard para visualizar todas as fichas de produção em aberto e andamento no processo produtivo de planos já gerados.

## Arquivo
- `DASHBOARD_FICHAS_PRODUCAO.SQL`: Script principal do dashboard

## Como usar
1. Execute o script no Sankhya (através do SQL Query ou como componente BI)
2. O resultado mostrará:
   - Número da ficha
   - Plano correspondente
   - Descrição do produto
   - Tamanho do lote
   - Saldo a produzir
   - Status do processo
   - Datas de previsão e início
   - Linha de produção

## Filtros aplicados
- Apenas processos com status 'Aberto' ou 'Em Produção'
- Processos não finalizados
- Apenas processos vinculados a planos gerados

## Personalização
Você pode adicionar filtros adicionais como:
- Por data: `AND PRC.DTPREVENT BETWEEN :DATA_INI AND :DATA_FIM`
- Por produto: `AND PRO.CODPROD = :COD_PROD`
- Por linha: `AND PRO.AD_LINHA = :LINHA`