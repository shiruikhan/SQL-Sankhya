# SQL Sankhya

Repositório pessoal de customizações e extensões para o ERP Sankhya, desenvolvidas em Oracle PL/SQL.

---

## Estrutura

```
SQL Sankhya/
├── triggers/           Triggers de negócio (validação, notificação, controle de status)
├── procedures/         Stored procedures (aprovações, MRP, integrações, logística)
├── functions/          Funções escalares auxiliares
├── view/               Views de consulta
├── componentes BI/     Queries analíticas para dashboards e relatórios gerenciais
├── reports/            Definições de relatórios Jasper (.jrxml)
├── java/               Classes Java e queries usadas em customizações de eventos
├── formulas/           Regras e fórmulas do ERP
├── audicon/            Procedures de integração contábil
└── inativos/           Objetos descontinuados
```

---

## Tecnologias

- **Oracle PL/SQL** — lógica de negócio, triggers, procedures e functions
- **SQL analítico** — CTEs, window functions, relatórios BI
- **Java** — listeners e utilitários de eventos do ERP
- **JasperReports (.jrxml)** — templates de relatórios impressos
- **Sankhya ERP** — plataforma-alvo de todas as customizações

---

## Domínios cobertos

| Domínio | Exemplos |
|---|---|
| Planejamento de produção (MRP/MPS) | Cálculo de necessidade, meta, lote, estoque |
| Compras e supply chain | Fluxo de aprovação de solicitações, prazos |
| Vendas e faturamento | NF-e, pedidos, inadimplência |
| Estoque | Saldo por empresa/local, estimativas, WIP |
| Financeiro | Naturezas, moedas, contas contábeis |
| Logística | Romaneios, etiquetas, expedição |
| BI / Gerencial | Dashboards de produção, vendas e compras |

---

## Convenções de nomenclatura

| Prefixo | Tipo |
|---|---|
| `STP_` | Stored procedure |
| `EVP_` | Procedure de visão externa |
| `TRG_` | Trigger |
| `V` / `VW_` | View |

---

## Observações

- Todo o código é compatível com **Oracle Database** (dialeto PL/SQL).
- Os scripts são independentes entre si; cada arquivo contém um único objeto de banco.
- A pasta `inativos/` preserva objetos descontinuados apenas para referência histórica.
- Dados sensíveis (credenciais, strings de conexão) são mantidos fora do repositório via `.env` (ignorado pelo `.gitignore`).
