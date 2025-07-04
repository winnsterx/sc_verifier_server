// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function transferOwnership(address newOwner) external;
}

contract CallFromLocker {
    // What if the Impersonator trusts calls from the ECLocker?
    function tryTransferAsLocker(address impersonator, address locker) external {
        // This won't work directly, but let's see
        IImpersonator(impersonator).transferOwnership(msg.sender);
    }
    
    // What if we need to impersonate the locker address itself?
    function getCodeAt(address addr) external view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
        return code;
    }
}