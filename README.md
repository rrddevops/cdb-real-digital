# 🏦 CBD Real Digital - Kit Onboarding

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hyperledger Besu](https://img.shields.io/badge/Hyperledger-Besu-2F3134?logo=hyperledger)](https://www.hyperledger.org/use/besu)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](https://docs.docker.com/compose/)

> **Kit de integração para o piloto do Real Digital (DREX)** - Moeda digital brasileira desenvolvida pelo Banco Central do Brasil

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Arquitetura](#-arquitetura)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Configuração Detalhada](#-configuração-detalhada)
- [APIs e Endpoints](#-apis-e-endpoints)
- [Smart Contracts](#-smart-contracts)
- [Frontend](#-frontend)
- [Exemplos de Uso](#-exemplos-de-uso)
- [Troubleshooting](#-troubleshooting)
- [Documentação](#-documentação)
- [Suporte](#-suporte)

## 🎯 Sobre o Projeto

O **CBD Real Digital** é o projeto piloto do Banco Central do Brasil para implementar a moeda digital brasileira (DREX). Este kit de onboarding fornece todas as ferramentas necessárias para que participantes autorizados se integrem à rede blockchain do Real Digital.

### 🚀 Principais Funcionalidades

- ✅ **Moeda Digital**: Real Digital (DREX) como CBDC
- ✅ **Títulos Tokenizados**: TPFt (Títulos Públicos Federais tokenizados)
- ✅ **Operações Financeiras**: Compra, venda, swap, resgate
- ✅ **Privacidade**: Soluções Starlight, Rayls e Anonymous Zether
- ✅ **APIs REST**: Interface completa para integração
- ✅ **Frontend**: Interface web intuitiva
- ✅ **Smart Contracts**: Contratos Solidity para todas as operações

## 🏗️ Arquitetura

### Tecnologias Utilizadas

| Componente | Tecnologia | Versão |
|------------|------------|---------|
| **Blockchain** | Hyperledger Besu | 23.10.1 |
| **Consenso** | QBFT | - |
| **Smart Contracts** | Solidity | 0.8.19 |
| **Frontend** | React/Node.js | - |
| **APIs** | REST/WebSocket | - |
| **Banco de Dados** | MongoDB | - |
| **Containerização** | Docker Compose | - |

### Topologia da Rede

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend Web  │    │   ZApp API      │    │   Timber API    │
│   (Porta 80)    │◄──►│   (Porta 3000)  │◄──►│   (Porta 3100)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   MongoDB       │
                    │   (Porta 27017) │
                    └─────────────────┘
```

## 📋 Pré-requisitos

### Requisitos de Sistema

- **Sistema Operacional**: Linux, Windows, macOS
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Node.js**: 16+
- **NPM**: 8+
- **Git**: 2.30+

### Requisitos de Rede

- **Acesso à RSFN**: Rede do Sistema Financeiro Nacional
- **Banda Mínima**: 6Mbps (recomendado 10Mbps)
- **Portas**: 30303 (P2P), 8545 (RPC), 3000 (Frontend), 3100 (APIs)
- **Firewall**: Configurado para permitir tráfego P2P

### Requisitos de Infraestrutura

- **CPU**: 4 cores mínimo
- **RAM**: 8GB mínimo
- **Storage**: 100GB mínimo
- **Redundância**: Links de rede redundantes

## ⚡ Instalação Rápida

### 1. Clone o Repositório

```bash
git clone https://github.com/bcb/pilotord-kit-onboarding.git
cd pilotord-kit-onboarding
```

### 2. Configuração Inicial

```bash
# Copiar arquivos de configuração
cp config.toml.example config.toml
cp static-nodes.json.example static-nodes.json

# Editar configurações
nano config.toml
nano static-nodes.json
```

### 3. Executar com Docker (Recomendado)

```bash
# Configurar variáveis de ambiente
export RPC_URL=ws://localhost:8545
export DEFAULT_ACCOUNT=0x...
export KEY=0x...
export ADMIN_ACCOUNT=0x...
export ADMIN_KEY=0x...

# Executar serviços
docker-compose up -d
```

### 4. Verificar Instalação

```bash
# Verificar containers
docker-compose ps

# Verificar APIs
curl http://localhost:3000/health
curl http://localhost:3100/health
```

## 🔧 Configuração Detalhada

### Configuração do Nó Blockchain

#### 1. Download do Hyperledger Besu

```bash
# Baixar versão específica
wget https://github.com/hyperledger/besu/releases/download/23.10.1/besu-23.10.1.tar.gz
tar -xzf besu-23.10.1.tar.gz
cd besu-23.10.1
```

#### 2. Configuração do config.toml

```toml
# Node Information
data-path="/caminho/para/a/pasta/data"
genesis-file="/caminho/para/o/arquivo/genesis.json"
revert-reason-enabled=true
identity="fullnode-seu-participante-1"

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

#### 3. Solicitar Permissão

```bash
# Obter enode ID
besu --data-path=Node-01/data/ public-key export-address

# Enviar email para: piloto.rd.tecnologia@bcb.gov.br
# Assunto: DEINF | Permissão de Nó na Rede | Participante: [nome]
# Conteúdo: enode://enodeID@IP_RSFN:PORT
```

#### 4. Executar o Nó

```bash
besu --config-file=config.toml
```

### Configuração das APIs

#### 1. Configurar Variáveis de Ambiente

```bash
# Criar arquivo .env
cat > .env << EOF
RPC_URL=ws://localhost:8545
DEFAULT_ACCOUNT=0x...
KEY=0x...
ADMIN_ACCOUNT=0x...
ADMIN_KEY=0x...
ESCROW_SHIELD_ADDRESS=0xf3cBfC5c2d71CdB931B004b3B5Ca4ABEdbA3Cd43
ERC20_ADDRESS=0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e
EOF
```

#### 2. Executar Serviços

```bash
# Executar todos os serviços
docker-compose up -d

# Verificar logs
docker-compose logs -f
```

## 🔌 APIs e Endpoints

### Endpoints Principais

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Frontend** | `http://localhost:3000` | Interface web |
| **Timber API** | `http://localhost:3100` | APIs de Merkle Tree |
| **Zokrates** | `http://localhost:8080` | Proving system |

### APIs REST Disponíveis

#### Operações de Depósito

```bash
# Depósito de Real Digital
POST /depositErc20
{
  "amount": 1000,
  "account": "0x..."
}

# Depósito de TPFt
POST /depositErc1155
{
  "tokenId": 1,
  "amount": 10,
  "account": "0x..."
}
```

#### Operações de Transferência

```bash
# Transferência privada
POST /transfer
{
  "to": "0x...",
  "amount": 500
}
```

#### Operações de Swap

```bash
# Swap Real Digital → TPFt
POST /startSwapFromErc20ToErc1155
{
  "erc20Address": "0x...",
  "counterParty": "0x...",
  "amountSent": 1000,
  "tokenIdReceived": 1,
  "tokenReceivedAmount": 5
}

# Completar swap
POST /completeSwapFromErc20ToErc1155
{
  "swapId": 123456
}
```

#### Consultas

```bash
# Consultar commitments
GET /getAllCommitments

# Consultar saldo
GET /balance
```

### Postman Collection

Importe o arquivo `SwapEscrow.postman_collection.json` no Postman para testar todas as APIs.

## 📜 Smart Contracts

### Contratos Principais

| Contrato | Endereço | Descrição |
|----------|----------|-----------|
| **RealDigital** | `0x...` | Moeda digital principal |
| **RealTokenizado** | `0x...` | Token representativo |
| **TPFt** | `0x...` | Títulos Públicos Federais |
| **AddressDiscovery** | `0xDc2633B0cdA829bd2A54Db3Fd39b474aa0953c70` | Descoberta de contratos |

### Operações Disponíveis

#### Operação 1002 - Liquidação de Oferta Pública
```solidity
function auctionPlacement(
    uint256 operationId,
    uint256 cnpj8Sender,
    uint256 cnpj8Receiver,
    CallerPart callerPart,
    TPFtData tpftData,
    uint256 tpftAmount,
    uint256 unitPrice
) external
```

#### Operação 1052 - Compra e Venda
```solidity
function trade(
    uint256 operationId,
    uint256 cnpj8Sender,
    uint256 cnpj8Receiver,
    CallerPart callerPart,
    TPFtData tpftData,
    uint256 tpftAmount,
    uint256 unitPrice
) external
```

#### Operação 1054 - Operação Compromissada
```solidity
function tradeRepo(
    uint256 operationId,
    uint256 cnpj8Sender,
    uint256 cnpj8Receiver,
    CallerPart callerPart,
    TPFtData tpftData,
    uint256 tpftAmount,
    uint256 unitPrice,
    uint256 returnUnitPrice,
    uint256 returnDate
) external
```

### Exemplos de Uso

```bash
# Navegar para pasta de exemplos
cd exemplos

# Instalar dependências
npm install

# Executar exemplos
npx hardhat run --network besu ./example1.ts
npx hardhat run --network besu ./example2.ts
npx hardhat run --network besu ./example3.ts
```

## 🖥️ Frontend

### Acesso ao Frontend

- **URL**: `http://localhost:3000`
- **Usuário**: Configurado via variáveis de ambiente
- **Senha**: Configurada via variáveis de ambiente

### Funcionalidades Disponíveis

- 📊 **Dashboard**: Visão geral de saldos e operações
- 💰 **Depósito**: Interface para depósitos de Real Digital e TPFt
- 🔄 **Transferência**: Transferências privadas entre carteiras
- 💱 **Swap**: Troca entre Real Digital e TPFt
- 📈 **Histórico**: Histórico completo de transações
- ⚙️ **Configurações**: Configurações de carteira e permissões

### Screenshots

![Dashboard](docs/images/dashboard.png)
![Operações](docs/images/operations.png)

## 📚 Exemplos de Uso

### Exemplo 1: Enable Account / Mint and Burn

```typescript
// example1.ts
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Account:", deployer.address);
  
  // Habilitar conta
  const enableAccount = await ethers.getContractAt("RealDigitalEnableAccount", "0x...");
  await enableAccount.enableAccount("0x...");
  
  // Mint Real Digital
  const str = await ethers.getContractAt("STR", "0x...");
  await str.requestToMint(1000000); // 10.000,00 DREX
}
```

### Exemplo 2: Transferência de CBDC

```typescript
// example2.ts
import { ethers } from "hardhat";

async function main() {
  const realDigital = await ethers.getContractAt("RealDigital", "0x...");
  
  // Buscar conta default
  const defaultAccount = await ethers.getContractAt("RealDigitalDefaultAccount", "0x...");
  const account = await defaultAccount.defaultAccount(12345678);
  
  // Transferir
  await realDigital.transfer(account, 500000); // 5.000,00 DREX
}
```

### Exemplo 3: Operação com TPFt

```typescript
// example3.ts
import { ethers } from "hardhat";

async function main() {
  const tpft = await ethers.getContractAt("ITPFt", "0x...");
  
  // Consultar saldo
  const balance = await tpft.balanceOf("0x...", 1);
  console.log("Saldo TPFt:", balance.toString());
}
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Erro de Permissão no Docker

```bash
# Problema: pull access denied for timber
# Solução: As imagens são customizadas, precisam ser construídas

# Construir imagens localmente
docker build -t timber ./timber
docker build -t zapp-escrow ./zapp
docker build -t starlight-mongo ./mongo
```

#### 2. Nó não Conecta à Rede

```bash
# Verificar static-nodes.json
cat static-nodes.json

# Verificar firewall
sudo ufw status

# Verificar conectividade
telnet 200.218.66.38 30004
```

#### 3. APIs não Respondem

```bash
# Verificar containers
docker-compose ps

# Verificar logs
docker-compose logs timber
docker-compose logs zapp

# Verificar variáveis de ambiente
docker-compose config
```

#### 4. Erro de Sincronização

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

### Logs Importantes

```bash
# Logs de sincronização
grep "Starting full sync" besu.log

# Logs de conexão P2P
grep "Connected to peer" besu.log

# Logs de erro de permissão
grep "Permission denied" besu.log
```

## 📖 Documentação

### Documentação Técnica

- [Arquitetura do Piloto](arquitetura.md)
- [Conexão com a Rede](ingresso.md)
- [Smart Contracts - Real Digital](smartcontracts.md)
- [Smart Contracts - Títulos](smartcontractsTitulos.md)
- [Exemplos de Interação](exemplos/README.md)

### Documentação de Privacidade

- [Anonymous Zether](AnonymousZether.md)
- [Starlight](Starlight.md)
- [Rayls](Rayls.md)

### Documentação de Operações

- [Depósitos](docs/DEPOSITOS.md)
- [Swaps](docs/SWAPS.md)
- [Erros](docs/ERROS.md)

## 🆘 Suporte

### Contatos

- **Email**: `piloto.rd.tecnologia@bcb.gov.br`
- **Assunto**: `DEINF | [Tipo de Solicitação] | Participante: [Nome]`

### Tipos de Solicitação

- **Permissão de Nó**: Solicitar autorização para conectar nó
- **Suporte Técnico**: Problemas de configuração ou operação
- **Dúvidas**: Esclarecimentos sobre funcionalidades
- **Feedback**: Sugestões de melhoria

### Recursos Adicionais

- **Postman Collection**: `SwapEscrow.postman_collection.json`
- **Exemplos**: Pasta `exemplos/`
- **Configurações**: Arquivos `config.toml`, `genesis.json`, `static-nodes.json`

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuição

Para contribuir com o projeto:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

**Desenvolvido pelo Banco Central do Brasil** 🇧🇷

*Este é um projeto piloto em ambiente de testes. A arquitetura está sujeita a evoluções que serão refletidas na documentação.*
