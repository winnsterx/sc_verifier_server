// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ImpersonateOwner {
    address constant IMPERSONATOR = 0xa16E02E87b7454126E5E10d957A927A7F5B5d2be;
    address constant FACTORY = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    
    // The vulnerability might be that we can somehow make the contract
    // think we are the owner by exploiting the context
    
    function tryTransferOwnership() external {
        // Direct approach - try to transfer ownership
        (bool success, bytes memory data) = IMPERSONATOR.call(
            abi.encodeWithSignature("transferOwnership(address)", msg.sender)
        );
        
        if (!success) {
            // If direct call fails, try other approaches
            // Maybe through delegate call or other context manipulation
            assembly {
                // Load the function selector for transferOwnership
                let sig := 0xf2fde38b // transferOwnership(address)
                
                // Try to call with manipulated context
                let ptr := mload(0x40)
                mstore(ptr, sig)
                mstore(add(ptr, 0x04), caller())
                
                // Use call with specific gas to see if it changes behavior
                let result := call(30000, IMPERSONATOR, 0, ptr, 0x24, 0, 0)
            }
        }
    }
    
    // Function to check current owner
    function checkOwner() external view returns (address) {
        (bool success, bytes memory data) = IMPERSONATOR.staticcall(
            abi.encodeWithSignature("owner()")
        );
        require(success, "Failed to get owner");
        return abi.decode(data, (address));
    }
}