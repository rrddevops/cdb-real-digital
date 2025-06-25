#!/bin/bash

# DBD Real Digital - Script de Setup
# Este script configura o ambiente para o piloto do Real Digital

set -e

echo "🏦 DBD Real Digital - Setup Inicial"
echo "=================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar pré-requisitos
check_prerequisites() {
    log "Verificando pré-requisitos..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        error "Docker não está instalado. Instale o Docker primeiro."
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não está instalado. Instale o Docker Compose primeiro."
        exit 1
    fi
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        warn "Node.js não está instalado. Será necessário para desenvolvimento local."
    fi
    
    # Verificar NPM
    if ! command -v npm &> /dev/null; then
        warn "NPM não está instalado. Será necessário para desenvolvimento local."
    fi
    
    log "Pré-requisitos verificados com sucesso!"
}

# Criar diretórios necessários
create_directories() {
    log "Criando diretórios necessários..."
    
    mkdir -p proving-files
    mkdir -p circuits
    mkdir -p build/contracts
    mkdir -p db
    mkdir -p orchestration/common
    
    log "Diretórios criados com sucesso!"
}

# Configurar arquivos de exemplo
setup_config_files() {
    log "Configurando arquivos de configuração..."
    
    # Verificar se config.toml existe
    if [ ! -f "config.toml" ]; then
        warn "Arquivo config.toml não encontrado. Você precisará configurá-lo manualmente."
        echo "Copie o arquivo config.toml.example para config.toml e edite conforme necessário."
    fi
    
    # Verificar se static-nodes.json existe
    if [ ! -f "static-nodes.json" ]; then
        warn "Arquivo static-nodes.json não encontrado. Você precisará configurá-lo manualmente."
        echo "Copie o arquivo static-nodes.json.example para static-nodes.json e edite conforme necessário."
    fi
    
    # Verificar se genesis.json existe
    if [ ! -f "genesis.json" ]; then
        error "Arquivo genesis.json não encontrado. Este arquivo é obrigatório."
        exit 1
    fi
    
    log "Arquivos de configuração verificados!"
}

# Configurar variáveis de ambiente
setup_environment() {
    log "Configurando variáveis de ambiente..."
    
    # Criar arquivo .env se não existir
    if [ ! -f ".env" ]; then
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
        log "Arquivo .env criado com valores padrão."
        warn "IMPORTANTE: Edite o arquivo .env com suas configurações reais!"
    else
        log "Arquivo .env já existe."
    fi
}

# Instalar dependências dos exemplos
setup_examples() {
    log "Configurando exemplos..."
    
    if [ -d "exemplos" ]; then
        cd exemplos
        
        if [ -f "package.json" ]; then
            log "Instalando dependências dos exemplos..."
            npm install
        fi
        
        cd ..
    else
        warn "Diretório 'exemplos' não encontrado."
    fi
}

# Testar Docker
test_docker() {
    log "Testando Docker..."
    
    if docker info &> /dev/null; then
        log "Docker está funcionando corretamente."
    else
        error "Docker não está funcionando. Verifique se o Docker está rodando."
        exit 1
    fi
}

# Mostrar próximos passos
show_next_steps() {
    echo ""
    echo "🎉 Setup concluído com sucesso!"
    echo "================================"
    echo ""
    echo "📋 Próximos passos:"
    echo ""
    echo "1. 🔧 Configure suas credenciais:"
    echo "   - Edite o arquivo .env com suas chaves privadas"
    echo "   - Configure config.toml com seu enode"
    echo "   - Configure static-nodes.json"
    echo ""
    echo "2. 🔐 Solicite permissão:"
    echo "   - Envie email para: piloto.rd.tecnologia@bcb.gov.br"
    echo "   - Assunto: DEINF | Permissão de Nó na Rede | Participante: [seu-nome]"
    echo "   - Inclua seu enode completo"
    echo ""
    echo "3. 🚀 Execute os serviços:"
    echo "   docker-compose up -d"
    echo ""
    echo "4. 🌐 Acesse as interfaces:"
    echo "   - Frontend: http://localhost:3000"
    echo "   - APIs: http://localhost:3100"
    echo ""
    echo "5. 📚 Teste os exemplos:"
    echo "   cd exemplos"
    echo "   npx hardhat run --network besu ./example1.ts"
    echo ""
    echo "📖 Documentação completa: README.md"
    echo "🆘 Suporte: piloto.rd.tecnologia@bcb.gov.br"
    echo ""
}

# Função principal
main() {
    echo "Iniciando setup do DBD Real Digital..."
    echo ""
    
    check_prerequisites
    create_directories
    setup_config_files
    setup_environment
    setup_examples
    test_docker
    show_next_steps
}

# Executar função principal
main "$@" 