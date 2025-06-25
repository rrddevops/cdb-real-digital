#!/bin/bash

# CBD Real Digital - Setup de Dados de Teste
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
    echo "║                Setup de Dados de Teste                       ║"
    echo "║                                                              ║"
    echo "║  🏦 Banco Central do Brasil - Projeto Piloto DREX           ║"
    echo "║  🚀 Hyperledger Besu + QBFT + Smart Contracts               ║"
    echo "║  🔐 Starlight + Rayls + Anonymous Zether                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para aguardar serviço
wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${CYAN}⏳ Aguardando $name...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $name está pronto${NC}"
            return 0
        else
            echo -n "   Tentativa $attempt/$max_attempts... "
            sleep 2
            ((attempt++))
        fi
    done
    
    echo -e "${RED}❌ Timeout aguardando $name${NC}"
    return 1
}

# Função para criar depósito de teste
create_test_deposit() {
    local type=$1
    local amount=$2
    local account=$3
    local token_id=${4:-1}
    
    echo -e "${CYAN}💰 Criando depósito de teste ($type)...${NC}"
    
    if [ "$type" = "erc20" ]; then
        response=$(curl -s -X POST http://localhost:3000/depositErc20 \
            -H "Content-Type: application/json" \
            -d "{\"amount\": $amount, \"account\": \"$account\"}")
    else
        response=$(curl -s -X POST http://localhost:3000/depositErc1155 \
            -H "Content-Type: application/json" \
            -d "{\"tokenId\": $token_id, \"amount\": $amount, \"account\": \"$account\"}")
    fi
    
    if echo "$response" | grep -q "success"; then
        echo -e "${GREEN}✅ Depósito $type criado: $amount${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro ao criar depósito $type${NC}"
        echo "   Resposta: $response"
        return 1
    fi
}

# Função para criar swap de teste
create_test_swap() {
    local amount_sent=$1
    local token_id=$2
    local token_amount=$3
    local counter_party=$4
    
    echo -e "${CYAN}🔄 Criando swap de teste...${NC}"
    
    local swap_data="{
        \"erc20Address\": \"0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e\",
        \"counterParty\": \"$counter_party\",
        \"amountSent\": $amount_sent,
        \"tokenIdReceived\": $token_id,
        \"tokenReceivedAmount\": $token_amount
    }"
    
    response=$(curl -s -X POST http://localhost:3000/startSwapFromErc20ToErc1155 \
        -H "Content-Type: application/json" \
        -d "$swap_data")
    
    if echo "$response" | grep -q "success"; then
        echo -e "${GREEN}✅ Swap criado: $amount_sent DREX → $token_amount TPFt${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro ao criar swap${NC}"
        echo "   Resposta: $response"
        return 1
    fi
}

# Função para completar swap
complete_test_swap() {
    local swap_id=$1
    
    echo -e "${CYAN}✅ Completando swap $swap_id...${NC}"
    
    response=$(curl -s -X POST http://localhost:3000/completeSwapFromErc20ToErc1155 \
        -H "Content-Type: application/json" \
        -d "{\"swapId\": $swap_id}")
    
    if echo "$response" | grep -q "success"; then
        echo -e "${GREEN}✅ Swap $swap_id completado${NC}"
        return 0
    else
        echo -e "${RED}❌ Erro ao completar swap $swap_id${NC}"
        echo "   Resposta: $response"
        return 1
    fi
}

# Função para mostrar dados de teste
show_test_data() {
    echo -e "${CYAN}📊 Dados de Teste Criados:${NC}"
    echo ""
    
    # Mostrar commitments
    echo -e "${YELLOW}📋 Commitments:${NC}"
    curl -s http://localhost:3000/getAllCommitments | jq '.' 2>/dev/null || echo "   Nenhum commitment encontrado"
    
    echo ""
    echo -e "${YELLOW}💰 Saldos Simulados:${NC}"
    echo "   Real Digital: 10,000.00 DREX"
    echo "   TPFt Série 1: 1,000 tokens"
    echo "   TPFt Série 2: 500 tokens"
    echo "   TPFt Série 3: 250 tokens"
    
    echo ""
    echo -e "${YELLOW}🔄 Swaps Disponíveis:${NC}"
    echo "   Swap #1: 1,000 DREX ↔ 100 TPFt Série 1"
    echo "   Swap #2: 500 DREX ↔ 50 TPFt Série 2"
    echo "   Swap #3: 250 DREX ↔ 25 TPFt Série 3"
}

# Função para criar cenários de teste
create_test_scenarios() {
    echo -e "${CYAN}🎭 Criando cenários de teste...${NC}"
    
    # Conta de teste
    local test_account="0x1234567890abcdef1234567890abcdef12345678"
    
    # Cenário 1: Depósitos iniciais
    echo ""
    echo -e "${PURPLE}📥 Cenário 1: Depósitos Iniciais${NC}"
    create_test_deposit "erc20" 10000 "$test_account"
    create_test_deposit "erc1155" 1000 "$test_account" 1
    create_test_deposit "erc1155" 500 "$test_account" 2
    create_test_deposit "erc1155" 250 "$test_account" 3
    
    # Cenário 2: Swaps básicos
    echo ""
    echo -e "${PURPLE}🔄 Cenário 2: Swaps Básicos${NC}"
    create_test_swap 1000 1 100 "$test_account"
    create_test_swap 500 2 50 "$test_account"
    create_test_swap 250 3 25 "$test_account"
    
    # Cenário 3: Swaps complexos
    echo ""
    echo -e "${PURPLE}🎯 Cenário 3: Swaps Complexos${NC}"
    create_test_swap 2000 1 200 "$test_account"
    create_test_swap 1500 2 150 "$test_account"
    
    # Aguardar um pouco
    sleep 2
    
    # Mostrar dados criados
    show_test_data
}

# Função para mostrar instruções de teste
show_test_instructions() {
    echo ""
    echo -e "${PURPLE}🧪 Instruções para Teste:${NC}"
    echo "=================================="
    echo ""
    echo -e "${CYAN}1. Acesse o Frontend:${NC}"
    echo "   http://localhost"
    echo ""
    echo -e "${CYAN}2. Conecte sua Carteira:${NC}"
    echo "   - Use MetaMask ou carteira Web3"
    echo "   - Configure a rede:"
    echo "     * Chain ID: 381660001"
    echo "     * RPC URL: ws://localhost:8545"
    echo ""
    echo -e "${CYAN}3. Teste as Funcionalidades:${NC}"
    echo "   - Verifique os saldos no dashboard"
    echo "   - Tente fazer um swap de 100 DREX por 10 TPFt"
    echo "   - Teste depósitos de Real Digital e TPFt"
    echo "   - Verifique o histórico de transações"
    echo ""
    echo -e "${CYAN}4. Cenários de Teste Disponíveis:${NC}"
    echo "   - Swap pequeno: 100 DREX ↔ 10 TPFt"
    echo "   - Swap médio: 500 DREX ↔ 50 TPFt"
    echo "   - Swap grande: 1000 DREX ↔ 100 TPFt"
    echo ""
    echo -e "${CYAN}5. Troubleshooting:${NC}"
    echo "   - Se houver erro, verifique os logs:"
    echo "     docker logs cbd-zapp"
    echo "   - Teste a API diretamente:"
    echo "     curl http://localhost:3000/getAllCommitments"
}

# Função principal
main() {
    show_banner
    
    echo -e "${GREEN}🧪 Configurando dados de teste para CBD Real Digital...${NC}"
    echo ""
    
    # Verificar argumentos
    local skip_wait=false
    local force_setup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-wait)
                skip_wait=true
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
                echo "  --skip-wait     Pular aguardar serviços"
                echo "  --force         Forçar setup"
                echo "  --help, -h      Mostrar esta ajuda"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opção desconhecida: $1${NC}"
                echo "Use --help para ver as opções disponíveis"
                exit 1
                ;;
        esac
    done
    
    # Aguardar serviços (se não pulado)
    if [ "$skip_wait" = false ]; then
        if ! wait_for_service "http://localhost:3000" "ZApp API"; then
            echo -e "${RED}❌ ZApp API não está disponível${NC}"
            exit 1
        fi
    fi
    
    # Criar cenários de teste
    create_test_scenarios
    
    # Mostrar instruções
    show_test_instructions
    
    echo ""
    echo -e "${GREEN}🎉 Dados de teste configurados com sucesso!${NC}"
    echo ""
    echo -e "${PURPLE}🔧 Comandos Úteis:${NC}"
    echo "   ./test-services.sh        # Executar testes"
    echo "   ./cbd-control.sh status   # Ver status"
    echo "   docker logs cbd-zapp      # Ver logs do ZApp"
}

# Executar função principal
main "$@" 