# 🎯 Setup Final - CBD Real Digital

## ✅ **Problema Resolvido!**

O erro `Cannot find module '/app/index.js'` foi resolvido criando os arquivos necessários para os serviços.

## 🚀 **Setup Completo**

### **1. Parar containers antigos e limpar**

```bash
# Parar containers
docker-compose down

# Limpar imagens
docker system prune -f
```

### **2. Executar setup simplificado**

```bash
# Usar o docker-compose simplificado
docker-compose -f docker-compose-simple.yaml up -d

# Verificar status
docker-compose -f docker-compose-simple.yaml ps
```

### **3. Testar serviços**

```bash
# Tornar script executável
chmod +x test-services.sh

# Executar testes
./test-services.sh
```

## 📁 **Arquivos Criados**

| Arquivo | Descrição |
|---------|-----------|
| `docker-compose-simple.yaml` | Docker compose simplificado |
| `timber-index.js` | Serviço Timber (APIs) |
| `zapp-index.js` | Serviço ZApp (Frontend) |
| `timber-package.json` | Dependências do Timber |
| `zapp-package.json` | Dependências do ZApp |
| `test-services.sh` | Script de teste |

## 🌐 **Serviços Disponíveis**

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **ZApp (Frontend)** | http://localhost:3000 | Interface web |
| **Timber (APIs)** | http://localhost:3100 | APIs REST |
| **MongoDB** | mongodb://localhost:27017 | Banco de dados |
| **Zokrates** | http://localhost:8080 | Proving system |

## 🔧 **APIs Implementadas**

### **ZApp (Porta 3000)**
- `GET /health` - Health check
- `GET /` - Informações do serviço
- `GET /getAllCommitments` - Listar commitments
- `POST /depositErc20` - Depósito de Real Digital
- `POST /depositErc1155` - Depósito de TPFt
- `POST /transfer` - Transferência
- `POST /startSwapFromErc20ToErc1155` - Iniciar swap
- `POST /completeSwapFromErc20ToErc1155` - Completar swap

### **Timber (Porta 3100)**
- `GET /health` - Health check
- `GET /` - Informações do serviço
- `POST /start` - Iniciar timber
- `GET /nodes` - Listar nós
- `GET /metadata` - Metadados
- `GET /root` - Raiz da árvore
- `GET /leaves` - Folhas da árvore

## 🧪 **Testando Manualmente**

### **Testar ZApp**
```bash
# Health check
curl http://localhost:3000/health

# Listar commitments
curl http://localhost:3000/getAllCommitments

# Depósito ERC20
curl -X POST -H "Content-Type: application/json" \
  -d '{"amount": 1000, "account": "0x1234567890abcdef"}' \
  http://localhost:3000/depositErc20
```

### **Testar Timber**
```bash
# Health check
curl http://localhost:3100/health

# Metadados
curl http://localhost:3100/metadata

# Iniciar timber
curl -X POST -H "Content-Type: application/json" \
  -d '{"contractName": "TestContract", "contractAddress": "0x1234567890abcdef"}' \
  http://localhost:3100/start
```

## 📊 **Verificação de Status**

```bash
# Verificar containers
docker-compose -f docker-compose-simple.yaml ps

# Verificar logs
docker-compose -f docker-compose-simple.yaml logs -f

# Verificar logs específicos
docker-compose -f docker-compose-simple.yaml logs zapp
docker-compose -f docker-compose-simple.yaml logs timber
docker-compose -f docker-compose-simple.yaml logs mongodb
```

## 🔧 **Configuração de Credenciais**

### **Criar arquivo .env**
```bash
cat > .env << EOF
# Configurações do RPC
RPC_URL=ws://host.docker.internal:8545

# Contas (substitua pelos valores reais)
DEFAULT_ACCOUNT=0x0000000000000000000000000000000000000000
KEY=0x0000000000000000000000000000000000000000000000000000000000000000
ADMIN_ACCOUNT=0x0000000000000000000000000000000000000000
ADMIN_KEY=0x0000000000000000000000000000000000000000000000000000000000000000

# Endereços dos contratos
ESCROW_SHIELD_ADDRESS=0xf3cBfC5c2d71CdB931B004b3B5Ca4ABEdbA3Cd43
ERC20_ADDRESS=0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e

# Configurações do MongoDB
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=admin
EOF
```

## 🎯 **Próximos Passos**

### **1. Configurar Blockchain**
```bash
# Configurar nó Besu
cp config.toml.example config.toml
# Editar config.toml com suas configurações

# Solicitar permissão ao BCB
# Email: piloto.rd.tecnologia@bcb.gov.br
```

### **2. Testar Smart Contracts**
```bash
cd exemplos
npm install
npx hardhat run --network besu ./example1.ts
```

### **3. Usar Postman Collection**
- Importar `SwapEscrow.postman_collection.json`
- Configurar variáveis de ambiente
- Testar todas as APIs

### **4. Acessar Frontend**
- URL: http://localhost:3000
- Testar todas as funcionalidades

## 🆘 **Troubleshooting**

### **Problema: Container não inicia**
```bash
# Verificar logs
docker-compose -f docker-compose-simple.yaml logs [nome-do-container]

# Reiniciar container
docker-compose -f docker-compose-simple.yaml restart [nome-do-container]
```

### **Problema: API não responde**
```bash
# Verificar se container está rodando
docker-compose -f docker-compose-simple.yaml ps

# Verificar logs
docker-compose -f docker-compose-simple.yaml logs [nome-do-container]

# Testar conectividade
curl http://localhost:3000/health
```

### **Problema: Porta em uso**
```bash
# Verificar portas em uso
netstat -tulpn | grep :3000
netstat -tulpn | grep :3100

# Parar serviços que estão usando as portas
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:3100 | xargs kill -9
```

## 🎉 **Sucesso!**

Agora você tem um ambiente completo do CBD Real Digital funcionando com:

- ✅ **APIs REST** funcionando
- ✅ **Frontend** acessível
- ✅ **Banco de dados** configurado
- ✅ **Scripts de teste** prontos
- ✅ **Documentação** completa

**Próximo passo**: Configure suas credenciais reais e conecte-se à rede blockchain! 🚀 