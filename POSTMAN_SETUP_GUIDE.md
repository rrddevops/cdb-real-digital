# 🚀 CBD Real Digital - Guia Postman

## 📋 Visão Geral

Este guia explica como configurar e usar a coleção do Postman para testar todas as APIs do CBD Real Digital. A coleção inclui testes para depósitos, swaps, transferências e consultas.

## 🎯 Funcionalidades da Coleção

### 📊 **Categorias de Testes**

1. **🔍 Health Check** - Verificação de saúde das APIs
2. **📊 Consultas e Status** - Consultas e verificações de status
3. **💰 Depósitos** - Operações de depósito de Real Digital e TPFt
4. **🔄 Swaps** - Operações de swap entre tokens
5. **📤 Transferências** - Transferências de tokens
6. **⚙️ Configurações** - Configurações do sistema
7. **🧪 Testes de Performance** - Testes de carga e performance
8. **📋 Relatórios** - Relatórios e análises

## 🛠️ Configuração Inicial

### 1. **Importar a Coleção**

1. Abra o **Postman**
2. Clique em **"Import"**
3. Selecione o arquivo: `CBD_Real_Digital_Postman_Collection.json`
4. Clique em **"Import"**

### 2. **Configurar Variáveis de Ambiente**

#### **Variáveis Obrigatórias:**

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `base_url_zapp` | `http://localhost:3000` | API ZApp |
| `base_url_timber` | `http://localhost:3100` | API Timber |
| `base_url_zokrates` | `http://localhost:8080` | Zokrates |
| `test_account` | `0x1234567890abcdef1234567890abcdef12345678` | Conta de teste |
| `real_digital_contract` | `0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e` | Contrato Real Digital |
| `tpft_contract` | `0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E` | Contrato TPFt |

#### **Como Configurar:**

1. Clique em **"Environments"** no Postman
2. Crie um novo ambiente: **"CBD Real Digital"**
3. Adicione as variáveis acima
4. Selecione o ambiente criado

### 3. **Verificar Ambiente**

Antes de executar os testes, certifique-se de que o ambiente está rodando:

```bash
# Verificar se os containers estão rodando
docker ps

# Verificar se as APIs estão respondendo
curl http://localhost:3000
curl http://localhost:3100
```

## 🧪 Executando os Testes

### **Sequência Recomendada:**

#### **1. Health Check**
```bash
# Executar todos os testes de saúde
1. ZApp API Health
2. Timber API Health
3. Zokrates Health
```

#### **2. Setup de Dados**
```bash
# Configurar dados de teste
1. Deposit Real Digital (ERC-20) - 1000 DREX
2. Deposit TPFt (ERC-1155) - 100 TPFt Série 1
3. Deposit Large Amount Real Digital - 10000 DREX
4. Deposit Multiple TPFt Series - 500 TPFt Série 2
```

#### **3. Testes de Swap**
```bash
# Testar operações de swap
1. Start Swap - Real Digital to TPFt
2. Start Swap - Large Amount
3. Start Swap - TPFt Series 2
4. Get Active Swaps
5. Complete Swap
```

#### **4. Testes de Transferência**
```bash
# Testar transferências
1. Transfer Real Digital
2. Transfer TPFt
```

#### **5. Consultas e Relatórios**
```bash
# Verificar dados
1. Get All Commitments
2. Get Transaction Report
3. Get Balance Report
```

## 📝 Exemplos de Uso

### **Exemplo 1: Depósito de Real Digital**

**Endpoint:** `POST {{base_url_zapp}}/depositErc20`

**Body:**
```json
{
    "amount": 1000.00,
    "account": "{{test_account}}"
}
```

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "commitmentId": "abc123",
        "amount": 1000.00,
        "account": "0x1234567890abcdef1234567890abcdef12345678"
    }
}
```

### **Exemplo 2: Swap Real Digital → TPFt**

**Endpoint:** `POST {{base_url_zapp}}/startSwapFromErc20ToErc1155`

**Body:**
```json
{
    "erc20Address": "{{real_digital_contract}}",
    "counterParty": "{{test_account}}",
    "amountSent": 1000,
    "tokenIdReceived": 1,
    "tokenReceivedAmount": 100
}
```

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": {
        "swapId": "swap123",
        "amountSent": 1000,
        "tokenReceivedAmount": 100
    }
}
```

### **Exemplo 3: Consulta de Commitments**

**Endpoint:** `GET {{base_url_zapp}}/getAllCommitments`

**Resposta Esperada:**
```json
{
    "status": "success",
    "data": [
        {
            "commitmentId": "abc123",
            "type": "deposit",
            "amount": 1000.00,
            "timestamp": "2025-06-25T00:00:00Z"
        }
    ],
    "count": 1
}
```

## 🔧 Configurações Avançadas

### **Variáveis Automáticas**

A coleção inclui scripts que preenchem automaticamente:

- `commitment_id` - ID do commitment criado
- `swap_id` - ID do swap iniciado
- `timestamp` - Timestamp da operação
- `operation_id` - ID único da operação

### **Testes Automáticos**

Cada requisição inclui testes automáticos:

```javascript
// Verificações automáticas
pm.test('Status code is 200', function () {
    pm.response.to.have.status(200);
});

pm.test('Response is JSON', function () {
    pm.response.to.be.json;
});

pm.test('Response time is less than 5000ms', function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});
```

### **Logs e Debug**

Para habilitar logs detalhados:

1. Abra o **Console** do Postman (View → Show Postman Console)
2. Execute as requisições
3. Verifique os logs no console

## 🚀 Execução em Lote

### **Runner do Postman**

1. Clique em **"Runner"** no Postman
2. Selecione a coleção **"CBD Real Digital"**
3. Configure as opções:
   - **Iterations**: 1
   - **Delay**: 1000ms
   - **Environment**: CBD Real Digital
4. Clique em **"Run"**

### **Execução via Newman (CLI)**

```bash
# Instalar Newman
npm install -g newman

# Executar coleção
newman run CBD_Real_Digital_Postman_Collection.json \
  --environment CBD_Real_Digital_Environment.json \
  --reporters cli,json \
  --reporter-json-export results.json
```

## 🐛 Troubleshooting

### **Problemas Comuns**

#### 1. **Erro de Conexão**
```
Error: connect ECONNREFUSED 127.0.0.1:3000
```
**Solução:**
- Verificar se os containers estão rodando
- Verificar se as portas estão corretas
- Executar: `docker ps`

#### 2. **Erro de CORS**
```
Access to fetch at 'http://localhost:3000' from origin 'null' has been blocked by CORS policy
```
**Solução:**
- Verificar configuração do Nginx
- Verificar se o proxy está funcionando
- Usar Postman (não tem problemas de CORS)

#### 3. **Erro de Validação**
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

### **Logs de Debug**

Para obter logs detalhados:

```bash
# Logs do ZApp
docker logs cbd-zapp

# Logs do Timber
docker logs cbd-timber

# Logs do Frontend
docker logs cbd-frontend
```

## 📊 Monitoramento

### **Métricas Importantes**

- **Tempo de Resposta**: < 5 segundos
- **Taxa de Sucesso**: > 95%
- **Throughput**: > 100 req/min

### **Alertas**

Configure alertas para:
- Status code != 200
- Response time > 5s
- Error rate > 5%

## 🔄 Integração com CI/CD

### **Pipeline de Testes**

```yaml
# Exemplo para GitHub Actions
name: API Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Start Environment
        run: |
          chmod +x *.sh
          ./start-environment.sh
      - name: Run API Tests
        run: |
          npm install -g newman
          newman run CBD_Real_Digital_Postman_Collection.json
      - name: Stop Environment
        run: ./stop-environment.sh
```

## 📚 Recursos Adicionais

### **Documentação Relacionada**
- [README.md](README.md) - Documentação principal
- [SCRIPTS_GUIDE.md](SCRIPTS_GUIDE.md) - Guia dos scripts
- [FRONTEND_GUIDE.md](FRONTEND_GUIDE.md) - Guia do frontend

### **Comandos Úteis**

```bash
# Iniciar ambiente
./start-environment.sh

# Executar testes de conectividade
./test-services.sh

# Configurar dados de teste
./setup-test-data.sh

# Ver logs
./cbd-control.sh logs
```

---

**Nota**: Esta coleção é parte do piloto CBD Real Digital. Para uso em produção, consulte a documentação oficial do Banco Central do Brasil. 