// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IImpersonator {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

contract SimpleOwnershipTransfer {
    function tryDirectTransfer(address impersonator) external {
        IImpersonator(impersonator).transferOwnership(msg.sender);
    }
    
    fallback() external payable {
        // Maybe we get a callback?
    }
}