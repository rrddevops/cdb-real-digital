# 🚀 Guia Rápido - DBD Real Digital

## ⚡ Início Rápido

### 1. Setup Inicial

```bash
# Executar script de setup
./setup.sh

# Ou manualmente:
chmod +x setup.sh
./setup.sh
```

### 2. Configurar Credenciais

```bash
# Editar arquivo .env com suas credenciais
nano .env

# Exemplo de configuração:
RPC_URL=ws://host.docker.internal:8545
DEFAULT_ACCOUNT=0x1234567890abcdef...
KEY=0xabcdef1234567890...
ADMIN_ACCOUNT=0x1234567890abcdef...
ADMIN_KEY=0xabcdef1234567890...
```

### 3. Executar Serviços

```bash
# Executar todos os serviços
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f
```

## 🔧 Resolução de Problemas

### Problema: "pull access denied for timber"

**Causa**: As imagens customizadas não estão disponíveis publicamente.

**Solução**: O docker-compose.yaml foi corrigido para usar imagens públicas.

```bash
# Remover containers antigos
docker-compose down

# Limpar imagens
docker system prune -f

# Executar novamente
docker-compose up -d
```

### Problema: "version is obsolete"

**Causa**: A versão no docker-compose.yaml está obsoleta.

**Solução**: A versão foi removida do arquivo.

### Problema: APIs não respondem

```bash
# Verificar se containers estão rodando
docker-compose ps

# Verificar logs específicos
docker-compose logs timber
docker-compose logs zapp

# Verificar conectividade
curl http://localhost:3000/health
curl http://localhost:3100/health
```

### Problema: Nó não conecta à rede

```bash
# Verificar configuração
cat config.toml
cat static-nodes.json

# Verificar conectividade
telnet 200.218.66.38 30004

# Verificar peers
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
  http://localhost:8545
```

## 🌐 Acessos

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Frontend** | http://localhost:3000 | Interface web |
| **APIs** | http://localhost:3100 | APIs REST |
| **RPC** | http://localhost:8545 | JSON-RPC |
| **WebSocket** | ws://localhost:8546 | WebSocket RPC |

## 📋 Checklist de Configuração

- [ ] Docker e Docker Compose instalados
- [ ] Script setup.sh executado
- [ ] Arquivo .env configurado
- [ ] config.toml configurado
- [ ] static-nodes.json configurado
- [ ] Permissão solicitada ao BCB
- [ ] Containers rodando
- [ ] APIs respondendo
- [ ] Frontend acessível

## 🆘 Suporte

- **Email**: piloto.rd.tecnologia@bcb.gov.br
- **Documentação**: README.md
- **Exemplos**: pasta exemplos/
- **Logs**: docker-compose logs

## 📚 Próximos Passos

1. **Testar APIs**: Use o Postman Collection
2. **Executar Exemplos**: cd exemplos && npm install
3. **Configurar Privacidade**: Starlight/Rayls se necessário
4. **Integrar Aplicação**: Use as APIs REST 