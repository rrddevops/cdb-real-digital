# 🐳 Configuração Docker - CBD Real Digital

## 🎯 **Problema Resolvido**

O erro `error getting credentials` ocorria porque o docker-compose original tentava baixar imagens customizadas que requerem credenciais especiais. Agora criamos uma versão que usa **apenas imagens públicas**.

## 🚀 **Solução: Docker Compose Simplificado**

### **Opção 1: Usar docker-compose-simple.yaml (Recomendado)**

```bash
# 1. Parar containers antigos
docker-compose down

# 2. Limpar imagens problemáticas
docker system prune -f

# 3. Usar o docker-compose simplificado
docker-compose -f docker-compose-simple.yaml up -d

# 4. Verificar status
docker-compose -f docker-compose-simple.yaml ps
```

### **Opção 2: Usar docker-compose.yaml corrigido**

```bash
# 1. Parar containers antigos
docker-compose down

# 2. Limpar imagens
docker system prune -f

# 3. Usar o docker-compose corrigido
docker-compose up -d

# 4. Verificar status
docker-compose ps
```

## 📋 **Imagens Utilizadas (Todas Públicas)**

| Serviço | Imagem | Fonte | Status |
|---------|--------|-------|--------|
| **MongoDB** | `mongo:6.0` | Docker Hub | ✅ Pública |
| **Node.js** | `node:18-alpine` | Docker Hub | ✅ Pública |
| **Zokrates** | `ghcr.io/eyblockchain/zokrates-worker-updated:latest` | GitHub Container Registry | ✅ Pública |

## 🔧 **Configuração das Variáveis de Ambiente**

### **Criar arquivo .env**

```bash
# Criar arquivo .env
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

## 🌐 **Portas e Acessos**

| Serviço | Porta Externa | Porta Interna | URL |
|---------|---------------|---------------|-----|
| **MongoDB** | 27017 | 27017 | `mongodb://localhost:27017` |
| **Zokrates** | 8080 | 8080 | `http://localhost:8080` |
| **Timber** | 3100 | 80 | `http://localhost:3100` |
| **ZApp** | 3000 | 3000 | `http://localhost:3000` |

## 📊 **Verificação do Setup**

### **1. Verificar Containers**

```bash
# Verificar se todos os containers estão rodando
docker-compose -f docker-compose-simple.yaml ps

# Verificar logs
docker-compose -f docker-compose-simple.yaml logs -f
```

### **2. Testar Conectividade**

```bash
# Testar MongoDB
curl http://localhost:27017

# Testar Zokrates
curl http://localhost:8080

# Testar Timber
curl http://localhost:3100

# Testar ZApp
curl http://localhost:3000
```

### **3. Verificar Logs Específicos**

```bash
# Logs do MongoDB
docker-compose -f docker-compose-simple.yaml logs mongodb

# Logs do Timber
docker-compose -f docker-compose-simple.yaml logs timber

# Logs do ZApp
docker-compose -f docker-compose-simple.yaml logs zapp

# Logs do Zokrates
docker-compose -f docker-compose-simple.yaml logs zokrates
```

## 🔧 **Troubleshooting**

### **Problema: "Port already in use"**

```bash
# Verificar portas em uso
netstat -tulpn | grep :3000
netstat -tulpn | grep :3100
netstat -tulpn | grep :27017

# Parar serviços que estão usando as portas
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:3100 | xargs kill -9
sudo lsof -ti:27017 | xargs kill -9
```

### **Problema: "Container keeps restarting"**

```bash
# Verificar logs do container
docker-compose -f docker-compose-simple.yaml logs [nome-do-container]

# Verificar recursos do sistema
docker stats

# Reiniciar container específico
docker-compose -f docker-compose-simple.yaml restart [nome-do-container]
```

### **Problema: "Cannot connect to MongoDB"**

```bash
# Verificar se MongoDB está rodando
docker-compose -f docker-compose-simple.yaml logs mongodb

# Conectar manualmente ao MongoDB
docker exec -it cbd-mongodb mongosh -u admin -p admin
```

## 🎯 **Próximos Passos**

1. **Execute o setup:**
   ```bash
   docker-compose -f docker-compose-simple.yaml up -d
   ```

2. **Configure suas credenciais** no arquivo `.env`

3. **Teste as APIs:**
   ```bash
   curl http://localhost:3000/health
   curl http://localhost:3100/health
   ```

4. **Acesse o frontend:**
   - URL: http://localhost:3000

5. **Use o Postman Collection:**
   - Importe `SwapEscrow.postman_collection.json`

## 🆘 **Suporte**

Se ainda houver problemas:

- **Logs completos**: `docker-compose -f docker-compose-simple.yaml logs`
- **Status dos containers**: `docker-compose -f docker-compose-simple.yaml ps`
- **Email**: `piloto.rd.tecnologia@bcb.gov.br`

---

**✅ Agora todas as imagens são públicas e não requerem credenciais especiais!** 