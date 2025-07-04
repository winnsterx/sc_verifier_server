pragma solidity ^0.8.0;

contract AttackerLoop {
    receive() external payable {
        while (true) {
            // Infinite loop to exhaust gas by using 0x00 opcode
            assembly { pop(0) }
        }
    }
}
