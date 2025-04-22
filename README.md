
# 🗃️ Repositório de Scripts Oracle para Integrações com Sankhya

Este repositório armazena procedures, triggers e functions desenvolvidas em PL/SQL para integrações, automações e personalizações do sistema Sankhya.  
Tem como objetivo centralizar, versionar e documentar todas as rotinas implementadas no ambiente Oracle.

---

## 📁 Estrutura Esperada

Os arquivos serão organizados em subpastas conforme a funcionalidade ou módulo relacionado. Exemplos:

```
📂 procedures/
   ├── stp_exemplo_processamento.sql
📂 triggers/
   ├── trg_auditoria_usuarios.sql
📂 functions/
   ├── fnc_calculo_desconto.sql
```

---

## 🔧 Tecnologias Utilizadas

- **Oracle Database (PL/SQL)**
- **Sankhya ERP**
- **GitHub** para versionamento e rastreamento de alterações

---

## 📌 Boas Práticas

- Nomear os arquivos com prefixos claros (`stp_`, `trg_`, `fnc_`)
- Comentar cabeçalhos com:
  - Objetivo
  - Responsável
  - Data de criação
  - Histórico de alterações
- Utilizar transações de forma segura
- Evitar código hardcoded e preferir uso de parâmetros

---

## 🚀 Utilização

Estes scripts são aplicados diretamente no banco de dados Oracle vinculado ao ambiente Sankhya. Recomenda-se:

1. Testar os scripts em ambiente de homologação antes de produção.
2. Validar impactos em processos automatizados.
3. Utilizar controle de versão para rollback em caso de falhas.

---

## 🧠 Objetivo do Repositório

✅ Centralização dos scripts  
✅ Controle de versão das alterações  
✅ Melhoria na governança técnica  
✅ Facilidade de auditoria e colaboração

---