pragma solidity ^0.8.0;

interface IMagicNum {
    function setSolver(address _solver) external;
}

contract MagicNumberSolutionCorrect {
    address public magicNumInstance;

    constructor(address _magicNumInstance) {
        magicNumInstance = _magicNumInstance;
    }

    function attack() public {
        IMagicNum(magicNumInstance).setSolver(address(this));
    }

    function magic() public pure returns (uint256) {
        assembly {
            mstore(0x00, 0x2a)
            return(0x00, 0x20)
        }
    }
}