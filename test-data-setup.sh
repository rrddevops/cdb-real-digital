#!/bin/bash

# CBD Real Digital - Setup de Dados de Teste
# Script para criar dados de teste para os testes do Postman

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Função para fazer requisição POST
make_request() {
    local endpoint=$1
    local data=$2
    local description=$3
    
    print_message "Executando: $description"
    
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$data" \
        "http://localhost:3000$endpoint")
    
    if echo "$response" | grep -q '"status":"success"'; then
        print_message "✓ $description - Sucesso"
        echo "$response" | jq -r '.data.commitmentId // .data.swapId // "N/A"'
    else
        print_warning "⚠ $description - Erro ou já existe"
        echo "$response"
    fi
    
    echo ""
}

print_message "Configurando dados de teste..."

# 1. Depósito de Real Digital
make_request "/depositErc20" \
    '{"amount": 1000.00, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
    "Depósito de 1000 DREX"

# 2. Depósito de TPFt Série 1
make_request "/depositErc1155" \
    '{"tokenId": 1, "amount": 100, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
    "Depósito de 100 TPFt Série 1"

# 3. Depósito de TPFt Série 2
make_request "/depositErc1155" \
    '{"tokenId": 2, "amount": 500, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
    "Depósito de 500 TPFt Série 2"

# 4. Depósito de grande quantidade de Real Digital
make_request "/depositErc20" \
    '{"amount": 10000.00, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
    "Depósito de 10000 DREX"

print_message "Dados de teste configurados!"
print_message "Agora você pode executar os testes do Postman."
