# 🗃️ Repositório de Scripts Oracle para Integrações com Sankhya

![Oracle](https://img.shields.io/badge/Oracle-PL%2FSQL-red)
![Sankhya](https://img.shields.io/badge/Sankhya-ERP-blue)
![Git](https://img.shields.io/badge/Git-Versionamento-orange)
![Status](https://img.shields.io/badge/Status-Ativo-success)

Este repositório contém **procedures**, **triggers** e **functions** desenvolvidas em **PL/SQL** para integrações, automações e personalizações do sistema **Sankhya ERP**.  
O objetivo é **centralizar, versionar e documentar** todas as rotinas implementadas no ambiente **Oracle**, garantindo maior controle e rastreabilidade.

---

## 📑 Sumário
1. [📂 Estrutura do Repositório](#-estrutura-do-repositório)
2. [🔧 Tecnologias Utilizadas](#-tecnologias-utilizadas)
3. [📌 Boas Práticas](#-boas-práticas)
4. [🚀 Como Utilizar](#-como-utilizar)
5. [🎯 Objetivos do Repositório](#-objetivos-do-repositório)

---

## 📂 Estrutura do Repositório

Os arquivos estão organizados em pastas conforme a funcionalidade ou módulo relacionado:

```
📂 componentes BI/   → Scripts relacionados a Business Intelligence
📂 functions/        → Funções PL/SQL
📂 inativos/         → Scripts descontinuados
📂 procedures/       → Procedures de processamento e automação
📂 reports/          → Relatórios personalizados
📂 triggers/         → Gatilhos de auditoria e automação
📂 view/             → Views para consultas específicas
README.md            → Este arquivo
```

---

## 🔧 Tecnologias Utilizadas

- **Oracle Database (PL/SQL)**
- **Sankhya ERP**
- **Git** para versionamento e rastreamento de alterações

---

## 📌 Boas Práticas

- Nomear arquivos com prefixos claros:  
  - `stp_` → Stored Procedures  
  - `trg_` → Triggers  
  - `fnc_` → Functions  
- Incluir cabeçalho nos scripts com:
  - Objetivo
  - Autor/Responsável
  - Data de criação
  - Histórico de alterações
- Utilizar transações de forma segura
- Evitar valores hardcoded — prefira parâmetros
- Sempre testar em **homologação** antes de aplicar em **produção**

---

## 🚀 Como Utilizar

1. Clone o repositório:
   ```bash
   git clone <URL_DO_REPOSITORIO>
   ```
2. Localize o script desejado na pasta correspondente.
3. Execute-o no ambiente de **homologação**.
4. Valide os impactos e, se aprovado, aplique em **produção**.

---

## 🎯 Objetivos do Repositório

- ✅ **Centralização** dos scripts  
- ✅ **Controle de versão** das alterações  
- ✅ **Governança técnica** aprimorada  
- ✅ **Facilidade de auditoria e colaboração**  
