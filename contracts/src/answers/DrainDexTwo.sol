pragma solidity ^0.8.0;

import "./SwappableTokenTwo.sol";

contract DrainDexTwo {
    address public immutable dex;

    constructor(address _dex) {
        dex = _dex;
    }

    function drain() external {
        // First swap token2 for token1 to reduce contract balance
        SwappableTokenTwo token1 = SwappableTokenTwo(0x123456789..., true, 0x7af6...
        // Add exploit logic here
    }
}
