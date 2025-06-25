#!/bin/bash

# CBD Real Digital - Script Principal de Controle
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
    echo "║                Controle do Ambiente                          ║"
    echo "║                                                              ║"
    echo "║  🏦 Banco Central do Brasil - Projeto Piloto DREX           ║"
    echo "║  🚀 Hyperledger Besu + QBFT + Smart Contracts               ║"
    echo "║  🔐 Starlight + Rayls + Anonymous Zether                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para mostrar menu principal
show_menu() {
    echo ""
    echo -e "${PURPLE}🎛️  Menu Principal:${NC}"
    echo "=================================="
    echo -e "${CYAN}1.${NC} 🚀 Iniciar Ambiente"
    echo -e "${CYAN}2.${NC} 🛑 Parar Ambiente"
    echo -e "${CYAN}3.${NC} 🔄 Reiniciar Ambiente"
    echo -e "${CYAN}4.${NC} 🧪 Executar Testes"
    echo -e "${CYAN}5.${NC} 📊 Status dos Serviços"
    echo -e "${CYAN}6.${NC} 📋 Ver Logs"
    echo -e "${CYAN}7.${NC} 🔧 Setup Inicial"
    echo -e "${CYAN}8.${NC} 🧹 Limpeza Completa"
    echo -e "${CYAN}9.${NC} 🌐 Abrir Frontend"
    echo -e "${CYAN}0.${NC} ❌ Sair"
    echo ""
}

# Função para verificar status dos serviços
check_services_status() {
    echo -e "${CYAN}📊 Verificando status dos serviços...${NC}"
    echo ""
    
    local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
    local running_count=0
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            echo -e "${GREEN}✅ $container - Rodando${NC}"
            ((running_count++))
        else
            echo -e "${RED}❌ $container - Parado${NC}"
        fi
    done
    
    echo ""
    echo -e "${PURPLE}📈 Resumo: $running_count/5 serviços rodando${NC}"
    
    if [ $running_count -eq 5 ]; then
        echo -e "${GREEN}🎉 Todos os serviços estão funcionando!${NC}"
        echo ""
        echo -e "${PURPLE}🌐 URLs de Acesso:${NC}"
        echo -e "${BLUE}   Frontend Web:${NC} http://localhost"
        echo -e "${BLUE}   ZApp API:${NC} http://localhost:3000"
        echo -e "${BLUE}   Timber API:${NC} http://localhost:3100"
        echo -e "${BLUE}   Zokrates:${NC} http://localhost:8080"
        echo -e "${BLUE}   MongoDB:${NC} localhost:27017"
    elif [ $running_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Alguns serviços não estão rodando${NC}"
    else
        echo -e "${RED}❌ Nenhum serviço está rodando${NC}"
    fi
}

# Função para mostrar logs
show_logs() {
    echo -e "${CYAN}📋 Logs dos Serviços:${NC}"
    echo ""
    
    local containers=("cbd-frontend" "cbd-zapp" "cbd-timber" "cbd-zokrates" "cbd-mongodb")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            echo -e "${YELLOW}📋 $container (últimas 5 linhas):${NC}"
            docker logs --tail=5 "$container" 2>&1
            echo ""
        fi
    done
}

# Função para abrir frontend
open_frontend() {
    echo -e "${CYAN}🌐 Abrindo frontend...${NC}"
    
    # Verificar se o frontend está rodando
    if docker ps --format "table {{.Names}}" | grep -q "cbd-frontend"; then
        echo -e "${GREEN}✅ Frontend está rodando${NC}"
        
        # Detectar sistema operacional
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            if command -v xdg-open &> /dev/null; then
                xdg-open http://localhost
            elif command -v gnome-open &> /dev/null; then
                gnome-open http://localhost
            else
                echo -e "${YELLOW}💡 Abra manualmente: http://localhost${NC}"
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            open http://localhost
        elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            # Windows
            start http://localhost
        else
            echo -e "${YELLOW}💡 Abra manualmente: http://localhost${NC}"
        fi
    else
        echo -e "${RED}❌ Frontend não está rodando${NC}"
        echo -e "${YELLOW}💡 Execute 'Iniciar Ambiente' primeiro${NC}"
    fi
}

# Função para limpeza completa
full_cleanup() {
    echo -e "${CYAN}🧹 Limpeza Completa do Ambiente${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  ATENÇÃO: Esta operação irá:${NC}"
    echo "   - Parar todos os containers"
    echo "   - Remover todos os containers"
    echo "   - Remover todas as imagens"
    echo "   - Remover todos os volumes"
    echo "   - Remover todas as redes"
    echo ""
    
    read -p "Tem certeza que deseja continuar? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}🛑 Parando containers...${NC}"
        docker-compose -f docker-compose-simple.yaml down --rmi all --volumes --remove-orphans 2>/dev/null
        
        echo -e "${CYAN}🗑️  Removendo containers...${NC}"
        docker container prune -f
        
        echo -e "${CYAN}🖼️  Removendo imagens...${NC}"
        docker image prune -a -f
        
        echo -e "${CYAN}💾 Removendo volumes...${NC}"
        docker volume prune -f
        
        echo -e "${CYAN}🌐 Removendo redes...${NC}"
        docker network prune -f
        
        echo -e "${GREEN}✅ Limpeza completa concluída${NC}"
    else
        echo -e "${YELLOW}❌ Operação cancelada${NC}"
    fi
}

# Função para executar comando
execute_command() {
    local command=$1
    
    case $command in
        1)
            echo -e "${CYAN}🚀 Iniciando ambiente...${NC}"
            if [ -f "start-environment.sh" ]; then
                chmod +x start-environment.sh
                ./start-environment.sh
            else
                echo -e "${RED}❌ Script start-environment.sh não encontrado${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}🛑 Parando ambiente...${NC}"
            if [ -f "stop-environment.sh" ]; then
                chmod +x stop-environment.sh
                ./stop-environment.sh
            else
                echo -e "${RED}❌ Script stop-environment.sh não encontrado${NC}"
            fi
            ;;
        3)
            echo -e "${CYAN}🔄 Reiniciando ambiente...${NC}"
            if [ -f "restart-environment.sh" ]; then
                chmod +x restart-environment.sh
                ./restart-environment.sh
            else
                echo -e "${RED}❌ Script restart-environment.sh não encontrado${NC}"
            fi
            ;;
        4)
            echo -e "${CYAN}🧪 Executando testes...${NC}"
            if [ -f "test-services.sh" ]; then
                chmod +x test-services.sh
                ./test-services.sh
            else
                echo -e "${RED}❌ Script test-services.sh não encontrado${NC}"
            fi
            ;;
        5)
            check_services_status
            ;;
        6)
            show_logs
            ;;
        7)
            echo -e "${CYAN}🔧 Executando setup inicial...${NC}"
            if [ -f "setup-environment.sh" ]; then
                chmod +x setup-environment.sh
                ./setup-environment.sh
            else
                echo -e "${RED}❌ Script setup-environment.sh não encontrado${NC}"
            fi
            ;;
        8)
            full_cleanup
            ;;
        9)
            open_frontend
            ;;
        0)
            echo -e "${GREEN}👋 Saindo...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opção inválida${NC}"
            ;;
    esac
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  start, 1     Iniciar ambiente"
    echo "  stop, 2      Parar ambiente"
    echo "  restart, 3   Reiniciar ambiente"
    echo "  test, 4      Executar testes"
    echo "  status, 5    Ver status dos serviços"
    echo "  logs, 6      Ver logs"
    echo "  setup, 7     Setup inicial"
    echo "  cleanup, 8   Limpeza completa"
    echo "  open, 9      Abrir frontend"
    echo "  menu         Menu interativo"
    echo "  help, -h     Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 start     # Iniciar ambiente"
    echo "  $0 status    # Ver status"
    echo "  $0 menu      # Menu interativo"
}

# Função principal
main() {
    show_banner
    
    # Verificar argumentos
    if [ $# -eq 0 ]; then
        # Modo interativo
        while true; do
            show_menu
            read -p "Escolha uma opção (0-9): " -n 1 -r
            echo
            execute_command $REPLY
            echo ""
            read -p "Pressione Enter para continuar..."
        done
    else
        # Modo comando direto
        case $1 in
            start|1)
                execute_command 1
                ;;
            stop|2)
                execute_command 2
                ;;
            restart|3)
                execute_command 3
                ;;
            test|4)
                execute_command 4
                ;;
            status|5)
                execute_command 5
                ;;
            logs|6)
                execute_command 6
                ;;
            setup|7)
                execute_command 7
                ;;
            cleanup|8)
                execute_command 8
                ;;
            open|9)
                execute_command 9
                ;;
            menu)
                # Modo interativo
                while true; do
                    show_menu
                    read -p "Escolha uma opção (0-9): " -n 1 -r
                    echo
                    execute_command $REPLY
                    echo ""
                    read -p "Pressione Enter para continuar..."
                done
                ;;
            help|-h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}❌ Comando desconhecido: $1${NC}"
                echo "Use '$0 help' para ver os comandos disponíveis"
                exit 1
                ;;
        esac
    fi
}

# Executar função principal
main "$@" 