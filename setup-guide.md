# Guia de Setup - DBD Real Digital

## 1. Configuração do Nó Participante

### 1.1 Download e Instalação do Hyperledger Besu
```bash
# Baixar Hyperledger Besu v23.10.1
wget https://github.com/hyperledger/besu/releases/download/23.10.1/besu-23.10.1.tar.gz
tar -xzf besu-23.10.1.tar.gz
cd besu-23.10.1
```

### 1.2 Configuração dos Arquivos

#### config.toml
```toml
# Node Information
data-path="/caminho/para/a/pasta/data"
genesis-file="/caminho/para/o/arquivo/genesis.json"
revert-reason-enabled=true
identity="fullnode-seu-participante-1"

logging="INFO"
nat-method="NONE"
min-gas-price=0

# P2P network
p2p-enabled=true
discovery-enabled=false
static-nodes-file="/caminho/para/o/arquivo/static-nodes.json"
p2p-port=30303
max-peers=25

# JSON-RPC
rpc-http-api=["DEBUG", "ETH", "ADMIN", "WEB3", "QBFT", "NET", "PERM", "TXPOOL", "PLUGINS", "MINER", "TRACE"]
rpc-http-cors-origins=["*"]
rpc-http-enabled=true
rpc-http-host="0.0.0.0"
rpc-http-port=8545

# Permissioning
permissions-nodes-contract-enabled=true
permissions-nodes-contract-address="0x0000000000000000000000000000000000009999"
permissions-nodes-contract-version=2
permissions-accounts-contract-enabled=true
permissions-accounts-contract-address="0x359e4Ac15c34db530DC61C93D3E646103A569a0A"
```

### 1.3 Obter Enode ID
```bash
besu --data-path=Node-01/data/ public-key export-address
```

### 1.4 Solicitar Permissão
Enviar email para: `piloto.rd.tecnologia@bcb.gov.br`
- Assunto: `DEINF | Permissão de Nó na Rede | Participante: [nome do participante]`
- Conteúdo: Enode completo no formato `enode://enodeID@IP_RSFN:PORT`

### 1.5 Executar o Nó
```bash
besu --config-file=config.toml
```

## 2. Configuração do Docker (Opcional)

### 2.1 Usar docker-compose.yaml
```bash
# Configurar variáveis de ambiente
export RPC_URL=ws://[HOST]:[PORT]
export DEFAULT_ACCOUNT=[ADDRESS_ACCOUNT]
export KEY=[PK]
export ADMIN_ACCOUNT=[ADDRESS_ACCOUNT]
export ADMIN_KEY=[PK]

# Executar serviços
docker-compose up -d
```

## 3. Integração com Smart Contracts

### 3.1 Configurar Hardhat
```bash
cd exemplos
npm install
```

### 3.2 Configurar hardhat.config.ts
```typescript
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
    },
  },
  networks: {
    besu: {
      url: "http://seu-node:8545",
      accounts: ["sua-chave-privada"]
    }
  }
};

export default config;
```

### 3.3 Executar Exemplos
```bash
# Exemplo 1: Enable Account / Mint and Burn
npx hardhat run --network besu ./example1.ts

# Exemplo 2: Transferência de CBDC
npx hardhat run --network besu ./example2.ts

# Exemplo 3: Ativar endereço para cliente
npx hardhat run --network besu ./example3.ts
```

## 4. APIs Disponíveis

### 4.1 Endpoints Principais
- **Timber (Merkle Tree)**: `http://localhost:3100`
- **ZApp (Frontend)**: `http://localhost:3000`
- **Zokrates (Proving)**: `http://localhost:8080`

### 4.2 APIs REST
- **Depósito**: `POST /depositErc20`, `POST /depositErc1155`
- **Transferência**: `POST /transfer`
- **Saque**: `POST /withdraw`
- **Swap**: `POST /startSwapFromErc20ToErc1155`
- **Consulta**: `GET /getAllCommitments`

### 4.3 Postman Collection
Importar `SwapEscrow.postman_collection.json` no Postman para testar todas as APIs.

## 5. Smart Contracts Principais

### 5.1 Contratos Core
- **RealDigital**: Moeda digital principal
- **RealTokenizado**: Token representativo
- **TPFt**: Títulos Públicos Federais tokenizados
- **AddressDiscovery**: Descoberta de endereços de contratos

### 5.2 Operações Disponíveis
- **1002**: Liquidação de oferta pública
- **1012**: Resgate de TPFt
- **1052**: Compra e venda de TPFt
- **1054**: Operação compromissada
- **1056**: Recompra e revenda

## 6. Frontend

### 6.1 Acesso ao Frontend
- URL: `http://localhost:3000`
- Funcionalidades: Depósito, transferência, saque, swap
- Interface intuitiva para todas as operações

### 6.2 Funcionalidades do Frontend
- Dashboard com saldos
- Formulários para operações
- Histórico de transações
- Configurações de carteira

## 7. Segurança e Permissionamento

### 7.1 Controle de Acesso
- Permissionamento onchain via contratos
- Roles específicas para cada operação
- Controle de carteiras habilitadas

### 7.2 Privacidade
- **Starlight**: Solução de privacidade para transferências
- **Rayls**: Sistema de privacidade adicional
- **Anonymous Zether**: Protocolo de privacidade avançado

## 8. Monitoramento e Logs

### 8.1 Verificar Status do Nó
```bash
# Verificar peers conectados
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
  http://localhost:8545

# Verificar detalhes dos peers
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
  http://localhost:8545
```

### 8.2 Logs Importantes
- Sincronização: `Starting full sync`
- Conexão P2P: `Connected to peer`
- Erros de permissão: `Permission denied`

## 9. Troubleshooting

### 9.1 Problemas Comuns
1. **Nó não conecta**: Verificar static-nodes.json e firewall
2. **Permissão negada**: Aguardar autorização do BCB
3. **Sincronização lenta**: Verificar banda de rede
4. **APIs não respondem**: Verificar se serviços estão rodando

### 9.2 Contatos de Suporte
- Email: `piloto.rd.tecnologia@bcb.gov.br`
- Documentação: Arquivos .md no repositório
- Exemplos: Pasta `exemplos/`

## 10. Próximos Passos

1. **Configurar nó**: Seguir passos 1-5
2. **Testar conectividade**: Verificar peers e sincronização
3. **Configurar APIs**: Usar docker-compose ou setup manual
4. **Testar operações**: Executar exemplos do Hardhat
5. **Integrar aplicação**: Usar APIs REST ou frontend
6. **Implementar privacidade**: Configurar Starlight/Rayls se necessário 