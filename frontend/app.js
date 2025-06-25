// CBD Real Digital Frontend Application
class CBDRealDigitalApp {
    constructor() {
        this.web3 = null;
        this.account = null;
        this.contracts = {};
        this.apiBaseUrl = 'http://localhost:3000';
        this.timberApiUrl = 'http://localhost:3100';
        
        // Dados de exemplo para demonstração
        this.demoData = {
            realDigitalBalance: 10000.00,
            tpftBalances: {
                1: 1000,
                2: 500,
                3: 250
            },
            activeSwaps: 3,
            recentTransactions: [
                { type: 'Depósito', amount: '1,000.00 DREX', status: 'Concluído', date: '2025-06-25' },
                { type: 'Swap', amount: '500 DREX → 50 TPFt', status: 'Pendente', date: '2025-06-25' },
                { type: 'Depósito TPFt', amount: '100 TPFt Série 1', status: 'Concluído', date: '2025-06-24' }
            ]
        };
        
        this.init();
    }

    async init() {
        this.setupEventListeners();
        this.loadSettings();
        await this.connectWallet();
        this.loadBalances();
        this.loadRecentActivity();
        this.loadTransactions();
        this.startPolling();
    }

    setupEventListeners() {
        // Swap form
        document.getElementById('swapForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.startSwap();
        });

        // Deposit forms
        document.getElementById('depositErc20Form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.depositErc20();
        });

        document.getElementById('depositErc1155Form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.depositErc1155();
        });

        // Settings forms
        document.getElementById('accountSettingsForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveAccountSettings();
        });

        document.getElementById('networkSettingsForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.saveNetworkSettings();
        });

        // Real-time updates
        document.getElementById('swapAmount').addEventListener('input', (e) => {
            this.updateSwapCalculation(e.target.value);
        });

        // Tab changes
        document.querySelectorAll('[data-bs-toggle="tab"]').forEach(tab => {
            tab.addEventListener('shown.bs.tab', (e) => {
                if (e.target.id === 'transactions-tab') {
                    this.loadTransactions();
                } else if (e.target.id === 'dashboard-tab') {
                    this.loadRecentActivity();
                }
            });
        });
    }

    async connectWallet() {
        try {
            if (typeof window.ethereum !== 'undefined') {
                this.web3 = new Web3(window.ethereum);
                const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
                this.account = accounts[0];
                this.updateAccountDisplay();
                this.showNotification('Carteira conectada com sucesso!', 'success');
            } else {
                this.showNotification('MetaMask não encontrado. Instale a extensão.', 'error');
                // Usar dados de exemplo se não houver carteira
                this.useDemoMode();
            }
        } catch (error) {
            console.error('Erro ao conectar carteira:', error);
            this.showNotification('Erro ao conectar carteira. Usando modo demonstração.', 'warning');
            this.useDemoMode();
        }
    }

    useDemoMode() {
        this.account = '0x1234567890abcdef1234567890abcdef12345678';
        this.updateAccountDisplay();
        this.showNotification('Modo demonstração ativado. Use dados de exemplo.', 'info');
    }

    updateAccountDisplay() {
        const accountElement = document.getElementById('accountAddress');
        if (this.account) {
            accountElement.textContent = `${this.account.substring(0, 6)}...${this.account.substring(38)}`;
        } else {
            accountElement.textContent = 'Não conectado';
        }
    }

    async loadBalances() {
        try {
            // Tentar carregar saldos reais primeiro
            const realDigitalBalance = await this.getRealDigitalBalance();
            const tpftBalance = await this.getTPFtBalance();
            const activeSwaps = await this.getActiveSwaps();

            // Se não conseguir carregar dados reais, usar dados de exemplo
            const finalRealDigital = realDigitalBalance > 0 ? realDigitalBalance : this.demoData.realDigitalBalance;
            const finalTpft = tpftBalance > 0 ? tpftBalance : this.demoData.tpftBalances[1];
            const finalSwaps = activeSwaps > 0 ? activeSwaps : this.demoData.activeSwaps;

            document.getElementById('realDigitalBalance').textContent = finalRealDigital.toFixed(2);
            document.getElementById('tpftBalance').textContent = finalTpft.toString();
            document.getElementById('activeSwaps').textContent = finalSwaps.toString();
        } catch (error) {
            console.error('Erro ao carregar saldos:', error);
            // Usar dados de exemplo em caso de erro
            document.getElementById('realDigitalBalance').textContent = this.demoData.realDigitalBalance.toFixed(2);
            document.getElementById('tpftBalance').textContent = this.demoData.tpftBalances[1].toString();
            document.getElementById('activeSwaps').textContent = this.demoData.activeSwaps.toString();
        }
    }

    async getRealDigitalBalance() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            // Simular cálculo de saldo baseado nos commitments
            return data.data ? data.data.length * 100 : 0;
        } catch (error) {
            console.error('Erro ao obter saldo Real Digital:', error);
            return 0;
        }
    }

    async getTPFtBalance() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            // Simular saldo TPFt
            return data.data ? Math.floor(data.data.length / 2) : 0;
        } catch (error) {
            console.error('Erro ao obter saldo TPFt:', error);
            return 0;
        }
    }

    async getActiveSwaps() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            // Simular swaps ativos
            return data.data ? Math.floor(data.data.length / 3) : 0;
        } catch (error) {
            console.error('Erro ao obter swaps ativos:', error);
            return 0;
        }
    }

    updateSwapCalculation(amount) {
        const tpftAmount = document.getElementById('tpftAmount');
        const exchangeRate = document.getElementById('exchangeRate');
        
        if (amount && !isNaN(amount)) {
            const tpftValue = parseFloat(amount);
            tpftAmount.value = tpftValue;
            exchangeRate.value = `1 DREX = 1 TPFt`;
        } else {
            tpftAmount.value = '';
        }
    }

    async startSwap() {
        const amount = document.getElementById('swapAmount').value;
        const tokenId = document.getElementById('tpftToken').value;
        const tpftAmount = document.getElementById('tpftAmount').value;

        if (!amount || !tpftAmount) {
            this.showNotification('Preencha todos os campos', 'error');
            return;
        }

        try {
            this.showNotification('Iniciando swap...', 'info');

            const swapData = {
                erc20Address: document.getElementById('realDigitalContract').value,
                counterParty: this.account,
                amountSent: parseFloat(amount),
                tokenIdReceived: parseInt(tokenId),
                tokenReceivedAmount: parseInt(tpftAmount)
            };

            console.log('Dados do swap:', swapData);

            const response = await fetch(`${this.apiBaseUrl}/startSwapFromErc20ToErc1155`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(swapData)
            });

            const result = await response.json();
            console.log('Resposta da API:', result);
            
            if (result.status === 'success') {
                this.showNotification('Swap iniciado com sucesso!', 'success');
                this.loadBalances();
                this.loadActiveSwaps();
            } else {
                this.showNotification(`Erro ao iniciar swap: ${result.message || 'Erro desconhecido'}`, 'error');
                console.error('Erro detalhado:', result);
            }
        } catch (error) {
            console.error('Erro ao iniciar swap:', error);
            this.showNotification(`Erro de conexão: ${error.message}`, 'error');
            
            // Em modo demo, simular sucesso
            if (!this.web3) {
                this.showNotification('Swap simulado com sucesso (modo demo)!', 'success');
                this.loadBalances();
                this.loadActiveSwaps();
            }
        }
    }

    async depositErc20() {
        const amount = document.getElementById('depositAmount').value;
        const account = document.getElementById('depositAccount').value || this.account;

        if (!amount) {
            this.showNotification('Preencha a quantidade', 'error');
            return;
        }

        try {
            this.showNotification('Realizando depósito...', 'info');

            const depositData = {
                amount: parseFloat(amount),
                account: account
            };

            const response = await fetch(`${this.apiBaseUrl}/depositErc20`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(depositData)
            });

            const result = await response.json();
            
            if (result.status === 'success') {
                this.showNotification('Depósito realizado com sucesso!', 'success');
                this.loadBalances();
                this.loadRecentActivity();
            } else {
                this.showNotification(`Erro ao realizar depósito: ${result.message || 'Erro desconhecido'}`, 'error');
            }
        } catch (error) {
            console.error('Erro ao realizar depósito:', error);
            this.showNotification(`Erro de conexão: ${error.message}`, 'error');
            
            // Em modo demo, simular sucesso
            if (!this.web3) {
                this.showNotification('Depósito simulado com sucesso (modo demo)!', 'success');
                this.loadBalances();
                this.loadRecentActivity();
            }
        }
    }

    async depositErc1155() {
        const tokenId = document.getElementById('tpftTokenId').value;
        const amount = document.getElementById('tpftDepositAmount').value;
        const account = document.getElementById('tpftDepositAccount').value || this.account;

        if (!tokenId || !amount) {
            this.showNotification('Preencha todos os campos', 'error');
            return;
        }

        try {
            this.showNotification('Realizando depósito TPFt...', 'info');

            const depositData = {
                tokenId: parseInt(tokenId),
                amount: parseInt(amount),
                account: account
            };

            const response = await fetch(`${this.apiBaseUrl}/depositErc1155`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(depositData)
            });

            const result = await response.json();
            
            if (result.status === 'success') {
                this.showNotification('Depósito TPFt realizado com sucesso!', 'success');
                this.loadBalances();
                this.loadRecentActivity();
            } else {
                this.showNotification(`Erro ao realizar depósito TPFt: ${result.message || 'Erro desconhecido'}`, 'error');
            }
        } catch (error) {
            console.error('Erro ao realizar depósito TPFt:', error);
            this.showNotification(`Erro de conexão: ${error.message}`, 'error');
            
            // Em modo demo, simular sucesso
            if (!this.web3) {
                this.showNotification('Depósito TPFt simulado com sucesso (modo demo)!', 'success');
                this.loadBalances();
                this.loadRecentActivity();
            }
        }
    }

    async loadRecentActivity() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            
            const activityTable = document.getElementById('recentActivity');
            
            if (data.data && data.data.length > 0) {
                const recentItems = data.data.slice(0, 5);
                activityTable.innerHTML = recentItems.map(item => `
                    <tr>
                        <td><i class="fas fa-exchange-alt me-2"></i>${item.type || 'Commitment'}</td>
                        <td>${item.amount || 'N/A'}</td>
                        <td><span class="status-badge status-success">Concluído</span></td>
                        <td>${new Date(item.timestamp || Date.now()).toLocaleDateString()}</td>
                    </tr>
                `).join('');
            } else {
                // Usar dados de exemplo se não houver dados reais
                activityTable.innerHTML = this.demoData.recentTransactions.map(item => `
                    <tr>
                        <td><i class="fas fa-exchange-alt me-2"></i>${item.type}</td>
                        <td>${item.amount}</td>
                        <td><span class="status-badge ${item.status === 'Concluído' ? 'status-success' : 'status-pending'}">${item.status}</span></td>
                        <td>${item.date}</td>
                    </tr>
                `).join('');
            }
        } catch (error) {
            console.error('Erro ao carregar atividade recente:', error);
            // Usar dados de exemplo em caso de erro
            const activityTable = document.getElementById('recentActivity');
            activityTable.innerHTML = this.demoData.recentTransactions.map(item => `
                <tr>
                    <td><i class="fas fa-exchange-alt me-2"></i>${item.type}</td>
                    <td>${item.amount}</td>
                    <td><span class="status-badge ${item.status === 'Concluído' ? 'status-success' : 'status-pending'}">${item.status}</span></td>
                    <td>${item.date}</td>
                </tr>
            `).join('');
        }
    }

    async loadTransactions() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            
            const transactionsTable = document.getElementById('transactionsTable');
            
            if (data.data && data.data.length > 0) {
                transactionsTable.innerHTML = data.data.map((item, index) => `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${item.type || 'Commitment'}</td>
                        <td>${item.amount || 'N/A'}</td>
                        <td>${this.account ? this.account.substring(0, 8) + '...' : 'N/A'}</td>
                        <td>${item.account || 'N/A'}</td>
                        <td><span class="status-badge status-success">Concluído</span></td>
                        <td>${new Date(item.timestamp || Date.now()).toLocaleString()}</td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary" onclick="app.viewTransaction(${index})">
                                <i class="fas fa-eye"></i>
                            </button>
                        </td>
                    </tr>
                `).join('');
            } else {
                // Usar dados de exemplo
                transactionsTable.innerHTML = this.demoData.recentTransactions.map((item, index) => `
                    <tr>
                        <td>${index + 1}</td>
                        <td>${item.type}</td>
                        <td>${item.amount}</td>
                        <td>${this.account ? this.account.substring(0, 8) + '...' : 'Demo'}</td>
                        <td>${this.account || 'Demo'}</td>
                        <td><span class="status-badge ${item.status === 'Concluído' ? 'status-success' : 'status-pending'}">${item.status}</span></td>
                        <td>${item.date}</td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary" onclick="app.viewTransaction(${index})">
                                <i class="fas fa-eye"></i>
                            </button>
                        </td>
                    </tr>
                `).join('');
            }
        } catch (error) {
            console.error('Erro ao carregar transações:', error);
            // Usar dados de exemplo em caso de erro
            const transactionsTable = document.getElementById('transactionsTable');
            transactionsTable.innerHTML = this.demoData.recentTransactions.map((item, index) => `
                <tr>
                    <td>${index + 1}</td>
                    <td>${item.type}</td>
                    <td>${item.amount}</td>
                    <td>${this.account ? this.account.substring(0, 8) + '...' : 'Demo'}</td>
                    <td>${this.account || 'Demo'}</td>
                    <td><span class="status-badge ${item.status === 'Concluído' ? 'status-success' : 'status-pending'}">${item.status}</span></td>
                    <td>${item.date}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary" onclick="app.viewTransaction(${index})">
                            <i class="fas fa-eye"></i>
                        </button>
                    </td>
                </tr>
            `).join('');
        }
    }

    async loadActiveSwaps() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/getAllCommitments`);
            const data = await response.json();
            
            const swapsList = document.getElementById('activeSwapsList');
            
            if (data.data && data.data.length > 0) {
                const swaps = data.data.slice(0, 3);
                swapsList.innerHTML = swaps.map((swap, index) => `
                    <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                        <div>
                            <strong>Swap #${index + 1}</strong><br>
                            <small class="text-muted">${swap.amount || 'N/A'} DREX → TPFt</small>
                        </div>
                        <button class="btn btn-sm btn-success" onclick="app.completeSwap(${index})">
                            Completar
                        </button>
                    </div>
                `).join('');
            } else {
                // Usar dados de exemplo
                swapsList.innerHTML = `
                    <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                        <div>
                            <strong>Swap #1</strong><br>
                            <small class="text-muted">1,000 DREX → 100 TPFt Série 1</small>
                        </div>
                        <button class="btn btn-sm btn-success" onclick="app.completeSwap(1)">
                            Completar
                        </button>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                        <div>
                            <strong>Swap #2</strong><br>
                            <small class="text-muted">500 DREX → 50 TPFt Série 2</small>
                        </div>
                        <button class="btn btn-sm btn-success" onclick="app.completeSwap(2)">
                            Completar
                        </button>
                    </div>
                `;
            }
        } catch (error) {
            console.error('Erro ao carregar swaps ativos:', error);
            // Usar dados de exemplo em caso de erro
            const swapsList = document.getElementById('activeSwapsList');
            swapsList.innerHTML = `
                <div class="d-flex justify-content-between align-items-center mb-2 p-2 border rounded">
                    <div>
                        <strong>Swap #1</strong><br>
                        <small class="text-muted">1,000 DREX → 100 TPFt Série 1</small>
                    </div>
                    <button class="btn btn-sm btn-success" onclick="app.completeSwap(1)">
                        Completar
                    </button>
                </div>
            `;
        }
    }

    async completeSwap(swapId) {
        try {
            this.showNotification('Completando swap...', 'info');

            const response = await fetch(`${this.apiBaseUrl}/completeSwapFromErc20ToErc1155`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ swapId: swapId })
            });

            const result = await response.json();
            
            if (result.status === 'success') {
                this.showNotification('Swap completado com sucesso!', 'success');
                this.loadBalances();
                this.loadActiveSwaps();
            } else {
                this.showNotification(`Erro ao completar swap: ${result.message || 'Erro desconhecido'}`, 'error');
            }
        } catch (error) {
            console.error('Erro ao completar swap:', error);
            this.showNotification(`Erro de conexão: ${error.message}`, 'error');
            
            // Em modo demo, simular sucesso
            if (!this.web3) {
                this.showNotification('Swap simulado completado (modo demo)!', 'success');
                this.loadBalances();
                this.loadActiveSwaps();
            }
        }
    }

    async saveAccountSettings() {
        const accountName = document.getElementById('accountName').value;
        const accountEmail = document.getElementById('accountEmail').value;

        // Salvar no localStorage
        localStorage.setItem('accountName', accountName);
        localStorage.setItem('accountEmail', accountEmail);

        this.showNotification('Configurações da conta salvas!', 'success');
    }

    async saveNetworkSettings() {
        const rpcUrl = document.getElementById('rpcUrl').value;
        const chainId = document.getElementById('chainId').value;
        const realDigitalContract = document.getElementById('realDigitalContract').value;
        const tpftContract = document.getElementById('tpftContract').value;

        // Salvar no localStorage
        localStorage.setItem('rpcUrl', rpcUrl);
        localStorage.setItem('chainId', chainId);
        localStorage.setItem('realDigitalContract', realDigitalContract);
        localStorage.setItem('tpftContract', tpftContract);

        this.showNotification('Configurações da rede salvas!', 'success');
    }

    loadSettings() {
        // Carregar configurações salvas
        const accountName = localStorage.getItem('accountName') || '';
        const accountEmail = localStorage.getItem('accountEmail') || '';
        const rpcUrl = localStorage.getItem('rpcUrl') || 'ws://localhost:8545';
        const chainId = localStorage.getItem('chainId') || '381660001';
        const realDigitalContract = localStorage.getItem('realDigitalContract') || '0x3A34C530700E3835794eaE04d2a4F22Ce750eF7e';
        const tpftContract = localStorage.getItem('tpftContract') || '0x4ABDE28B04315C05a4141a875f9B33c9d1440a8E';

        document.getElementById('accountName').value = accountName;
        document.getElementById('accountEmail').value = accountEmail;
        document.getElementById('rpcUrl').value = rpcUrl;
        document.getElementById('chainId').value = chainId;
        document.getElementById('realDigitalContract').value = realDigitalContract;
        document.getElementById('tpftContract').value = tpftContract;
        document.getElementById('walletAddress').value = this.account || 'Não conectado';
    }

    showNotification(message, type = 'info') {
        const toast = document.getElementById('notificationToast');
        const toastTitle = document.getElementById('toastTitle');
        const toastMessage = document.getElementById('toastMessage');

        toastTitle.textContent = type === 'success' ? 'Sucesso' : type === 'error' ? 'Erro' : type === 'warning' ? 'Aviso' : 'Informação';
        toastMessage.textContent = message;

        toast.classList.remove('bg-success', 'bg-danger', 'bg-info', 'bg-warning');
        toast.classList.add(type === 'success' ? 'bg-success' : type === 'error' ? 'bg-danger' : type === 'warning' ? 'bg-warning' : 'bg-info');

        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
    }

    startPolling() {
        // Atualizar dados a cada 30 segundos
        setInterval(() => {
            this.loadBalances();
            this.loadRecentActivity();
        }, 30000);
    }

    viewTransaction(index) {
        this.showNotification(`Visualizando transação #${index + 1}`, 'info');
    }

    refreshTransactions() {
        this.loadTransactions();
        this.showNotification('Transações atualizadas!', 'success');
    }
}

// Funções globais
function connectWallet() {
    app.connectWallet();
}

function refreshTransactions() {
    app.refreshTransactions();
}

// Inicializar aplicação
let app;
document.addEventListener('DOMContentLoaded', () => {
    app = new CBDRealDigitalApp();
}); 