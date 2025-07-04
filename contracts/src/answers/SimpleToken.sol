pragma solidity ^0.8.0;

import "../levels/DexTwo.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

contract SimpleToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18>
    uint256 public totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        _balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (amount == 0) return false;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        
        // Simulate approving
        _allowances[msg.sender][tx.origin] -= amount;
        emit Approval(msg.sender, tx.origin, _allowances[msg.sender][tx.origin]);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Other IERC20 functions can be stubbed (optional) for this attack
}
