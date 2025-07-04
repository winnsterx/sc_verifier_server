pragma solidity ^0.8.0;

contract MagicReturnContract {
    
    fallback() external payable {
        assembly {
            mstore(0x00, 0xdeadbeef)
            return(0x1c, 0x4)
        }
    }
}
