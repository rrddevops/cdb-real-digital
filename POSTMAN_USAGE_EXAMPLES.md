# 🚀 CBD Real Digital - Exemplos de Uso Postman

## 📋 Visão Geral

Este documento contém exemplos práticos de como usar os scripts e coleções do Postman para testar o CBD Real Digital.

## 🛠️ Scripts Disponíveis

### 1. **setup-postman.sh** - Configuração Automática

```bash
# Executar configuração completa
./setup-postman.sh

# O que o script faz:
# ✓ Verifica se o ambiente está rodando
# ✓ Testa conectividade das APIs
# ✓ Cria arquivo de ambiente do Postman
# ✓ Cria script de teste automatizado
# ✓ Cria script de dados de teste
```

### 2. **run-token-tests.sh** - Testes de Token

```bash
# Executar todos os testes de token
./run-token-tests.sh

# Executar apenas testes de erro
./run-token-tests.sh --errors

# Executar apenas testes de performance
./run-token-tests.sh --perf

# Executar apenas setup de dados
./run-token-tests.sh --setup

# Gerar relatório apenas
./run-token-tests.sh --report
```

## 📊 Exemplos de Testes

### **Exemplo 1: Teste Completo de Transferência**

```bash
# 1. Configurar ambiente
./setup-postman.sh

# 2. Executar testes de token
./run-token-tests.sh

# 3. Verificar relatório
cat token_test_report_*.txt
```

**Saída Esperada:**
```
================================
  CBD Real Digital - Token Tests
================================
[INFO] Verificando ambiente...
✓ Ambiente está rodando
--- Configurando Dados de Teste ---
[INFO] Executando: Depósito de 5000 DREX na conta 1
✓ Depósito de 5000 DREX na conta 1 - Sucesso
[INFO] Executando: Depósito de 1000 TPFt Série 1 na conta 1
✓ Depósito de 1000 TPFt Série 1 na conta 1 - Sucesso
...
```

### **Exemplo 2: Teste Específico de Performance**

```bash
# Executar apenas testes de performance
./run-token-tests.sh --perf
```

**Testes Executados:**
- 5 transferências simultâneas
- Transferência de grande quantidade (5000 DREX)
- Verificação de tempo de resposta

### **Exemplo 3: Teste de Tratamento de Erros**

```bash
# Executar apenas testes de erro
./run-token-tests.sh --errors
```

**Testes Executados:**
- Transferência com saldo insuficiente
- Transferência para endereço inválido
- Transferência com valor zero

## 🎯 Exemplos de Requisições Postman

### **1. Transferência de Real Digital**

**Endpoint:** `POST {{base_url_zapp}}/transfer`

**Body:**
```json
{
    "to": "0xabcdef1234567890abcdef1234567890abcdef12",
    "amount": 100.00
}
```

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "transactionId": "tx_123456",
        "from": "0x1234567890abcdef1234567890abcdef12345678",
        "to": "0xabcdef1234567890abcdef1234567890abcdef12",
        "amount": 100.00,
        "timestamp": "2025-06-25T10:30:00Z"
    }
}
```

### **2. Transferência de TPFt**

**Endpoint:** `POST {{base_url_zapp}}/transferErc1155`

**Body:**
```json
{
    "to": "0xabcdef1234567890abcdef1234567890abcdef12",
    "tokenId": 1,
    "amount": 50
}
```

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "transactionId": "tx_789012",
        "from": "0x1234567890abcdef1234567890abcdef12345678",
        "to": "0xabcdef1234567890abcdef1234567890abcdef12",
        "tokenId": 1,
        "amount": 50,
        "timestamp": "2025-06-25T10:31:00Z"
    }
}
```

### **3. Swap Real Digital → TPFt**

**Endpoint:** `POST {{base_url_zapp}}/startSwapFromErc20ToErc1155`

**Body:**
```json
{
    "erc20Address": "0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e",
    "counterParty": "0xabcdef1234567890abcdef1234567890abcdef12",
    "amountSent": 500,
    "tokenIdReceived": 1,
    "tokenReceivedAmount": 50
}
```

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "swapId": "swap_345678",
        "amountSent": 500,
        "tokenReceivedAmount": 50,
        "status": "pending"
    }
}
```

### **4. Consulta de Saldo**

**Endpoint:** `GET {{base_url_zapp}}/balance?account={{test_account}}`

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "account": "0x1234567890abcdef1234567890abcdef12345678",
        "realDigital": 3400.00,
        "tpft": {
            "1": 925,
            "2": 400
        },
        "lastUpdated": "2025-06-25T10:35:00Z"
    }
}
```

## 🔧 Configuração Manual do Postman

### **1. Importar Coleção**

1. Abra o **Postman**
2. Clique em **"Import"**
3. Selecione: `CBD_Real_Digital_Postman_Collection.json`
4. Clique em **"Import"**

### **2. Configurar Ambiente**

1. Clique em **"Environments"**
2. Clique em **"Import"**
3. Selecione: `CBD_Real_Digital_Environment.json`
4. Clique em **"Import"**
5. Selecione o ambiente **"CBD Real Digital"**

### **3. Executar Testes**

#### **Opção A: Runner do Postman**
1. Clique em **"Runner"**
2. Selecione a coleção **"CBD Real Digital"**
3. Configure:
   - **Iterations**: 1
   - **Delay**: 1000ms
   - **Environment**: CBD Real Digital
4. Clique em **"Run"**

#### **Opção B: Newman CLI**
```bash
# Instalar Newman
npm install -g newman

# Executar coleção
newman run CBD_Real_Digital_Postman_Collection.json \
  --environment CBD_Real_Digital_Environment.json \
  --reporters cli,json,html \
  --reporter-json-export results.json \
  --reporter-html-export report.html
```

## 📈 Exemplos de Relatórios

### **Relatório de Teste Completo**

```
CBD Real Digital - Relatório de Testes de Token
===============================================
Data: 25/06/2025
Timestamp: 2025-06-25_10-30-00

RESUMO DOS TESTES:
==================

1. Configuração de Dados de Teste:
   ✓ Depósito de 5000 DREX na conta 1
   ✓ Depósito de 1000 TPFt Série 1 na conta 1
   ✓ Depósito de 500 TPFt Série 2 na conta 1
   ✓ Depósito de 2000 DREX na conta 2

2. Transferências de Real Digital:
   ✓ Transferência pequena (100 DREX)
   ✓ Transferência média (500 DREX)
   ✓ Transferência grande (1000 DREX)
   ✓ Transferência para múltiplas contas

3. Transferências de TPFt:
   ✓ Transferência TPFt Série 1 (50 tokens)
   ✓ Transferência TPFt Série 2 (100 tokens)
   ✓ Transferência múltiplos tipos

4. Swaps de Tokens:
   ✓ Swap 500 DREX → 50 TPFt Série 1
   ✓ Swap 1000 DREX → 100 TPFt Série 2

5. Validações:
   ✓ Consulta de saldo
   ✓ Consulta de histórico
   ✓ Validação de transação

6. Tratamento de Erros:
   ✓ Saldo insuficiente
   ✓ Endereço inválido
   ✓ Valor zero

7. Testes de Performance:
   ✓ 5 transferências simultâneas
   ✓ Transferência de grande quantidade

STATUS: Testes concluídos com sucesso!
```

### **Relatório Newman (JSON)**

```json
{
    "run": {
        "stats": {
            "iterations": {
                "total": 1,
                "pending": 0,
                "failed": 0
            },
            "items": {
                "total": 25,
                "pending": 0,
                "failed": 0
            },
            "requests": {
                "total": 25,
                "pending": 0,
                "failed": 0
            },
            "testScripts": {
                "total": 25,
                "pending": 0,
                "failed": 0
            },
            "prerequestScripts": {
                "total": 25,
                "pending": 0,
                "failed": 0
            },
            "assertions": {
                "total": 75,
                "pending": 0,
                "failed": 0
            },
            "testDuration": 45000,
            "responseAverage": 1800
        }
    }
}
```

## 🐛 Troubleshooting

### **Problema: Erro de Conexão**

```bash
# Verificar se os containers estão rodando
docker ps

# Verificar se as APIs estão respondendo
curl http://localhost:3000
curl http://localhost:3100

# Reiniciar ambiente se necessário
./restart-environment.sh
```

### **Problema: Erro de Validação**

```json
{
    "status": "error",
    "message": "Invalid parameters"
}
```

**Solução:**
- Verificar formato do JSON
- Verificar se todos os campos obrigatórios estão preenchidos
- Verificar se os endereços estão corretos

### **Problema: Saldo Insuficiente**

```json
{
    "status": "error",
    "message": "Insufficient balance"
}
```

**Solução:**
```bash
# Executar setup de dados
./run-token-tests.sh --setup
```

## 📚 Próximos Passos

1. **Executar testes básicos:**
   ```bash
   ./run-token-tests.sh
   ```

2. **Explorar coleção no Postman:**
   - Importar coleção
   - Executar testes individuais
   - Analisar respostas

3. **Criar testes customizados:**
   - Modificar parâmetros
   - Adicionar novos cenários
   - Criar testes específicos

4. **Integrar com CI/CD:**
   - Usar Newman em pipelines
   - Gerar relatórios automáticos
   - Configurar alertas

---

**Nota**: Estes exemplos são parte do piloto CBD Real Digital. Para uso em produção, consulte a documentação oficial do Banco Central do Brasil. 