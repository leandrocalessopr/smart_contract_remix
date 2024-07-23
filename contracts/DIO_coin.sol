// SPDX-License-Identifier: UNLICENSED
// Desenvolvendo o smart contract.

// Declarando o compilador.
pragma solidity ^0.8.0;

// Declaração da interface ERC20
interface IRC20 {
    // Função para obter o suprimento total de tokens
    function totalSupply() external view returns (uint256);

    // Função para checar o saldo de determinado endereço
    function balanceOf(address account) external view returns (uint256);

    // Função para verificar o allowance (limite de transferência) entre o proprietário e o gastador
    function allowance(address owner, address spender) external view returns (uint256);

    // Função para transferir tokens para um destinatário
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Função para aprovar uma determinada quantidade de tokens que um gastador pode gastar em nome do proprietário
    function approve(address spender, uint256 amount) external returns (bool);

    // Função para transferir tokens de uma conta para outra usando o allowance
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Evento emitido quando tokens são transferidos
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Evento emitido quando uma aprovação é feita
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementação do contrato DIOcoin que segue a interface ERC20
contract DIOcoin is IRC20 {
    // Definição do nome, símbolo e casas decimais do token
    string public constant name = "DIOcoin";
    string public constant symbol = "DIO";
    uint8 public constant decimals = 18;

    // Variável privada para armazenar o suprimento total de tokens
    uint256 private _totalSupply;
    
    // Mapeamento para armazenar os saldos dos endereços
    mapping(address => uint256) private _balances;
    
    // Mapeamento para armazenar as permissões de transferências (allowances)
    mapping(address => mapping(address => uint256)) private _allowances;

    // Construtor do contrato que define o suprimento inicial de tokens
    constructor(uint256 initialSupply) {
        // Define o suprimento total inicial
        _totalSupply = initialSupply;
        
        // Atribui todo o suprimento inicial ao criador do contrato
        _balances[msg.sender] = initialSupply;
        
        // Emite um evento de transferência do endereço zero para o criador do contrato
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // Função para obter o suprimento total de tokens
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Função para checar o saldo de determinado endereço
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // Função para verificar o allowance (limite de transferência) entre o proprietário e o gastador
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Função para transferir tokens para um destinatário
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        // Chama a função interna _transfer para realizar a transferência
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Função para aprovar uma determinada quantidade de tokens que um gastador pode gastar em nome do proprietário
    function approve(address spender, uint256 amount) external override returns (bool) {
        // Chama a função interna _approve para registrar a aprovação
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Função para transferir tokens de uma conta para outra usando o allowance
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        // Chama a função interna _transfer para realizar a transferência
        _transfer(sender, recipient, amount);
        
        // Reduz o allowance do remetente pelo valor transferido
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // Função interna para realizar transferências de tokens
    function _transfer(address sender, address recipient, uint256 amount) internal {
        // Verifica se o endereço do remetente não é o endereço zero
        require(sender != address(0), "ERC20: transfer from the zero address");
        
        // Verifica se o endereço do destinatário não é o endereço zero
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        // Verifica se o saldo do remetente é suficiente para a transferência
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        // Reduz o saldo do remetente pelo valor transferido
        _balances[sender] -= amount;
        
        // Aumenta o saldo do destinatário pelo valor transferido
        _balances[recipient] += amount;
        
        // Emite um evento de transferência
        emit Transfer(sender, recipient, amount);
    }

    // Função interna para aprovar uma determinada quantidade de tokens que um gastador pode gastar em nome do proprietário
    function _approve(address owner, address spender, uint256 amount) internal {
        // Verifica se o endereço do proprietário não é o endereço zero
        require(owner != address(0), "ERC20: approve from the zero address");
        
        // Verifica se o endereço do gastador não é o endereço zero
        require(spender != address(0), "ERC20: approve to the zero address");

        // Define o allowance do gastador para o valor especificado
        _allowances[owner][spender] = amount;
        
        // Emite um evento de aprovação
        emit Approval(owner, spender, amount);
    }
}
