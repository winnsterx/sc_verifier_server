pragma solidity ^0.8.0;
contract Attacker42 {
    function whatIsTheMeaningOfLife() public pure returns (bytes32) {
        return bytes32(uint256(42));
    }
}