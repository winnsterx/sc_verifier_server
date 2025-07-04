pragma solidity ^0.8.0;

contract MagicNumberFixed {
    receive() external payable {
        assembly {
            mstore(0x00, 0x58)  // 88 in hex
            return(0x00, 0x20)  // Return 88
        }
    }
}
