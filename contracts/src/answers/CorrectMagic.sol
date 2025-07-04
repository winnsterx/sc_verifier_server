pragma solidity ^0.8.0;

interface IMagicNum {
    function setSolver(address _solver) external;
}

contract CorrectMagic {
    address public magicNum;

    constructor(address _magicNum) {
        magicNum = _magicNum;
    }

    function magic() external pure returns (uint8) {
        return 42;
    }

    function setAsSolver() external {
        IMagicNum(magicNum).setSolver(address(this));
    }
}
