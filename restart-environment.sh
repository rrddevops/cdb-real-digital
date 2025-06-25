#!/bin/bash

# CBD Real Digital - Script de Reinicialização do Ambiente
# ========================================================

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
    echo "║              Reiniciando Ambiente                            ║"
    echo "║                                                              ║"
    echo "║  🏦 Banco Central do Brasil - Projeto Piloto DREX           ║"
    echo "║  🚀 Hyperledger Besu + QBFT + Smart Contracts               ║"
    echo "║  🔐 Starlight + Rayls + Anonymous Zether                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para verificar se containers estão rodando
check_running_containers() {
    local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
    local running_containers=()
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            running_containers+=("$container")
        fi
    done
    
    if [ ${#running_containers[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Nenhum container está rodando. Iniciando ambiente...${NC}"
        return 1
    fi
    
    echo -e "${CYAN}📊 Containers rodando:${NC}"
    for container in "${running_containers[@]}"; do
        echo -e "${YELLOW}   - $container${NC}"
    done
    
    return 0
}

# Função para parar serviços
stop_services() {
    echo -e "${CYAN}🛑 Parando serviços...${NC}"
    
    if [ -f "docker-compose-simple.yaml" ]; then
        echo -e "${YELLOW}   Parando com docker-compose...${NC}"
        docker-compose -f docker-compose-simple.yaml down
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Serviços parados com sucesso${NC}"
        else
            echo -e "${RED}❌ Erro ao parar serviços${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}   Arquivo docker-compose-simple.yaml não encontrado${NC}"
        echo -e "${YELLOW}   Parando containers individualmente...${NC}"
        
        local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
        
        for container in "${containers[@]}"; do
            if docker ps --format "table {{.Names}}" | grep -q "$container"; then
                echo -e "${YELLOW}     Parando $container...${NC}"
                docker stop "$container" > /dev/null 2>&1
            fi
        done
        
        echo -e "${GREEN}✅ Containers parados${NC}"
    fi
}

# Função para aguardar parada completa
wait_for_stop() {
    echo -e "${CYAN}⏳ Aguardando parada completa...${NC}"
    
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        local running_containers=$(docker ps --format "table {{.Names}}" | grep -c "cbd-")
        
        if [ $running_containers -eq 0 ]; then
            echo -e "${GREEN}✅ Todos os serviços parados${NC}"
            break
        else
            echo -n "   Aguardando... "
            sleep 2
            ((attempt++))
        fi
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo -e "${YELLOW}⚠️  Alguns serviços podem ainda estar parando${NC}"
    fi
}

# Função para iniciar serviços
start_services() {
    echo -e "${CYAN}🚀 Iniciando serviços...${NC}"
    
    if [ -f "docker-compose-simple.yaml" ]; then
        echo -e "${YELLOW}   Iniciando com docker-compose...${NC}"
        docker-compose -f docker-compose-simple.yaml up -d
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Serviços iniciados com sucesso${NC}"
        else
            echo -e "${RED}❌ Erro ao iniciar serviços${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Arquivo docker-compose-simple.yaml não encontrado${NC}"
        return 1
    fi
}

# Função para aguardar inicialização
wait_for_startup() {
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
        return 1
    fi
    
    return 0
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

# Função para mostrar logs de erro
show_error_logs() {
    echo ""
    echo -e "${CYAN}📋 Logs de erro (últimas 10 linhas):${NC}"
    echo ""
    
    local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            echo -e "${YELLOW}📋 $container:${NC}"
            docker logs --tail=10 "$container" 2>&1 | head -10
            echo ""
        fi
    done
}

# Função para mostrar próximos passos
show_next_steps() {
    echo ""
    echo -e "${PURPLE}📝 Próximos Passos:${NC}"
    echo "1. Abra http://localhost no seu navegador"
    echo "2. Verifique se a carteira ainda está conectada"
    echo "3. Teste as funcionalidades de swap e depósito"
    echo ""
    echo -e "${PURPLE}🔧 Comandos Úteis:${NC}"
    echo "   ./stop-environment.sh      # Parar ambiente"
    echo "   ./start-environment.sh     # Iniciar ambiente"
    echo "   ./test-services.sh         # Executar testes"
    echo "   docker-compose -f docker-compose-simple.yaml logs -f  # Ver logs"
}

# Função principal
main() {
    show_banner
    
    echo -e "${GREEN}🔄 Reiniciando ambiente CBD Real Digital...${NC}"
    echo ""
    
    # Verificar argumentos
    local skip_tests=false
    local show_logs=false
    local force_restart=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-tests)
                skip_tests=true
                shift
                ;;
            --show-logs)
                show_logs=true
                shift
                ;;
            --force)
                force_restart=true
                shift
                ;;
            --help|-h)
                echo "Uso: $0 [opções]"
                echo ""
                echo "Opções:"
                echo "  --skip-tests      Pular execução dos testes"
                echo "  --show-logs       Mostrar logs de erro"
                echo "  --force           Forçar reinicialização"
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
    
    # Verificar se containers estão rodando
    local containers_running=false
    if check_running_containers; then
        containers_running=true
    fi
    
    # Se não há containers rodando e não é force, apenas iniciar
    if [ "$containers_running" = false ] && [ "$force_restart" = false ]; then
        echo -e "${YELLOW}💡 Nenhum container rodando. Iniciando ambiente...${NC}"
        
        if [ -f "start-environment.sh" ]; then
            chmod +x start-environment.sh
            ./start-environment.sh --skip-tests
        else
            echo -e "${RED}❌ Script start-environment.sh não encontrado${NC}"
            exit 1
        fi
        return
    fi
    
    # Parar serviços
    echo -e "${CYAN}🔄 Fase 1: Parando serviços...${NC}"
    if ! stop_services; then
        echo -e "${RED}❌ Erro ao parar serviços${NC}"
        exit 1
    fi
    
    # Aguardar parada completa
    wait_for_stop
    
    # Pequena pausa para garantir parada completa
    echo -e "${CYAN}⏳ Aguardando 5 segundos...${NC}"
    sleep 5
    
    # Iniciar serviços
    echo -e "${CYAN}🔄 Fase 2: Iniciando serviços...${NC}"
    if ! start_services; then
        echo -e "${RED}❌ Erro ao iniciar serviços${NC}"
        exit 1
    fi
    
    # Aguardar inicialização
    if ! wait_for_startup; then
        echo -e "${RED}❌ Erro na inicialização${NC}"
        if [ "$show_logs" = true ]; then
            show_error_logs
        fi
        exit 1
    fi
    
    # Mostrar status
    show_status
    
    # Executar testes (se não pulado)
    if [ "$skip_tests" = false ]; then
        run_tests
    fi
    
    # Mostrar próximos passos
    show_next_steps
    
    echo ""
    echo -e "${GREEN}🎉 Ambiente reiniciado com sucesso!${NC}"
}

# Executar função principal
main "$@" 