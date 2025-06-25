#!/bin/bash

# CBD Real Digital - Script de Setup Inicial
# ==========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para exibir banner
show_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    CBD Real Digital                          ║"
    echo "║                Setup Inicial do Ambiente                     ║"
    echo "║                                                              ║"
    echo "║  🏦 Banco Central do Brasil - Projeto Piloto DREX           ║"
    echo "║  🚀 Hyperledger Besu + QBFT + Smart Contracts               ║"
    echo "║  🔐 Starlight + Rayls + Anonymous Zether                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para verificar pré-requisitos
check_prerequisites() {
    echo -e "${CYAN}🔍 Verificando pré-requisitos...${NC}"
    
    local missing_deps=()
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("Docker")
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("Docker Compose")
    fi
    
    # Verificar Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("Git")
    fi
    
    # Verificar curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}❌ Dependências faltando:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "${RED}   - $dep${NC}"
        done
        echo ""
        echo -e "${YELLOW}💡 Instale as dependências e execute novamente.${NC}"
        exit 1
    fi
    
    # Verificar se Docker está rodando
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker não está rodando. Inicie o Docker primeiro.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Pré-requisitos verificados${NC}"
}

# Função para criar estrutura de diretórios
create_directories() {
    echo -e "${CYAN}📁 Criando estrutura de diretórios...${NC}"
    
    local directories=(
        "frontend"
        "db"
        "proving-files"
        "circuits"
        "build/contracts"
        "logs"
    )
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo -e "${GREEN}   ✅ Criado: $dir${NC}"
        else
            echo -e "${YELLOW}   ⚠️  Já existe: $dir${NC}"
        fi
    done
}

# Função para verificar arquivos existentes
check_existing_files() {
    echo -e "${CYAN}📋 Verificando arquivos existentes...${NC}"
    
    local existing_files=()
    local missing_files=()
    
    # Lista de arquivos importantes
    local important_files=(
        "docker-compose-simple.yaml"
        "frontend/index.html"
        "frontend/app.js"
        "frontend/nginx.conf"
        "zapp-package.json"
        "zapp-index.js"
        "timber-package.json"
        "timber-index.js"
        "test-services.sh"
        "README.md"
    )
    
    for file in "${important_files[@]}"; do
        if [ -f "$file" ]; then
            existing_files+=("$file")
        else
            missing_files+=("$file")
        fi
    done
    
    if [ ${#existing_files[@]} -gt 0 ]; then
        echo -e "${GREEN}📋 Arquivos encontrados:${NC}"
        for file in "${existing_files[@]}"; do
            echo -e "${GREEN}   ✅ $file${NC}"
        done
    fi
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Arquivos faltando:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${YELLOW}   - $file${NC}"
        done
    fi
}

# Função para configurar arquivo de configuração
setup_config() {
    echo -e "${CYAN}⚙️  Configurando arquivo de configuração...${NC}"
    
    if [ ! -f "config.toml" ]; then
        if [ -f "config.toml.example" ]; then
            cp config.toml.example config.toml
            echo -e "${GREEN}✅ Arquivo config.toml criado a partir do exemplo${NC}"
        else
            echo -e "${YELLOW}⚠️  Arquivo config.toml.example não encontrado${NC}"
            echo -e "${YELLOW}   Crie manualmente o arquivo config.toml${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Arquivo config.toml já existe${NC}"
    fi
}

# Função para configurar permissões
setup_permissions() {
    echo -e "${CYAN}🔐 Configurando permissões...${NC}"
    
    # Tornar scripts executáveis
    local scripts=(
        "start-environment.sh"
        "stop-environment.sh"
        "restart-environment.sh"
        "test-services.sh"
        "setup-environment.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            echo -e "${GREEN}   ✅ $script (executável)${NC}"
        fi
    done
}

# Função para verificar conectividade de rede
check_network() {
    echo -e "${CYAN}🌐 Verificando conectividade de rede...${NC}"
    
    # Verificar se as portas estão livres
    local ports=(80 3000 3100 8080 27017)
    local busy_ports=()
    
    for port in "${ports[@]}"; do
        if command -v netstat &> /dev/null; then
            if netstat -an 2>/dev/null | grep -q ":$port "; then
                busy_ports+=("$port")
            fi
        elif command -v ss &> /dev/null; then
            if ss -tuln 2>/dev/null | grep -q ":$port "; then
                busy_ports+=("$port")
            fi
        fi
    done
    
    if [ ${#busy_ports[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Portas ocupadas:${NC}"
        for port in "${busy_ports[@]}"; do
            echo -e "${YELLOW}   - Porta $port${NC}"
        done
        echo -e "${YELLOW}💡 Pare os serviços que usam essas portas antes de continuar${NC}"
    else
        echo -e "${GREEN}✅ Todas as portas necessárias estão livres${NC}"
    fi
}

# Função para baixar imagens Docker
download_docker_images() {
    echo -e "${CYAN}🐳 Baixando imagens Docker...${NC}"
    
    local images=(
        "mongo:6.0"
        "node:18-alpine"
        "nginx:alpine"
        "ghcr.io/eyblockchain/zokrates-worker-updated:latest"
    )
    
    for image in "${images[@]}"; do
        echo -n "   Baixando $image... "
        if docker pull "$image" > /dev/null 2>&1; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
        fi
    done
}

# Função para criar arquivo .env (se necessário)
create_env_file() {
    echo -e "${CYAN}📝 Criando arquivo .env...${NC}"
    
    if [ ! -f ".env" ]; then
        cat > .env << EOF
# CBD Real Digital - Variáveis de Ambiente
# ========================================

# Configurações da Rede
RPC_URL=ws://localhost:8545
CHAIN_ID=381660001

# Endereços dos Contratos
REAL_DIGITAL_CONTRACT=0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e
TPFT_CONTRACT=0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E
ESCROW_SHIELD_ADDRESS=0xf3cBfC5c2d71CdB931B004b3B5Ca4ABEdbA3Cd43

# Configurações do MongoDB
MONGO_URL=mongodb://admin:admin@localhost:27017
MONGO_DB=cbd_db

# Configurações dos Serviços
ZOKRATES_URL=http://localhost:8080
TIMBER_URL=http://localhost:3100
ZAPP_URL=http://localhost:3000

# Configurações de Desenvolvimento
NODE_ENV=development
LOG_LEVEL=debug
EOF
        echo -e "${GREEN}✅ Arquivo .env criado${NC}"
    else
        echo -e "${YELLOW}⚠️  Arquivo .env já existe${NC}"
    fi
}

# Função para mostrar resumo
show_summary() {
    echo ""
    echo -e "${PURPLE}📊 Resumo do Setup:${NC}"
    echo "=================================="
    
    # Verificar arquivos criados
    local created_files=0
    local total_files=0
    
    local check_files=(
        "docker-compose-simple.yaml"
        "frontend/index.html"
        "frontend/app.js"
        "frontend/nginx.conf"
        "zapp-package.json"
        "zapp-index.js"
        "timber-package.json"
        "timber-index.js"
        "test-services.sh"
        "start-environment.sh"
        "stop-environment.sh"
        "restart-environment.sh"
        "setup-environment.sh"
        "README.md"
        ".env"
    )
    
    for file in "${check_files[@]}"; do
        ((total_files++))
        if [ -f "$file" ]; then
            ((created_files++))
        fi
    done
    
    echo -e "${CYAN}📁 Arquivos: $created_files/$total_files criados${NC}"
    
    # Verificar diretórios
    local created_dirs=0
    local total_dirs=0
    
    local check_dirs=("frontend" "db" "proving-files" "circuits" "build/contracts" "logs")
    
    for dir in "${check_dirs[@]}"; do
        ((total_dirs++))
        if [ -d "$dir" ]; then
            ((created_dirs++))
        fi
    done
    
    echo -e "${CYAN}📂 Diretórios: $created_dirs/$total_dirs criados${NC}"
    
    # Verificar scripts executáveis
    local exec_scripts=0
    local total_scripts=0
    
    local scripts=("start-environment.sh" "stop-environment.sh" "restart-environment.sh" "test-services.sh" "setup-environment.sh")
    
    for script in "${scripts[@]}"; do
        ((total_scripts++))
        if [ -x "$script" ]; then
            ((exec_scripts++))
        fi
    done
    
    echo -e "${CYAN}🔧 Scripts: $exec_scripts/$total_scripts executáveis${NC}"
}

# Função para mostrar próximos passos
show_next_steps() {
    echo ""
    echo -e "${PURPLE}📝 Próximos Passos:${NC}"
    echo "1. Execute: ./start-environment.sh"
    echo "2. Aguarde a inicialização dos serviços"
    echo "3. Acesse: http://localhost"
    echo "4. Conecte sua carteira (MetaMask)"
    echo "5. Configure a rede no MetaMask:"
    echo "   - Chain ID: 381660001"
    echo "   - RPC URL: ws://localhost:8545"
    echo ""
    echo -e "${PURPLE}🔧 Comandos Úteis:${NC}"
    echo "   ./start-environment.sh     # Iniciar ambiente"
    echo "   ./stop-environment.sh      # Parar ambiente"
    echo "   ./restart-environment.sh   # Reiniciar ambiente"
    echo "   ./test-services.sh         # Executar testes"
    echo ""
    echo -e "${PURPLE}📚 Documentação:${NC}"
    echo "   README.md                   # Documentação principal"
    echo "   FRONTEND_GUIDE.md          # Guia do frontend"
    echo "   FINAL_SETUP.md             # Setup detalhado"
}

# Função principal
main() {
    show_banner
    
    echo -e "${GREEN}🔧 Configurando ambiente CBD Real Digital...${NC}"
    echo ""
    
    # Verificar argumentos
    local skip_download=false
    local force_setup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-download)
                skip_download=true
                shift
                ;;
            --force)
                force_setup=true
                shift
                ;;
            --help|-h)
                echo "Uso: $0 [opções]"
                echo ""
                echo "Opções:"
                echo "  --skip-download   Pular download de imagens Docker"
                echo "  --force           Forçar setup completo"
                echo "  --help, -h        Mostrar esta ajuda"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opção desconhecida: $1${NC}"
                echo "Use --help para ver as opções disponíveis"
                exit 1
                ;;
        esac
    done
    
    # Executar verificações
    check_prerequisites
    
    # Criar estrutura
    create_directories
    
    # Verificar arquivos
    check_existing_files
    
    # Configurar arquivos
    setup_config
    create_env_file
    
    # Configurar permissões
    setup_permissions
    
    # Verificar rede
    check_network
    
    # Baixar imagens (se não pulado)
    if [ "$skip_download" = false ]; then
        download_docker_images
    fi
    
    # Mostrar resumo
    show_summary
    
    # Mostrar próximos passos
    show_next_steps
    
    echo ""
    echo -e "${GREEN}🎉 Setup concluído com sucesso!${NC}"
}

# Executar função principal
main "$@" 