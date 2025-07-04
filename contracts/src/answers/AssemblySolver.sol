pragma solidity ^0.8.0;

contract AssemblySolver {
    
    fallback() external payable {
        assembly {
            mstore(0x80, 0x2a)
            return(0x80, 32)
        }
    }
}
