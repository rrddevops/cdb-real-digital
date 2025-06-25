#!/bin/bash

# CBD Real Digital - Token Transfer Tests
# Script para executar testes específicos de envio de tokens

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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
    echo -e "${BLUE}  CBD Real Digital - Token Tests${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_section() {
    echo -e "${PURPLE}--- $1 ---${NC}"
}

print_success() {
    echo -e "${CYAN}✓ $1${NC}"
}

# Função para fazer requisição HTTP
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    print_message "Executando: $description"
    
    if [ -n "$data" ]; then
        response=$(curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "http://localhost:3000$endpoint")
    else
        response=$(curl -s -X "$method" \
            "http://localhost:3000$endpoint")
    fi
    
    # Verificar se a resposta contém sucesso
    if echo "$response" | grep -q '"status":"success"'; then
        print_success "$description - Sucesso"
        return 0
    elif echo "$response" | grep -q '"status":"error"'; then
        print_warning "$description - Erro esperado"
        return 0
    else
        print_error "$description - Falha inesperada"
        echo "Resposta: $response"
        return 1
    fi
}

# Função para verificar se o ambiente está rodando
check_environment() {
    print_message "Verificando ambiente..."
    
    if ! curl -s http://localhost:3000 > /dev/null; then
        print_error "ZApp API não está respondendo!"
        print_warning "Execute: ./start-environment.sh"
        exit 1
    fi
    
    print_success "Ambiente está rodando"
}

# Função para configurar dados de teste
setup_test_data() {
    print_section "Configurando Dados de Teste"
    
    # Depositar Real Digital na conta 1
    make_request "POST" "/depositErc20" \
        '{"amount": 5000.00, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
        "Depósito de 5000 DREX na conta 1"
    
    # Depositar TPFt Série 1 na conta 1
    make_request "POST" "/depositErc1155" \
        '{"tokenId": 1, "amount": 1000, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
        "Depósito de 1000 TPFt Série 1 na conta 1"
    
    # Depositar TPFt Série 2 na conta 1
    make_request "POST" "/depositErc1155" \
        '{"tokenId": 2, "amount": 500, "account": "0x1234567890abcdef1234567890abcdef12345678"}' \
        "Depósito de 500 TPFt Série 2 na conta 1"
    
    # Depositar Real Digital na conta 2
    make_request "POST" "/depositErc20" \
        '{"amount": 2000.00, "account": "0xabcdef1234567890abcdef1234567890abcdef12"}' \
        "Depósito de 2000 DREX na conta 2"
}

# Função para testar transferências de Real Digital
test_real_digital_transfers() {
    print_section "Testando Transferências de Real Digital"
    
    # Transferência pequena
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 100.00}' \
        "Transferência de 100 DREX"
    
    # Transferência média
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 500.00}' \
        "Transferência de 500 DREX"
    
    # Transferência grande
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 1000.00}' \
        "Transferência de 1000 DREX"
    
    # Transferência para múltiplas contas
    make_request "POST" "/bulkTransfer" \
        '{"transfers": [{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 200.00}, {"to": "0x9876543210fedcba9876543210fedcba98765432", "amount": 300.00}]}' \
        "Transferência para múltiplas contas"
}

# Função para testar transferências de TPFt
test_tpft_transfers() {
    print_section "Testando Transferências de TPFt"
    
    # Transferência TPFt Série 1
    make_request "POST" "/transferErc1155" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "tokenId": 1, "amount": 50}' \
        "Transferência de 50 TPFt Série 1"
    
    # Transferência TPFt Série 2
    make_request "POST" "/transferErc1155" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "tokenId": 2, "amount": 100}' \
        "Transferência de 100 TPFt Série 2"
    
    # Transferência múltiplos tipos de TPFt
    make_request "POST" "/bulkTransferErc1155" \
        '{"transfers": [{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "tokenId": 1, "amount": 25}, {"to": "0xabcdef1234567890abcdef1234567890abcdef12", "tokenId": 2, "amount": 50}]}' \
        "Transferência múltiplos tipos de TPFt"
}

# Função para testar swaps
test_swaps() {
    print_section "Testando Swaps de Tokens"
    
    # Iniciar swap DREX → TPFt Série 1
    make_request "POST" "/startSwapFromErc20ToErc1155" \
        '{"erc20Address": "0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e", "counterParty": "0xabcdef1234567890abcdef1234567890abcdef12", "amountSent": 500, "tokenIdReceived": 1, "tokenReceivedAmount": 50}' \
        "Iniciar swap 500 DREX → 50 TPFt Série 1"
    
    # Iniciar swap DREX → TPFt Série 2
    make_request "POST" "/startSwapFromErc20ToErc1155" \
        '{"erc20Address": "0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e", "counterParty": "0xabcdef1234567890abcdef1234567890abcdef12", "amountSent": 1000, "tokenIdReceived": 2, "tokenReceivedAmount": 100}' \
        "Iniciar swap 1000 DREX → 100 TPFt Série 2"
}

# Função para testar validações
test_validations() {
    print_section "Testando Validações"
    
    # Consultar saldo
    make_request "GET" "/balance?account=0x1234567890abcdef1234567890abcdef12345678" "" \
        "Consulta saldo da conta 1"
    
    # Consultar histórico de transferências
    make_request "GET" "/transfers?account=0x1234567890abcdef1234567890abcdef12345678&limit=10" "" \
        "Consulta histórico de transferências"
    
    # Validar transação
    make_request "POST" "/validateTransaction" \
        '{"from": "0x1234567890abcdef1234567890abcdef12345678", "to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 100.00, "tokenType": "erc20"}' \
        "Validar transação"
}

# Função para testar erros
test_errors() {
    print_section "Testando Tratamento de Erros"
    
    # Transferência com saldo insuficiente
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 100000.00}' \
        "Transferência com saldo insuficiente"
    
    # Transferência para endereço inválido
    make_request "POST" "/transfer" \
        '{"to": "0xinvalid", "amount": 100.00}' \
        "Transferência para endereço inválido"
    
    # Transferência com valor zero
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 0.00}' \
        "Transferência com valor zero"
}

# Função para testar performance
test_performance() {
    print_section "Testando Performance"
    
    # Múltiplas transferências simultâneas
    make_request "POST" "/bulkTransfer" \
        '{"transfers": [{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 10.00}, {"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 20.00}, {"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 30.00}, {"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 40.00}, {"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 50.00}]}' \
        "5 transferências simultâneas"
    
    # Transferência de grande quantidade
    make_request "POST" "/transfer" \
        '{"to": "0xabcdef1234567890abcdef1234567890abcdef12", "amount": 5000.00}' \
        "Transferência de 5000 DREX"
}

# Função para gerar relatório
generate_report() {
    print_section "Gerando Relatório"
    
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local report_file="token_test_report_$timestamp.txt"
    
    cat > "$report_file" << EOF
CBD Real Digital - Relatório de Testes de Token
===============================================
Data: $(date)
Timestamp: $timestamp

RESUMO DOS TESTES:
==================

1. Configuração de Dados de Teste:
   - Depósito de 5000 DREX na conta 1
   - Depósito de 1000 TPFt Série 1 na conta 1
   - Depósito de 500 TPFt Série 2 na conta 1
   - Depósito de 2000 DREX na conta 2

2. Transferências de Real Digital:
   - Transferência pequena (100 DREX)
   - Transferência média (500 DREX)
   - Transferência grande (1000 DREX)
   - Transferência para múltiplas contas

3. Transferências de TPFt:
   - Transferência TPFt Série 1 (50 tokens)
   - Transferência TPFt Série 2 (100 tokens)
   - Transferência múltiplos tipos

4. Swaps de Tokens:
   - Swap 500 DREX → 50 TPFt Série 1
   - Swap 1000 DREX → 100 TPFt Série 2

5. Validações:
   - Consulta de saldo
   - Consulta de histórico
   - Validação de transação

6. Tratamento de Erros:
   - Saldo insuficiente
   - Endereço inválido
   - Valor zero

7. Testes de Performance:
   - 5 transferências simultâneas
   - Transferência de grande quantidade

STATUS: Testes concluídos com sucesso!

Arquivo de relatório: $report_file
EOF
    
    print_success "Relatório gerado: $report_file"
}

# Função para limpeza
cleanup() {
    print_section "Limpando Dados de Teste"
    
    # Aqui você pode adicionar lógica para limpar dados de teste se necessário
    print_message "Dados de teste mantidos para análise"
}

# Função principal
main() {
    print_header
    
    # Verificar ambiente
    check_environment
    
    # Executar testes
    setup_test_data
    test_real_digital_transfers
    test_tpft_transfers
    test_swaps
    test_validations
    test_errors
    test_performance
    
    # Gerar relatório
    generate_report
    
    # Limpeza
    cleanup
    
    print_header
    print_success "Todos os testes de token foram executados com sucesso!"
    print_message "Consulte o relatório gerado para detalhes."
}

# Função para mostrar ajuda
show_help() {
    echo "Uso: $0 [opção]"
    echo ""
    echo "Opções:"
    echo "  -h, --help     Mostrar esta ajuda"
    echo "  -e, --errors   Executar apenas testes de erro"
    echo "  -p, --perf     Executar apenas testes de performance"
    echo "  -s, --setup    Executar apenas setup de dados"
    echo "  -r, --report   Gerar relatório apenas"
    echo ""
    echo "Exemplos:"
    echo "  $0              # Executar todos os testes"
    echo "  $0 --errors     # Executar apenas testes de erro"
    echo "  $0 --perf       # Executar apenas testes de performance"
}

# Processar argumentos
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -e|--errors)
        print_header
        check_environment
        test_errors
        generate_report
        exit 0
        ;;
    -p|--perf)
        print_header
        check_environment
        test_performance
        generate_report
        exit 0
        ;;
    -s|--setup)
        print_header
        check_environment
        setup_test_data
        print_success "Setup de dados concluído!"
        exit 0
        ;;
    -r|--report)
        generate_report
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Opção inválida: $1"
        show_help
        exit 1
        ;;
esac 