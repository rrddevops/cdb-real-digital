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

### 📊 Diagrama da Infraestrutura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CBD Real Digital - Ambiente                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │   Frontend Web  │    │   ZApp API      │    │   Timber API    │     │
│  │   (Porta 80)    │◄──►│   (Porta 3000)  │◄──►│   (Porta 3100)  │     │
│  │   cbd-frontend  │    │   cbd-zapp      │    │   cbd-timber    │     │
│  │   nginx:alpine  │    │   node:18       │    │   node:18       │     │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘     │
│           │                       │                       │             │
│           └───────────────────────┼───────────────────────┘             │
│                                   │                                     │
│                    ┌─────────────────┐    ┌─────────────────┐          │
│                    │   MongoDB       │    │   Zokrates      │          │
│                    │   (Porta 27017) │    │   (Porta 8080)  │          │
│                    │   cbd-mongodb   │    │   cbd-zokrates  │          │
│                    │   mongo:6.0     │    │   zokrates-img  │          │
│                    └─────────────────┘    └─────────────────┘          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Rede Docker (bridge)                        │   │
│  │              Comunicação entre containers                      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Volumes Persistentes                        │   │
│  │  mongodb-data:/data/db    (Dados do MongoDB)                   │   │
│  │  proving-files:/app/output (Arquivos de prova)                 │   │
│  │  circuits:/app/circuits    (Circuitos Zokrates)                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        Acesso Externo                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  🌐 Navegador Web: http://localhost                                    │
│  🔌 API ZApp: http://localhost:3000                                   │
│  📊 API Timber: http://localhost:3100                                 │
│  🧮 Zokrates: http://localhost:8080                                   │
│  🗄️  MongoDB: localhost:27017                                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 🔧 Detalhes dos Serviços

| Serviço | Container | Imagem | Porta | Descrição |
|---------|-----------|--------|-------|-----------|
| **Frontend Web** | `cbd-frontend` | `nginx:alpine` | 80 | Interface web principal |
| **ZApp API** | `cbd-zapp` | `node:18-alpine` | 3000 | API de operações |
| **Timber API** | `cbd-timber` | `node:18-alpine` | 3100 | API de logs/commitments |
| **MongoDB** | `cbd-mongodb` | `mongo:6.0` | 27017 | Banco de dados |
| **Zokrates** | `cbd-zokrates` | `zokrates-worker` | 8080 | Proving system |

### 🌐 Fluxo de Dados

```
1. Usuário → Frontend (Nginx) → ZApp API → MongoDB
2. Frontend → Timber API → MongoDB (logs)
3. ZApp API → Zokrates → Proving files
4. ZApp API ↔ Timber API (sincronização)
```

## 🎯 Funcionalidades do Frontend

### 📊 Dashboard
- **Saldo em Tempo Real**: Real Digital e TPFt
- **Atividade Recente**: Últimas transações
- **Status da Rede**: Informações de conectividade
- **Swaps Ativos**: Operações pendentes

### 💱 Troca de Tokens
- **Swap Real Digital ↔ TPFt**: Interface intuitiva
- **Cálculo Automático**: Taxas de câmbio em tempo real
- **Gestão de Swaps**: Visualizar e completar operações
- **Histórico Completo**: Todas as transações

### 💰 Depósitos
- **Depósito Real Digital**: ERC-20
- **Depósito TPFt**: ERC-1155
- **Configuração de Contas**: Endereços de destino

### ⚙️ Configurações
- **Configuração de Conta**: Nome, email, endereço
- **Configuração de Rede**: RPC, Chain ID, contratos
- **Persistência Local**: Configurações salvas automaticamente

## 🛠️ Scripts de Controle

### 📋 Scripts Disponíveis

| Script | Descrição | Uso |
|--------|-----------|-----|
| `cbd-control.sh` | Controle principal interativo | `./cbd-control.sh` |
| `start-environment.sh` | Iniciar ambiente | `./start-environment.sh` |
| `stop-environment.sh` | Parar ambiente | `./stop-environment.sh` |
| `restart-environment.sh` | Reiniciar ambiente | `./restart-environment.sh` |
| `setup-environment.sh` | Setup inicial | `./setup-environment.sh` |
| `setup-test-data.sh` | Dados de teste | `./setup-test-data.sh` |
| `test-services.sh` | Testes de conectividade | `./test-services.sh` |

### 📚 Documentação dos Scripts
Para informações detalhadas sobre todos os scripts, consulte: **[SCRIPTS_GUIDE.md](SCRIPTS_GUIDE.md)**

### 🎛️ Script Principal - `cbd-control.sh`

**Controle centralizado com menu interativo:**

```bash
# Menu interativo
./cbd-control.sh

# Comandos diretos
./cbd-control.sh start      # Iniciar ambiente
./cbd-control.sh stop       # Parar ambiente
./cbd-control.sh restart    # Reiniciar ambiente
./cbd-control.sh status     # Ver status
./cbd-control.sh test       # Executar testes
./cbd-control.sh logs       # Ver logs
./cbd-control.sh open       # Abrir frontend
./cbd-control.sh cleanup    # Limpeza completa
```

**Opções do Menu:**
1. 🚀 Iniciar Ambiente
2. 🛑 Parar Ambiente
3. 🔄 Reiniciar Ambiente
4. 🧪 Executar Testes
5. 📊 Status dos Serviços
6. 📋 Ver Logs
7. 🔧 Setup Inicial
8. 🧹 Limpeza Completa
9. 🌐 Abrir Frontend
0. ❌ Sair

### 🚀 Script de Inicialização - `start-environment.sh`

**Inicia o ambiente completo com verificações:**

```bash
# Inicialização básica
./start-environment.sh

# Opções avançadas
./start-environment.sh --skip-tests      # Pular testes
./start-environment.sh --force-cleanup   # Limpeza forçada
./start-environment.sh --help            # Ajuda
```

**Funcionalidades:**
- ✅ Verificação de pré-requisitos (Docker, Docker Compose)
- ✅ Verificação de arquivos necessários
- ✅ Parada de containers existentes
- ✅ Inicialização com docker-compose
- ✅ Aguardamento de inicialização completa
- ✅ Execução automática de testes
- ✅ Status detalhado dos serviços

### 🛑 Script de Parada - `stop-environment.sh`

**Para o ambiente de forma segura:**

```bash
# Parada básica
./stop-environment.sh

# Opções avançadas
./stop-environment.sh --remove    # Remover containers
./stop-environment.sh --cleanup   # Limpar recursos
./stop-environment.sh --help      # Ajuda
```

**Funcionalidades:**
- ✅ Verificação de containers rodando
- ✅ Parada segura com docker-compose
- ✅ Opção de remoção de containers
- ✅ Limpeza de recursos Docker
- ✅ Preservação de dados importantes

### 🔄 Script de Reinicialização - `restart-environment.sh`

**Reinicia o ambiente completamente:**

```bash
# Reinicialização básica
./restart-environment.sh

# Opções avançadas
./restart-environment.sh --skip-tests  # Pular testes
./restart-environment.sh --show-logs   # Mostrar logs
./restart-environment.sh --force       # Forçar reinicialização
./restart-environment.sh --help        # Ajuda
```

### 🔧 Script de Setup - `setup-environment.sh`

**Configura o ambiente pela primeira vez:**

```bash
# Setup básico
./setup-environment.sh

# Opções avançadas
./setup-environment.sh --skip-download  # Pular download de imagens
./setup-environment.sh --force          # Forçar setup completo
./setup-environment.sh --help           # Ajuda
```

**Funcionalidades:**
- ✅ Verificação de pré-requisitos
- ✅ Criação de estrutura de diretórios
- ✅ Download de imagens Docker
- ✅ Configuração de arquivos (.env, config.toml)
- ✅ Configuração de permissões
- ✅ Verificação de conectividade de rede

### 🧪 Script de Dados de Teste - `setup-test-data.sh`

**Configura dados de exemplo para demonstração:**

```bash
# Setup de dados de teste
./setup-test-data.sh

# Opções avançadas
./setup-test-data.sh --skip-wait    # Pular aguardar serviços
./setup-test-data.sh --force        # Forçar setup
./setup-test-data.sh --help         # Ajuda
```

**Dados Criados:**
- 💰 10,000 DREX disponíveis
- 🏦 1,000 TPFt Série 1
- 🏦 500 TPFt Série 2
- 🏦 250 TPFt Série 3
- 🔄 3 swaps de exemplo ativos

### 🧪 Script de Testes - `test-services.sh`

**Executa testes de conectividade e funcionalidade:**

```bash
# Execução básica
./test-services.sh
```

**Testes Realizados:**
- ✅ Verificação de containers Docker
- ✅ Teste de conectividade de portas
- ✅ Teste de APIs (ZApp, Timber, Zokrates)
- ✅ Teste do frontend web
- ✅ Verificação de funcionalidades específicas
- ✅ Relatório detalhado de status

## 🚀 Setup Inicial do Ambiente

### 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

```bash
# Verificar Docker
docker --version
docker-compose --version

# Verificar se Docker está rodando
docker info
```

### 🔧 Configuração Inicial Completa

#### **Passo 1: Clone e Setup Inicial**
```bash
# Clone o repositório (se ainda não fez)
git clone <repository-url>
cd pilotord-kit-onboarding

# Tornar scripts executáveis
chmod +x *.sh

# Setup inicial do ambiente
./setup-environment.sh
```

#### **Passo 2: Iniciar Serviços**
```bash
# Iniciar todos os serviços
./start-environment.sh

# Verificar status
./cbd-control.sh status
```

#### **Passo 3: Configurar Dados de Teste**
```bash
# Configurar dados de exemplo
./setup-test-data.sh

# Executar testes de conectividade
./test-services.sh
```

#### **Passo 4: Acessar Frontend**
```bash
# Abrir frontend no navegador
./cbd-control.sh open

# Ou acesse manualmente: http://localhost
```

### 🎯 Setup Rápido (Comando Único)

Para uma configuração completa com um comando:

```bash
# Setup completo automático
chmod +x *.sh && ./setup-environment.sh && ./start-environment.sh && ./setup-test-data.sh && echo "🎉 Ambiente configurado! Acesse: http://localhost"
```

### 🔍 Verificação do Setup

Após o setup, verifique se tudo está funcionando:

```bash
# Verificar todos os containers
docker ps

# Verificar portas
netstat -an | grep -E ":(80|3000|3100|8080|27017)"

# Testar APIs
curl http://localhost:3000/getAllCommitments
curl http://localhost:3100/logs

# Verificar frontend
curl http://localhost
```

## 🎯 Fluxo de Uso Recomendado

### Primeira Configuração
```bash
# 1. Setup inicial
./setup-environment.sh

# 2. Iniciar ambiente
./start-environment.sh

# 3. Configurar dados de teste
./setup-test-data.sh

# 4. Verificar status
./cbd-control.sh status

# 5. Abrir frontend
./cbd-control.sh open
```

### Uso Diário
```bash
# Iniciar ambiente
./cbd-control.sh start

# Verificar status
./cbd-control.sh status

# Executar testes
./cbd-control.sh test

# Parar ambiente
./cbd-control.sh stop
```

### Troubleshooting
```bash
# Ver logs de erro
./cbd-control.sh logs

# Reiniciar ambiente
./cbd-control.sh restart

# Limpeza completa (cuidado!)
./cbd-control.sh cleanup
```

## 🌐 Wallet Web - Frontend

### 🎨 Interface Principal
**URL**: http://localhost

### 🔗 Funcionalidades da Wallet Web

#### 📱 **Dashboard Principal**
- **Saldo em Tempo Real**
  - Real Digital (DREX): Exibição do saldo atual
  - TPFt: Quantidade de tokens por série
  - Swaps Ativos: Operações pendentes

- **Atividade Recente**
  - Últimas 5 transações
  - Status de cada operação
  - Timestamps detalhados

- **Status da Rede**
  - Conectividade com blockchain
  - Último bloco processado
  - Gas price atual

#### 💱 **Troca de Tokens (Swap)**
- **Interface Intuitiva**
  - Campo para quantidade de Real Digital
  - Seleção de token TPFt (Série 1, 2, 3)
  - Cálculo automático da quantidade de TPFt
  - Taxa de câmbio em tempo real

- **Swaps Disponíveis**
  - Visualização de swaps ativos
  - Botão para completar operações
  - Histórico de swaps realizados

#### 💰 **Depósitos**
- **Depósito Real Digital (ERC-20)**
  - Campo para quantidade em DREX
  - Campo para conta de destino (opcional)
  - Confirmação automática

- **Depósito TPFt (ERC-1155)**
  - Seleção de Token ID
  - Campo para quantidade
  - Campo para conta de destino

#### 📜 **Histórico de Transações**
- **Lista Completa**
  - Todas as operações realizadas
  - Filtros por tipo de transação
  - Detalhes completos de cada operação
  - Status em tempo real
  - Ações disponíveis (visualizar, reverter)

#### ⚙️ **Configurações**
- **Configurações da Conta**
  - Nome da conta
  - Email de contato
  - Endereço da carteira (somente leitura)

- **Configurações da Rede**
  - RPC URL (padrão: ws://localhost:8545)
  - Chain ID (padrão: 381660001)
  - Endereços dos contratos:
    - Real Digital: `0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e`
    - TPFt: `0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E`

### 🔗 Integração com Carteira

#### Conectar MetaMask
1. **Clique em "Conectar Carteira"** no canto superior direito
2. **Autorize o MetaMask** quando solicitado
3. **Verifique o endereço** exibido na interface

#### Configurar Rede
No MetaMask, adicione uma nova rede com:
- **Nome**: CBD Real Digital
- **Chain ID**: 381660001
- **RPC URL**: ws://localhost:8545
- **Símbolo**: DREX

### 🎨 Interface e Design

#### Características Visuais
- **Design Responsivo**: Funciona em desktop, tablet e mobile
- **Tema Moderno**: Gradientes e sombras suaves
- **Cores Institucionais**: Azul e verde do Banco Central
- **Ícones Intuitivos**: Font Awesome para melhor UX

#### Componentes Principais
- **Cards Informativos**: Saldos e status
- **Tabelas Interativas**: Histórico e transações
- **Formulários Validados**: Entrada de dados segura
- **Notificações Toast**: Feedback em tempo real

### 🔧 Funcionalidades Técnicas

#### APIs Integradas
- **ZApp API** (porta 3000): Operações principais
- **Timber API** (porta 3100): Logs e commitments
- **Proxy Nginx**: Roteamento e CORS

#### Recursos Avançados
- **Atualização Automática**: Dados atualizados a cada 30s
- **Persistência Local**: Configurações salvas no navegador
- **Validação em Tempo Real**: Verificação de dados
- **Tratamento de Erros**: Mensagens amigáveis
- **Modo Demonstração**: Funciona sem carteira conectada

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Frontend não carrega
```bash
# Verificar se o container está rodando
docker ps | grep frontend

# Ver logs do frontend
docker logs cbd-frontend
```

#### 2. APIs não respondem
```bash
# Verificar todos os serviços
docker-compose -f docker-compose-simple.yaml ps

# Ver logs dos serviços
docker logs cbd-zapp
docker logs cbd-timber
```

#### 3. Carteira não conecta
- Verifique se o MetaMask está instalado
- Certifique-se de estar na rede correta (Chain ID: 381660001)
- Tente recarregar a página
- Use o modo demonstração se necessário

#### 4. Erro de CORS
- O Nginx está configurado para resolver problemas de CORS
- Se persistir, verifique as configurações do proxy no `nginx.conf`

#### 5. Erro ao fazer swap
```bash
# Verificar logs do ZApp
docker logs cbd-zapp

# Testar API diretamente
curl http://localhost:3000/getAllCommitments

# Configurar dados de teste
./setup-test-data.sh
```

### Logs dos Serviços
```bash
# Ver logs em tempo real
docker-compose -f docker-compose-simple.yaml logs -f

# Logs específicos
docker logs -f cbd-frontend
docker logs -f cbd-zapp
docker logs -f cbd-timber
```

## 📋 Próximos Passos

### 1. Configurar Nó Blockchain
- Configure um nó Hyperledger Besu
- Conecte à rede piloto
- Configure as chaves privadas

### 2. Testar Smart Contracts
- Deploy dos contratos
- Teste das operações básicas
- Verificação de permissões

### 3. Integração com Outros Participantes
- Configurar conectividade P2P
- Testar operações entre participantes
- Validar privacidade

## 📞 Suporte

Para suporte técnico:
- **Email**: suporte@bancocentral.gov.br
- **Documentação**: [Link para documentação oficial]
- **Issues**: [Link para repositório de issues]

## 📄 Licença

Este projeto é parte do piloto CBD Real Digital do Banco Central do Brasil.

---

**Nota**: Este é um ambiente de desenvolvimento/teste. Para uso em produção, consulte a documentação oficial do Banco Central do Brasil.
