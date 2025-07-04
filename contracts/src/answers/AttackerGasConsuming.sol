pragma solidity ^0.8.0;

contract AttackerGasConsuming {
    receive() external payable {
        assembly {
            for {} {} {
                pop(keccak256(0x0, 0x20))
            }
        }
    }
}
