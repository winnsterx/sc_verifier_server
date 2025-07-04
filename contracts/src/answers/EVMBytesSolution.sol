pragma solidity ^0.7.0;

contract EVMBytesSolution {
    constructor() {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x602a60005260206000f3)
            return(ptr, 0x0a) // 10 bytes.
        }
    }
}