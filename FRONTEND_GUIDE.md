# 🎨 Frontend CBD Real Digital - Guia Completo

## 📋 Visão Geral

O frontend do CBD Real Digital é uma interface web moderna e intuitiva que permite aos usuários interagir com o sistema de moeda digital brasileira DREX. A interface oferece funcionalidades completas para troca de tokens, depósitos, configurações e monitoramento de operações.

## 🚀 Acesso Rápido

**URL Principal**: http://localhost

### Requisitos do Navegador
- **Chrome/Edge**: Versão 90+
- **Firefox**: Versão 88+
- **Safari**: Versão 14+
- **MetaMask**: Extensão instalada (recomendado)

## 🎯 Funcionalidades Principais

### 1. 📊 Dashboard
O dashboard é a tela principal que mostra:

- **Saldos em Tempo Real**
  - Real Digital (DREX)
  - TPFt (Títulos Públicos Federais tokenizados)
  - Swaps ativos

- **Atividade Recente**
  - Últimas 5 transações
  - Status de cada operação
  - Timestamps

- **Status da Rede**
  - Conectividade com blockchain
  - Último bloco processado
  - Gas price atual

### 2. 💱 Troca de Tokens (Swap)
Interface completa para trocar Real Digital por TPFt:

#### Como Fazer um Swap:
1. **Acesse a aba "Troca de Tokens"**
2. **Digite a quantidade** de Real Digital
3. **Selecione o token TPFt** desejado (Série 1, 2 ou 3)
4. **Verifique o cálculo automático** da quantidade de TPFt
5. **Clique em "Iniciar Troca"**

#### Swaps Ativos:
- Visualize todos os swaps pendentes
- Complete swaps em andamento
- Monitore o status das operações

### 3. 💰 Depósitos
Dois tipos de depósito disponíveis:

#### Depósito Real Digital (ERC-20):
- Quantidade em DREX
- Conta de destino (opcional - usa carteira conectada)
- Confirmação automática

#### Depósito TPFt (ERC-1155):
- Token ID específico
- Quantidade de tokens
- Conta de destino

### 4. 📜 Histórico de Transações
Lista completa de todas as operações:

- **Filtros por tipo** de transação
- **Detalhes completos** de cada operação
- **Status em tempo real**
- **Ações disponíveis** (visualizar, reverter)

### 5. ⚙️ Configurações
Duas seções de configuração:

#### Configurações da Conta:
- Nome da conta
- Email de contato
- Endereço da carteira (somente leitura)

#### Configurações da Rede:
- RPC URL (padrão: ws://localhost:8545)
- Chain ID (padrão: 381660001)
- Endereços dos contratos:
  - Real Digital: `0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e`
  - TPFt: `0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E`

## 🔗 Integração com Carteira

### Conectar MetaMask:
1. **Clique em "Conectar Carteira"** no canto superior direito
2. **Autorize o MetaMask** quando solicitado
3. **Verifique o endereço** exibido na interface

### Configurar Rede:
No MetaMask, adicione uma nova rede com:
- **Nome**: CBD Real Digital
- **Chain ID**: 381660001
- **RPC URL**: ws://localhost:8545
- **Símbolo**: DREX

## 🎨 Interface e Design

### Características Visuais:
- **Design Responsivo**: Funciona em desktop, tablet e mobile
- **Tema Moderno**: Gradientes e sombras suaves
- **Cores Institucionais**: Azul e verde do Banco Central
- **Ícones Intuitivos**: Font Awesome para melhor UX

### Componentes Principais:
- **Cards Informativos**: Saldos e status
- **Tabelas Interativas**: Histórico e transações
- **Formulários Validados**: Entrada de dados segura
- **Notificações Toast**: Feedback em tempo real

## 🔧 Funcionalidades Técnicas

### APIs Integradas:
- **ZApp API** (porta 3000): Operações principais
- **Timber API** (porta 3100): Logs e commitments
- **Proxy Nginx**: Roteamento e CORS

### Recursos Avançados:
- **Atualização Automática**: Dados atualizados a cada 30s
- **Persistência Local**: Configurações salvas no navegador
- **Validação em Tempo Real**: Verificação de dados
- **Tratamento de Erros**: Mensagens amigáveis

## 🐛 Troubleshooting

### Problemas Comuns:

#### 1. Carteira não conecta
```
Solução:
- Verifique se o MetaMask está instalado
- Recarregue a página
- Verifique se está na rede correta
- Limpe o cache do navegador
```

#### 2. APIs não respondem
```
Solução:
- Verifique se os containers estão rodando
- Teste as URLs diretamente:
  - http://localhost:3000
  - http://localhost:3100
- Verifique os logs dos serviços
```

#### 3. Saldos não atualizam
```
Solução:
- Aguarde a atualização automática (30s)
- Clique em "Atualizar" manualmente
- Verifique a conectividade com a blockchain
```

#### 4. Erro de CORS
```
Solução:
- O Nginx está configurado para resolver CORS
- Se persistir, verifique as configurações do proxy
- Reinicie o container frontend
```

### Logs e Debug:
```bash
# Ver logs do frontend
docker logs cbd-frontend

# Ver logs das APIs
docker logs cbd-zapp
docker logs cbd-timber

# Testar conectividade
curl http://localhost
curl http://localhost:3000
curl http://localhost:3100
```

## 📱 Responsividade

### Breakpoints:
- **Desktop**: > 1200px
- **Tablet**: 768px - 1199px
- **Mobile**: < 767px

### Adaptações Mobile:
- Menu colapsável
- Cards empilhados
- Tabelas com scroll horizontal
- Botões maiores para touch

## 🔒 Segurança

### Medidas Implementadas:
- **Validação de Entrada**: Todos os campos validados
- **Sanitização de Dados**: Prevenção de XSS
- **HTTPS Ready**: Configuração para produção
- **CORS Configurado**: Controle de acesso

### Boas Práticas:
- Nunca compartilhe chaves privadas
- Use MetaMask para transações
- Verifique endereços antes de enviar
- Mantenha o navegador atualizado

## 🚀 Deploy em Produção

### Configurações Recomendadas:
```nginx
# nginx.conf para produção
server {
    listen 443 ssl;
    server_name seu-dominio.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # Configurações de segurança
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
```

### Variáveis de Ambiente:
```bash
# .env para produção
NODE_ENV=production
API_BASE_URL=https://api.seu-dominio.com
TIMBER_API_URL=https://timber.seu-dominio.com
```

## 📞 Suporte

### Recursos de Ajuda:
- **Documentação**: Este guia
- **Logs**: Console do navegador (F12)
- **Testes**: Script `test-services.sh`
- **Comunidade**: Repositório do projeto

### Contatos:
- **Email**: suporte@bancocentral.gov.br
- **Issues**: GitHub do projeto
- **Documentação**: README.md principal

---

**Nota**: Este frontend é parte do piloto CBD Real Digital. Para uso em produção, consulte a documentação oficial do Banco Central do Brasil. 