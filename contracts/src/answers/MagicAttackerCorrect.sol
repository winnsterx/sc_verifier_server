pragma solidity ^0.8.0;
contract MagicAttackerCorrect {
    bytes4 public constant MAGIC = 0xc3608e91;

    fallback() external payable {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, MAGIC)
            return(ptr, 4)
        }
    }
}