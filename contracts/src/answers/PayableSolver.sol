pragma solidity ^0.8.0;

interface IMagicNum {
    function setSolver(address) external;
}

contract PayableSolver {
    IMagicNum public immutable instance;

    constructor(address _instance) {
        instance = IMagicNum(_instance);
        instance.setSolver(address(this));
    }

    fallback() external payable {
        assembly {
            mstore(0x00, 0x2a)
            return(0x00, 32)
        }
    }
}
