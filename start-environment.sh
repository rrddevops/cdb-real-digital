#!/bin/bash

# CBD Real Digital - Script de Inicialização do Ambiente
# =====================================================

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
    echo "║                Ambiente de Desenvolvimento                   ║"
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
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker não encontrado. Instale o Docker primeiro.${NC}"
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose não encontrado. Instale o Docker Compose primeiro.${NC}"
        exit 1
    fi
    
    # Verificar se Docker está rodando
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker não está rodando. Inicie o Docker primeiro.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Pré-requisitos verificados${NC}"
}

# Função para verificar arquivos necessários
check_files() {
    echo -e "${CYAN}📁 Verificando arquivos necessários...${NC}"
    
    local missing_files=()
    
    # Lista de arquivos obrigatórios
    local required_files=(
        "docker-compose-simple.yaml"
        "frontend/index.html"
        "frontend/app.js"
        "frontend/nginx.conf"
        "zapp-package.json"
        "zapp-index.js"
        "timber-package.json"
        "timber-index.js"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        echo -e "${RED}❌ Arquivos faltando:${NC}"
        for file in "${missing_files[@]}"; do
            echo -e "${RED}   - $file${NC}"
        done
        echo -e "${YELLOW}💡 Execute o setup inicial primeiro.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Todos os arquivos necessários encontrados${NC}"
}

# Função para parar containers existentes
stop_existing_containers() {
    echo -e "${CYAN}🛑 Parando containers existentes...${NC}"
    
    # Parar containers específicos se existirem
    local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            echo -e "${YELLOW}   Parando $container...${NC}"
            docker stop "$container" > /dev/null 2>&1
        fi
    done
    
    echo -e "${GREEN}✅ Containers parados${NC}"
}

# Função para limpar containers antigos
cleanup_old_containers() {
    echo -e "${CYAN}🧹 Limpando containers antigos...${NC}"
    
    # Remover containers parados
    docker container prune -f > /dev/null 2>&1
    
    # Remover imagens não utilizadas (opcional)
    read -p "Deseja remover imagens não utilizadas? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -f > /dev/null 2>&1
        echo -e "${GREEN}✅ Imagens limpas${NC}"
    fi
}

# Função para iniciar serviços
start_services() {
    echo -e "${CYAN}🚀 Iniciando serviços...${NC}"
    
    # Iniciar com docker-compose
    echo -e "${YELLOW}   Iniciando containers...${NC}"
    docker-compose -f docker-compose-simple.yaml up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Serviços iniciados com sucesso${NC}"
    else
        echo -e "${RED}❌ Erro ao iniciar serviços${NC}"
        exit 1
    fi
}

# Função para aguardar inicialização
wait_for_services() {
    echo -e "${CYAN}⏳ Aguardando inicialização dos serviços...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -n "   Tentativa $attempt/$max_attempts... "
        
        # Verificar se todos os containers estão rodando
        local running_containers=$(docker ps --format "table {{.Names}}" | grep -c "cbd-")
        
        if [ $running_containers -eq 5 ]; then
            echo -e "${GREEN}✅ Todos os serviços prontos${NC}"
            break
        else
            echo -e "${YELLOW}⏳ Aguardando...${NC}"
            sleep 10
            ((attempt++))
        fi
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo -e "${RED}❌ Timeout aguardando serviços${NC}"
        echo -e "${YELLOW}💡 Verifique os logs: docker-compose -f docker-compose-simple.yaml logs${NC}"
    fi
}

# Função para mostrar status
show_status() {
    echo -e "${CYAN}📊 Status dos serviços:${NC}"
    echo ""
    
    docker-compose -f docker-compose-simple.yaml ps
    
    echo ""
    echo -e "${PURPLE}🌐 URLs de Acesso:${NC}"
    echo -e "${BLUE}   Frontend Web:${NC} http://localhost"
    echo -e "${BLUE}   ZApp API:${NC} http://localhost:3000"
    echo -e "${BLUE}   Timber API:${NC} http://localhost:3100"
    echo -e "${BLUE}   Zokrates:${NC} http://localhost:8080"
    echo -e "${BLUE}   MongoDB:${NC} localhost:27017"
}

# Função para executar testes
run_tests() {
    echo ""
    echo -e "${CYAN}🧪 Executando testes de conectividade...${NC}"
    
    if [ -f "test-services.sh" ]; then
        chmod +x test-services.sh
        ./test-services.sh
    else
        echo -e "${YELLOW}⚠️  Script de teste não encontrado${NC}"
    fi
}

# Função para mostrar próximos passos
show_next_steps() {
    echo ""
    echo -e "${PURPLE}📝 Próximos Passos:${NC}"
    echo "1. Abra http://localhost no seu navegador"
    echo "2. Conecte sua carteira (MetaMask)"
    echo "3. Configure a rede no MetaMask:"
    echo "   - Chain ID: 381660001"
    echo "   - RPC URL: ws://localhost:8545"
    echo "4. Teste as funcionalidades de swap e depósito"
    echo ""
    echo -e "${PURPLE}🔧 Comandos Úteis:${NC}"
    echo "   ./stop-environment.sh     # Parar ambiente"
    echo "   ./restart-environment.sh  # Reiniciar ambiente"
    echo "   ./test-services.sh        # Executar testes"
    echo "   docker-compose -f docker-compose-simple.yaml logs -f  # Ver logs"
}

# Função principal
main() {
    show_banner
    
    echo -e "${GREEN}🚀 Iniciando ambiente CBD Real Digital...${NC}"
    echo ""
    
    # Verificar argumentos
    local skip_tests=false
    local force_cleanup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-tests)
                skip_tests=true
                shift
                ;;
            --force-cleanup)
                force_cleanup=true
                shift
                ;;
            --help|-h)
                echo "Uso: $0 [opções]"
                echo ""
                echo "Opções:"
                echo "  --skip-tests      Pular execução dos testes"
                echo "  --force-cleanup   Forçar limpeza de containers antigos"
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
    check_files
    
    # Parar containers existentes
    stop_existing_containers
    
    # Limpeza opcional
    if [ "$force_cleanup" = true ]; then
        cleanup_old_containers
    fi
    
    # Iniciar serviços
    start_services
    
    # Aguardar inicialização
    wait_for_services
    
    # Mostrar status
    show_status
    
    # Executar testes (se não pulado)
    if [ "$skip_tests" = false ]; then
        run_tests
    fi
    
    # Mostrar próximos passos
    show_next_steps
    
    echo ""
    echo -e "${GREEN}🎉 Ambiente iniciado com sucesso!${NC}"
}

# Executar função principal
main "$@" 