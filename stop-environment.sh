#!/bin/bash

# CBD Real Digital - Script de Parada do Ambiente
# ===============================================

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
    echo "║                Parando Ambiente                              ║"
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
        echo -e "${YELLOW}⚠️  Nenhum container CBD Real Digital está rodando${NC}"
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

# Função para remover containers (opcional)
remove_containers() {
    local force_remove=false
    
    # Verificar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove)
                force_remove=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ "$force_remove" = true ]; then
        echo -e "${CYAN}🗑️  Removendo containers...${NC}"
        
        if [ -f "docker-compose-simple.yaml" ]; then
            docker-compose -f docker-compose-simple.yaml down --rmi all --volumes --remove-orphans
        else
            local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
            
            for container in "${containers[@]}"; do
                if docker ps -a --format "table {{.Names}}" | grep -q "$container"; then
                    echo -e "${YELLOW}   Removendo $container...${NC}"
                    docker rm -f "$container" > /dev/null 2>&1
                fi
            done
        fi
        
        echo -e "${GREEN}✅ Containers removidos${NC}"
    else
        read -p "Deseja remover os containers? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            remove_containers --remove
        fi
    fi
}

# Função para limpar recursos
cleanup_resources() {
    local force_cleanup=false
    
    # Verificar argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cleanup)
                force_cleanup=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [ "$force_cleanup" = true ]; then
        echo -e "${CYAN}🧹 Limpando recursos Docker...${NC}"
        
        # Remover containers parados
        docker container prune -f > /dev/null 2>&1
        
        # Remover redes não utilizadas
        docker network prune -f > /dev/null 2>&1
        
        # Remover volumes não utilizados (cuidado!)
        read -p "Deseja remover volumes não utilizados? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker volume prune -f > /dev/null 2>&1
            echo -e "${GREEN}✅ Volumes limpos${NC}"
        fi
        
        echo -e "${GREEN}✅ Recursos limpos${NC}"
    else
        read -p "Deseja limpar recursos Docker não utilizados? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup_resources --cleanup
        fi
    fi
}

# Função para mostrar status final
show_final_status() {
    echo -e "${CYAN}📊 Status final:${NC}"
    echo ""
    
    # Verificar containers parados
    local stopped_containers=$(docker ps -a --format "table {{.Names}}" | grep -c "cbd-")
    
    if [ $stopped_containers -gt 0 ]; then
        echo -e "${YELLOW}📋 Containers parados:${NC}"
        docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep "cbd-"
    else
        echo -e "${GREEN}✅ Nenhum container CBD Real Digital encontrado${NC}"
    fi
    
    echo ""
    echo -e "${PURPLE}💾 Dados preservados:${NC}"
    echo "   - Volumes MongoDB (dados do banco)"
    echo "   - Arquivos de configuração"
    echo "   - Logs (se configurados)"
}

# Função para mostrar comandos úteis
show_useful_commands() {
    echo ""
    echo -e "${PURPLE}🔧 Comandos Úteis:${NC}"
    echo "   ./start-environment.sh     # Iniciar ambiente"
    echo "   ./restart-environment.sh   # Reiniciar ambiente"
    echo "   docker ps -a               # Ver todos os containers"
    echo "   docker volume ls           # Ver volumes"
    echo "   docker network ls          # Ver redes"
    echo ""
    echo -e "${PURPLE}📁 Limpeza Completa:${NC}"
    echo "   docker system prune -a     # Limpar tudo (cuidado!)"
    echo "   docker volume prune        # Limpar volumes não utilizados"
}

# Função principal
main() {
    show_banner
    
    echo -e "${GREEN}🛑 Parando ambiente CBD Real Digital...${NC}"
    echo ""
    
    # Verificar argumentos
    local remove_containers_flag=false
    local cleanup_flag=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove)
                remove_containers_flag=true
                shift
                ;;
            --cleanup)
                cleanup_flag=true
                shift
                ;;
            --help|-h)
                echo "Uso: $0 [opções]"
                echo ""
                echo "Opções:"
                echo "  --remove          Remover containers após parar"
                echo "  --cleanup         Limpar recursos Docker não utilizados"
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
    
    # Verificar se há containers rodando
    if ! check_running_containers; then
        echo -e "${YELLOW}💡 Nenhuma ação necessária${NC}"
        exit 0
    fi
    
    # Parar serviços
    if ! stop_services; then
        echo -e "${RED}❌ Erro ao parar serviços${NC}"
        exit 1
    fi
    
    # Remover containers (se solicitado)
    if [ "$remove_containers_flag" = true ]; then
        remove_containers --remove
    fi
    
    # Limpar recursos (se solicitado)
    if [ "$cleanup_flag" = true ]; then
        cleanup_resources --cleanup
    fi
    
    # Mostrar status final
    show_final_status
    
    # Mostrar comandos úteis
    show_useful_commands
    
    echo ""
    echo -e "${GREEN}🎉 Ambiente parado com sucesso!${NC}"
}

# Executar função principal
main "$@" 