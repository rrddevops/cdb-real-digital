#!/bin/bash

# CBD Real Digital - Setup Postman
# Script para automatizar a configuração do Postman

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  CBD Real Digital - Postman Setup${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Função para verificar se o comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para verificar se o ambiente está rodando
check_environment() {
    print_message "Verificando se o ambiente está rodando..."
    
    if ! docker ps | grep -q "cbd-zapp"; then
        print_error "Container cbd-zapp não está rodando!"
        print_warning "Execute: ./start-environment.sh"
        exit 1
    fi
    
    if ! docker ps | grep -q "cbd-timber"; then
        print_error "Container cbd-timber não está rodando!"
        print_warning "Execute: ./start-environment.sh"
        exit 1
    fi
    
    print_message "Ambiente está rodando ✓"
}

# Função para testar conectividade das APIs
test_apis() {
    print_message "Testando conectividade das APIs..."
    
    # Testar ZApp API
    if curl -s http://localhost:3000 > /dev/null; then
        print_message "ZApp API (porta 3000) ✓"
    else
        print_error "ZApp API não está respondendo na porta 3000"
        return 1
    fi
    
    # Testar Timber API
    if curl -s http://localhost:3100 > /dev/null; then
        print_message "Timber API (porta 3100) ✓"
    else
        print_error "Timber API não está respondendo na porta 3100"
        return 1
    fi
    
    # Testar Zokrates
    if curl -s http://localhost:8080 > /dev/null; then
        print_message "Zokrates (porta 8080) ✓"
    else
        print_warning "Zokrates não está respondendo na porta 8080"
    fi
    
    print_message "Todas as APIs estão respondendo ✓"
}

# Função para criar arquivo de ambiente do Postman
create_environment_file() {
    print_message "Criando arquivo de ambiente do Postman..."
    
    cat > CBD_Real_Digital_Environment.json << EOF
{
    "id": "cbd-real-digital-env",
    "name": "CBD Real Digital",
    "values": [
        {
            "key": "base_url_zapp",
            "value": "http://localhost:3000",
            "type": "default",
            "enabled": true
        },
        {
            "key": "base_url_timber",
            "value": "http://localhost:3100",
            "type": "default",
            "enabled": true
        },
        {
            "key": "base_url_zokrates",
            "value": "http://localhost:8080",
            "type": "default",
            "enabled": true
        },
        {
            "key": "test_account",
            "value": "0x1234567890abcdef1234567890abcdef12345678",
            "type": "default",
            "enabled": true
        },
        {
            "key": "recipient_account",
            "value": "0xabcdef1234567890abcdef1234567890abcdef12",
            "type": "default",
            "enabled": true
        },
        {
            "key": "real_digital_contract",
            "value": "0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e",
            "type": "default",
            "enabled": true
        },
        {
            "key": "tpft_contract",
            "value": "0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E",
            "type": "default",
            "enabled": true
        },
        {
            "key": "rpc_url",
            "value": "ws://localhost:8545",
            "type": "default",
            "enabled": true
        },
        {
            "key": "chain_id",
            "value": "381660001",
            "type": "default",
            "enabled": true
        },
        {
            "key": "commitment_id",
            "value": "",
            "type": "default",
            "enabled": true
        },
        {
            "key": "swap_id",
            "value": "",
            "type": "default",
            "enabled": true
        },
        {
            "key": "start_date",
            "value": "2025-06-01",
            "type": "default",
            "enabled": true
        },
        {
            "key": "end_date",
            "value": "2025-06-30",
            "type": "default",
            "enabled": true
        }
    ],
    "_postman_variable_scope": "environment"
}
EOF
    
    print_message "Arquivo de ambiente criado: CBD_Real_Digital_Environment.json"
}

# Função para criar script de teste automatizado
create_test_script() {
    print_message "Criando script de teste automatizado..."
    
    cat > run-postman-tests.sh << 'EOF'
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
EOF
    
    chmod +x run-postman-tests.sh
    print_message "Script de teste criado: run-postman-tests.sh"
}

# Função para criar dados de teste
create_test_data() {
    print_message "Criando dados de teste..."
    
    cat > test-data-setup.sh << 'EOF'
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
EOF
    
    chmod +x test-data-setup.sh
    print_message "Script de dados de teste criado: test-data-setup.sh"
}

# Função para mostrar instruções
show_instructions() {
    print_message "Configuração concluída!"
    echo ""
    echo -e "${BLUE}📋 Próximos Passos:${NC}"
    echo ""
    echo "1. ${GREEN}Importar no Postman:${NC}"
    echo "   - Abra o Postman"
    echo "   - Clique em 'Import'"
    echo "   - Selecione: CBD_Real_Digital_Postman_Collection.json"
    echo "   - Selecione: CBD_Real_Digital_Environment.json"
    echo ""
    echo "2. ${GREEN}Configurar dados de teste:${NC}"
    echo "   ./test-data-setup.sh"
    echo ""
    echo "3. ${GREEN}Executar testes:${NC}"
    echo "   ./run-postman-tests.sh"
    echo ""
    echo "4. ${GREEN}Ou executar manualmente:${NC}"
    echo "   - Use o Runner do Postman"
    echo "   - Ou execute via Newman CLI"
    echo ""
    echo -e "${BLUE}📚 Documentação:${NC}"
    echo "   - POSTMAN_SETUP_GUIDE.md - Guia completo"
    echo "   - README.md - Documentação principal"
    echo ""
}

# Função principal
main() {
    print_header
    
    # Verificar dependências
    if ! command_exists docker; then
        print_error "Docker não está instalado!"
        exit 1
    fi
    
    if ! command_exists curl; then
        print_error "curl não está instalado!"
        exit 1
    fi
    
    if ! command_exists jq; then
        print_warning "jq não está instalado. Instalando..."
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command_exists yum; then
            sudo yum install -y jq
        elif command_exists brew; then
            brew install jq
        else
            print_error "Não foi possível instalar jq automaticamente"
            exit 1
        fi
    fi
    
    # Verificar ambiente
    check_environment
    
    # Testar APIs
    test_apis
    
    # Criar arquivos
    create_environment_file
    create_test_script
    create_test_data
    
    # Mostrar instruções
    show_instructions
}

# Executar função principal
main "$@" 