pragma solidity ^0.8.0;

contract MagicFallback {
    fallback() external payable {
        assembly {
            mstore(0, 42)
            return(0, 32)
        }
    }
}
