pragma solidity ^0.8.0;
contract GasDrainInfinite {
    receive() external payable {
        while (true) {
            continue;
        }
    }
}
