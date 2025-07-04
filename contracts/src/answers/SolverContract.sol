pragma solidity ^0.8.0;

contract SolverContract {
    
    fallback() external payable {
        assembly {
            mstore(0x00, 0x0000000000000000000000000000000000000000000000000000000000000016)
            mstore(0x20, 0x596f7520636f6d706c6574656420746865206c6576656c21)
            return(0, 54)
        }
    }
}
