#!/bin/bash

# CBD Real Digital - Teste Automatizado Postman
# Script para executar testes via Newman (CLI do Postman)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Executando Testes Postman${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar se Newman está instalado
if ! command -v newman >/dev/null 2>&1; then
    print_error "Newman não está instalado!"
    print_message "Instalando Newman..."
    npm install -g newman
fi

# Verificar se os arquivos existem
if [ ! -f "CBD_Real_Digital_Postman_Collection.json" ]; then
    print_error "Arquivo de coleção não encontrado!"
    exit 1
fi

if [ ! -f "CBD_Real_Digital_Environment.json" ]; then
    print_error "Arquivo de ambiente não encontrado!"
    exit 1
fi

print_header

# Criar diretório para relatórios
mkdir -p reports

# Executar testes
print_message "Executando testes da coleção..."

newman run CBD_Real_Digital_Postman_Collection.json \
    --environment CBD_Real_Digital_Environment.json \
    --reporters cli,json,html \
    --reporter-json-export reports/results.json \
    --reporter-html-export reports/report.html \
    --delay-request 1000 \
    --timeout-request 10000

print_message "Testes concluídos!"
print_message "Relatórios gerados em: reports/"
print_message "- JSON: reports/results.json"
print_message "- HTML: reports/report.html"
