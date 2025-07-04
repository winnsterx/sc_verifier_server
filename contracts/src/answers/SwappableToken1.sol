pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract SwappableToken1 is ERC20 {
    address private _dex;

    constructor(address dexInstance) ERC20("Token1", "TK1") {
        _mint(msg.sender, 1000000 * 10**18);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}