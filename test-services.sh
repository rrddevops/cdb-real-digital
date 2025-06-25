#!/bin/bash

# Script para testar os serviços do CBD Real Digital

echo "🚀 Testando Serviços CBD Real Digital"
echo "======================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para testar endpoint
test_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -n "🔍 Testando $name... "
    
    if command -v curl &> /dev/null; then
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
        if [ "$response" = "$expected_status" ]; then
            echo -e "${GREEN}✅ OK${NC}"
            return 0
        else
            echo -e "${RED}❌ Erro (Status: $response)${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  curl não encontrado${NC}"
        return 1
    fi
}

# Função para verificar container
check_container() {
    local container=$1
    local name=$2
    
    echo -n "🐳 Verificando $name... "
    
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        echo -e "${GREEN}✅ Rodando${NC}"
        return 0
    else
        echo -e "${RED}❌ Parado${NC}"
        return 1
    fi
}

# Função para verificar porta
check_port() {
    local port=$1
    local name=$2
    
    echo -n "🔌 Verificando $name (porta $port)... "
    
    if command -v netstat &> /dev/null; then
        if netstat -an 2>/dev/null | grep -q ":$port "; then
            echo -e "${GREEN}✅ Ativa${NC}"
            return 0
        else
            echo -e "${RED}❌ Inativa${NC}"
            return 1
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln 2>/dev/null | grep -q ":$port "; then
            echo -e "${GREEN}✅ Ativa${NC}"
            return 0
        else
            echo -e "${RED}❌ Inativa${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  Não foi possível verificar${NC}"
        return 1
    fi
}

echo ""
echo "📋 Verificando Containers Docker"
echo "--------------------------------"

# Verificar containers
check_container "cbd-mongodb" "MongoDB"
check_container "cbd-zokrates" "Zokrates"
check_container "cbd-timber" "Timber API"
check_container "cbd-zapp" "ZApp API"
check_container "cbd-frontend" "Frontend Web"

echo ""
echo "🔌 Verificando Portas"
echo "---------------------"

# Verificar portas
check_port "27017" "MongoDB"
check_port "8080" "Zokrates"
check_port "3100" "Timber API"
check_port "3000" "ZApp API"
check_port "80" "Frontend Web"

echo ""
echo "🌐 Testando APIs"
echo "---------------"

# Aguardar um pouco para os serviços inicializarem
echo "⏳ Aguardando inicialização dos serviços..."
sleep 10

# Testar endpoints
test_endpoint "http://localhost:3000" "ZApp API"
test_endpoint "http://localhost:3100" "Timber API"
test_endpoint "http://localhost:8080" "Zokrates"

echo ""
echo "🎨 Testando Frontend"
echo "-------------------"

# Testar frontend
test_endpoint "http://localhost" "Frontend Web"
test_endpoint "http://localhost/api/" "API Proxy"

echo ""
echo "📊 Verificando Funcionalidades Específicas"
echo "------------------------------------------"

# Testar endpoints específicos do ZApp
echo -n "🔍 Testando getAllCommitments... "
if command -v curl &> /dev/null; then
    response=$(curl -s "http://localhost:3000/getAllCommitments" 2>/dev/null)
    if echo "$response" | grep -q "data"; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${YELLOW}⚠️  Resposta inesperada${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  curl não encontrado${NC}"
fi

# Testar endpoints específicos do Timber
echo -n "🔍 Testando logs do Timber... "
if command -v curl &> /dev/null; then
    response=$(curl -s "http://localhost:3100/logs" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${YELLOW}⚠️  Erro na resposta${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  curl não encontrado${NC}"
fi

echo ""
echo "🔧 Verificando Configurações"
echo "----------------------------"

# Verificar arquivos de configuração
echo -n "📁 Verificando config.toml... "
if [ -f "config.toml" ]; then
    echo -e "${GREEN}✅ Existe${NC}"
else
    echo -e "${YELLOW}⚠️  Não encontrado (use config.toml.example)${NC}"
fi

echo -n "📁 Verificando docker-compose-simple.yaml... "
if [ -f "docker-compose-simple.yaml" ]; then
    echo -e "${GREEN}✅ Existe${NC}"
else
    echo -e "${RED}❌ Não encontrado${NC}"
fi

echo -n "📁 Verificando frontend/index.html... "
if [ -f "frontend/index.html" ]; then
    echo -e "${GREEN}✅ Existe${NC}"
else
    echo -e "${RED}❌ Não encontrado${NC}"
fi

echo ""
echo "📈 Status Geral"
echo "--------------"

# Contar containers rodando
running_containers=$(docker ps --format "table {{.Names}}" | grep -c "cbd-")
total_containers=5

echo "🐳 Containers rodando: $running_containers/$total_containers"

if [ $running_containers -eq $total_containers ]; then
    echo -e "${GREEN}🎉 Todos os serviços estão rodando!${NC}"
else
    echo -e "${YELLOW}⚠️  Alguns serviços podem não estar funcionando${NC}"
fi

echo ""
echo "🌐 URLs de Acesso"
echo "----------------"
echo -e "${BLUE}Frontend Web:${NC} http://localhost"
echo -e "${BLUE}ZApp API:${NC} http://localhost:3000"
echo -e "${BLUE}Timber API:${NC} http://localhost:3100"
echo -e "${BLUE}Zokrates:${NC} http://localhost:8080"
echo -e "${BLUE}MongoDB:${NC} localhost:27017"

echo ""
echo "📝 Próximos Passos"
echo "-----------------"
echo "1. Abra http://localhost no seu navegador"
echo "2. Conecte sua carteira (MetaMask)"
echo "3. Configure as opções de rede:"
echo "   - Chain ID: 381660001"
echo "   - RPC URL: ws://localhost:8545"
echo "4. Teste as funcionalidades de swap e depósito"

echo ""
echo "🔧 Comandos Úteis"
echo "----------------"
echo "docker-compose -f docker-compose-simple.yaml logs -f    # Ver logs"
echo "docker-compose -f docker-compose-simple.yaml restart    # Reiniciar serviços"
echo "docker-compose -f docker-compose-simple.yaml down       # Parar serviços"

echo ""
echo "✅ Teste concluído!" 